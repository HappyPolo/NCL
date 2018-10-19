; ===============================================
; bar_5.ncl
;
; Concepts illustrated:
;   - Drawing multiple sets of filled bars up or down based on multiple Y reference values
;   - Drawing bars instead of curves in an XY plot
;   - Changing the aspect ratio of a bar plot
;   - Setting the minimum/maximum value of the Y axis in a bar plot
;   - Changing the labels and tickmarks in a bar plot
;   - Adding labels to the right Y axis
;
; ===============================================
;
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
;
; This file still has to be loaded manually
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl"

begin
 fili  = "Jsst.nc"
 f     = addfile (fili , "r")
 time  = f->time

 date  = f->date
 sst   = f->SST                  
 sst   = (/ sst /)*0.1                  ; scale sst anomalies 

 wgt   = (/ 1., 2., 1./)
 wgt   = wgt/sum(wgt)
 sst   = wgt_runave (sst, wgt, 0)

 warm  = (/1951,1953,1957,1963,1965,1969 \  ; warm years
         , 1972,1976,1982,1987,1991 /)
 nWarm = dimsizes(warm)                     ; number of curves

 nMonth= 37
 month = fspan(0., 36., 37)
 month@long_name = "Month"
 data  = new( (/nWarm,nMonth/), float)  ; make one array for
                                        ; multiple lines


;Please note: we have found that running other SST data through this
;script resulted in a 1-year offset.  To compensate for this, we
;added the line:indStrt   = indStrt-12 to the loop.

 do nW=0,nWarm-1                        ; Fill each 37 month segment
    indStrt    = ind(date.eq.warm(nW)*100+01)
    indLast    = indStrt+nMonth-1
    data(nW,:) = sst(indStrt:indLast)
 end do
;----------------------------------
; create plot
;----------------------------------
 wks   = gsn_open_wks ("png", "bar" )  ; send graphics to PNG file
 res          = True
 res@trYMinF  = -2.0              ; bottom of Y-scale
 res@trYMaxF  =  2.0              ; nominal top of Y-scale
 tickMark     =  1.0              ; tick Mark increment (1 degree)
 curv_offset  =  res@trYMaxF-res@trYMinF   ; range
 res@trYMaxF  =  curv_offset*nWarm + res@trYMinF + tickMark
 
 do nW=0,nWarm-1
    data(nW,:)  = data(nW,:) + curv_offset*nW 
 end do

 res@xyMonoDashPattern    = True  ; all solid lines
 res@tmYLLabelFontHeightF = 0.01  ; default is 0.02
 res@tmYLMode      = "Explicit"   ; Define own left tick mark labels.
 res@tmYLValues    = fspan(res@trYMinF,res@trYMaxF,floattointeger((res@trYMaxF-res@trYMinF)/tickMark)+1 )
 res@tmYUseLeft    = False
 res@tmYRLabelsOn  = True

 res@tmYRMode      = "Explicit"   ; Define own right tick mark labels.
 res@tmYRValues    = res@tmYLValues  
 res@tmYRLabelFontHeightF = res@tmYLLabelFontHeightF 
 res@tmYLLabels    = (/" ","-1.0","0.0","1.0" \     ; left labels
                      ," ","-1.0","0.0","1.0" \
                      ," ","-1.0","0.0","1.0" \
                      ," ","-1.0","0.0","1.0" \
                      ," ","-1.0","0.0","1.0" \
                      ," ","-1.0","0.0","1.0" \
                      ," ","-1.0","0.0","1.0" \
                      ," ","-1.0","0.0","1.0" \
                      ," ","-1.0","0.0","1.0" \
                      ," ","-1.0","0.0","1.0" \
                      ," ","-1.0","0.0","1.0" ," "," "/)
 res@tmYRLabels    = (/" ","","1951","" \          ; right labels
                      ," ","","1953","" \
                      ," ","","1957","" \
                      ," ","","1963","" \
                      ," ","","1965","" \
                      ," ","","1969","" \
                      ," ","","1972","" \
                      ," ","","1976","" \
                      ," ","","1982","" \
                      ," ","","1987","" \
                      ," ","","1991","" ," "," "/)

 res@gsnRightString  = "~N~(~S~o~N~C)"
 res@gsnCenterString = "Warm Events"
 res@tiMainString    = "Monthly SST Anomalies for Nino-3"
 res@gsnYRefLine = res@trYMinF + 0.5*curv_offset + ispan(0,nWarm-1,1)*curv_offset

 res@gsnAboveYRefLineColor = "Red"
 res@gsnBelowYRefLineColor = "Blue"
 res@tmXBMode      = "Explicit" ; Define own tick mark labels.
 res@tmXBValues    = (/  0. ,  6. ,  12.,  18.,  24.,  30.,  36./)
; note, if the text of your plot looks exactly like listed below, then
; you do not have the correct function code a ~ in your .hluresfile.  
; Don't know what a .hluresfile is?  See the main page of the graphics
; web site for details.
 res@tmXBLabels    = (/"Jan~B~-1~N~","Jul~B~-1~N~","Jan~B~0~N~","Jul~B~0~N~",\
                       "Jan~B~+1~N~","Jul~B~+1~N~","Jan~B~+2~N~"/)
 


 res@gsnXYBarChart = True
 plot  = gsn_csm_xy (wks,month,data(0:nWarm-1,:),res)
end
