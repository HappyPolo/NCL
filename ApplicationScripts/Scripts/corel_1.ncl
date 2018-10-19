;*************************************************
; corel_1.ncl
;
; Concepts illustrated:
;   - Calculating a cross correlation
;   - Generating an equally-spaced span of integers
;
;************************************************
;
; This file is loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
begin
;************************************************
; open file and read in variable
;************************************************
  in  = addfile("b003_TS_200-299.nc","r")
  ts = in->TS
;************************************************
; extract time series from 3d data
;************************************************
  ts1=ts(:,45,64)                               ; extract time series
  ts2=ts(:,23,117)
;************************************************
; calculate cross correlations
;************************************************
  maxlag = 25                                   ; set lag
; note, the max lag should not be more than N/4
  
  ccr = esccr(ts1,ts2,maxlag)                   ; calc cross cor
  x   = ispan(0,maxlag-1,1)                     ; define x axis
;************************************************
; plot the correlations
;************************************************
  wks  = gsn_open_wks("png","corel")                 ; send graphics to PNG file
  res                 = True                         ; make plot mods
  res@tiMainString    = "37.7N 180E vs 23.72S 149W"  ; title
  res@tiXAxisString   = "LAG"                        ; x-axis label
  
  plot = gsn_xy(wks,x,ccr,res)                       ; plot correlation
;************************************************
end






	
