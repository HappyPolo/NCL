;***********************************************************
; Generate conventional EOFs
;***********************************************************
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"  
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"  
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl" 

begin
   neof    =  2

   latS    = -15
   latN    =  15

   ymdStrt = 19950101                         ; start yyyymmdd
   ymdLast = 19991231                         ; last  

   yrStrt  = ymdStrt/10000
   yrLast  = ymdLast/10000

   pltDir  = "./"                             ; plot directory
   pltType = "ps" 
   pltName = "mjoclivar"                      ; yrStrt+"_"+yrLast
  
   diri    = "/Users/shea/Data/AMWG/"         ; input directory   

   filolr  = "olr.day.anomalies.1980-2005.nc"
   filu200 = "uwnd.day.200.anomalies.1980-2005.nc"
   filu850 = "uwnd.day.850.anomalies.1980-2005.nc"

;************************************************
; create BandPass Filter
;************************************************
  ihp      = 2                             ; bpf=>band pass filter
  nWgt     = 201
  sigma    = 1.0                           ; Lanczos sigma
  fca      = 1./100.
  fcb      = 1./20.
  wgt      = filwgts_lanczos (nWgt, ihp, fca, fcb, sigma )

;***********************************************************
; Find the indices corresponding to the start/end times
;***********************************************************
   f       = addfile (diri+filolr , "r")                         
   TIME    = f->time                          ; days since ...
   YMD     = cd_calendar(TIME, -2)            ; entire (time,6)

   iStrt   = ind(YMD.eq.ymdStrt)              ; index start
   iLast   = ind(YMD.eq.ymdLast)              ; index last 
   delete(TIME)
   delete(YMD )

;***********************************************************
; Read anomalies
;***********************************************************
   work    = f->OLR_anom(iStrt:iLast,{latS:latN},:) 
   OLR     = dim_avg_Wrap(work(time|:,lon|:,lat|:))
  ;printVarSummary(OLR)
  ;printMinMax(OLR, True)

   f       = addfile (diri+filu850 , "r")                         
   work    = f->U_anom(iStrt:iLast,{latS:latN},:) 
   U850    = dim_avg_Wrap(work(time|:,lon|:,lat|:))
  ;printVarSummary(U850)
  ;printMinMax(U850, True)

   f       = addfile (diri+filu200 , "r")                         
   work    = f->U_anom(iStrt:iLast,{latS:latN},:) 
   U200    = dim_avg_Wrap(work(time|:,lon|:,lat|:))  ; (time,lon)
  ;printVarSummary(U200)
  ;printMinMax(U200, True)

   dimw    = dimsizes( work )
   ntim    = dimw(0)
   nlat    = dimw(1)
   mlon    = dimw(2)
   delete(work)

   time    = f->time(iStrt:iLast)             ; days since ...
   lon     = f->lon                                           

;************************************************
; Apply the band pass filter to the original anomalies
;************************************************
  olr   = wgt_runave_Wrap ( OLR(lon|:, time|:), wgt, 0)
  u850  = wgt_runave_Wrap (U850(lon|:, time|:), wgt, 0)
  u200  = wgt_runave_Wrap (U200(lon|:, time|:), wgt, 0)

;************************************************
; remove means of band pass series: *not* necessary 
;************************************************
  olr   = dim_rmvmean( olr)                   ; (lon,time)
  u850  = dim_rmvmean(u850)
  u200  = dim_rmvmean(u200)

;************************************************
; Compute the temporal variance
;************************************************
  var_olr  = dim_variance_Wrap( olr)          ; (lon)
  var_u850 = dim_variance_Wrap(u850)
  var_u200 = dim_variance_Wrap(u200)

;************************************************
; Compute the zonal mean of the temporal variance
;************************************************
  zavg_var_olr  = dim_avg_Wrap( var_olr )     
  zavg_var_u850 = dim_avg_Wrap( var_u850)
  zavg_var_u200 = dim_avg_Wrap( var_u200)

;************************************************
; Normalize by sqrt(avg_var*)
;************************************************
  olr   =  olr/sqrt(zavg_var_olr )          ; (lon,time)
  u850  = u850/sqrt(zavg_var_u850)
  u200  = u200/sqrt(zavg_var_u200)

