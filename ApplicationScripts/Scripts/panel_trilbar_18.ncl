;*************************************************
; panel_trilbar_18.ncl
;
; Concepts illustrated:
;   - Combining two sets of paneled plots on one page
;   - Maximizing plots after they've been created
;   - Drawing two labelbars in a combined panel plot
;   - Using cnFillPalette to assign a color palette to contours
;   - Using lbBoxEndCapStyle to draw triangles at the end of a labelbar
;*************************************************
;
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"

begin
;**************************************************
; Read data
;**************************************************
    fl_mdl  = addfile("TS.cam3.toga_ENS.1950-2000.nc","r")

    yr0 = fl_mdl->TS(12,:,:)
    yr1 = fl_mdl->TS(600,:,:)
    yr0 = yr0-273.15                        ; convert to degrees C
    yr1 = yr1-273.15                        ; convert to degrees C
    yr0@units = "C"
    yr1@units = "C"
;**************************************************
; calculate difference
;**************************************************
    diff                    = yr1           ; trick to create array with coordinate info
    diff                    = yr1 - yr0     ; over write values with differences
    diff@long_name          =  "1999-1951 TS field differences"
    print("========================================")
    printVarSummary(diff)   
    print(" min="+min(diff)+"   max="+max(diff))
;**************************************************
; plot
;**************************************************
    wks  = gsn_open_wks("png","panel_trilbar")             ; send graphics to PNG file
    
    res                     = True
    res@gsnDraw             = False
    res@gsnFrame            = False
    res@mpFillOn            = False            ; no need   
    res@cnLevelSelectionMode= "ExplicitLevels"   ; manual set levels
    res@cnLevels            = ispan(-30,270,15) * 0.1
    res@lbLabelStrings      = sprintf("%5.1f",res@cnLevels)
    res@cnFillOn            = True             ; color fill plot
    res@cnFillPalette       = "BlAqGrYeOrRe"
    res@cnLinesOn           = False
    res@cnLineLabelsOn      = False
    res@cnInfoLabelOn       = False
    res@lbLabelBarOn        = False            ; turn off individual label bars
    plot = new(2,graphic)    
    
    res@gsnLeftString       = "TS"
    res@gsnRightString      = "~S~o~N~C"

    res@gsnCenterString     = "Jan. 1999"
    plot(0) = gsn_csm_contour_map(wks,yr1,res)

    res@gsnCenterString     = "Jan. 1951"
    plot(1) = gsn_csm_contour_map(wks,yr0,res)
    
    panres1                   = True                   ; modify the panel plot
    panres1@gsnFrame          = False                  ; don't advance frame yet
    panres1@gsnPanelLabelBar  = True                   ; add common colorbar
    panres1@gsnPanelTop       = 0.95                   ; Make sure not too close to 
    panres1@gsnPanelBottom    = 0.35                   ; edge, so it maximizes better.
    panres1@lbOrientation     = "vertical"
    panres1@pmLabelBarWidthF  = 0.075                 ; make thinner
    panres1@pmLabelBarHeightF = 0.55  

    MAXIMIZE_OUTPUT           = True                  ; if maximization of plots is desired.

    panres1@lbBoxEndCapStyle  = "RectangleEnds"       ; this is the default
    if(MAXIMIZE_OUTPUT) then
      panres1@gsnDraw = False                           ; draw later, in maximize mode
;
; It is necessary to return the id of the paneled plots,
; so they can "live" for the rest of this script, for
; when we maximize them later.
; 
      panelid1 = gsn_panel_return(wks,plot,(/2,1/),panres1) 
    else
      panres1@gsnDraw = True
      gsn_panel(wks,plot,(/2,1/),panres1)               ; now draw as one 
    end if
    
    res@cnLevels            := ispan(-4,4,1)
    res@lbLabelStrings      := sprintf("%5.1f",res@cnLevels)
    res@cnFillPalette       = "BlueWhiteOrangeRed"    ; select a color map with white in the middle

    res@gsnCenterString     = "Difference: Jan 1999 - Jan 1951"
    plot2 = gsn_csm_contour_map(wks, diff ,res)
    
    panres1@gsnPanelTop    = 0.35
    panres1@gsnPanelBottom = .05
    panres1@pmLabelBarHeightF = 0.25  

    if(MAXIMIZE_OUTPUT) then
      panres1@gsnDraw = False                           ; draw later, in maximize mode
;
; It is necessary to return the id of the paneled plots,
; so they can "live" for the rest of this script, for
; when we maximize them later.
; 
      panres1@lbBoxEndCapStyle  = "TriangleBothEnds"    ; Added in NCL V6.4.0
      panelid2 = gsn_panel_return(wks,plot2,(/1,1/),panres1)

;---If maximization is desired, used this
      mres = True
      maximize_output(wks,mres)
    else
      panres1@gsnDraw = True
      gsn_panel(wks,plot2,(/1,1/),panres1)
      frame(wks)
    end if
end
    

