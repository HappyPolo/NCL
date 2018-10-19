;*************************************************
; proj_1.ncl
;************************************************
;
; Concepts illustrated:
;   - Drawing filled contours over a Mollweide map
;   - Setting the spacing for latitude/longitude grid lines
;   - Changing the font size of the labelbar's labels
;   - Spanning part of a color map for contour fill
;   - Turning off the map perimeter (boundary)
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


  res                   = True
  res@mpProjection      = "Mollweide"       ; choose projection
  res@mpGridAndLimbOn   = True              ; turn on lat/lon lines
  res@mpPerimOn         = False             ; turn off box around plot
  res@mpGridLatSpacingF = 30.               ; spacing for lat lines
  res@mpGridLonSpacingF = 30.               ; spacing for lon lines
  res@mpFillOn          = False
 
  res@cnFillOn          = True              ; color plot desired
  res@cnFillPalette     = "gui_default"     ; set color map
  res@cnLineLabelsOn    = False             ; turn off contour lines
  res@txFontHeightF     = 0.015 

  res@vpXF            = 0.1                 ; make plot bigger
  res@vpYF            = 0.9         
  res@vpWidthF        = 0.8
  res@vpHeightF       = 0.8

  res@lbLabelFontHeightF  = 0.015           ; label bar font height

  res@tiMainString       = "Example of Mollweide Projection"  ; add a title
  res@tiMainFontHeightF  = .018                               ; font height

  contour = gsn_csm_contour_map(wks,t,res)  ; create the plot
end
