;*************************************************
; NCL Graphics: sat_2.ncl
;************************************************
;   - Using 'short2flt' to unpack 'short' data
;   - Drawing filled contours over a satellite map
;   - Changing the view of a satellite map
;   - Explicitly setting contour fill colors
;************************************************
; These files are loaded by default in NCL V6.2.0 and newer 
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
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
  res = True

  res@gsnMaximize                = True

  res@cnHighLabelsOn             = True       ; turn on H labels
  res@cnHighLabelFontHeightF     = 0.024      ; change H font
  res@cnHighLabelBackgroundColor = -1         ; make H background transparent

  res@cnLowLabelsOn              = True       ; turn on L labels
  res@cnLowLabelFontHeightF      = 0.024      ; change L font
  res@cnLowLabelBackgroundColor  = -1         ; make L background transparent

  res@cnLabelDrawOrder           = "PostDraw" ; draw lables over lines

  res@mpProjection               = "Satellite" ; choose map projection
  res@mpCenterLonF               = 270.0       ; choose center lon
  res@mpCenterLatF               = 45.         ; choose center lat
  res@mpSatelliteDistF           = 3.0         ; choose satellite view
	
  res@mpOutlineOn                = True        ; turn on continental outlines
  res@mpOutlineBoundarySets      = "National"  ; add country boundaries
  res@mpGridLineDashPattern      = 2           ; make lat/lon lines dash
  res@mpGridAndLimbOn            = True
  res@gsnAddCyclic              = True         ; add a cyclic longitude point

  res@cnLevelSelectionMode 	= "ManualLevels"  ; manually set cont levels
  res@cnMinLevelValF       	= 948             ; min lev
  res@cnMaxLevelValF	        = 1064            ; max lev
  res@cnLevelSpacingF           = 4               ; spacing
  res@cnLineThicknessF          = 1.10            ; change line thickness

  res@tiMainString    = "~F22~SLP 1963, January 24th" ; add title
;
; sat_2.ncl differs from sat_2.ncl from this point on...
;
  res@cnFillOn                   = True
  res@lbLabelBarOn               = False         ; turn off labelbar
  res@cnInfoLabelOn              = True          ; turn on info abel
  res@cnMonoFillColor            = False
  res@cnMonoFillPattern          = True
  res@cnFillColors               = new(32,string) ; 32 is # of cn levels
  res@cnFillColors(:)            = "transparent"
  res@cnFillColors(19:22)        = "lightgray"
  res@cnFillColors(23:29)        = "gray55"
	
  map = gsn_csm_contour_map(wks,slp_float(21,:,:),res)
                            
end
	 
