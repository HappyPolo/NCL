;***************************************************************
; ssmiv7_2.ncl
;
; Concepts illustrated:
;   - Using functions for cleaner code
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
  return(x)
end

;***************************************************************
; User Input
;***************************************************************
   diri    = "./"                            ; input directory
   fili    = "f17_ssmis_201207v7.nc"         ; netCDF4

   pltDir  = "./"                            ; directory for plot output
   pltType = "png"                           ; ps, png, pdf, x11, eps
;***************************************************************
; Read the desired variables
;***************************************************************

   f       = addfile(diri+fili, "r")

   wnd     = get_var_ssmi(f, "wind_speed")
   awvc    = get_var_ssmi(f, "atmosphere_water_vapor_content")
   aclwc   = get_var_ssmi(f, "atmosphere_cloud_liquid_water_content")
   rr      = get_var_ssmi(f, "rainfall_rate")

   printVarSummary(wnd)
   printVarSummary(awvc)
   printVarSummary(aclwc)
   printVarSummary(rr)

   yyyymm = str_get_cols(f@begin_time, 0, 6)
;************************************************
; Create panel plot 
;************************************************
   fsfx   = get_file_suffix(fili,0)
  ;pltName = fsfx@fBase                    ; plot name output
   pltName = "ssmiv7"  

   wks    = gsn_open_wks(pltType, pltDir+pltName)
   
   plot = new ( 4 , "graphic")
 
   res                      = True     ; plot mods desired
   res@gsnDraw              = False    ; don't draw
   res@gsnFrame             = False    ; don't advance frame
 
   res@cnFillOn             = True     ; turn on color fill
   res@cnFillPalette        = "BlAqGrYeOrReVi200"  ; set color map
   res@cnLinesOn            = False    ; turn of contour lines
   res@cnFillMode           = "RasterFill"         ; Raster Mode
   res@cnLinesOn            =  False       ; Turn off contour lines
   res@cnLineLabelsOn       =  False       ; Turn off contour lines
   res@mpFillOn             = False
   res@mpCenterLonF         = 210   

   resP                     = True
   resP@gsnMaximize         = True                ; make ps/eps/pdf large [no effect x11]
 ;;resP@gsnPaperOrientation = "Portrait"          ; force portrait
   resP@txString            = "Monthly Mean: "+fili
   
   res@gsnCenterString   = yyyymm
   plot(0) = gsn_csm_contour_map(wks,  wnd, res)
   plot(1) = gsn_csm_contour_map(wks, awvc, res)

   res@cnLevelSelectionMode = "ExplicitLevels" 

   res@cnLevels          = fspan(0.05,0.5,19)                   
   plot(2) = gsn_csm_contour_map(wks,aclwc, res)

   delete(res@cnLevels)
   
  ;res@cnLevels          = (/0.1,0.25,0.5,0.75,1.0,1.5,2.0/) 
   res@cnLevels          = fspan(0.05,1.0,20)                   
   plot(3) = gsn_csm_contour_map(wks,   rr, res)
   
   gsn_panel(wks,plot,(/2,2/),resP)               ; now draw as one plot
