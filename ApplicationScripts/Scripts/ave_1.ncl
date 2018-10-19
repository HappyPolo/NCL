;**************************************
;  ave_1.ncl
;
; Concepts illustrated:
;   - Calculating a global weighted average
;   - Drawing a time series plot
;   - Copying attributes from one variable to another
;
;**************************************
;
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"   
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
;**************************************
begin
;****************************************
  in = addfile("b003_TS_200-299.nc","r")
  ts = in->TS                            ; read in data
  gw = in->gw                            ; get gaussian weights for ave
;****************************************
; calculate averages
;****************************************
; arguments:
; data
; weights in y direction
; weights in x direction (we just use 1.0 since there are none)
; option (0 means use missing values, 1 means the ave will be missing if
;    ANY data in the array is missing.

  globav  = wgt_areaave(ts,gw,1.0,0)
  copy_VarAtts(ts,globav)
;****************************************
; Create plot
;****************************************
 wks = gsn_open_wks("png","ave")        ; send graphics to PNG file
 res = True
 res@tiYAxisString= globav@long_name + " (" + globav@units + ")"
 res@tiXAxisString= "Time Steps"
 res@tiMainString = "Global Weighted Average"
 x = ispan(0,dimsizes(globav)-1,1)                      ; create x-axis
 plot = gsn_csm_xy(wks,x,globav,res); create plot
end


