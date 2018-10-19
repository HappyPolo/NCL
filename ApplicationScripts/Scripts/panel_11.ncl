; ===========================================
; 	panel_11.ncl
; ===========================================
;
; Concepts illustrated:
;   - Specifying how many plots to draw in each row
;   - Left-justifying and centering paneled plots
;
;
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"

begin

 ;=============================================
; data processing
;=============================================
 diri  = ncargpath("data") + "/cdf/"
 fili  = "chi200_ud_smooth.nc"                 ; filename
 
 f     = addfile (diri+fili , "r")             ; add file
 lat   = f->lat                                ; get lat
 lon   = f->lon                                ; get lon
 time  = f->time                               ; get time
 nlat  = dimsizes(lat)                         ; size of lat
 mlon  = dimsizes(lon)                         ; size of lon

 scale = 1.e6                                  ; scale factor
 chi   = f->CHI                                ; get chi
 chi   = chi/scale                             ; scale for convenience
;==============================================
; create plot
;=============================================
 lonE  = 100.           ; Pacific
 lonW  = 220.

 wks  = gsn_open_wks ("png", "panel" )              ; send graphics to PNG file
 plot = new ( 7 , graphic)


 hres                          = True
 hres@gsnDraw                  = False
 hres@gsnFrame                 = False

 hres@tiMainString             = "Pacific Region"

 hres@cnLevelSelectionMode     = "ManualLevels"     ; manual levels
 hres@cnMinLevelValF           = -10.
 hres@cnMaxLevelValF           =  10.
 hres@cnLevelSpacingF          = 2. 

 plot(0) = gsn_csm_hov(wks, chi(:,{0:80}), hres)
 plot(1) = gsn_csm_hov(wks, chi(:,{10:90}), hres)
 plot(2) = gsn_csm_hov(wks, chi(:,{20:100}), hres)
 plot(3) = gsn_csm_hov(wks, chi(:,{30:110}), hres)
 plot(4) = gsn_csm_hov(wks, chi(:,{40:120}), hres)
 plot(5) = gsn_csm_hov(wks, chi(:,{50:130}), hres)
 plot(6) = gsn_csm_hov(wks, chi(:,{60:140}), hres)

;==============================================
; create panel
;=============================================
 pres                 = True
 pres@gsnPanelRowSpec = True                   ; tell panel what order to plot
 gsn_panel(wks,plot,(/1,3,2,1/),pres)

 pres@gsnPanelCenter  = False
 gsn_panel(wks,plot,(/1,3,2,1/),pres)
end
