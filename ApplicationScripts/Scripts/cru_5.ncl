;*****************************************************
; cru_5.ncl
;
; Concepts illustrated:
;   - Plotting Hadley Center's land/sea variance-adjusted anomalies
;   - Paneling six plots on a page with a common labelbar
;   - Redefining the time coordinate array of a variable
;   - Drawing raster contours
;
;*****************************************************
;
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"  
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"  
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"

;***************************************************
; Specify user desired yyyymm to be plotted
;***************************************************
  yyyymm = (/187101,187107,195001,195007,200001,200007/)

;***************************************************
; Read temperature anomalies
; data are stored as type "short" ... convert to float
;***************************************************
  fili   = "hadcrut4_median.nc"
  f      = addfile(fili,"r")
  T      = f->temperature_anomaly

;***************************************
; For demo purposes: create a companion TIME array 
; Use this to replace the ; current time coordinate variable
; then use this to access specific months
;***************************************  

  TIME   = cd_calendar(T&time, -1)           ; YYYYMM
  T&time = TIME   

;***************************************
; create plot
;***************************************  
  wks = gsn_open_wks("png","cru")            ; send graphics to PNG file

  plot= new (dimsizes(yyyymm), graphic)      ; create graphical array
  
  res                      = True            ; plot mods desired
  res@gsnDraw              = False           ; don't draw yet 
  res@gsnFrame             = False           ; don't advance frame yet 

  res@cnFillOn             = True            ; color contours
  res@cnFillPalette        = "gui_default"
  res@cnLinesOn            = False           ; turn off contour lines
  res@cnFillMode           = "RasterFill"    ; Raster Mode
  res@cnLevelSelectionMode = "ManualLevels"  ; set manual contour levels
  res@cnMinLevelValF       = -7.0            ; set min contour level
  res@cnMaxLevelValF       =  7.0            ; set max contour level
  res@cnLevelSpacingF      =  1.0            ; set contour spacing

  res@lbLabelBarOn         = False           ; turn off individual lb's

  res@gsnLeftString   = "Temp Anomaly"                
  do nt=0,dimsizes(yyyymm)-1
     res@gsnCenterString = yyyymm(nt)
     plot(nt) = gsn_csm_contour_map_ce(wks,T({yyyymm(nt)},:,:),res)
  end do
;************************************************
; create panel plot
;************************************************
  resP                  = True               ; modify the panel plot
  resP@txString         = fili
  resP@gsnPanelLabelBar = True               ; add common label bar
  resP@gsnMaximize      = True               ; make ps, eps, pdf large
  gsn_panel(wks,plot,(/3,2/),resP)           ; now draw as one plot
