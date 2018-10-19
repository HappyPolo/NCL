;----------------------------------------------------------------------
; indices_soi_2.ncl
;
; Concepts illustrated:
;   - Computing correlations between SOI and various gridded variables
;   - Drawing a time series plot
;----------------------------------------------------------------------
; SOI description: See example indices_soi_1.ncl
;
; Read MSLP and air temperatures from 20th Century Reanalysis
; Read precipitation from GPCP
;
; [1] Compute SOI using grid points closest to Tahiti & Darwin
; [2] Compute correlation between SOI and global MSLP, AIR and PRC
;---------------------------------------------------------------------------
;
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl" 
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl" 
;---------------------------------------------------------------------------
;                         User input
;---------------------------------------------------------------------------
  dir20   = "./"
  filslp  = "prmsl.mon.mean.nc"
  filtmp  = "air.sig995.mon.mean.nc"
 
  dirprc  = "./"
  filprc  = "V22_GPCP.1979-2010.nc"

  yrStrt  = 1950          ; manually specify for convenience
  yrLast  = 2010          ; 20th century ends 2010  

  clStrt  = 1950          ; reference climatology for SOI
  clLast  = 1979          

  yrStrtP = 1979          ; 1st year GPCP
  yrLastP = yrLast        ; match 20th century

  latT    = -17.6         ; Tahiti
  lonT    = 210.75  
  latD    = -12.5         ; Darwin 
  lonD    = 130.83  

  PLOT    = True
  pltType = "png"         ; send graphics to PNG file
  pltDir  = "./"          ; dir to which plots are sent
 ;pltName = "SOI."+yrStrt+"-"+yrLast
  pltName = "indices_soi"

  pltTitle= "SOI (20th Century): "  +yrStrt+"-"+yrLast

;-------------------- End User Input ---------------------------------------

  nmos   = 12
  nyrs   = yrLast-yrStrt+1

  fslp   = addfile(dir20 +filslp , "r")
  ftmp   = addfile(dir20 +filtmp , "r")
  fprc   = addfile(dirprc+filprc , "r")

  TIME   = fslp->time
  YYYYMM = cd_calendar(TIME, -1)
  tStrt  = ind(YYYYMM .eq. (yrStrt*100 +  1))       ; indices 20th century
  tLast  = ind(YYYYMM .eq. (yrLast*100 + 12))       ; relative to entire dataset

  yyyymm = YYYYMM(tStrt:tLast)
  tStrtP = ind(yyyymm .eq. (yrStrtP*100+  1))       ; relative to yrStrt, yrLast
  tLastP = ind(yyyymm .eq. (yrLastP*100+ 12))

  T      = short2flt(fslp->prmsl(tStrt:tLast,{latT},{lonT}))
  D      = short2flt(fslp->prmsl(tStrt:tLast,{latD},{lonD}))

  T&time = yyyymm                                   ; convenience
  D&time = yyyymm

  tClmStrt = ind(yyyymm.eq.(clStrt*100 +  1))       ; index for clStrt     
  tClmLast = ind(yyyymm.eq.(clLast*100 + 12))       ; index for clStrt     

  TClm   = new ( nmos, typeof(T), T@_FillValue)     ; monthly climatologies
  DClm   = new ( nmos, typeof(D), D@_FillValue)

  do nmo=0,nmos-1                                   ; reference clm for each month
     TClm(nmo) = avg(T(tClmStrt+nmo:tClmLast:nmos))
     DClm(nmo) = avg(D(tClmStrt+nmo:tClmLast:nmos))
  end do

  TAnom    = T
  DAnom    = D
  do nmo=0,nmos-1                                   ; anomalies reference clim
     TAnom(nmo::nmos) = T(nmo::nmos) - TClm(nmo)
     DAnom(nmo::nmos) = D(nmo::nmos) - DClm(nmo)
  end do

;;TAnomStd   = stddev(TAnom)                        ; overall stddev of anomalies
;;DAnomStd   = stddev(DAnom)
  TAnomStd   = stddev(TAnom(tClmStrt:tClmLast))     ; stddev of anomalies over clStrt & clLast
  DAnomStd   = stddev(DAnom(tClmStrt:tClmLast))
                                                    ; signal and noise
  soi_signal = (TAnom/TAnomStd) - (DAnom/DAnomStd)  ; (ntim)
  copy_VarCoords(TAnom, soi_signal)
  soi_signal@long_name = "SOI: 20th Century Reanalysis: "+yrStrt+"-"+yrLast
  printVarSummary(soi_signal)

;*********************************
; lag-0 correlation      
;*********************************

  slp   = short2flt(fslp->prmsl(tStrt:tLast,:,:))
  rslp  = escorc(soi_signal,slp(lat|:,lon|:,time|:))
  copy_VarCoords(slp(0,:,:), rslp)
  rslp@long_name = "Correlation: SOI-SLP: "+yrStrt+"-"+yrLast
