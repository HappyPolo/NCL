;************************************************
; zonal_2.ncl
;
; Concepts illustrated:
;   - Drawing a zonal means plot
;   - Using dim_avg_Wrap to calculate a zonal average
;************************************************
;
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl" 
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl" 
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl" 
;************************************************
begin
;************************************************
; variable and file handling
;************************************************
  in  = addfile("83.nc","r")
  ts  = in->T                                        ; select variable to ave
; use wrapper function so that meta data is preserved
  zave = dim_avg_Wrap(ts)                            ; calculate zonal ave
;************************************************
; plotting
;************************************************
  wks  = gsn_open_wks("png","zonal")               ; send graphics to PNG file

  res            = True                            ; plot mods desired
  res@trYReverse = True                            ; reverse Y axis
  res@trXReverse = True                            ; reverse X axis

  plot=gsn_csm_contour(wks,zave(0,:,:),res)             ; plot zonal ave
;***********************************************
end


