;***********************************************************
; Generate conventional EOFs using 20-100 day filtered data
;***********************************************************
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"  
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"  
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl" 

begin
   neof    =  3

   latS    = -30
   latN    =  30

   ymdStrt = 19950101                         ; start yyyymmdd
   ymdLast = 19991231                         ; last  

   yrStrt  = ymdStrt/10000
   yrLast  = ymdLast/10000

   pltDir  = "./"                             ; plot directory
   pltType = "ps"
   pltName = "mjoclivar"                      ; yrStrt+"_"+yrLast
  
   diri    = "/Users/shea/Data/AMWG/"         ; input directory   

  ;fili    = "olr.day.anomalies.1980-2005.nc"
  ;vName   = "OLR_anom"

   plev    = 850                              ; 850 or 200 hPa
   fili    = "uwnd.day."+plev+".anomalies.1980-2005.nc"
   vName   = "U_anom"

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
; Find the indicies (subscripts) corresponding to the start/end times
;***********************************************************

   f       = addfile (diri+fili , "r")                         
   TIME    = f->time                          ; days since ...
   YMD     = cd_calendar(TIME, -2)            ; entire (time,6)

   iStrt   = ind(YMD.eq.ymdStrt)              ; index start
   iLast   = ind(YMD.eq.ymdLast)              ; index last 
   delete(TIME)
   delete(YMD )

;***********************************************************
; Read anomalies
;***********************************************************
   X       = f->$vName$(iStrt:iLast,{latS:latN},:) ; U_anom_sm
   printVarSummary(X)
   printMinMax(X, True)

   time    = f->time(iStrt:iLast)             ; days since ...

   dimX    = dimsizes( X )
   ntim    = dimX(0)
   nlat    = dimX(1)
   mlon    = dimX(2)

;************************************************
; Apply the band pass filter to the original anomalies
;************************************************
  x   = wgt_runave_Wrap (X(lat|:, lon|:, time|:), wgt, 0)

;************************************************
; remove means of band pass series: *not* necessary 
;************************************************
  x   =dim_rmvmean( x )

;************************************************
; Compute EOFs; no need to areal weight (15S to 15N)
;************************************************

  eof    = eofunc_Wrap(x, neof, False)
  eof_ts = eofunc_ts_Wrap(x,eof,False)

  printVarSummary( eof )
  printVarSummary( eof_ts )

;------------------------------------------------------------
; PLOTS
;------------------------------------------------------------
  if (pltType.eq."png") then
      pltTypeLocal = "eps"
  else
      pltTypeLocal = pltType
  end if

  pltPath = pltDir+pltName

  wks = gsn_open_wks(pltTypeLocal,pltPath)
  gsn_define_colormap(wks,"BlwhRe") 
  plot = new(neof,graphic)                ; create graphic array
                                          ; only needed if paneling
; EOF patterns

  res                      = True         
  res@gsnDraw              = False        ; don't draw yet
  res@gsnFrame             = False        ; don't advance frame yet
  res@gsnSpreadColors      = True         ; spread out color table
  res@gsnStringFontHeightF = 0.015         ; make larger than default
 
  res@mpFillOn             = False        ; turn off map fill
  res@mpMinLatF            = latS         ; zoom in on map
  res@mpMaxLatF            = latN
  res@mpCenterLonF         = 180.
  res@cnFillOn             = True         ; turn on color fill
  res@cnLinesOn            = False        ; True is default
  res@cnLineLabelsOn       = False        ; True is default
  res@lbLabelBarOn         = False        ; turn off individual lb's
                                          ; set symmetric plot min/max
  symMinMaxPlt(eof,  8, False, res)       ; contributed.ncl

; panel plot only resources
  resP                     = True         ; modify the panel plot
  resP@gsnMaximize         = True         ; large format
  resP@gsnPanelLabelBar    = True         ; add common colorbar
  resP@lbLabelAutoStride   = True         ; auto stride on labels
  resP@lbLabelFontHeightF  = 0.01

  txString            = vName+": "+yrStrt+"-"+yrLast
  if (isvar("plev")) then
      txString = txString+": "+plev+" hPa"
  end if

;*******************************************
; first plot
;*******************************************
  do n=0,neof-1
     res@gsnLeftString   = "EOF "+(n+1)
     if (n.eq.0) then
         res@gsnCenterString = txString
     else
         res@gsnCenterString = ""
     end if
     res@gsnRightString  = sprintf("%5.1f", eof@pcvar(n)) +"%"
     plot(n)=gsn_csm_contour_map_ce(wks,eof(n,:,:),res)
  end do
  gsn_panel(wks,plot,(/neof,1/),resP)     ; now draw as one plot

;*******************************************
; second plot
;*******************************************
  rts           = True
  rts@gsnDraw   = False       ; don't draw yet
  rts@gsnFrame  = False       ; don't advance frame yet
  rts@gsnScale  = True        ; force text scaling               

; these four resources allow the user to stretch the plot size, and
; decide exactly where on the page to draw it.

  rts@vpHeightF = 0.40        ; Changes the aspect ratio
  rts@vpWidthF  = 0.85
  rts@vpXF      = 0.10        ; change start locations
  rts@vpYF      = 0.75        ; the plot

  rts@gsnYRefLine           = 0.              ; reference line   
 ;rts@gsnXYBarChart         = True            ; create bar chart 
  rts@gsnAboveYRefLineColor = "red"           ; above ref line fill red
  rts@gsnBelowYRefLineColor = "blue"          ; below ref line fill blue

; panel plot only resources
  rtsP                     = True             ; modify the panel plot
  rtsP@gsnMaximize         = True             ; large format
  rtsP@txString            = txString

; create individual plots

  yyyymmdd= cd_calendar(time, -2)
  yrfrac  = yyyymmdd_to_yyyyfrac(yyyymmdd, 0.0)
  delete(yrfrac@long_name)

  nGrd    = nlat*mlon 
  eof_ts  = eof_ts/nGrd
  rts@tiYAxisString = x@units  

  do n=0,neof-1
     rts@gsnLeftString  = "EOF "+(n+1)
     rts@gsnRightString = sprintf("%5.1f", eof@pcvar(n)) +"%"
     work = wgt_runave_Wrap(eof_ts(n,:),121, 1)
     plot(n) = gsn_csm_xy (wks,yrfrac,   work    ,rts)
    ;plot(n) = gsn_csm_xy (wks,yrfrac,eof_ts(n,:),rts)
  end do
  gsn_panel(wks,plot,(/neof,1/),rtsP)     ; now draw as one plot

   if (pltType.eq."png") then
       if (.not.isvar("pltConvert")) then
           pltConvert = " "               ; default
       end if
       system("convert "+pltConvert+" "+pltPath+".eps "+pltPath+".png")
       system("convert "+pltConvert+" "+pltPath+".eps "+pltPath+".png")
       system("/bin/rm -f "+pltPath+".eps")
   end if

end