;************************************************
; Compute EOFs
;************************************************
  eof_olr     = eofunc_Wrap(olr    , neof, False)      ; (neof,lon)
  eof_ts_olr  = eofunc_ts_Wrap(olr , eof_olr ,False)   ; (neof,time)
  print("==============")
  printVarSummary(eof_olr )
  printMinMax(eof_olr , True)

  eof_u850    = eofunc_Wrap(u850   , neof, False)      ; (neof,lon)
  eof_ts_u850 = eofunc_ts_Wrap(u850, eof_u850,False)   ; (neof,time)
  print("==============")
  printVarSummary(eof_u850)
  printMinMax(eof_u850, True)

  eof_u200    = eofunc_Wrap(u200   , neof, False)      ; (neof,lon)
  eof_ts_u200 = eofunc_ts_Wrap(u200,eof_u200,False)    ; (neof,time)
  print("==============")
  printVarSummary(eof_u200)
  printMinMax(eof_u200, True)

;************************************************
; Compute cross correlation of each EOF time series at zero-lag
;************************************************
  mxlag     = 25

  rlag_ou8  = esccr(eof_ts_olr , eof_ts_u850, mxlag)          ; (N,mxlag+1)
  rlag_ou2  = esccr(eof_ts_olr , eof_ts_u200, mxlag)          ; (N,mxlag+1)
  rlag_u8u2 = esccr(eof_ts_u850, eof_ts_u200, mxlag)          ; (N,mxlag+1)

  rlag_u8o  = esccr(eof_ts_u850, eof_ts_olr , mxlag)          ; (N,mxlag+1)
  rlag_u2o  = esccr(eof_ts_u200, eof_ts_olr , mxlag)          ; (N,mxlag+1)
  rlag_u2u8 = esccr(eof_ts_u200, eof_ts_u850, mxlag)          ; (N,mxlag+1)

  ccr_ou8   = new ( (/neof,2*mxlag+1/), float)    
  ccr_ou8(:,0:mxlag-1) = rlag_ou8(:,1:mxlag:-1)  ; "negative lag", -1 reverses order
  ccr_ou8(:,mxlag:)    = rlag_u8o(:,0:mxlag)     ; "positive lag"

  ccr_ou2   = new ( (/neof,2*mxlag+1/), float)    
  ccr_ou2(:,0:mxlag-1) = rlag_ou2(:,1:mxlag:-1)  ; "negative lag", -1 reverses order
  ccr_ou2(:,mxlag:)    = rlag_u2o(:,0:mxlag)     ; "positive lag"

  ccr_u8u2  = new ( (/neof,2*mxlag+1/), float)    
  ccr_u8u2(:,0:mxlag-1) = rlag_u2u8(:,1:mxlag:-1); "negative lag", -1 reverses order
  ccr_u8u2(:,mxlag:)    = rlag_u8u2(:,0:mxlag)   ; "positive lag"

  ccr_ou8  = where( ccr_ou8.gt. 1.0, 1.0, ccr_ou8)   
  ccr_ou8  = where( ccr_ou8.lt.-1.0,-1.0, ccr_ou8)     
  ccr_ou2  = where( ccr_ou2.gt. 1.0, 1.0, ccr_ou2)   
  ccr_ou2  = where( ccr_ou2.lt.-1.0,-1.0, ccr_ou2)     
  ccr_u8u2 = where(ccr_u8u2.gt. 1.0, 1.0, ccr_u8u2)   
  ccr_u8u2 = where(ccr_u8u2.lt.-1.0,-1.0, ccr_u8u2)     

;------------------------------------------------------------
; PLOTS
;------------------------------------------------------------

  yyyymmdd = cd_calendar(time, -2)
  yrfrac   = yyyymmdd_to_yyyyfrac(yyyymmdd, 0.0)
  delete(yrfrac@long_name)
  delete(lon@long_name)

  day      = ispan(-mxlag, mxlag, 1)
 ;day@long_name = "lag (day)"

  if (pltType.eq."png") then
      pltTypeLocal = "eps"
  else
      pltTypeLocal = pltType
  end if

  pltPath = pltDir+pltName

  wks = gsn_open_wks(pltTypeLocal,pltPath)
  plot = new(3,graphic)                ; create graphic array
                                          ; only needed if paneling
  rts           = True
  rts@gsnDraw   = False       ; don't draw yet
  rts@gsnFrame  = False       ; don't advance frame yet
  rts@gsnScale  = True        ; force text scaling               

  rts@vpHeightF = 0.40        ; Changes the aspect ratio
  rts@vpWidthF  = 0.85
  rts@vpXF      = 0.10        ; change start locations
  rts@vpYF      = 0.75        ; the plot
  rts@xyLineThicknesses = (/2, 2, 2/)
  rts@gsnYRefLine            = 0.                  ; reference line   
  rts@gsnXRefLine            = 0.                  ; reference line   

  rts@pmLegendDisplayMode    = "Always"            ; turn on legend
  rts@pmLegendSide           = "Top"               ; Change location of 
  rts@pmLegendParallelPosF   = 0.86                ; move units right
  rts@pmLegendOrthogonalPosF = -0.50               ; move units down
  rts@pmLegendWidthF         = 0.15                ; Change width and
  rts@pmLegendHeightF        = 0.15                ; height of legend.
  rts@lgLabelFontHeightF     = 0.0175

  rtsP                       = True                ; modify the panel plot
  rtsP@gsnMaximize           = True                ; large format

  z_eof = new ( (/3,mlon/), typeof(olr), getFillValue(olr) )
  z_ts  = new ( (/3,ntim/), typeof(olr), getFillValue(olr) )

