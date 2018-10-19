;----------------------------------------------------------------------
; dataonmap_9.ncl
;
; Concepts illustrated:
;   - Plotting contours on a rectilinear grid
;   - Using 'short2flt' to unpack 'short' data
;   - Drawing filled contours over a satellite map
;   - Changing the view of a satellite map
;----------------------------------------------------------------------
; These files are loaded by default in NCL V6.2.0 and newer 
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
;----------------------------------------------------------------------

begin
;---Read in netCDF file
  f = addfile("slp.1963.nc","r") 

;---Unpack data and convert from Pa to hPa
  slp_short = f->slp
  printVarSummary(slp_short)
  printMinMax(slp_short,0)

  slp_float = short2flt(slp_short)    ; unpack the data
  slp_float = slp_float * 0.01        ; convert to hPa
  slp_float@units = "hPa"             ; update the units

  printVarSummary(slp_float)
  printMinMax(slp_float,0)

  wks = gsn_open_wks("png","dataonmap")         ; send graphics to PNG file

  res                   = True

  res@gsnMaximize       = True         ; Maximize plot in frame

  res@mpProjection      = "Satellite" ; choose map projection
  res@mpCenterLonF      = 270.0       ; choose center lon
  res@mpCenterLatF      = 45.         ; choose center lat
  res@mpSatelliteDistF  = 3.0         ; choose satellite view
  res@mpPerimOn         = False
  res@mpGridAndLimbOn   = True

  res@cnFillOn          = True	
  res@cnLinesOn         = False
  res@cnLevelSpacingF   = 5           ; NCL chose 10

  res@lbOrientation     = "Vertical"	
  res@lbLabelFontHeightF = 0.01

  res@tiMainString      = "~F22~SLP 1963, January 24th" ; add title
  res@gsnLeftString     = ""          ; Blank these out
  res@gsnRightString    = ""

  map = gsn_csm_contour_map(wks,slp_float(21,:,:),res)
                            
end
	 
