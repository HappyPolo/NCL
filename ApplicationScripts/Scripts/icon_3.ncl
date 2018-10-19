;----------------------------------------------------------------------
; icon_3.ncl
;
; Concepts illustrated:
;   - Plotting ICON model data
;   - Drawing filled polygons on a map
;   - Turning on edges for polygons
;   - Attaching a custom labelbar to a map
;   - Using "systemfunc" to execute a UNIX command
;   - Using "systemfunc" to get the current date
;
;----------------------------------------------------------------------
; For a faster version of this code, see "icon_faster_3.ncl", which
; uses new resources "gsSegments" and "gsColors" to significantly
; speed up the drawing of filled polygons.  You need V6.2.0 in order
; to use these new resources.
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

  wks = gsn_open_wks("ps","icon")
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

  draw(plot)

;
; Go through the vertices and create a logical array that
; indicates if the vertices are w/in the lat/lon area we're
; interested in.
;
  flags = new(dimsizes(var),logical,"No_FillValue")
  do i = 0,dimsizes(var) - 1
    flags(i) = where(all(vlon(i,:) .gt. res@mpMaxLonF) .or. \
                     all(vlon(i,:) .lt. res@mpMinLonF) .or. \
                     all(vlat(i,:) .gt. res@mpMaxLatF) .or. \
                     all(vlat(i,:) .lt. res@mpMinLatF), \
                     False, True)
  end do
  print ("out-of-bounds triangles: " + dimsizes(ind(flags .eq. False)))


; Set up a resource list for the polygons.
  pres             = True
  pres@gsEdgesOn   = True   ; Turn on edges
  pres@gsFillIndex = 0      ; Solid fill, the default

; First draw the triangles associated with the lowest level.
  vlow = ind(var .lt. levels(0))
  do i = 0, dimsizes(vlow)-1
    pres@gsFillColor = colors(0)
    if (.not. flags(vlow(i))) then
      continue
    end if
    gsn_polygon(wks,plot,vlon(vlow(i),:),vlat(vlow(i),:),pres)
  end do

  print ("finished level 0 -- " + dimsizes(vlow) + " triangles considered")

; Now draw the triangles associated with the rest of the levels.
  do i = 0, dimsizes(levels) -2
    vind = ind(var .ge. levels(i) .and. var .lt. levels(i+1))
    do j = 0, dimsizes(vind)-1
      if (.not. flags(vind(j))) then
        continue
      end if
      pres@gsFillColor = colors(i+1)
      gsn_polygon(wks,plot,vlon(vind(j),:),vlat(vind(j),:),pres)
    end do
    print ("finished level " + i + "  -- " + dimsizes(vind) + \
           " triangles considered")
    delete(vind)
  end do

  frame(wks)   ; Advance the frame

  end_code_time = get_cpu_time()
  print("--> Elapsed time in CPU seconds: " + (end_code_time-start_code_time))

end