;------------------------------------------------------------
; EOF spatial patterns   [neof,time]
;------------------------------------------------------------
  rtsP@txString              = "Univariate EOF: 15S-15N: "+yrStrt+"-"+yrLast 
  
  do n=0,neof-1
    z_eof(0,:)  = eof_olr (n,:)
    z_eof(1,:)  = eof_u850(n,:)
    z_eof(2,:)  = eof_u200(n,:)
    delete(z_eof@long_name)
    rts@xyExplicitLegendLabels = \ 
       (/"OLR:"+sprintf("%5.1f", eof_olr@pcvar(n))  +"%" \
        ,"U850:"+sprintf("%5.1f",eof_u850@pcvar(n)) +"%" \
        ,"U200:"+sprintf("%5.1f",eof_u200@pcvar(n)) +"%" /) 
  
    rts@gsnLeftString  = "EOF "+(n+1)
    plot(n) = gsn_csm_xy (wks,lon,z_eof,rts)
  end do
  gsn_panel(wks,plot(0:1),(/2,1/),rtsP)     ; now draw as one plot

  delete(rts@xyExplicitLegendLabels) 

;------------------------------------------------------------
; EOF time series   [neof,time]
;------------------------------------------------------------
;;do n=0,neof-1
;;  z_ts(0,:)   = eof_ts_olr (n,:)
;;  z_ts(1,:)   = eof_ts_u850(n,:)
;;  z_ts(2,:)   = eof_ts_u200(n,:)
;;  delete(z_ts@long_name)
;;
;;  rts@gsnLeftString  = "EOF "+(n+1)
;;  rts@gsnRightString = "r(o,u8)=" +sprintf("%3.2f",r_olr_u850(n))+", " \
;;                     + "r(o,u2)=" +sprintf("%3.2f",r_olr_u200(n))+", " \
;;                     + "r(u8,u2)="+sprintf("%3.2f",r_u850_u200(n)      ) 
;;  plot(n) = gsn_csm_xy (wks,yrfrac,z_ts,rts)
;;end do
;;gsn_panel(wks,plot(n),(/1,1/),rtsP)     ; now draw as one plot

;------------------------------------------------------------
; plot croos correlations   [neof,time]
;------------------------------------------------------------
 ;rts@tiYAxisString    = "lag(r)"
  rts@xyExplicitLegendLabels = (/ "EOF 1", "EOF 2"/) 
  rts@pmLegendOrthogonalPosF = -1.135              ; move units down
  rts@pmLegendParallelPosF   =  0.095              ; move units right
  rts@pmLegendWidthF         =  0.15               ; Change width and
  rts@pmLegendHeightF        =  0.10               ; height of legend.

  delete(rts@gsnLeftString)
  rts@gsnCenterString = "r(OLR,U850)"
  plot(0) = gsn_csm_xy (wks,day,ccr_ou8 ,rts)
  rts@gsnCenterString = "r(OLR,U200)"
  plot(1) = gsn_csm_xy (wks,day,ccr_ou2 ,rts)
  rts@gsnCenterString = "r(U850,U200)"
  plot(2) = gsn_csm_xy (wks,day,ccr_u8u2,rts)
  rtsP@txString = "Lag(r): Univariate EOF: 15S-15N: "+yrStrt+"-"+yrLast 
  gsn_panel(wks,plot,(/3,1/),rtsP)     ; now draw as one plot
  
   if (pltType.eq."png") then
       if (.not.isvar("pltConvert")) then
           pltConvert = " "               ; default
       end if
       system("convert "+pltConvert+" "+pltPath+".eps "+pltPath+".png")
       system("convert "+pltConvert+" "+pltPath+".eps "+pltPath+".png")
       system("/bin/rm -f "+pltPath+".eps")
   end if

end
