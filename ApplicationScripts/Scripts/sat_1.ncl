;*************************************************
; NCL Graphics: sat_1.ncl
;*************************************************
; Concepts illustrated:
;   - Using 'short2flt' to unpack 'short' data
;   - Drawing line contours over a satellite map
;   - Changing the view of a satellite map
;************************************************
; This file is loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"   
;************************************************
begin
;************************************************
; read in netCDF file
;************************************************
  f = addfile("slp.1963.nc","r") 
;************************************************
; unpack data and convert from Pa to hPa
;************************************************
  slp_short = f->slp
  printVarSummary(slp_short)

  slp_float = short2flt(slp_short)
  slp_float = slp_float * 0.01
  slp_float@units = "hPa"
;************************************************
; plotting parameters
;************************************************
  wks = gsn_open_wks("png","sat")             ; send graphics to PNG file

  res                            = True       ; plot mods desired

  res@gsnMaximize                = True

;  res@cnHighLabelsOn             = True       ; turn on H labels
;  res@cnHighLabelFontHeightF     = 0.024      ; change H font
  res@cnHighLabelBackgroundColor = -1         ; make H background transparent

  res@cnLowLabelsOn              = True       ; turn on L labels
  res@cnLowLabelFontHeightF      = 0.024      ; change L font
  res@cnLowLabelBackgroundColor  = -1

  res@cnLabelDrawOrder           = "PostDraw" ; draw labels over lines

  res@mpProjection               = "Satellite" ; choose map projection
  res@mpCenterLonF               = 270.0       ; choose center lon
  res@mpCenterLatF               = 45.         ; choose center lat
  res@mpSatelliteDistF           = 3.0         ; choose satellite view

  res@mpFillOn                   = True        ; color continents
  res@mpFillColors               = (/"white","lightcyan","lightgray","lightcyan"/); colors to draw
  res@mpOutlineOn                = True        ; turn on continental outlines
  res@mpOutlineBoundarySets      = "National"  ; add country boundaries
  res@mpGridLineDashPattern      = 2           ; make lat/lon lines dash
	
  res@cnLevelSelectionMode 	= "ManualLevels"  ; manually set cont levels
  res@cnMinLevelValF       	= 948             ; min lev
  res@cnMaxLevelValF	        = 1064            ; max lev
  res@cnLevelSpacingF           = 4               ; spacing
  res@cnLineThicknessF          = 1.10            ; change line thickness

  res@tiMainString    = "~F22~SLP 1963, January 24th" ; add title

  map = gsn_csm_contour_map(wks,slp_float(24,:,:),res)
end
	 
