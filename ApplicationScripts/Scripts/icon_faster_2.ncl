;----------------------------------------------------------------------
; icon_faster_2.ncl
;
; Concepts illustrated:
;   - Plotting ICON model data
;   - Using special "gsSegments" resource for faster primitive draws
;   - Contouring one-dimensional X, Y, Z data
;   - Using triangular meshes to create contours
;   - Drawing filled polygons on a map
;   - Turning on edges for polygons
;   - Using "getvalues" to retrieve resource values
;   - Using "systemfunc" to execute a UNIX command
;   - Using "systemfunc" to get the current date
;
;----------------------------------------------------------------------
; This script is identical to icon_2.ncl, except it uses some resources
; (gsSegments and gsColors) that are only available in NCL V6.2.0.
; 
; Use of these resources can significantly speed up code for plotting 
; filled polygons.  This particular example doesn't take long, so
; the speed up is not as noticeable: 1.74 CPU seconds versus 0.53 
; seconds.
;----------------------------------------------------------------------
 load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
 load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
 load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
;----------------------------------------------------------------------
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

  rad2deg = get_r2d(scale)     ; radians to degrees

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

; Note: clon and clat are longitude and latitude of triangle centers.
;       Locations of the cell corners are given by 
;       clon_vertices and clat_vertices in the nc file.

;---------------------------------------------------------------
; make plot
;---------------------------------------------------------------

  wks = gsn_open_wks("ps","icon_faster")

; Set up resources for contour/map plot.
  ResC                = True

  ResC@gsnFrame       = False
  ResC@gsnMaximize    = True

  ResC@cnFillOn       = True
  ResC@cnLinesOn      = False
  ResC@cnInfoLabelOn  = False
  ResC@cnFillPalette  = colormap

  FontHeight = 0.018

  ResC@tiXAxisFontHeightF        = FontHeight
  ResC@tiYAxisFontHeightF        = FontHeight
  ResC@tmXBLabelFontHeightF      = FontHeight
  ResC@tmYLLabelFontHeightF      = FontHeight
  ResC@gsnStringFontHeightF      = FontHeight - 0.002

  ResC@tmXBLabelJust  = "CenterCenter"

  ResC@mpProjection   = "CylindricalEquidistant"
  ResC@mpLimitMode    = "LatLon"
  ResC@mpCenterLonF   = 180.
  ResC@mpMinLonF      =  90.
  ResC@mpMaxLonF      = 270.
  ResC@mpMinLatF      =  25.
  ResC@mpMaxLatF      =  75.

  ResC@gsnMajorLonSpacing =  30. 
  ResC@gsnMinorLonSpacing =  10.
  ResC@gsnMajorLatSpacing =  15. 
  ResC@gsnMinorLatSpacing =   5. 

;  ResC@mpGeophysicalLineColor = "transparent"
  ResC@mpFillOn               = False

  ResC@sfXArray                 = x  ; These are 1D arrays, so a triangular
  ResC@sfYArray                 = y  ; mesh will be created internally.

  ResC@lbLabelBarOn             = True 
  ResC@pmLabelBarHeightF        = 0.07
  ResC@pmLabelBarWidthF         = 0.7
  ResC@pmLabelBarOrthogonalPosF = 0.25
  ResC@lbLabelAutoStride        = True
  ResC@lbLabelFontHeightF       = FontHeight

  ResC@cnLevelSelectionMode = "ManualLevels"

  ResC@gsnLeftString        = LeftString 
  ResC@gsnCenterString      = CenterString
  ResC@gsnRightString       = RightString 

  ResC@cnMinLevelValF       = varMin
  ResC@cnMaxLevelValF       = varMax
  ResC@cnLevelSpacingF      = varInt
  ResC@cnFillMode           = "rasterfill"
  ResC@cnRasterSmoothingOn  = True
  ResC@mpGreatCircleLinesOn = True

; Create and draw the plot, but don't advance the frame.
; This is necessary in order to get the tickmarks and labelbar.
  plot = gsn_csm_contour_map(wks,var,ResC)

; Retrieve the contour levels and colors used. This information
; will be used to draw the filled triangles.
  getvalues plot@contour
   "cnLevels"     : levels
   "cnFillColors" : colors
  end getvalues

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
  end if

;---All triangles inbetween levels
  do i = 1, dimsizes(levels) - 1
    vind := ind(var .ge. levels(i-1) .and. var .lt. levels(i))
    if(.not.all(ismissing(vind))) then
      gscolors(vind) = colors(i)
      ntri_tot = ntri_tot + dimsizes(vind)
    end if
  end do

;---All triangles higher than highest level
  vind = ind(var .ge. levels(dimsizes(levels)-1))
  if(.not.all(ismissing(vind))) then
    gscolors(vind) = colors(dimsizes(levels)-1)
    ntri_tot = ntri_tot + dimsizes(vind)
  end if

  pres@gsColors = gscolors
  pres@gsSegments = ispan(0,dimsizes(var) * 3,3)

  gsid = gsn_add_polygon(wks,plot,ndtooned(vlon),ndtooned(vlat),pres)

  draw(plot)
  frame(wks)   ; Advance the frame


  print("--> Total number of triangles:   " + ntri_tot)
  end_code_time = get_cpu_time()
  print("--> Elapsed time in CPU seconds: " + (end_code_time-start_code_time))
end

