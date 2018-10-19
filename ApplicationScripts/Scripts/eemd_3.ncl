;***************************************************************
; eemd_3.ncl    
;
; Concepts illustrated:
;   - Reading data from a NetCDF file
;   - Extracting user specified time period using 'ind' function
;   - Specifying 'eemd' options
;   - Using both 'eemd' and 'ceemdan' functions
;   - Printing min / max of each IMF
;   - Adding figure strings to paneled plots
;
;***************************************************************
; Requires NCL 6.4.0 or higher
;***************************************************************
; Based upon:
; Salisbury, J. I., and M. Wimbush, 2002: 
;   Using modern time series analysis techniques to predict 
;   ENSO events from the SOI time series
; Nonlinear Processes Geophys., 9, 341–345, doi: 10.5194/ npg-9-341-2002
; http://www.nonlin-processes-geophys.net/9/341/2002/npg-9-341-2002.pdf
;***************************************************************

  ymStrt = 197001                     ; period used in paper
  ymLast = 201012                     ; file goes through 201612

  diri   = "./"
  fili   = "SOI.nc"
  pthi   = diri + fili

  f      = addfile(pthi,"r")
  YYYYMM = f->time                     ; *ALL* times
  iStrt  = ind(ymStrt.eq.YYYYMM)
  iLast  = ind(ymLast.eq.YYYYMM)

  soi    = f->SOI_SIGNAL(iStrt:iLast)
  yyyymm = f->time(iStrt:iLast)
  time   = f->TIME(iStrt:iLast)
;;print(yyyymm+"  "+time+"    "+soi)
  ntim   = dimsizes(time)

  soi@long_name = "SOI: "+ymStrt+"-"+ymLast    ; change name

; EEMD options

  nrep   = 250
  nimf   = 8                              ; set nimf=0, means the function wil calculate
  noise  = 0.2
  dims   = 0
  opt    = False

  soi_eemd = eemd(soi,nimf,nrep,noise,opt,dims)
  soi_eemd@long_name = "soi_ceemdan: "+ymStrt+"-"+ymLast+": nrep="+nrep+": noise="+noise
  printVarSummary(soi_eemd)
  printMinMax(soi_eemd,0)

  soi_ceemdan = ceemdan(soi,nimf,nrep,noise,opt,dims) 
  soi_ceemdan@long_name = "soi_ceemdan: "+ymStrt+"-"+ymLast+": nrep="+nrep+": noise="+noise
  printVarSummary(soi_ceemdan)
  printMinMax(soi_ceemdan,0)

  dime  = dimsizes(soi_eemd)
  NIMF  = dime(0)                               ; if input nimf=0 (NIMF is calculated)
  NTIM  = dime(1)                               ; same as ntim

; plots

  wks  = gsn_open_wks("png","eemd")
  plot = new( 2, "graphic")

; full period

  ymfrac       = yyyymm_to_yyyyfrac(yyyymm, 0.0)
  delete(ymfrac@long_name)              ; do not want automatically plotted

  res          = True
  res@vpHeightF= 0.4                    ; change aspect ratio of plot
  res@vpWidthF = 0.7 
                                        ; arbitrary; esthetic reasons only
  res@trXMinF  = min(ymfrac) - 2        ; get away from the left  boundary
  res@trXMaxF  = max(ymfrac) + 2        ; get away from the right boundary        

  delete(soi@long_name)
  res@tiMainString = "SOI: "+ymStrt+"-"+ymLast
  plot(0)      = gsn_csm_xy(wks,ymfrac,soi,res)              ; raw data

; panel

  res@gsnDraw  = False                  ; panel
  res@gsnFrame = False

  resP         = True
  resP@gsnMaximize = True
  resP@txString= ymStrt+"-"+ymLast

  do ni=0,nimf-1
     soi_eemd@long_name = "soi_eemd: nimf="+(ni+1)
     printMinMax(soi_eemd(ni,:),0)

     soi_ceemdan@long_name = "soi_ceemdan: nimf="+(ni+1)
     printMinMax(soi_ceemdan(ni,:),0)

     delete([/soi_eemd@long_name, soi_ceemdan@long_name/])   ; do not plot as Y axis

     res@tiMainString = "soi_eemd: nimf="+(ni+1)+": "+ymStrt+"-"+ymLast
     plot(0) = gsn_csm_xy(wks,ymfrac,soi_eemd(ni,:)   ,res)  ; each IMF

     res@tiMainString = "soi_ceemdan: nimf="+(ni+1)+": "+ymStrt+"-"+ymLast
     plot(1) = gsn_csm_xy(wks,ymfrac,soi_ceemdan(ni,:),res) 

     gsn_panel(wks,plot,(/2,1/),resP)  
  end do
