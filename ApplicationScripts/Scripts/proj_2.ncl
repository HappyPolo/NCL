;*************************************************
; proj_2.ncl
;************************************************
;
; Concepts illustrated:
;   - Drawing filled contours over a Mercator map
;   - Setting the spacing for latitude/longitude grid lines
;   - Turning off the map perimeter (boundary)
;   - Making the plot larger using viewport resources
;   - Turning off map fill
;   - Spanning part of a color map for contour fill
;
;
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl" 
;************************************************
begin
;************************************************
; read in netCDF file
;************************************************
  a = addfile("atmos.nc","r")
;************************************************
; read in zonal winds
;************************************************
  t = a->TS(0,:,:)                                ; read July zonal winds
;************************************************
; create plot
;************************************************
  wks = gsn_open_wks("png","proj")          ; send graphics to PNG file
  gsn_define_colormap(wks,"gui_default")

  res                   = True
  res@mpProjection      = "Mercator"        ; choose projection
  res@mpGridAndLimbOn   = True              ; turn on lat/lon lines
  res@mpPerimOn         = False             ; turn off box around plot
  res@mpGridLatSpacingF = 20.               ; spacing for lat lines
  res@mpGridLonSpacingF = 30.               ; spacing for lon lines
  res@mpFillOn          = False
 
  res@cnFillOn          = True              ; color plot desired
  res@cnLineLabelsOn    = False             ; turn off contour lines

  res@vpXF            = 0.1                 ; make plot bigger
  res@vpYF            = 0.9         
  res@vpWidthF        = 0.8
  res@vpHeightF       = 0.8

  res@gsnSpreadColors     = True
  res@gsnSpreadColorStart = 2
  res@gsnSpreadColorEnd   = -3

  res@lbLabelFontHeightF  = 0.015           ; label bar font height
 
  res@tiMainString       = "Example of Mercator Projection"   ; add a title
  res@tiMainFontHeightF  = .018                               ; font height

  contour = gsn_csm_contour_map(wks,t,res)  ; create the plot
end
