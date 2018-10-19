;*************************************************
; xy_8.ncl
;
; Concepts illustrated:
;   - Forcing tickmarks and labels to be drawn on the top X axis in an XY plot
;   - Changing the line dash pattern in an XY plot
;   - Explicitly setting tickmarks and labels on the top X axis
;
;************************************************
;
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"   
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"    
;************************************************
begin
;************************************************
; read in data
;************************************************
   fn  = "SOI_Darwin.nc" ; define filename
   in  = addfile(fn,"r")                                 ; open netcdf file
   soi = in->DSOI                                       ; get data
;************************************************
; calculate spectrum
;************************************************
  spec = specx_anal(soi,0,7,0.10)
;************************************************
; plotting
;************************************************
   wks  = gsn_open_wks("png","xy")                 ; send graphics to PNG file 

   res               = True	                   ; plot mods desired
   res@tiMainString  = "Period (months/cycle)"     ; title
   res@tiXAxisString = "Frequency (cycles/month)"  ; xaxis string
   res@tiYAxisString = "Variance"                  ; yaxis string

; add additional axis on top of plot
   res@tmXUseBottom  = False      ; Keep top axis independent of bottom.
   res@tmXTLabelsOn  = True       ; have tick mark labels
   res@tmXTOn        = True       ; have tick marks
   res@tmXTMode      = "Explicit" ; label independently
   res@tmXTValues    = (/0.0,0.10,0.20,0.30,0.40,0.50/)
   res@tmXTLabels    = (/"0.0","10.0","5.0","3.3","2.5","2.0"/)
   

   plot=gsn_csm_xy(wks,spec@frq,spec@spcx,res)     ; create plot   
end