;;printVarSummary(rslp)

  tmp   = short2flt(ftmp->air(tStrt:tLast,:,:))
  rtmp  = escorc(soi_signal,tmp(lat|:,lon|:,time|:))
  copy_VarCoords(slp(0,:,:), rtmp)
  rtmp@long_name = "Correlation: SOI-TMP: "+yrStrt+"-"+yrLast
;;printVarSummary(rtmp)

  YYYYMMP = (fprc->date)/100                       ; entire GPCP 
  pStrtP  = ind(YYYYMMP.eq.(yrStrtP*100 +  1))
  pLastP  = ind(YYYYMMP.eq.(yrLastP*100 + 12))

  prc   = fprc->PREC
  rprc  = escorc(soi_signal(tStrtP:tLastP),prc(lat|:,lon|:,time|pStrtP:pLastP))
  copy_VarCoords(prc(0,:,:), rprc)
  rprc@long_name = "Correlation: SOI-GPCP: "+yrStrtP+"-"+yrLastP
;;printVarSummary(rprc)

;*********************************
; 11-point smoother: Use reflective boundaries to fill out plot  
;*********************************

  kopt = 1                                        ; reflective 
  wgt  = (/ 0.0270, 0.05856, 0.09030, 0.11742, 0.13567, \
            0.1421, 0.13567, 0.11742, 0.09030, 0.05856, 0.027 /)
  soi_signal_smth11 = wgt_runave_Wrap (soi_signal,wgt,kopt) 
  printVarSummary(soi_signal_smth11)

;*********************************
; plot figures
;*********************************
if (PLOT) then
  yrfrac = yyyymm_to_yyyyfrac(yyyymm, 0.0)         ; yrfrac(*)

  plot   = new (3, "graphic")

  wks = gsn_open_wks(pltType, pltDir+pltName)     

  resxy                  = True           ; x-y resxyources       
  resxy@gsnYRefLine      = 0.0            ; create a reference line 
  resxy@gsnAboveYRefLineColor = "blue"    ; above ref line fill red
  resxy@gsnBelowYRefLineColor = "red"     ; below ref line fill blue

  resxy@vpHeightF        = 0.4            ; change aspect ratio of plot
  resxy@vpWidthF         = 0.8            
  resxy@vpXF             = 0.1            ; start plot at x ndc coord 
  
  resxy@trYMinF          = -4.0           ; min value on y-axis
  resxy@trYMaxF          =  4.0           ; max value on y-axis
  resxy@xyLineThicknessF =  2.0 
  
  resxy@tiYAxisString    = "SOI: smooth"        ; y-axis label      
  resxy@tiMainString     = pltTitle                            
  pltxy = gsn_csm_xy (wks,yrfrac,soi_signal_smth11,resxy)

  rescn = True
  rescn@gsnDraw              = False
  rescn@gsnFrame             = False
  rescn@cnFillOn             = True     ; turn on color fill
  rescn@cnFillPalette        = "BlWhRe" ; set color map
  rescn@cnLinesOn            = False    ; turn of contour lines
  rescn@cnLineLabelsOn       = False    ; turn of contour line labels
  rescn@cnLevelSelectionMode = "ManualLevels"     ; set manual contour levels
  rescn@cnMinLevelValF       = -0.9               ; set min contour level
  rescn@cnMaxLevelValF       =  0.9               ; set max contour level
  rescn@cnLevelSpacingF      =  0.1               ; set contour spacing
  rescn@lbLabelBarOn         = False              ; turn off individual cb's
  rescn@mpCenterLonF         = 180.
  rescn@mpFillOn             = False              ; do not grey fill land

  rescn@mpProjection         = "Robinson"
  rescn@mpPerimOn            = False     
  rescn@mpGridAndLimbOn      = True 
  rescn@mpGridLatSpacingF    =  90                ; change latitude  line spacing
  rescn@mpGridLonSpacingF    = 360.               ; change longitude line spacing
 ;rescn@mpGridLineColor      = "transparent"      ; trick ncl into drawing perimeter
  rescn@mpGridAndLimbOn      = True               ; turn on lat/lon lines

                                                  ; eliminate really small values
  rslp    = where(abs(rslp).lt.0.10, rslp@_FillValue, rslp)
  rtmp    = where(abs(rtmp).lt.0.10, rtmp@_FillValue, rtmp)
  rprc    = where(abs(rprc).lt.0.10, rprc@_FillValue, rprc)

  rescn@gsnRightString = "20th Century Reanalysis"
  plot(0) = gsn_csm_contour_map(wks,rslp, rescn)  ; create plot 
  plot(1) = gsn_csm_contour_map(wks,rtmp, rescn)  ; create plot 

  rescn@gsnRightString = "GPCP: "+filprc
  plot(2) = gsn_csm_contour_map(wks,rprc, rescn)  ; create plot 

  resP                     = True                ; modify the panel plot
  resP@txString            = "SOI Correlation: lag=0"
  resP@gsnPanelLabelBar    = True                ; add common colorbar
  resP@gsnMaximize         = True                ; add common colorbar
  gsn_panel(wks,plot,(/3,1/),resP)               ; now draw as one plot
end if
