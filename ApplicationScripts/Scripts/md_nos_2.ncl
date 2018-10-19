load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"  
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"  
begin
;*******************************************
; open file and read in data
;*******************************************
  f     = addfile ("20040217ruc20n.grb", "r")
  SLP   = f->MSLMA_252_MSL
  LAT2D = f->gridlat_252
  LON2D = f->gridlon_252
;********************************************
; reorder arrays
;********************************************
  slp   = SLP(initial_time0|:,gridy_252|:,gridx_252|:)
  lon2d = LON2D(gridy_252|:,gridx_252|:)
  lat2d = LAT2D(gridy_252|:,gridx_252|:)
;********************************************
; create plot
;********************************************
  wks  = gsn_open_wks ("ps", "md_nos")              ; open workstation
  gsn_define_colormap (wks,"gui_default")           ; choose color map
  
  res                        = True                 ; plot mods desired
  res@cnFillOn               = True                 ; color fill  
  res@cnLinesOn              = False                ; no contour lines
  res@cnLineLabelsOn         = False                ; no contour labels
  res@gsnSpreadColors        = True                 ; use total colormap
  res@lbLabelAutoStride      = True                 ; nice lat/lon labels

  res@tiMainString           = "20040217ruc20n.grb" ; title
  
  res@pmTickMarkDisplayMode  = "Always"             ; turn on tickmarks
  res@gsnAddCyclic           = False                ; regional data

; !!!!! any plot of data that is on a native grid, must use the "corners"
; method of zooming in on map.
  res@mpLimitMode       = "Corners"                 ; choose range of map
  res@mpLeftCornerLatF  = lat2d@corners(0)
  res@mpRightCornerLatF = lat2d@corners(2)
  res@mpLeftCornerLonF  = lon2d@corners(0)
  res@mpRightCornerLonF = lon2d@corners(2)

; The following 4 pieces of information are REQUIRED to properly display
; data on a native lambert conformal grid.  This data should be specified
; somewhere in the model itself.
  
  res@mpProjection        = "LambertConformal"
  res@mpLambertParallel1F = lat2d@La1
  res@mpLambertParallel2F = lat2d@La1+20
  res@mpLambertMeridianF  = lat2d@Lov

; usually, when data is placed onto a map, it is TRANSFORMED to the specified
; projection. Since this model is already on a native lambert conformal grid,
; we want to turn OFF the tranformation.
  
  res@tfDoNDCOverlay = True

  plot = gsn_csm_contour_map(wks,slp(0,:,:),res)  ; Draw contours over a map.
  
end
