;----------------------------------------------------------------------
; dataonmap_zoom_10.ncl
;
; Concepts illustrated:
;   - Plotting WRF data on native grid
;   - Plotting WRF data on non-native grid
;   - Zooming in on a WRF map
;----------------------------------------------------------------------
; These files are loaded by default in NCL V6.2.0 and newer 
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/wrf/WRF_contributed.ncl"
;----------------------------------------------------------------------

begin
;---Read some data off a WRF output file.
  f  = addfile("wrfout_d01_2003-07-15_00:00:00.nc","r")
  q2 = f->Q2                     ; (Time, south_north, west_east )

;----------------------------------------------------------------------
; This section selects a lat/lon region of interest by specifying
; the lower left and upper right corners of a lat/lon box.
; Use the wrf_user_ll_to_ij function to get the index values
; that *approximately* match the lat/lon area of interest.
;----------------------------------------------------------------------

;---Set the two lat/lon corners that we want to zoom in on.
  minlat =   24.
  maxlat =   30.
  minlon = -100.
  maxlon =  -90.

  lats = (/ minlat, maxlat /)
  lons = (/ minlon, maxlon /)
  loc  = wrf_user_ll_to_ij(f, lons, lats, True)
; 
; loc(0,:) is west-east (x)
; loc(1,:) is south-north (y)
;
; Use "loc" values to set special resources for zooming in on map.
;
  loc = loc-1       ; Index values are returned as 1 to N, so we have to
                    ; subtract 1 for 0 to N-1 indexing that NCL requires.

;---Start the graphics
  wks = gsn_open_wks("png" ,"dataonmap_zoom")     ; png,ps,pdf,x11,eps

;---Set resources common to both plots
  res                       = True
  res@gsnMaximize           = True                ; maximize size
  res@cnFillOn              = True                ; color plot desired
  res@cnFillPalette         = "BlGrYeOrReVi200"
  res@cnLinesOn             = False               ; turn off contour lines
  res@cnLineLabelsOn        = False               ; turn off contour labels
  res@cnLevelSelectionMode  = "ExplicitLevels"
  res@cnLevels              = ispan(145,345,20) * 0.0001
  res@gsnAddCyclic          = False               ; turn off longitude cyclic point
  res@mpDataBaseVersion     = "MediumRes"
  res@pmTickMarkDisplayMode = "Always"            ; nicer tickmarks

;----------------------------------------------------------------------
; This section shows how to zoom in on WRF data using the native
; projection. 
;
; You must set five special resources that will be used by
; wrf_map_resources to calculate the approximate map corners
; need to match the lat/lon box requested.
;----------------------------------------------------------------------
  res1        = res         ; Make copy of common resource list

  res1@ZoomIn = True        ; These five resources are required
  res1@Xstart = loc(0,0)    ; when zooming in on WRF data and
  res1@Xend   = loc(0,1)    ; keeping the same map projection.
  res1@Ystart = loc(1,0)
  res1@Yend   = loc(1,1)

;
; Call wrf_map_resources to set various map resources based on the
; five resource values set above, and based on global attributes on
; the file pointed to by "f".
;  
  res1 = wrf_map_resources(f, res1)
  res1@tfDoNDCOverlay              = True     ; Tells NCL this is a native projection

;---Overwrite some of the resources set by wrf_map_resources.
  res1@mpUSStateLineColor          = "black"
  res1@mpNationalLineColor         = "black"
  res1@mpGeophysicalLineColor      = "black"
  res1@mpUSStateLineThicknessF     = 2.0
  res1@mpNationalLineThicknessF    = 2.0
  res1@mpGeophysicalLineThicknessF = 2.0

;
; Set a title and create a native projection WRF plot.
;
; Note that you MUST subset the data here, using the same i,j 
; index values you calculated earlier!
;
  res1@tiMainString = "Zooming in on WRF data using 'ZoomIn' attribute"
  plot = gsn_csm_contour_map(wks,q2(0,loc(1,0):loc(1,1),loc(0,0):loc(0,1)),res1)

;----------------------------------------------------------------------
; This section shows how to zoom in on WRF data using the lat/lon
; arrays read off the file. In this section, we are NOT doing a
; native map projection, but instead are plotting the data on a 
; simple lat/lon projection.
;----------------------------------------------------------------------
  q2@lat2d = f->XLAT(0,:,:)       ; Required for plotting in non-native
  q2@lon2d = f->XLONG(0,:,:)      ; map projection.

  res2              = res         ; Make copy of common resource list

  res2@mpMinLatF    = minlat      ; Area we want to zoom in on
  res2@mpMaxLatF    = maxlat
  res2@mpMinLonF    = minlon
  res2@mpMaxLonF    = maxlon
  res2@pmTitleZone  = 4           ; Moves title closer to plot

;---Set a title and create a non-native projection WRF plot.
  res2@tiMainString = "Zooming in on WRF data using 2D lat/lon arrays"
  plot = gsn_csm_contour_map(wks,q2(0,:,:),res2)

end

