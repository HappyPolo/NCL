;***************************************************************
; calipso_1.ncl
;
; Concepts illustrated:
;   - Reading CALIPSO data
;***************************************************************
;
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl" 
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl" 
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl" 
;**************************************************************
begin
;***************************************************************
; User Input
;***************************************************************
                                         ; INPUT
   diri    = "./"                        ; input directory
   filday  = "MapLowMidHigh330m_20062011_day_CFMIP2_sat_2.65.nc"
   filngt  = "MapLowMidHigh330m_20062011_night_CFMIP2_sat_2.65.nc"

   pltDir  = "./"                        ; directory for plot output
   pltType = "png"                       ; send graphics to PNG file                     
   pltName = "calipso"

;***************************************************************
; Read CALIPSO Cloud Fraction variables
;***************************************************************

  fday       = addfile(diri+filday, "r")
  cf_low_day = fday->cllcalipso          ; Low-level Cloud Fraction
  cf_mid_day = fday->clmcalipso          ; Mid-level Cloud Fraction
  cf_hgh_day = fday->clhcalipso          ; High-level Cloud Fraction
  cf_tot_day = fday->clccalipso          ; Total Cloud Fraction
  cf_clr_day = fday->clccalipso          ; Total Clear Fraction

  fngt       = addfile(diri+filngt, "r")
  cf_low_ngt = fngt->cllcalipso          ; Low-level Cloud Fraction
  cf_mid_ngt = fngt->clmcalipso          ; Mid-level Cloud Fraction
  cf_hgh_ngt = fngt->clhcalipso          ; High-level Cloud Fraction
  cf_tot_ngt = fngt->clccalipso          ; Total Cloud Fraction
  cf_clr_ngt = fngt->clccalipso          ; Total Clear Fraction


;***************************************************************
; Extract temporal information 
;***************************************************************
   ymd_day = cd_calendar(fday->time, -2) ; yyyymmdd
   ymd_ngt = cd_calendar(fngt->time, -2) ; yyyymmdd

;***************************************************************
; Create plot 
;***************************************************************

       nt     = 0    ; arbitrary

       wks    = gsn_open_wks(pltType, pltDir+pltName)
       plot = new ( 10, "graphic")
     
       res                      = True     ; plot mods desired
       res@gsnDraw              = False    ; don't draw
       res@gsnFrame             = False    ; don't advance frame
     
       res@cnFillOn             = True     ; turn on color fill
       res@cnFillPalette        = "WhViBlGrYeOrRe" ; set color map
       res@cnLinesOn            = False    ; turn of contour lines
       res@cnFillMode           = "RasterFill" ; Raster Mode
       res@cnLinesOn            =  False       ; Turn off contour lines
       res@cnLineLabelsOn       =  False       ; Turn off contour lines
       res@lbLabelBarOn         = False        ; turn off individual cb's
     
       res@mpCenterLonF         = 0.           ; 210.
       res@mpFillOn             = False
      ;res@mpFillDrawOrder      = "PostDraw"
       res@mpPerimOn            = False	     
       res@mpProjection         = "Robinson"       
       res@mpGridAndLimbOn      = True 
       res@mpGridLatSpacingF    =  30        
       res@mpGridLonSpacingF    =  30.      
       res@mpGridLineDashPattern=  11         ; 0 - solid,  1/2/11 - dash    
       res@mpGridLineThicknessF = 0.5

       res@gsnRightString = ""
       res@gsnStringFontHeightF = 0.017

       res@gsnCenterString = "cf_low_day"
       plot(0) = gsn_csm_contour_map(wks,cf_low_day(nt,:,:), res)
       res@gsnCenterString = "cf_mid_day"
       plot(2) = gsn_csm_contour_map(wks,cf_mid_day(nt,:,:), res)
       res@gsnCenterString = "cf_high_day"
       plot(4) = gsn_csm_contour_map(wks,cf_hgh_day(nt,:,:), res)
       res@gsnCenterString = "cf_total_day"
       plot(6) = gsn_csm_contour_map(wks,cf_tot_day(nt,:,:), res)
       res@gsnCenterString = "cf_clear_day"
       plot(8) = gsn_csm_contour_map(wks,cf_clr_day(nt,:,:), res)

       res@gsnCenterString = "cf_low_night"
       plot(1) = gsn_csm_contour_map(wks,cf_low_ngt(nt,:,:), res)
       res@gsnCenterString = "cf_mid_night"
       plot(3) = gsn_csm_contour_map(wks,cf_mid_ngt(nt,:,:), res)
       res@gsnCenterString = "cf_high_night"
       plot(5) = gsn_csm_contour_map(wks,cf_hgh_ngt(nt,:,:), res)
       res@gsnCenterString = "cf_tot_night"
       plot(7) = gsn_csm_contour_map(wks,cf_tot_ngt(nt,:,:), res)
       res@gsnCenterString = "cf_clear_night"
       plot(9) = gsn_csm_contour_map(wks,cf_clr_ngt(nt,:,:), res)


       resP = True
       resP@gsnMaximize         = True                ; make ps/eps/pdf large
     ;;resP@gsnPaperOrientation = "Portrait"          ; force portrait
       resP@gsnPanelLabelBar    = True                ; add common colorbar
       resP@lbLabelFontHeightF  = 0.0175              ; change font size
       resP@txString            = "CALIPSO: Cloud Fraction: "+ pltName+": "+ymd_ngt(nt)
       gsn_panel(wks,plot,(/5,2/),resP)               ; now draw as one plot
  
  end

