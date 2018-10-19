;************************************************
; zonal_1.ncl
;
; Concepts illustrated:
;   - Drawing a zonal means plot
;************************************************
;
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl" 
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl" 
;************************************************
begin
;************************************************
; variable and file handling
;************************************************
  fn  = "83.nc"                                 ; define filename
  in  = addfile(fn,"r")                         ; open netcdf file
  ts = in->TS                                   ; select variable to ave
;************************************************
; data processing
;************************************************
  zave = dim_avg(ts)                            ; calculate zonal ave
;************************************************
; plotting
;************************************************
  wks  = gsn_open_wks("png","zonal")                ; send graphics to PNG file
  
  plot=gsn_csm_xy(wks,zave(0,:),ts&lat,False)       ; plot zonal ave
;***********************************************
end


