;*************************************************
; corel_2.ncl
;
; Concepts illustrated:
;   - Calculating positive and negative lags in a cross correlation
;   - Illustrate using coordinate subscripting syntax [ {,,,} ] to select locations
;   - Illustrate reversing array order via the  ::-1 syntax
;
;************************************************
;
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"  
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
begin
;************************************************
; variable and file handling
;************************************************
   in  = addfile("b003_TS_200-299.nc","r")
   ts = in->TS

;************************************************
; extract 2 arbitrary time series from 3d data 
; Two method: (i) standard indexing; (ii) coordinate subscripting
;************************************************

  ;ts1=ts(:,45,64)                               ; (i) extract time series via indexing
  ;ts2=ts(:,23,117)

   lat1 = 37.1
   lon1 = 180  
   lat2 = -23.5
   lon2 = 329.1
   ts1  = ts(:,{lat1},{lon1})                    ; extract time series via
   ts2  = ts(:,{lat2},{lon2})                    ; (ii) coordinate subscripting {...}

                                                 ; print variable overview
  ;printVarSummary(ts1)                          ; ts1@lat , ts1@lon are the selected grid pts
  ;printVarSummary(ts2)                          ; ts2@lat , ts2@lon

;************************************************
; calculate cross correlations 
;           Note: ccr1(0)=ccr2(0) 
;************************************************
   maxlag = 25                                     ; set lag
   ccr1   = esccr(ts1,ts2,maxlag)                  ; calc positive lag cross cor: ccr1(maxlag+1)
   ccr2   = esccr(ts2,ts1,maxlag)                  ; calc negative lag cross cor: ccr2(maxlag+1)
  ;print("---")                 
  ;print("ccr1="+sprintf("%7.3f", ccr1)+"  ccr2="+sprintf("%7.3f", ccr2) \
  ;             +"  ccr2(::-1)="+sprintf("%7.3f", ccr2(::-1)))
;************************************************
;  combine pos and neg into one time series      
;          do not repeat the ccr(0) index
;************************************************
   totlag =2*maxlag +1                           ; set total lag

   ccrtot = new( totlag, typeof(ccr1) )          ; allocate memory 
   ccrtot(0:maxlag )   = ccr2(::-1)              ; ::-1 means reverse the order 
   ccrtot(maxlag+1:)   = ccr1(1:)                ; ccr1(0:mxlagmaxlag-1)
 
   x = ispan(-maxlag,maxlag,1)                   ; define x axis

  ;print("---")
  ;print("x="+sprintf("%7.3f", x)+"  ccrtot="+sprintf("%7.3f", ccrtot))

;************************************************
; plot the correlations
;************************************************
   wks  = gsn_open_wks("png","corel")                  ; send graphics to PNG file
   res                 = True                         ; make plot mods
   res@tiMainString    = "("+sprintf("%5.1f",ts1@lat)+","+sprintf("%5.1f",ts1@lon)+") and " \ 
                       + "("+sprintf("%5.1f",ts2@lat)+","+sprintf("%5.1f",ts2@lon)+")"  
   res@tiXAxisString   = "LAG"                        ; x-axis label

   res@trXMinF  = -maxlag
   res@trXMaxF  =  maxlag

   plot = gsn_xy(wks,x,ccrtot,res)                       ; plot correlation
end
