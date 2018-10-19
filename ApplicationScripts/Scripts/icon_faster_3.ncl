;----------------------------------------------------------------------
; icon_faster_3.ncl
;
; Concepts illustrated:
;   - Plotting ICON model data
;   - Using special "gsSegments" resource for faster primitive draws
;   - Drawing filled polygons on a map
;   - Turning on edges for polygons
;   - Attaching a custom labelbar to a map
;   - Using "systemfunc" to execute a UNIX command
;   - Using "systemfunc" to get the current date
;
;----------------------------------------------------------------------
; This script is identical to icon_2.ncl, except it uses some resources
; (gsSegments and gsColors) that are only available in NCL V6.2.0.
; 
; Use of these resources can significantly speed up code for plotting 
; filled polygons.  This particular example doesn't take long, so
; the speed up is not as noticeable: 1.64 CPU seconds versus 0.33
; seconds.
;----------------------------------------------------------------------
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"

;*************************************************
; Function to attach a custom label bar
;************************************************* 
undef("attach_labelbar")
function attach_labelbar(wks,map,labels,colors)
local lbres, nlevels, amres
begin
  nlevels = dimsizes(labels)

  lbres = True
  lbres@lbPerimOn            = False               ; no label bar box
  lbres@lbOrientation        = "Horizontal"        ; orientation
  lbres@vpWidthF             = 0.7                 ; width of labelbar
  lbres@vpHeightF            = 0.10                ; height of labelbar
  lbres@lbLabelFontHeightF   = 0.015               ; label font height
  lbres@lbLabelAlignment     = "InteriorEdges"     ; where to label
  lbres@lbMonoFillPattern    = True                ; fill sold
  lbres@lbFillColors         = colors
  
  lbid = gsn_create_labelbar (wks,nlevels+1,labels,lbres)

  amres                  = True
  amres@amJust           = "TopCenter"
  amres@amOrthogonalPosF = 0.7
  map@annoid = gsn_add_annotation(map,lbid,amres)

  return(map)
end
;---------------------------------------------------------------

;*************************************************
; Main code
;************************************************* 
 begin
  start_code_time = get_cpu_time()

  Model      = "ICOHDC" 
  Resolution = "R2B4L31" 
  ConfigStr  = "D1 spr0.90" 

  LeftString   = "850 hPa div. (10~S~-6~N~ s~S~-1~N~) at day 9"
  RightString  = Model+" "+Resolution+" "+ConfigStr 
  CenterString = ""

  DataFileName = "DIV850_day9.nc"  ; input
  VarName      = "DIV"             ; variable name in the input file       

  colormap  = "testcmap"
  scale     = 1e6

  varMin = -15.  ; minimum contour level
  varMax =  15.  ; maximum contour level
  varInt =   3.  ; interval between contours

  rad2deg = get_r2d("float")    ; radians to degrees

;---------------------------------------------------------------
; read in the meteorological field and grid information
;---------------------------------------------------------------

  File = addfile( DataFileName, "r" )

  var = File->$VarName$(0,0,:)   ; dims: (time,lev,cell)
  var = var*scale

  x = File->clon *rad2deg   ; cell center, lon
  y = File->clat *rad2deg   ; cell center, lat
  vlon = File->clon_vertices * rad2deg
  print("longitude min/max: " + min(vlon) + " " + max(vlon))  
  vlon = where(vlon.lt.0, vlon + 360, vlon)
  print("longitude min/max: " + min(vlon) + " " + max(vlon))  
  vlat = File->clat_vertices * rad2deg

; note: clon and clat are longitude and latitude of triangle centers.
;       Locations of the cell corners are given by 
;       clon_vertices and clat_vertices in the nc file.

;---------------------------------------------------------------
; make plot
;---------------------------------------------------------------

  wks = gsn_open_wks("ps","icon_faster")
  gsn_define_colormap(wks,colormap)

; Get color map length
  getvalues wks
    "wkColorMapLen" : clen   
  end getvalues

; Set up resources for map plot.
  res                = True

  res@gsnFrame       = False
  res@gsnDraw        = False
  res@gsnMaximize    = True

  FontHeight = 0.018

  res@tiXAxisFontHeightF        = FontHeight
  res@tiYAxisFontHeightF        = FontHeight
  res@tmXBLabelFontHeightF      = FontHeight
  res@tmYLLabelFontHeightF      = FontHeight
  res@gsnStringFontHeightF      = FontHeight +0.002

  res@tmXBLabelJust  = "CenterCenter"

  res@mpProjection   = "CylindricalEquidistant"
  res@mpLimitMode    = "LatLon"
  res@mpCenterLonF   = 180.
  res@mpMinLonF      =  90.
  res@mpMaxLonF      = 270.
  res@mpMinLatF      =  25.
  res@mpMaxLatF      =  75.

  res@gsnMajorLonSpacing =  30. 
  res@gsnMinorLonSpacing =  10.
  res@gsnMajorLatSpacing =  15. 
  res@gsnMinorLatSpacing =   5. 

  res@mpFillOn           = False

  res@gsnLeftString   = LeftString 
  res@gsnCenterString = CenterString
  res@gsnRightString  = RightString 

  res@mpGreatCircleLinesOn = True

  plot = gsn_csm_map(wks,res)

; Number of different triangle levels we want.
  nlevels = 11
  levels = fspan(varMin,varMax,nlevels)
  colors = ispan(2,clen,floattoint((clen-2)/nlevels))

; Attach a labelbar and draw the plot with the labelbar.

  plot = attach_labelbar(wks,plot,levels+"",colors)

;---Create color array for triangles
  ntri     = dimsizes(y)                  ;-- Number of triangles
  gscolors = new(ntri,integer)
  gscolors = -1                           ;-- Initialize to transparent

;---Set up a resource list for the polygons.
  pres             = True
  pres@gsEdgesOn   = True   ; Turn on edges
  pres@gsFillIndex = 0      ; Solid fill, the default

;---All triangles less than lowest level
  vind = ind(var .lt. levels(0))
  if(.not.all(ismissing(vind))) then
    gscolors(vind) = colors(0)
    ntri_tot = dimsizes(vind)
    print ("finished level 0 -- " + dimsizes(vind) + " triangles considered")
  end if

;---All triangles inbetween levels
  do i = 1, dimsizes(levels) - 1
    vind := ind(var .ge. levels(i-1) .and. var .lt. levels(i))
    if(.not.all(ismissing(vind))) then
      gscolors(vind) = colors(i)
      ntri_tot = ntri_tot + dimsizes(vind)
      print ("finished level " + i + "  -- " + dimsizes(vind) + \
             " triangles considered")
    end if
  end do

  pres@gsColors = gscolors
  pres@gsSegments = ispan(0,dimsizes(var) * 3,3)

  gsid = gsn_add_polygon(wks,plot,ndtooned(vlon),ndtooned(vlat),pres)

  draw(plot)
  frame(wks)   ; Advance the frame

  end_code_time = get_cpu_time()
  print("--> Elapsed time in CPU seconds: " + (end_code_time-start_code_time))

end

