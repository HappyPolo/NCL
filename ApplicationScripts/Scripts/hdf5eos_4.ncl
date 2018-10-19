;******************************************************************
; hdf5eos_4.ncl
;
; Concepts illustrated:
;   - Reading HDF-EOS5 ['he5'] data
;   - Calculating dispersions statistics
;   - Calculating Probability Density Functions
;   - Displaying Probability Density Functions
;   - Plotting HE5 data
;************************************************
; Basic User input
;************************************************
diri = "./"
fili = "HIRDLS2_v02-04-19-01-c01_2006d138.he5"

pltType  = "png"                     ; send graphics to PNG file
pltName  = "hdf5eos"
;********** End User Input **********************
;
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"   
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"    
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
;
; This file still has to be loaded manually    
load "./HDFEOS_LIB.ncl"

;************************************************
;                MAIN
;************************************************
  begin
;************************************************
; Open file and read variables 
;************************************************
      f = addfile(diri + fili, "r")
     ;print(f)
      
      T    = f->Temperature_HIRDLS    ; ( nTimes_HIRDLS, nLevels_HIRDLS )
      A    = f->Altitude_HIRDLS       ; ( nTimes_HIRDLS, nLevels_HIRDLS )
      O3   = f->O3_HIRDLS             ; ( nTimes_HIRDLS, nLevels_HIRDLS )
     ;P    = f->Pressure_HIRDLS       ; ( nLevels_HIRDLS )
     ;lat  = f->Latitude_HIRDLS       ; ( nTimes_HIRDLS )
     ;lon  = f->Longitude_HIRDLS

      time = f->Time_HIRDLS           ; ( nTimes_HIRDLS )
      ntim = dimsizes(time)

;************************************************
; Print overview of variables  
;************************************************

      printVarSummary(T)
      printMinMax(T, True)
      printVarSummary(A)
      printMinMax(A, True)
      printVarSummary(O3)
      printMinMax(O3, True)       ; <=== this has outliers
      print("==============")

;************************************************
; Calculate/print robust measures of dispersion
; Some of these variables have outliers.
;************************************************

      optStat = True
      optStat@PrintStat = True

      T_stat = stat_dispersion(T , optStat)
      print("==============")

      O3_stat = stat_dispersion(O3, optStat)
      print("==============")

      A_stat  = stat_dispersion(A, optStat)
      print("==============")

;************************************************
; time units: NCL does not yet have a function analogous
; to cd_calendar for TAI93 (International Atomic Time) 
;************************************************

      telapse = (time - time(0))/60   ; just for fun!
      telapse@long_name = "Elapsed Time (minutes)"
      telapse@units     = "minutes since "+time(0)

      T&nTimes_HIRDLS   = telapse
  
;************************************************
; Calculate PDFs (probability distribution functions)   
; http://www.ncl.ucar.edu/Applications/pdf.shtml
; http://www.ncl.ucar.edu/Document/Functions/Contributed/pdfx.shtml
;************************************************

      T_pdf  = pdfx(T, 0, False)    ; default number of bins
      O3_pdf = pdfx(O3,0, False) 
      A_pdf  = pdfx(A, 0, False)    

;************************************************
; Graphics
;************************************************

      wks   = gsn_open_wks (pltType,pltName)          ; open workstation
      gsn_define_colormap(wks,"amwg")                 ; choose colormap

