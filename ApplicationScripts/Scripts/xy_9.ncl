;************************************************
; xy_9.ncl
;
; Concepts illustrated:
;   - Drawing grid lines on an XY plot
;   - Changing the thickness and pattern of grid lines on an XY plot
;
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
  fn   = "SOI_Darwin.nc" ; define filename
  in   = addfile(fn,"r")                                  ; open netcdf file
  soi  = in->DSOI                                         ; get data
  spec = specx_anal(soi,0,7,.10)                          ; calc spectrum
;************************************************
; plotting
;************************************************
  wks  = gsn_open_wks("png","xy")                 ; send graphics to PNG file
  
  res               = True                        ; plot mods desired
  res@tiMainString  = "Period (months/cycle)"     ; title
  res@tiXAxisString = "Frequency (cycles/month)"  ; xaxis
  res@tiYAxisString = "Variance"                  ; yaxis
  
  res@tmXMajorGrid                = True          ; implement x grid 
  res@tmXMajorGridThicknessF      = 1.0           ; 2.0 is default
  res@tmXMajorGridLineDashPattern = 2             ; select short dash lines
  
  res@tmYMajorGrid                = True          ; implement y grid
  res@tmYMajorGridThicknessF      = 1.0           ; 2.0 is default
  res@tmYMajorGridLineDashPattern = 2             ; select short dash lines
  
  plot = gsn_csm_xy(wks,spec@frq,spec@spcx,res)   ; create plot   
;***********************************************
end


