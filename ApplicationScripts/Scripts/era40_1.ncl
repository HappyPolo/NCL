;************************************************
; era40_1.ncl
;
; Concepts illustrated:
;   - Reading GRIB data
;   - Plotting ERA40 data
;   - Spanning the full color map for contour fill
;   - Drawing color-filled contours over a cylindrical equidistant map
;   - Selecting a different color map
;
;*************************************************
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"  
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"  
;************************************************
begin
;************************************************
; create pointer to file and read in data
;************************************************
  in = addfile("ers40_u01276.grb","r")
  T = in->T_GDS0_ISBL_123
;************************************************
; create default plot
;************************************************
  wks = gsn_open_wks("ps","ers40")               ; open a ps file
  gsn_define_colormap(wks,"BlAqGrYeOrRe")        ; choose colormap

  res                       = True               ; plot mods desired
  res@cnFillOn              = True               ; turn on color fill
  res@cnLinesOn             = False              ; turn off contour lines

;---This resource not needed in V6.1.0
  res@gsnSpreadColors       = True               ; use full range of color map

  plot = gsn_csm_contour_map_ce(wks,T(0,0,:,:),res)     
end



