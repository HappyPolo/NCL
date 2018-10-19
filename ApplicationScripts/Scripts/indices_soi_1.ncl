;----------------------------------------------------------------------
; indices_soi_1.ncl
;
; Concepts illustrated:
;   - Computing the Southern Oscillation Index signal and noise values
;   - Drawing a time series plot
;----------------------------------------------------------------------
; The Southern Oscillation Index (SOI) presented below is computed using 
; monthly mean sea level pressure anomalies at Tahiti (T) and Darwin (D). 
; The SOI [T-D] is an optimal index that combines the Southern Oscillation 
; into one series. The SOI noise [T+D] series is a measure of small scale 
; and/or transient phenomena that are not part of the large scale Southern 
; Oscillation. These SOI values are similar to those calculated by the 
; Climate Prediction Center in that they have been derived using normalization 
; factors derived from monthly values.
; 
; The SOI values prior to 1935 should be used with caution. There are 
; questions regarding the consistency and quality of the Tahiti pressure 
; values prior ; to 1935.
; 
; The smoothed curves were created using a filter which effectively removes 
; fluctuations with periods of less than 8 months but includes all others. 
; At 24 months 80% of the variance is retained. 
; 
; As noted above, the SOI presented here are derived using monthly values as 
; was done in Trenberth (MWR, 1984). However, Trenberth notes that better 
; signal-to-noise ratios may be obtained by using normalization factors 
; based upon overall standard deviation of the anomalies. 
;
; Trenberth (1984), "Signal versus Noise in the Southern Oscillation" 
; Monthly Weather Review 112:326-332
;---------------------------------------------------------------------------
; Data may be downloaded fom: http://www.cgd.ucar.edu/cas/catalog/climind/soi.html
;
; All values have had 1000 subtracted; input arrays are of the form:
;  1866   7.2   6.3   8.3   9.7  10.7  13.1  13.1  13.0  11.8  10.6   8.7   7.8
;  1867   7.4   6.4   8.7   9.7  10.7  12.4  12.8  12.4  11.3   9.6  10.5   7.9
;   ::
;  2011   5.1   5.0   6.3   8.9  12.0  13.5  13.2  13.6  12.6  10.3   8.6   5.0
;  2012   6.0   7.2   6.3  10.7  11.3  13.3 -99.9 -99.9 -99.9 -99.9 -99.9 -99.9
;---------------------------------------------------------------------------
;
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl" 
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl" 
;---------------------------------------------------------------------------
;                         User input
;---------------------------------------------------------------------------
  diri    = "./"
  filt    = "tahiti.ascii"
  fild    = "darwin.ascii"

  yrStrt  = 1866          ; manually specify for convenience
  yrLast  = 2012       

  clStrt  = 1951          ; climatology start 
  clLast  = 1980          ;             last

  PLOT    = True
  pltType = "png"         ; send graphics to PNG file
  pltDir  = "./"        ; dir to which plots are sent
 ;pltName = "SOI."+yrStrt+"-"+yrLast
  pltName = "indices_soi"

  pltTitle= "SOI (station): "  +yrStrt+"-"+yrLast+ ": Base "+clStrt+"-"+clLast

  netCDF  = True
   

;-------------------- End User Input ---------------------------------------

  nmos   = 12
  ncol   = nmos+1
  nyrs   = yrLast-yrStrt+1

;*********************************
; Read years and data as 2D array; simple error checking 
;*********************************

  arrayT = asciiread(diri+filt, (/nyrs,ncol/), "float")  
  arrayD = asciiread(diri+fild, (/nyrs,ncol/), "float")

  arrayT@_FillValue = -99.9                         ; manually assign
  arrayD@_FillValue = -99.9
  
  yearT  = arrayT(:,0)                              ; years are 1st (0-th) col
  yearD  = arrayD(:,0)
  if (.not.all(yearT.eq.yearD)) then
      print("data arrays must have the same years")
      exit
  end if

  if (yrStrt.ne.yearT(0) .or. yrLast.ne.yearT(nyrs-1)) then
      print("user specified start and last year do not match those on the files")
      exit
  end if

  T      = arrayT(:,1:)                             ; T(:,:) => (nyrs,nmos)
  D      = arrayD(:,1:)                             ; T(:,:) => (nyrs,nmos)

;*********************************
; Climatology and anomalies from base climatology   
;*********************************

  iClmStrt = ind(yearT.eq.clStrt)                   ; index for clStrt     
  iClmLast = ind(yearT.eq.clLast)                   ;           clLast

  TClm     = new ( nmos, typeof(T), T@_FillValue)   ; Array for monthly climatologies
  DClm     = new ( nmos, typeof(D), D@_FillValue)
  
  do nmo=0,nmos-1                                   ; reference clm for each month
     TClm(nmo) = avg(T(iClmStrt:iClmLast,nmo))
     DClm(nmo) = avg(D(iClmStrt:iClmLast,nmo))
  end do

  TAnom    = T
  DAnom    = D
  do nmo=0,nmos-1                                   ; anomalies from reference climatology
     TAnom(:,nmo) = T(:,nmo) - TClm(nmo)
     DAnom(:,nmo) = D(:,nmo) - DClm(nmo)
  end do

