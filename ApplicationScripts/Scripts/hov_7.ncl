; ===========================================
; hov_7.ncl
; ===========================================
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
begin
;=============================================
; data processing
;=============================================
 diri  = ncargpath("data") + "/cdf/"
 fili  = "chi200_ud_smooth.nc"                 ; filename
 
 f     = addfile (diri+fili , "r")             ; add file
 scale = 1.e6                                  ; scale factor
 chi   = f->CHI                                ; get chi
 chi   = chi/scale                             ; scale for convenience
; ===========================
; Create plot:Select Pacific region via coordinate subscripting
; ===========================
 wks  = gsn_open_wks ("png", "hov")           ; send graphics to PNG file
 res                 = True                   ; plot mods desired
 res@tiMainString    = "Pacific Region"       ; title
 res@cnLevelSpacingF = 2.                     ; contour interval

;
; Do special labels on Y axis. There will be 6 tickmarks per each
; month, with a month label appearing in the middle.  Here, we are
; treating minor tickmarks like major tickmarks, and vice versa, since
; only the major tickmarks can actually be labeled.
;
 months      = (/  12,   1,  2,    3,   4,   5/)      ; Dec 1950 - May 1951
 years       = (/1950,1951,1951,1951,1951,1951/)
 tk_per_mon  = 6                                      ; Tickmarks per month.
 nmonths     = dimsizes(months)
 ndays       = nmonths * tk_per_mon

 day_in_mon  = new(nmonths,float)           ; Number of days in each month
 do i=0,nmonths-1
   day_in_mon(i) = days_in_month(years(i),months(i))*1.
 end do

 major_ticks = new(ndays,float)    ; Array to hold major tickmark values.
 imonth      = 0
 days_accum  = 0.
 ii5         = ispan(1,5,1)*1.
 do i=0,ndays-1,6
   major_ticks(i) = days_accum
   major_ticks(i+1:i+5) = major_ticks(i) + ii5*(day_in_mon(imonth)/tk_per_mon)
   days_accum     = days_accum + day_in_mon(imonth)
   imonth = imonth + 1
 end do

 res@tmYLMode           = "Explicit"         ; Define own tick mark labels.
 res@tmYLMinorValues    = major_ticks(0:ndays-1:6)
 res@tmYLValues         = major_ticks
 res@tmYLLabels         = new(ndays,string)
 res@tmYLLabels(:)     = ""

; Label mid tickmark with the month label.
 res@tmYLLabels(3::6)  = (/"DEC", "JAN", "FEB", "MAR", "APR", "MAY"/)

 res@tmYLMinorOutwardLengthF = 0.02    ; Increase length and size of
 res@tmYLMinorLengthF        = 0.02    ; minor tickmarks
 res@tmYLMinorThicknessF     = 2.0
 res@tmYLMajorOutwardLengthF = 0.01
 res@tmYLMajorLengthF        = 0.01

 plot = gsn_csm_hov(wks, chi(:,{100:220}), res)   ; create plot

end