;************************************************
; plot PDFs
;************************************************
      npdf     = 3
      plt_pdf  = new ( npdf, "graphic")

      res_pdf  = True
      res_pdf@gsnDraw          = False
      res_pdf@gsnFrame         = False

      res_pdf@xyLineColor      = "blue"
      res_pdf@xyLineThicknessF = 3
      res_pdf@tiYAxisString    = "PDF (%)"
      res_pdf@trYMinF          = -0.005      ; offset bottom axis

      res_pdf@gsnCenterString  = T@long_name
      plt_pdf(0) = gsn_csm_xy (wks, T_pdf@bin_center, T_pdf, res_pdf)

      res_pdf@gsnCenterString  = O3@long_name
      plt_pdf(1) = gsn_csm_xy (wks,O3_pdf@bin_center,O3_pdf, res_pdf)

      res_pdf@gsnCenterString  = A@long_name
      plt_pdf(2) = gsn_csm_xy (wks,A_pdf@bin_center,A_pdf, res_pdf)

      resP = True
      resP@txString            = fili
      gsn_panel(wks,plt_pdf,(/2,2/),resP)        ; now draw as one plot

;****************************************************
; Scale O3 for nicer looking plots (not so many decimal pts)
;****************************************************
      O3       = O3*1e6
      O3@units = O3@units + "*1e6" 

;****************************************************
; Plot selected variables as a function of "time" 
;      and a 2-D vertical coordinate ( here, ALT[*][*] )
;      Reorder so "time" is the "x" axis
;****************************************************
; Limits were set after looking at the stat_dispersion
; The last plot is rather non-sensical but was done 'for fun'
;****************************************************
      ncn      = 3
      plt_cn   = new ( ncn, "graphic")

      res_cn = True
      res_cn@gsnDraw              = False
      res_cn@gsnFrame             = False

      res_cn@tiXAxisString        = telapse@long_name
      res_cn@tiYAxisString        = "Level"

      res_cn@cnLevelSelectionMode = "ManualLevels" ; set manual contour levels
      res_cn@cnMinLevelValF       = 210.           ; set min contour level
      res_cn@cnMaxLevelValF       = 260.           ; set max contour level
      res_cn@cnLevelSpacingF      =   5.           ; set contour spacing

      plt_cn(0) = HIR_contour_2D2D(wks, telapse \
                                  ,A(nLevels_HIRDLS|:,nTimes_HIRDLS|:) \
                                  ,T(nLevels_HIRDLS|:,nTimes_HIRDLS|:) \
                                  ,res_cn)

      res_cn@cnMinLevelValF       = 0.50          ; after 1e6 scaling
      res_cn@cnMaxLevelValF       = 6.00  
      res_cn@cnLevelSpacingF      = 0.50 
      plt_cn(1) = HIR_contour_2D2D(wks, telapse \
                                  , A(nLevels_HIRDLS|:,nTimes_HIRDLS|:) \
                                  ,O3(nLevels_HIRDLS|:,nTimes_HIRDLS|:) \
                                  ,res_cn)

      res_cn@cnMinLevelValF       = 10000.
      res_cn@cnMaxLevelValF       = 90000.         ; set max contour level
      res_cn@cnLevelSpacingF      = 10000.         ; set contour spacing

      plt_cn(2) = HIR_contour_2D2D(wks, telapse \
                                  ,A(nLevels_HIRDLS|:,nTimes_HIRDLS|:) \
                                  ,A(nLevels_HIRDLS|:,nTimes_HIRDLS|:) \
                                  ,res_cn)

      resP = True
      resP@txString            = fili
      gsn_panel(wks,plt_cn,(/2,2/),resP)        ; now draw as one plot

; ****************************************************
; time series:  three different variables
; ****************************************************
      kl = 50    ; arbitrary level

      resLeft   = True
      resLeft@gsnMaximize   = True
      resLeft@gsnPaperOrientation   = "portrait"          ; force portrait
      resLeft@tiMainString  = fili
      resLeft@tiXAxisString = "Elapsed Time (minutes)"

      resRight  = True
      resRight@tiYAxisString = A@long_name +"("+A@units+") : kl="+kl
      resRight2 = True
      resRight2@tiYAxisString = O3@long_name +"("+O3@units+") : kl="+kl
      plot  = TimeSeries_y3(wks, telapse,T(:,kl),A(:,kl) ,O3(:,kl),resLeft,resRight,resRight2)
  end
