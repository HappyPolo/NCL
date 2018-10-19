;*************************************************
; NCL tutorial script: vort_1.ncl
;*************************************************
;
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
begin
;************************************************
; variable and file handling
;************************************************
  in  = addfile("80.nc","r")                             ; open netcdf file
  u   = in->U                                            ; pull u off file
  v   = in->V                                            ; pull v off file
;************************************************
; calculate vorticity on a Gaussian Grid
; scale for visual convenience
;************************************************
  scale = 1.e05                                  
  vrt   = u                                      ; retain coordinates
  vrt   = uv2vrG_Wrap(u,v) * scale
  vrt@long_name = "vorticity"
  vrt@units     = "scaled"
;************************************************
; create plot
;************************************************
  wks  = gsn_open_wks("png","vort")              ; send graphics to PNG file

  res                   = True                   ; plot mods desired
  res@cnFillOn          = True                   ; turn on color
  res@cnFillPalette     = "BlWhRe"               ; set color map
  res@cnLinesOn         = False                  ; no contour lines

  res@cnLevelSelectionMode = "ManualLevels"       ; set manual contour levels
  res@cnMinLevelValF       = -4                   ; set min contour level
  res@cnMaxLevelValF       =  4                   ; set max contour level
  res@cnLevelSpacingF      =  0.5                 ; set contour spacing


  plot = gsn_csm_contour_map(wks,vrt(0,2,:,:),res) ; create plot  
;************************************************
end