;;TAnomStd = stddev(TAnom)                          ; overall stddev of anomalies
;;DAnomStd = stddev(DAnom)
  TAnomStd = stddev(TAnom(iClmStrt:iClmLast,:))     ; stddev of anomalies over clStrt & clLast
  DAnomStd = stddev(DAnom(iClmStrt:iClmLast,:))
                                                    ; signal and noise
  soi_signal = (TAnom/TAnomStd) - (DAnom/DAnomStd)  ; (nyrs,nmos)
  soi_noise  = (TAnom/TAnomStd) + (DAnom/DAnomStd) 
  printVarSummary(soi_signal)

;*********************************
; original approach:  month-by-month normalization
;*********************************
;;TMonStd  = new ( nmos, typeof(T), T@_FillVlaue)   ; Array for monthly std
;;DMonStd  = new ( nmos, typeof(D), D@_FillVlaue)
;;do nmo=0,nmos-1                                   ; anomalies form base climatology
;;   TMonStd(nmo) = stddev(TAnom(:,nmo)
;;   DMonStd(nmo) = stddev(DAnom(:,nmo) 
;;end do
;;sst_signal = TAnom
;;sst_noise  = TAnom
;;do nmo=0,nmos-1                                   ; anomalies form base climatology
;;   soi_signal(:,nmo) = (TAnom(:,nmo)/TAnomStd(nmo)) \ 
;;                     - (DAnom(:,nmo)/DAnomStd(nmo))  
;;   soi_noise (:,nmo) = (TAnom(:,nmo)/TAnomStd(nmo)) \ 
;;                     + (DAnom(:,nmo)/DAnomStd(nmo))  
;;end do

;*********************************
; stuff for netCDF & plot
;*********************************

  yyyymm = yyyymm_time(yrStrt,yrLast,"integer")    ; yyyymm(*)
  yrfrac = yyyymm_to_yyyyfrac(yyyymm, 0.0)         ; yrfrac(*)

  yyyy   = yyyymm/100
  month  = yyyymm - (yyyy*100)
  day    = conform(yyyy, 1, -1)
  hour   = conform(yyyy, 0, -1)
  minute = conform(yyyy, 0, -1)
  sec    = conform(yyyy, 0, -1)
  tunits = "days since "+yyyy(0)+"-1-1 00:00:0.0"
  time   = cd_inv_calendar(yyyy,month,day,hour,minute,sec,tunits,0)
  time!0 = "time"
  time&time = time

  soi_signal_1d      = ndtooned( soi_signal )      ; plot 1d array
  soi_signal_1d!0    = "time"
  soi_signal_1d&time =  time
  soi_noise_1d       = ndtooned( soi_noise  )
  soi_noise_1d!0     = "time"
  soi_noise_1d&time  =  time

  soi_signal_1d@long_name  = "SOI signal"
  soi_noise_1d@long_name   = "SOI noise"

  delete(yrfrac@long_name)
  yrfrac&time = yyyymm
;*********************************
; 11-point smoother: Use reflective boundaries to fill out plot  
;*********************************

  kopt = 1                                        ; reflective 
  wgt  = (/ 0.0270, 0.05856, 0.09030, 0.11742, 0.13567, \
            0.1421, 0.13567, 0.11742, 0.09030, 0.05856, 0.027 /)
  soi_signal_smth11 = wgt_runave_Wrap (soi_signal_1d,wgt,kopt) 
  soi_noise_smth11  = wgt_runave_Wrap (soi_noise_1d ,wgt,kopt) 

  printVarSummary(soi_signal_smth11)
  printVarSummary(soi_noise_smth11)

;*********************************
; plot figures
;*********************************
if (PLOT) then
  wks = gsn_open_wks(pltType, pltDir+pltName)     

  plot= new (2,"graphic")

  res                  = True           ; x-y resources       
  res@gsnDraw          = False
  res@gsnFrame         = False
  res@gsnYRefLine      = 0.0            ; create a reference line 
  res@gsnAboveYRefLineColor = "blue"    ; above ref line fill red
  res@gsnBelowYRefLineColor = "red"     ; below ref line fill blue

  res@vpHeightF        = 0.4            ; change aspect ratio of plot
  res@vpWidthF         = 0.8            
  res@vpXF             = 0.1            ; start plot at x ndc coord 
  
  res@trYMinF          = -4.0           ; min value on y-axis
  res@trYMaxF          =  4.0           ; max value on y-axis
  res@xyLineThicknessF =  2.0 

  
  res@tiYAxisString    = "SOI: smooth"        ; y-axis label      
  plot(0) = gsn_csm_xy (wks,yrfrac,soi_signal_smth11,res)

  res@tiYAxisString    = "SOI Noise: smooth"    ; y-axis label      
  plot(1) = gsn_csm_xy (wks,yrfrac,soi_noise_smth11,res)

  resP                 = True           ; panel resources
  resP@gsnMaximize     = True
  resP@txString        = pltTitle                            
  gsn_panel(wks,plot,(/2,1/),resP)

;********************************************
; create attached plots
; Set up resource lists for attaching the plot.
; The res1 will apply to the base plot, and the
; res2 to the plots being attached.  These resources
; lists are *not* for changing things like line color,
; but for changing things like whether the plots
; are maximized, and which axis they are attached on.
;********************************************
  res1                     = True
  res2                     = True
  res2@gsnAttachPlotsXAxis = True
  amid = gsn_attach_plots(plot(0),(/plot(1)/),res1,res2)
  draw(plot)    
  frame(wks)

  delete(res)                        ; start over (easier)

; Create 3rd plot

  res          = True
  res@gsnScale = True
  res@gsnFrame = False
  res@gsnMaximize = True      ; make as large as possible
  res@gsnPaperOrientation = "portrait"
  res@xyMonoDashPattern   = True      ; Define line pattern.
  res@xyLineThicknessF    = 2.0       ; default is 1.0        
 
  res@trYMinF   = -4.0                ; min Y to plot
  res@trYMaxF   =  4.0                ; max Y to plot
  res@trXMinF   = 1950                ; min X to plot
  res@trXMaxF   = yrLast+1            ; max X to plot
  res@tiMainString = "Southern Oscillation Index: Station"
 ;res@tiYAxisString= "Standardized (ANNUAL)"       
 
  res@vpYF      = 0.80                 ; Change size and location of plot.
  res@vpXF      = 0.175
  res@vpWidthF  = 0.78 
  res@vpHeightF = 0.55 

  res@gsnYRefLine           = 1.0     ; create a reference line   
  res@gsnAboveYRefLineColor = "blue"
  res@gsnBelowYRefLineColor = "transparent"

  tStrt= ind(yyyymm.eq.(res@trXMinF*100 + 1))
  tLast= ind(yyyymm.eq.(yrLast*100+12))
  plot = gsn_csm_xy (wks,yrfrac(tStrt:tLast),soi_signal_smth11(tStrt:tLast),res)

  res@gsnYRefLine           = -1.0   ; create a reference line   
  res@gsnAboveYRefLineColor = "transparent"
  res@gsnBelowYRefLineColor = "red"
  plot = gsn_csm_xy (wks,yrfrac(tStrt:tLast),soi_signal_smth11(tStrt:tLast),res)
  
  gsLine             = True            
  gsLine@gsLineColor = "Foreground"      ; Set polyline color
  gsLine@gsLineDashPattern = 0           ; solid
  gsLine@gsLineThicknessF  = 1.          ; default 1.0                                 
  zero = new ( dimsizes(yrfrac(tStrt:tLast)) , float)
  zero = 0.0
  gsn_polyline(wks,plot,yrfrac(tStrt:tLast),zero,gsLine) 
  frame (wks)

end if

;*********************************
; Create simple netCDF
;*********************************
if (netCDF) then
     wgt!0= "nwgt"
     wgt@long_name = "11-point low pass filter weights"
     wgt@info      = "removes fluctuations with periods of less than 8 months; at 24 months 80% of the variance is retained "

      nline  = inttochar(10)

      diro   = "./"
      filo   = "SOI.nc"
      NCFILE = diro+filo

      system ("/bin/rm -f " +  NCFILE)    ; remove any pre-exist file 
      fo     = addfile ( NCFILE , "c")
      fo@title        = nline+ "Darwin/Tahiti Sea Level Pressure and various SOIs" +nline
      fo@source       = nline+ "ftp.ncep.noaa.gov:/pub/cpc/wd52dg/data/indices"+nline+\
                               "http://www.cpc.ncep.noaa.gov/data/indices/index.html"+nline+\
                        nline+ \
                               "Darwin and Tahiti SLP prior to 1882 and 1935, respectively"+nline+\
                               "were added from the CRU [http://www.cru.uea.ac.uk/]"+nline
      fo@comment      = nline + \
                         "The variables SOI_SIGNAL, SOI_NOISE "+nline+\
                         "were derived using standardized values derived from"+nline+\
                         "monthly values over the "+clStrt+"-"+clLast+" reference period."+nline+\
                         nline+\
                         "As noted by Trenberth, better signal-to-noise ratios can "+nline+\
                         "be obtained using standardized values derived from annual"+nline+\
                         "values.                                                  "
      fo@reference    = nline + \
                         "Signal Versus Noise in the Southern Oscillation" + nline +\
                         "Trenberth, MWR, Feb 1984: 112:326-332" + nline

      fo@creation_date= nline+ systemfunc ("date" ) + nline 

      fo->time        = time
      fo->yyyymm      = yyyymm
      fo->wgt         = wgt
      fo->SOI_SIGNAL  = soi_signal_1d
      fo->SOI_NOISE   = soi_noise_1d
      fo->SOI_SIGNAL_LOWPASS = soi_signal_smth11
      fo->SOI_NOISE_LOWPASS  = soi_noise_smth11 
  end if
