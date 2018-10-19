begin

;---Read data. Note that it is represented by 2D lat/lon arrays
  a     = addfile("ruc.grb","r")
  temp  = a->TMP_236_SPDY
  lat2d = a->gridlat_236
  lon2d = a->gridlon_236

;---Print information about file variables
  printVarSummary(temp)     ; 6 x 113 x 151
  printVarSummary(lat2d)    ; 113 x 151
  printVarSummary(lon2d)    ; 113 x 151
  printMinMax(lat2d,0)
  printMinMax(lon2d,0)

  wks = gsn_open_wks("png","latlon_subset_compare")

  plots = new(2,"graphic")

  lat_min =   31
  lat_max =   42
  lon_min = -110
  lon_max = -102

  ;---Now zoom in on map and add some primitives so to see the grid and lat/lon points.
  res                   = True

  res@gsnMaximize           = True     ; maximize plot in frame

  res@cnFillOn              = True     ; turn on contour fill
  res@cnLinesOn             = False    ; turn off contour lines
  res@cnLineLabelsOn        = False    ; turn off contour line labels
  res@gsnAddCyclic          = False    ; don't add longitude cyclic point

  ; Set the contour levels for both plots
  mnmxint               = nice_mnmxintvl(min(temp(0,:,:)), max(temp(0,:,:)), 24, False)
  res@cnLevelSelectionMode = "ManualLevels"
  res@cnMinLevelValF    = mnmxint(0)
  res@cnMaxLevelValF    = mnmxint(1)
  res@cnLevelSpacingF   = mnmxint(2)

  res@mpDataBaseVersion     = "MediumRes"    ; better map resolution
  res@mpOutlineBoundarySets = "USStates"
  res@pmTickMarkDisplayMode = "Always"       ; better looking tickmarks
     
  res@mpMinLatF         = lat_min-2
  res@mpMaxLatF         = lat_max+2
  res@mpMinLonF         = lon_min-2
  res@mpMaxLonF         = lon_max+2
  res@mpCenterLonF      = (res@mpMinLonF + res@mpMaxLonF) / 2.

  res@lbLabelBarOn      = False

  res@gsnDraw           = False
  res@gsnFrame          = False

;  res@gsnCenterStringFontHeightF = 0.012

  res@gsnLeftString      = ""
  res@gsnRightString     = ""

  gsres                  = True
  gsres@gsnCoordsAsLines = True
  gsres@gsnCoordsAttach  = True

  mkres               = True
  mkres@gsMarkerIndex = 16     ; filled dot
  mkres@gsMarkerColor = "black"
  mkres@gsMarkerSizeF = 10

  do index=0,1

    if (index.eq.0) then
      ij      = getind_latlon2d(lat2d,lon2d,(/lat_min,lat_max/),(/lon_min,lon_max/))

      ilat1 = ij(0,0)
      ilat2 = ij(1,0)
      ilon1 = ij(0,1)
      ilon2 = ij(1,1)
    else
      ij      := region_ind(lat2d,lon2d,lat_min,lat_max, lon_min,lon_max)

      ;---Store to local variables for better code readability
      ilat1 := ij(0)
      ilat2 := ij(1)
      ilon1 := ij(2)
      ilon2 := ij(3)
   end if

   ;---Subscript variables using these index values
   temp_sub  := temp(:,ilat1:ilat2,ilon1:ilon2)     ; 6 x 30 x 21
   lat2d_sub := lat2d(ilat1:ilat2,ilon1:ilon2)      ; 30 x 21
   lon2d_sub := lon2d(ilat1:ilat2,ilon1:ilon2)      ; 30 x 21

   ;---Print information about the new variables
   printVarSummary(temp_sub)
   printVarSummary(lat2d_sub)
   printVarSummary(lon2d_sub)
   printMinMax(lat2d_sub,0)
   printMinMax(lon2d_sub,0)

   res@sfYArray              := lat2d_sub    ; this will help NCL plot data
   res@sfXArray              := lon2d_sub    ; correctly over the map

   if (index.eq.0) then
     res@gsnCenterString       = "getind_latlon2d"
   else
     res@gsnCenterString       := "region_ind"
   end if

   plot = gsn_csm_contour_map(wks,temp_sub(0,:,:),res)
   plots(index) = plot

   ;---Attach lat/lon grid lines of subsetted data.
   gsres@gsnCoordsLat     := lat2d_sub
   gsres@gsnCoordsLon     := lon2d_sub
   gsn_coordinates(wks,plot,temp_sub(0,:,:),gsres)

   nlondata := dimsizes(lon2d_sub(:,0))
   nlonsubdata := dimsizes(lon2d_sub(0,:))
   nlatdata := dimsizes(lat2d_sub(:,0))
   nlatsubdata := dimsizes(lat2d_sub(0,:))

   ;---Attach two markers showing two lat,lon corners of interest
;   mkid = gsn_add_polymarker(wks,plot,(/lon_min,lon_max/),(/lat_min,lat_max/),mkres)
   mkid = gsn_add_polymarker(wks,plot,(/lon2d_sub(0,0),lon2d_sub(nlondata-1,nlonsubdata-1)/),(/lat2d_sub(0,0),lat2d_sub(nlatdata-1,nlatsubdata-1)/),mkres)
   plot@mkid = mkid

  end do

  resP = True
  resP@gsnPanelMainString  = "Comparing two functions for subsetting lat/lon data"
  resP@gsnPanelLabelBar    = True
  resP@lbLabelFontHeightF  = 0.009

  gsn_panel(wks,plots,(/1,2/),resP)

end
