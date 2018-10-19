;----------------------------------------------------------------------
; fanal_1.ncl
;
; Concepts illustrated:
;   - Calculating zonal Fourier information of a monthly climatology
;---------------------------------------------------------
; Calculate zonal Fourier information of a monthly climatology           
; .  Amplitude, Phase, Percent Variance at each latitude
;---------------------------------------------------------
;
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"   
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
 
   diri = "./"
   fili = "ERAI.1989-2005.climo.subset.nc"
   f    = addfile(diri+fili,"r")               ; climatology: 1989-2005
   z    = f->Z500                              ; (time,lat,lon)   
   printVarSummary(z)                          ; ( 12 ,121,240)
 
   dimz = dimsizes(z)
   nmos = dimz(0)                              ; 12
   nlat = dimz(1)                              ; 121
   mlon = dimz(2)                              ; 240
 
;****************************************
; Calculate harmonics           
;   finfo(0,:,:,nhar) - amplitude of each harmonic
;   finfo(1,:,:,nhar) - phase of each harmonic
;   finfo(2,:,:,nhar) - percent variance explained by each harmonic 
;****************************************
 
   nhar    = mlon/2                           ; # of harmonics
   finfo_z = fourier_info(z, nhar, 1.)        ; fourier_info works on *right* dim => lon
                                              ; (3,12,121,nhar)
   copy_VarCoords(z(:,:,0), finfo_z(0,:,:,0)) ; trick
   finfo_z!0 = "ftype"
   finfo_z!3 = "harmonic"
 ;;finfo_z@long_name = "Z500: amp, phase, % variance""
   printVarSummary(finfo_z)                   ; [ftype|3]x[time|12]x[lat|121]x[harmonic|120]
 
;****************************************
; Create plot
;****************************************
   month   = (/"Jan","Feb","Mar","Apr","May","Jun"\
              ,"Jul","Aug","Sep","Oct","Nov","Dec"/) 
  
   nharPlt = 2
   nmoPlt  = 2    ; Jan and Jul
   plot    = new (nmoPlt*3,"graphic")
                             
   maxAmp  = max(finfo_z(0,:,:,:))
  
   pltType = "png"                               ; send graphics to PNG file
   pltName = "fanal"
  
   wks     = gsn_open_wks(pltType, pltName)    
  
   res                      = True          ; individual plot
   res@gsnDraw              = False
   res@gsnFrame             = False
   res@xyLineThicknessF     = 2.0
   res@xyLineColors         = (/"blue","red"/)   ; change line colors 
   res@xyDashPattern        = 0                  ; Make curves all solid
  
; add a legend
   res@pmLegendDisplayMode    = "Always"              ; turn on legend
   res@pmLegendSide           = "Top"                 ; Change location of 
   res@pmLegendParallelPosF   = .85                   ; move units right
   res@pmLegendOrthogonalPosF = -0.85                 ; more neg = down
   res@pmLegendWidthF         = 0.13                  ; Change width and
   res@pmLegendHeightF        = 0.075                 ; height of legend.
   res@lgLabelFontHeightF     = .02                   ; change font height
   res@lgPerimOn              = False                 ; no box around
   res@xyExplicitLegendLabels = (/"HAR 1", "HAR 2"/) ; legend labels
  
   np = -1
   do nmo=0,nmos-1,6
  
      np = np+1
      res@gsnLeftString  = "Amplitude Harmonics 1 & 2"
      res@gsnRightString = month(nmo)+": "+z@units
      res@trXMaxF        = maxAmp   
      work               = finfo_z(ftype|0, time|nmo, harmonic|0:1 ,lat|:)  ; reorder
      plot(np)           = gsn_csm_xy(wks,work,z&lat,res)
  
      np = np+1
      res@gsnLeftString  = "Phase Harmonics 1 & 2"
      res@gsnRightString = month(nmo)+": deg"
      res@trXMaxF        = 360.0      
      work               = finfo_z(ftype|1, time|nmo, harmonic|0:1 ,lat|:)  ; reorder
      plot(np)           = gsn_csm_xy(wks,work,z&lat,res)
  
      np = np+1
      res@gsnLeftString  = "% Variances Harmonics 1 & 2"
      res@gsnRightString = month(nmo)+": %"
      res@trXMaxF        = 100.0      
      work               = finfo_z(ftype|2, time|nmo, harmonic|0:1 ,lat|:)  ; reorder
      plot(np)           = gsn_csm_xy(wks,work,z&lat,res)
  
   end do
  
   resP                     = True          ; panel resources
   resP@gsnMaximize         = True
   resP@txString            = "ERA-Interim: 1989-2005: Z500"
   gsn_panel(wks,plot,(/nmoPlt,3/),resP)
