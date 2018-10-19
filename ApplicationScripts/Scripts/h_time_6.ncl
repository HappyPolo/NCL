; ===============================================
; h_time_6.ncl              
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

 yrStrt   = 1953
 yrLast   = 2013
 nyrs     = yrLast-yrStrt+1
 YYYYMM   = yyyymm_time(yrStrt, yrLast, "integer")
 YYYYMMF  = yyyymm_to_yyyyfrac(YYYYMM, 0.0)
 NTIM     = dimsizes(YYYYMM)

 f    = addfile ("./qbo.nc" , "r")
 date = f->date             ; date(time)   YYYYMM
 time = f->month_elapse     ; (time)   months since Jan 1950
 p    = f->plev             ; plev(lev)    pressure (hPa)

 UQBO = f->U                ; U(time,lev)
 printVarSummary (UQBO)

 UQBO = smth9(UQBO, 0.50, 0.25, False)
 
 klev = dimsizes(p)
 ntim = dimsizes(date)

 U    = new ( (/klev,NTIM/), typeof(UQBO), getFillValue(UQBO)) 

 ntStrt = ind(date(0).eq.YYYYMM)
 ntLast = ind(date(ntim-1).eq.YYYYMM)
 
 U(:,ntStrt:ntLast) = (/ UQBO(plev|: , time|:) /) 
 U!0  = "plev"
 U!1  = "time"
 U&plev = p    
 U&time = YYYYMMF
 printVarSummary (U)

 nmos   = 12
 nyrplt = 20                    ; number of yrs/(contour plot)
 nmoplt = nyrplt*nmos           ; number of months/(contour plot)
 npltfrm= nyrs/nyrplt           ; # (contour plots)/frame 
                                ; same as number decades/plot

 plot   = new ( npltfrm, "graphic")

 wks    = gsn_open_wks ("png", "h_time")  ; send graphics to PNG file
;gsn_define_colormap(wks,"BlueRed")     
;gsn_define_colormap(wks,"amwg")       
                                ; resources which do not change
 res            = True
 res@gsnDraw    = False         ; Don't draw the plot or advance the
 res@gsnFrame   = False         ; Don't advance frame
 res@vpWidthF   = .90
 res@vpHeightF  = .25 
 res@vpXF       = .10



 res@tmXTOn               = False
 res@tmXBMode             = "Explicit"     
 res@cnLineLabelsOn       = False 
 res@cnInfoLabelOn        = False      ; Turn off info label.
 res@cnMinLevelValF       = -40.
 res@cnMaxLevelValF       =  40.
 res@cnLevelSpacingF      =  10.     
 
 res@cnFillOn             = True
 res@cnFillPalette        = "amwg"     ; set color map
 res@lbLabelBarOn         = False      ; turn off individual lb's

 resP                     = True                ; modify the panel plot
 resP@gsnFrame            = False               ; do not advance the frame
 resP@txString            = "QBO: Zonal Wind"
 resP@gsnPanelBottom      = 0.03                ; extra space at bottom
 resP@gsnMaximize         = True                ; max plot foot print
 resP@gsnPanelYWhiteSpacePercent = 0.0          ; 1.0 is the default
 resP@gsnPanelLabelBar    = True                ; add common colorbar
 resP@lbLabelFontHeightF  = 0.012
 res@tmXBTickSpacingF     = 5
 res@cnLevelSelectionMode = "ManualLevels"

 source = "Source: http://www.geo.fu-berlin.de/en/met/ag/strat/produkte/qbo/"

 txres                    = True                ; additional info
 txres@txFontHeightF      = 0.010               ; size of meta data
 txres@txJust             = "CenterCenter"

 nplt   = 0
 nn     = 1
 if (nyrplt.gt.15) then
     nn = 2                         ; better spacing
 end if
 
 do nt=0,ntim-1,nmoplt              ; start months
    res@tmXBLabels = YYYYMM(nt:nt+nmoplt-1:nmos*nn)/100
    res@tmXBValues = YYYYMMF(nt:nt+nmoplt-1:nmos*nn)
    res@tmXBMinorValues = YYYYMMF(nt+nmos:nt+nmoplt-1:nmos)

    plot(nplt)     = gsn_csm_pres_hgt (wks, U(:,nt:nt+nmoplt-1), res )

    delete (res@tmXBLabels)         ; size may change
    delete (res@tmXBValues)
    delete (res@tmXBMinorValues)

    nplt           = nplt+1              
    if (nplt.eq.npltfrm) then
        gsn_panel(wks,plot,(/npltfrm,1/),resP)  
        gsn_text_ndc  (wks, source, 0.50, 0.02, txres)
        frame(wks)
        exit

        nplt = 0
        NMOPLT = NMOPLT-1           
        print ("====> New Frame/Page")
    end if
 end do

 gsn_panel(wks,plot(0:nplt-1),(/npltfrm,1/),resP)  
 gsn_text_ndc  (wks, source, 0.50, 0.02, txres)
 frame(wks)

end
