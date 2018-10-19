;*************************************************
; zonal_4.ncl
;
; Concepts illustrated:
;   - Drawing a zonal means plot
;   - Customzing the axes of a zonal means plot
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
  in  = addfile("atmos.nc","r")
  T   = in->T                                     ; select variable to ave
;************************************************
;  calculate zonal average of 3d variable
;************************************************
  zave = dim_avg_Wrap(T)                             ; calculate zonal ave
;************************************************
;  calculate eta
;************************************************
  a=in->hyam                                    ; select hyam 
  b=in->hybm                                    ; select hybm
  p=in->P0                                      ; select P0
  eta = (a+b)*p                                 ; calc eta
  eta = eta/100                                 ; scale eta by 100
;************************************************
; plotting
;************************************************
  wks  = gsn_open_wks("png","zonal")              ; send graphics to PNG file
  
  res               = True
  res@tiXAxisString = "latitude"                  ; x-axis label
  res@tiYAxisString = "eta x 1000"                ; y-axis label
  res@sfXArray      = zave&lat                    ; put lat on x axis
  res@sfYArray      = eta                         ; put eta on y axis
  res@trYReverse    = True                        ; reverses y axis
  res@trXReverse    = True                        ; reverse X axis
  
  plot=gsn_contour(wks,zave(0,:,:),res)           ; plot zonal ave
;***********************************************
end


