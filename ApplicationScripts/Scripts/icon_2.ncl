;----------------------------------------------------------------------
; icon_2.ncl
;
; Concepts illustrated:
;   - Plotting ICON model data
;   - Contouring one-dimensional X, Y, Z data
;   - Using triangular meshes to create contours
;   - Drawing filled polygons on a map
;   - Turning on edges for polygons
;   - Using "getvalues" to retrieve resource values
;   - Using "systemfunc" to execute a UNIX command
;   - Using "systemfunc" to get the current date
;
;----------------------------------------------------------------------
; For a faster version of this code, see "icon_faster_2.ncl", which
; uses new resources "gsSegments" and "gsColors" to significantly
; speed up the drawing of filled polygons.  You need V6.2.0 in order
; to use these new resources.
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

  rad2deg = get_r2d("float")   ; radians to degrees

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

  wks = gsn_open_wks("ps","icon")

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

;
; Go through the vertices and create a logical array that
; indicates if the vertices are w/in the lat/lon area we're
; interested in.
;
  flags = new(dimsizes(var),logical,"No_FillValue")
  do i = 0,dimsizes(var) - 1
    flags(i) = where(all(vlon(i,:) .gt. ResC@mpMaxLonF) .or. \
                     all(vlon(i,:) .lt. ResC@mpMinLonF) .or. \
                     all(vlat(i,:) .gt. ResC@mpMaxLatF) .or. \
                     all(vlat(i,:) .lt. ResC@mpMinLatF), \
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

