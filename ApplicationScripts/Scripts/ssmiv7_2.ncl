;***************************************************************
; ssmiv7_1.ncl
;
; Concepts illustrated:
;   - Using functions for cleaner code
;   - Using dim_avg_n, conform, ismissing
;     
;*********** Load Libraries ************************************
;
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl" 
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl" 
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl" 
;**************************************************************

undef("get_var_ssmi")
function get_var_ssmi(f[1]:file,var[1]:string)
; local utility function for cleaner code
local xs, x, ymdh
begin
  xs = f->$var$
  xs = where(xs.ge.toshort(251), toshort(255), xs)
  xs@_FillValue = toshort(255)               ; CF conforming
  
  x  = short2flt(xs)

  delete(x&time)                             ; delete type dhort
  ymdh   = cd_calendar(xs&time, -3)          ; yyyymmddhh
  x&time = ymdh

  return(x)
end

;***************************************************************
; User Input
;***************************************************************
   diri    = "./"                            ; input directory
   fili    = "f15_ssmi_20111231v7.nc"        ; netCDF4

   pltDir  = "./"                            ; directory for plot output
   pltType = "png"                           ; ps, png, pdf, x11, eps
;***************************************************************
; Read the desired variables
;***************************************************************

   f       = addfile(diri+fili, "r")

   ymdh    = cd_calendar(f->time, -3)

   wnd     = get_var_ssmi(f, "wind_speed")
   awvc    = get_var_ssmi(f, "atmosphere_water_vapor_content")
   aclwc   = get_var_ssmi(f, "atmosphere_cloud_liquid_water_content")
   rr      = get_var_ssmi(f, "rainfall_rate")

   printVarSummary(wnd)
   printVarSummary(awvc)
   printVarSummary(aclwc)
   printVarSummary(rr)

   dimv    = dimsizes(wnd)
   ntim    = dimv(0)

;************************************************
; Average the ascending and descending
; Here 2 overlapping obs average, else just use one obs
;************************************************
   
   wndAvg   = dim_avg_n_Wrap(wnd, 0)
   awvcAvg  = dim_avg_n_Wrap(awvc, 0)
   aclwcAvg = dim_avg_n_Wrap(aclwc, 0)
   rrAvg    = dim_avg_n_Wrap(rr, 0)

   printVarSummary(rrAvg)
   printVarSummary(wndAvg)
   printVarSummary(awvcAvg)
   printVarSummary(aclwcAvg)

;************************************************
; Locations where there are overlapping observations
;************************************************

   WND   = wnd
   AWVC  = awvc
   ACLWC = aclwc
   RR    = rr

   WNDX  = conform(WND  ,ismissing(WND(0,:,:))  .or. ismissing(WND(1,:,:))  , (/1,2/)   )
   AWVCX = conform(AWVC ,ismissing(AWVC(0,:,:)) .or. ismissing(AWVC(1,:,:)) , (/1,2/)   )
   ACLWCX= conform(ACLWC,ismissing(ACLWC(0,:,:)).or. ismissing(ACLWC(1,:,:)), (/1,2/) )
   RRX   = conform(RR   ,ismissing( RR(0,:,:))  .or. ismissing( RR(1,:,:))  , (/1,2/)   )

   WND   = where(WNDX  ,  WND@_FillValue  , WND  )
   AWVC  = where(AWVCX ,  AWVC@_FillValue , AWVC )
   ACLWC = where(ACLWCX,  ACLWC@_FillValue, ACLWC)
   RR    = where(RRX   ,  RR@_FillValue   , RR   )

   WNDAvg   = dim_avg_n_Wrap(WND  , 0)
   AWVCAvg  = dim_avg_n_Wrap(AWVC , 0)
   ACLWCAvg = dim_avg_n_Wrap(ACLWC, 0)
   RRAvg    = dim_avg_n_Wrap(RR   , 0)

;************************************************
; Create panel plot 
;************************************************
   fsfx   = get_file_suffix(fili,0)
  ;pltName = fsfx@fBase                    ; netCDF name output
   pltName = "ssmiv7"

   wks    = gsn_open_wks(pltType, pltDir+pltName)
   
   plot = new ( 4 , "graphic")
 
   res                      = True     ; plot mods desired
   res@gsnDraw              = False    ; don't draw
   res@gsnFrame             = False    ; don't advance frame
 
   res@cnFillOn             = True     ; turn on color fill
   res@cnFillPalette        = "amwg"   ; set color map
   res@cnLinesOn            = False    ; turn of contour lines
   res@cnFillMode           = "RasterFill"         ; Raster Mode
   res@cnLinesOn            =  False       ; Turn off contour lines
   res@cnLineLabelsOn       =  False       ; Turn off contour lines
   res@mpFillOn             = False

   resP                     = True
   resP@gsnMaximize         = True                ; make ps/eps/pdf large [no effect x11]
 ;;resP@gsnPaperOrientation = "Portrait"          ; force portrait
   resP@txString            = fili
   
   do nt=0,ntim-1
      res@gsnCenterString   = ymdh(nt)
      plot(0) = gsn_csm_contour_map(wks,  wnd(nt,:,:), res)
      plot(1) = gsn_csm_contour_map(wks, awvc(nt,:,:), res)
      plot(2) = gsn_csm_contour_map(wks,aclwc(nt,:,:), res)
      plot(3) = gsn_csm_contour_map(wks,   rr(nt,:,:), res)
   
      gsn_panel(wks,plot,(/2,2/),resP)               ; now draw as one plot
   end do

   delete(res@gsnCenterString)

   res@gsnCenterString   = ymdh(0)/100 +": Average"
   plot(0) = gsn_csm_contour_map(wks,  wndAvg, res)
   plot(1) = gsn_csm_contour_map(wks, awvcAvg, res)
   plot(2) = gsn_csm_contour_map(wks,aclwcAvg, res)
   plot(3) = gsn_csm_contour_map(wks,   rrAvg, res)
   
   gsn_panel(wks,plot,(/2,2/),resP)               ; now draw as one plot

   plot(0) = gsn_csm_contour_map(wks,  WNDAvg, res)
   plot(1) = gsn_csm_contour_map(wks, AWVCAvg, res)
   plot(2) = gsn_csm_contour_map(wks,ACLWCAvg, res)
   plot(3) = gsn_csm_contour_map(wks,   RRAvg, res)
   
   gsn_panel(wks,plot,(/2,2/),resP)               ; now draw as one plot
