; ===========================================
; panel_10.ncl
; ===========================================
;
; Concepts illustrated:
;   - Drawing Hovmueller plots
;   - Attaching plots along the Y axis
;   - Using a blue-white-red color map
;   - Drawing zonal average plots
; ===========================================
; See example panel_attach_10.ncl for an
; example of panelling four of these types
; of plots.
; ===========================================
;
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
;
; This file still has to be loaded manually
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl"

begin
 dir   = ncargpath("data") + "/cdf/"
 f     = addfile (dir+"chi200_ud_smooth.nc","r")
 scale = 1.e6                                    ; scale factor
 chi   = f->CHI                                  ; get chi
 chi   = chi/scale                               ; scale for convenience
;==============================================
; create color plot
;=============================================
 wks  = gsn_open_wks ("png", "panel" )            ; send graphics to PNG file

 hres                          = True             ; plot mods desired
 hres@gsnDraw                  = False            ; don't draw yet
 hres@gsnFrame                 = False            ; don't advance frame yet

 hres@cnFillOn                 = True             ; turn on color fill
 hres@pmLabelBarOrthogonalPosF = -.05             ; position label bar
 hres@cnFillPalette            = "BlWhRe"
 hres@tiMainString             = "Pacific Region" ; title

 hres@cnLevelSelectionMode     = "ManualLevels"   ; manual contour levels
 hres@cnMinLevelValF           = -10.             ; minimum level
 hres@cnMaxLevelValF           =  10.             ; maximum level
 hres@cnLevelSpacingF          =   2.             ; contour spacing

 base_plot = gsn_csm_hov(wks, chi(:,{100:220}), hres)
;==============================================
; create xy plot
;=============================================
 x   = dim_avg(chi)                    ; average chi
 x!0 = "chi"                           ; remove warning message
 y   = ispan(0,dimsizes(chi&time)-1,1) ; create y-axis
 y!0 = "time"   

 xyres                 = True         ; xy plot mods desired
 xyres@vpWidthF        = .20          ; set width of second plot
 xyres@tmXBMinorOn     = False        ; no minor tickmarks
 xyres@tmXBLabelStride = 2            ; label stride

 xyres@gsnDraw         = False        ; don't draw yet
 xyres@gsnFrame        = False        ; don't advance frame yet

 xyres@gsnCenterString = "Zonal Ave"  ; add title
 xyres@txFontHeightF   = .015         ; change font height

 xyres@trXMinF         = min(x)
 xyres@trXMaxF         = max(x)
 xyres@trYMinF         = min(chi&time)
 xyres@trYMaxF         = max(chi&time)

 plot = gsn_csm_xy(wks, x,y,xyres)
;==============================================
;  attach plots
;=============================================
 newplot = gsn_attach_plots(base_plot,(/plot/),hres,xyres)
 draw(base_plot)
 frame(wks)
 
end
