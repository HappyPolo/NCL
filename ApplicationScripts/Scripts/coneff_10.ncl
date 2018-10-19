;******************************************************************* 
;  coneff_10.ncl
;
; Concepts illustrated:
;   - Drawing a latitude/time contour plot
;   - Filling contours with multiple shaded patterns
;   - Changing the density of contour shaded patterns
;   - Drawing the zero contour line thicker
;   - Paneling two plots horizontally on a page
;   - Adding a common labelbar to paneled plots
;
;*******************************************************************
;
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
;
; This file still has to be loaded manually
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl"
;********************************************************************
begin
 scale= 100.

 fili = "ECMWF_ZM_REGIONS_OMEGA_V2.nc"  
 f        = addfile (fili , "r")
 zm_afr   = f->ZM_AFR
 zm_namer = f->ZM_NAMER
 zm_samer = f->ZM_SAMER
 zm_asau  = f->ZM_ASAU
 zm_pac1  = f->ZM_PAC1
 zm_pac2  = f->ZM_PAC2
 zm_atl   = f->ZM_ATL
 lat      = f->lat
 time     = f->time

 zm_afr   = (/ zm_afr*scale   /)
 zm_namer = (/ zm_namer*scale /)
 zm_samer = (/ zm_samer*scale /)
 zm_asau  = (/ zm_asau*scale  /)
 zm_pac1  = (/ zm_pac1*scale  /)
 zm_pac2  = (/ zm_pac2*scale  /)
 zm_atl   = (/ zm_atl*scale   /)
;******************************************
; create plot
;******************************************
 wks  = gsn_open_wks ("png", "coneff" )     ; open workstation and send data to PNG file
 res            = True
 res@gsnDraw    = False                     ; do not draw
 res@gsnFrame   = False                     ; do not advance frame

 res@gsnRightString = "10~S~-2~N~ Pa/s"     ; "fancy" label
 res@trYReverse     = True                  ; reverse "time" axis
 res@lbLabelBarOn   = False                 ; turn off label bar

 res@cnLevelSelectionMode = "ManualLevels"  ; manually specify contour levels
 res@cnMinLevelValF       = -4.             ; min level
 res@cnMaxLevelValF       =  5.             ; max level
 res@cnLevelSpacingF      =  1.             ; contour interval

 res@cnInfoLabelOn   = False                ; turn off info label box
 res@cnLineLabelsOn  = False                ; no lables on line
 res@cnFillOn        = True                 ; fill contour intervals

 res@cnMonoFillColor = True                 ; default color is fground [black]
 res@cnMonoFillPattern = False              ; want multiple patterns 
 res@cnMonoFillScale   = False              ; want patterns w/ diff densities 
 res@cnFillPatterns    = (/ 3,  3,  3  \    ; 3=slant lines
                          ,-1 ,-1 ,-1  \    ; -1=transparent
                          , 17, 17, 17, 17, 17/) ; stipling
 res@cnFillScales      = (/0.3,0.45,0.6 \   ; line density
                          , 1., 1., 1.  \   ; default [no op]
                          ,0.7,0.6,0.5,0.40,0.3/) ; stiple density

 res@tmYLMode   = "Explicit"                ; explicit tick labels
 res@tmYLValues = (/ time /)                ; label at "time"
 res@tmYLLabels = (/"Jan","Feb","Mar","Apr","May","Jun" \
                   ,"Jul","Aug","Sep","Oct","Nov","Dec" /) 

 plot    = new ( 2, graphic)
 plot(0) = gsn_csm_time_lat (wks, zm_afr(:,{-52:52})  , res )  
 plot(1) = gsn_csm_time_lat (wks, zm_asau(:,{-52:52}) , res )  

 do np=0,1                                  ; thicken the zero contour
    plot(np) = ZeroLineContourThick (plot(np), 3)
 end do

 resP                  = True               ; panel only resources
 resP@gsnPanelLabelBar = True               ; add common label bar
 gsn_panel (wks,plot,(/1,2/),resP)           

end
