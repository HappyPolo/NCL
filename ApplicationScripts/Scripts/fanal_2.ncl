;----------------------------------------------------------------------
; fanal_2.ncl
;
; Concepts illustrated:
;   - Calculating temporal Fourier information of a monthly climatology
;---------------------------------------------------------
; Calculate temporal Fourier information of a monthly climatology
; .  Amplitude, Phase, Percent Variance over the mean annual cycle
;---------------------------------------------------------
;
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"   
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"

  id = "./" 
  in = addfile(id+"ERAI.1989-2005.climo.subset.nc","r")  ; climatology: 1989-2005

  t2 = in->TREFHT                                 ; (time,lat,lon)   
  ts = in->TS                                     ; ( 12 ,121,240)

;****************************************
; Calculate temporal harmonics: reorder so 'time' is right dimension           
;   finfo(0,:,:,nhar) - amplitude of each harmonic
;   finfo(1,:,:,nhar) - phase of each harmonic
;   finfo(2,:,:,nhar) - percent variance explained by each harmonic 
;****************************************
  nhar     = 3                                               ; return 1st 'nhar' harmonics
                                                             ; reorder
  finfo_t2 = fourier_info (t2(lat|:,lon|:,time|:), nhar, 1.) ; fourier_info works on right dim
  finfo_ts = fourier_info (ts(lat|:,lon|:,time|:), nhar, 1.) ; [3] x [121] x [240] x [nhar]

  copy_VarCoords(t2(0,:,:), finfo_t2(0,:,:,0))         ; trick
  finfo_t2@long_name = "Amplitude: TREFHT: 1989-2005"
  finfo_t2@units     = "degK"
  printVarSummary(finfo_t2)

  copy_VarCoords(ts(0,:,:), finfo_ts(0,:,:,0))
  finfo_ts@long_name = "Amplitude: TSKIN: 1989-2005"
  finfo_ts@units     = "degK"
  printVarSummary(finfo_ts)

  diff_amp = finfo_ts(0,:,:,:) - finfo_t2(0,:,:,:)
  diff_amp@long_name = "Amplitude Difference: TSKIN-TREFHT"
  diff_amp@units     = "degK"
  copy_VarCoords(ts(0,:,:), diff_amp(:,:,0))
                                                       ; trick to avoid division by 0.0
  finfo_t2@_FillValue = t2@_FillValue
  finfo_t2(0,:,:,:) = where(finfo_t2(0,:,:,:).eq.0, t2@_FillValue, finfo_t2(0,:,:,:)) 
  finfo_ts@_FillValue = ts@_FillValue
  finfo_ts(0,:,:,:) = where(finfo_ts(0,:,:,:).eq.0, ts@_FillValue, finfo_ts(0,:,:,:)) 

  ratio    = finfo_ts(0,:,:,:)/finfo_t2(0,:,:,:)       ; ratio of harmonics
  copy_VarCoords(finfo_t2(0,:,:,:), ratio)
  ratio@long_name = "ratio: TSKIN/TREFHT: 1989-2005"
  printVarSummary(ratio)

;****************************************
; Create plot
;****************************************
  nharPlt = 1                                               
  plot    = new (3,"graphic") 
 
  pltType = "png"                          ; send graphics to PNG file
  pltName = "fanal"
  wks     = gsn_open_wks(pltType, pltName)    
 
  res                      = True          ; individual plot
  res@gsnDraw              = False
  res@gsnFrame             = False
  res@cnFillOn             = True          ; turn on color
  res@cnFillPalette        = "BlAqGrYeOrReVi200" ; set color map
  res@cnLinesOn            = False         ; turn on line labels
  res@cnLineLabelsOn       = False         ; turn on line labels
  res@lbOrientation        = "vertical"    ; vertical label bar
 
  res@cnLevelSelectionMode = "ManualLevels"; set manual contour levels
  res@cnMinLevelValF       =   2.          ; set min contour level
  res@cnMaxLevelValF       =  30.          ; set max contour level
  res@cnLevelSpacingF      =   2.0         ; set contour spacing
 
  res@gsnLeftString        = "TREFHT: Amplitude Harmonic "+nharPlt
  plot(0) = gsn_csm_contour_map(wks,finfo_t2(0,:,:,nharPlt-1),res)
 
  res@cnMinLevelValF       =  -3.          ; set min contour level
  res@cnMaxLevelValF       =   3.          ; set max contour level
  res@cnLevelSpacingF      =   0.5         ; set contour spacing
 
  res@gsnLeftString        = diff_amp@long_name+": Harmonic "+nharPlt
  plot(1) = gsn_csm_contour_map(wks,diff_amp(:,:,0),res)
 
  res@cnMinLevelValF       =  0.70         
  res@cnMaxLevelValF       =  1.70        
  res@cnLevelSpacingF      =  0.10       
 
  res@gsnLeftString        = "Ratio (TSKIN/TREFHT): Amplitude Harmonic "+nharPlt
  plot(2) = gsn_csm_contour_map(wks,ratio(:,:,nharPlt-1),res)
 
  resP                     = True          ; panel resources
  resP@gsnPaperOrientation = "portrait"
  resP@gsnMaximize         = True
 
  resP@txString            = "ERA-Interim: 1989-2005"
  gsn_panel(wks,plot,(/3,1/),resP)
