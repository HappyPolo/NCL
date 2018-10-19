;--------------------------------------------------
; datarid_6.ncl
;--------------------------------------------------
; Concepts illustrated:
;   - Drawing a lat/lon grid using gsn_coordinates
;   - Masking a data array based on a geographical area obtained from a shapefile
;   - Using functions for cleaner code
;--------------------------------------------------
;
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "./shapefile_utils.ncl"

;----------------------------------------------------------------------
; Procedure to add shapefile outlines to the given plot.
;----------------------------------------------------------------------
procedure add_shp_outlines(wks,plot,shp_filename)
local lnres
begin
;---Resources for polyline
  lnres                  = True
  lnres@gsLineColor      = "NavyBlue"
  lnres@gsLineThicknessF = 1.0    ; 1 is the default

  plot@lines = gsn_add_shapefile_polylines(wks, plot, shp_filename, lnres)
end

begin
  tf    = addfile("$NCARG_ROOT/lib/ncarg/data/cdf/Tstorm.cdf","r")
  t     = tf->t(0,:,:)     ; first time step

  t&lat@units = "degrees_north"
  t&lon@units = "degrees_east"

;---Convert to different units
  t       = ((/t/) - 273.15) * 9.0/5.0 +32.0
  t@units = "degF"


;---Mask "t" based on shapefile outline
  print("Masking data based on shapefile outline...")
  dir          = "USA_adm/"
  shp_filename = dir + "USA_adm0.shp"
  tmask        = shapefile_mask_data(t,shp_filename,True)

  wks = gsn_open_wks("png","datagrid") ; send graphics to PNG file

;---Set up some contour resources.
  res                       = True
  res@gsnMaximize           = True
  res@gsnDraw               = False   ; Don't draw plot
  res@gsnFrame              = False   ; Don't advance frame.

  res@gsnAddCyclic          = False
  res@gsnLeftString         = "temperature"
  res@cnFillOn              = True
  res@cnLinesOn             = False
  res@cnLineLabelsOn        = False
  res@cnInfoLabelOn         = False
  res@cnLevelSpacingF       = 5
  res@lbLabelBarOn          = False    ; will add later in paneled plots

  res@mpFillOn              = False 
  res@mpProjection          = "LambertEqualArea"
  res@mpGridAndLimbOn       = False

  res@mpDataBaseVersion     = "MediumRes"
  res@mpOutlineBoundarySets = "GeophysicalAndUSStates"   ; "AllBoundaries"
 
;---Zoom in on North America
  res@mpLimitMode           = "LatLon"
  res@mpMinLatF             = min(t&lat)-1
  res@mpMaxLatF             = max(t&lat)-1
  res@mpMinLonF             = min(t&lon)-1
  res@mpMaxLonF             = max(t&lon)+1
  res@mpCenterLonF          = -100.0
  res@mpCenterLatF          = 40.0

;---Create two map plots so we can attach data grid later
  res@tiMainString           = "Lat/lon locations of original data"
  plot_orig = gsn_csm_contour_map(wks,t,res)

  res@tiMainString           = "Lat/lon locations of masked data; red = missing points"
  res@mpOutlineOn            = False    ; will add shapefile outlines
  plot_mask = gsn_csm_contour_map(wks,tmask,res)

;---Add shapefile outlinesß
  add_shp_outlines(wks,plot_mask,shp_filename)

;---Attach original lat/lon grid over original data.
  gres                 = True
  gres@gsMarkerSizeF   = 3
  gres@gsnFrame        = False
  gres@gsnDraw         = False
  gres@gsnCoordsAttach = True
  gsn_coordinates(wks,plot_orig,t,gres)

;
; Attach lat/lon grid over masked data, with missing and non-missing 
; locations colored differently.
;
  gres@gsnCoordsNonMissingColor = "black"
  gres@gsnCoordsMissingColor    = "red"
  gsn_coordinates(wks,plot_mask,tmask,gres)


;---Draw both plots in a panel
  pres                  = True
  pres@gsnMaximize      = True
  pres@gsnPanelLabelBar = True  
  gsn_panel(wks,(/plot_orig,plot_mask/),(/2,1/),pres)
end
