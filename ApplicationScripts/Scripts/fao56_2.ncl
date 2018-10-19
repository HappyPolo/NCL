;***************************************************************
; fao56_2.ncl      
;
; Concepts illustrated:
;   - Creating a latitude variable va an NCL function
;   - Creating a 'time' array consisting of day-of-year
;   - Use radext_fao56 and daylight_fao56 to create values for each day of yesr
;   - Reversing the order of the variables via named dimensions
;   - Create an 'x-axis' that assigns named months to the mid day of each month
;   - Create contour plots
;***************************************************************
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"   
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/crop.ncl"
;***************************************************************
; The 'crop.ncl' library is available from 6.4.0 onward
;***************************************************************
;---------------------------  MAIN ------------------------------

   nlat   = 178                           ; lat: [-89.494..89.494]
   lat    = latGlobeFo(nlat, "lat", "latitude", "degrees_north")
   printVarSummary(lat)

; create a 'time' array

   jday   = ispan(1,365,1)                ; every day of year
   jday@long_name = "day oy year"
   jday!0 = "jday"                        ; make a coordinate variable
   jday&jday = jday

; calculate 'radext' and 'daylight'

   radext   = radext_fao56(jday, lat, 1)  ; will create [jday | 365] x [lat | 90]
   printVarSummary(radext)
   printMinMax(radext, 0)

   daylight = daylight_fao56(jday, lat)   ; will create [jday | 365] x [lat | 90]
   printVarSummary(daylight)
   printMinMax(daylight, 0)

;=================================================
; PLOT
;=================================================
; set variables for labeling
;=================================================
   nmos  = 12
   yyyy  = conform_dims(nmos, 2015, -1)      ; yyyy[12]
   mm    = ispan(1,nmos,1)                   ; mm[12]
   dd    = (/ 16, 14, 16, 15, 16, 15, 16, 16, 15, 16, 15, 16 /) 
   ddmid = day_of_year(yyyy, mm, dd)         ; mid-month (approx)  
   plot  = new (2,"graphic")
 
   wks   = gsn_open_wks("ps","fao56") 
   gsn_define_colormap(wks, "amwg256")       ; arbitrary
 
   res                      = True    
   res@gsnDraw              = False          ; don't draw
   res@gsnFrame             = False          ; don't advance frame
   
   res@vpWidthF             = 0.85           ; change aspect ratio of plot
   res@vpHeightF            = 0.6
   res@vpXF                 = 0.1            ; start plot further to the left
 
   res@cnFillOn             = True   
   res@cnLinesOn            = False          ; default is True  
   res@cnLineLabelsOn       = False          ; default is True  

   res@cnLevelSelectionMode = "ManualLevels" ; set manual contour levels
   res@cnMinLevelValF       =   2.           ; set min contour level
   res@cnMaxLevelValF       =  44.           ; set max contour level
   res@cnLevelSpacingF      =   2.           ; set contour spacing

   res@lbOrientation        = "Vertical"
 
   res@tmXBMode              = "Explicit"  
   res@tmXBValues            = ddmid         ; place at rge center of the month
   res@tmXBLabels            = (/"Jan","Feb","Mar","Apr","May","Jun" \
                                ,"Jul","Aug","Sep","Oct","Nov","Dec" /)
    
; set all occurrences of 0.0 to _FillValue to more clearly delineate wher 0.0 occurs

   radext@_FillValue = 1e20
   radext  = where(radext.eq.0, radext@_FillValue, radext)

   plot(0) = gsn_csm_contour(wks,radext(lat|:,jday|:),res)          ; contour the variable
                                                                    ; make lat the 'y-axis'

   res@cnMinLevelValF       =   1.           ; set min contour level
   res@cnMaxLevelValF       =  23.           ; set max contour level
   res@cnLevelSpacingF      =   1.           ; set contour spacing
 
   daylight@_FillValue = 1e20
   daylight = where(daylight.eq.0, daylight@_FillValue, daylight)
   plot(1)  = gsn_csm_contour(wks,daylight(lat|:,jday|:),res)       ; contour the variable

;************************************************
; create panel
;************************************************
   resP                     = True                ; modify the panel plot
   resP@gsnMaximize         = True
  ;resP@txString            = "FAO 56"
   gsn_panel(wks,plot,(/2,1/),resP)               ; now draw as one plot
