;************************************************************
; mjoclivar_3.ncl
;   - Generate Sample Variances as in Fig 3 and 4
;   - Extract daily values and derived quantities for a user specified period
;   - Generate Lanczos filter weights (filwgts_lanczos)
;     The  'fca', 'fcb' and number of weights are specified by the MJO project
;   - Apply the daily data using the filter weights weights (wgt_runave_n_Wrap)                      
;   - Plot assorted quantities as per Fig 3 and 4
;   - Move the 'cnInfoLabelString' into the plot for the overlay plot
;   - Create panel plots for winter and summer
;***********************************************************
;
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
;***********************************************************

begin
   plev    = 850                              ; 850hPa

   ymdStrt = 19900101                         ; start yyyymmdd
   ymdLast = 19991231                         ; last  

   yrStrt  = ymdStrt/10000
   yrLast  = ymdLast/10000

   pltDir  = "./"                             ; plot directory
   pltType = "png"                            ; png, ps, ....
   pltName = "mjocliar"                       ; yrStrt+"_"+yrLast
  
   diri    = "./"                             ; input directory   

   monsea  = (/ (/ 5, 6, 7, 8, 9,10/) \       ; May-Oct [summer]
              , (/ 1, 2, 3, 4,11,12/) /)      ; Nov-Apr [winter]
;************************************************
; create BandPass Filter
;************************************************
  ihp      = 2                                ; bpf=>band pass filter
  nWgt     = 201
  sigma    = 1.0                              ; Lanczos sigma
  fca      = 1./100.
  fcb      = 1./20.
  wgt      = filwgts_lanczos (nWgt, ihp, fca, fcb, sigma )

;***********************************************************
; Read daily U anomalies
;***********************************************************

   fili    = "uwnd.day."+plev+".anomalies.1980-2005.nc"
   f       = addfile (diri+fili , "r")                         
   TIME    = f->time                          ; days since ...
   YMD     = ut_calendar(TIME, -2)            ; entire (time,6)

   iStrt   = ind(YMD.eq.ymdStrt)              ; index start
   iLast   = ind(YMD.eq.ymdLast)              ; index last 
   delete(TIME)
   delete(YMD )

   x       = f->U_anom(iStrt:iLast,:,:)       ; U_anom_sm
   printVarSummary(x)
   printMinMax(x, True)

   time    = f->time(iStrt:iLast)             ; days since ...
   ymdhms  = ut_calendar(time, 0 )            ; (ntim,2)
   mm      = floattoint( ymdhms(:,1) )        ; just months

   iSummer = ind( mm.ge.5 .and. mm.le.10)
   iWinter = ind((mm.ge.1 .and. mm.le. 4) .or.  \
                 (mm.ge.11.and. mm.le.12) )

;***********************************************************
; Read daily OLR anomalies: same times as above
;***********************************************************

   fili    = "olr.day.anomalies.1980-2005.nc"
   f       = addfile (diri+fili , "r")                         
   y       = f->OLR_anom(iStrt:iLast,:,:)      ; OLR_anom_sm
   printVarSummary(y)
   printMinMax(y, True)

;************************************************
; Compute unfiltered seasonal variances (lat,lon)
;************************************************

  xVarWinter = dim_variance_n_Wrap( x(iWinter,:,:), 0 )    
  xVarSummer = dim_variance_n_Wrap( x(iSummer,:,:), 0 )
  xVarWinter = dim_variance_n_Wrap( x(iWinter,:,:), 0 ) 
  yVarWinter = dim_variance_n_Wrap( y(iWinter,:,:), 0 ) 
  yVarSummer = dim_variance_n_Wrap( y(iSummer,:,:), 0 ) 

;************************************************
; Apply the Lanczos band pass filter weights to the original anomalies (time,lat,lon)
;************************************************

  xBPF = wgt_runave_n_Wrap (x, wgt, 0, 0)               
  yBPF = wgt_runave_n_Wrap (y, wgt, 0, 0)

;************************************************
; Compute filtered seasonal variances (lat,lon)
;************************************************

  xVarWinterBPF = dim_variance_n_Wrap( xBPF(iWinter,:,:), 0 )  
  xVarSummerBPF = dim_variance_n_Wrap( xBPF(iSummer,:,:), 0 ) 
  yVarWinterBPF = dim_variance_n_Wrap( yBPF(iWinter,:,:), 0 ) 
  yVarSummerBPF = dim_variance_n_Wrap( yBPF(iSummer,:,:), 0 ) 

;************************************************
; Compute (filiered_variance)/(unfiltered_variance)
;************************************************

  xRatioVarWinter = (xVarWinterBPF/xVarWinter)*100
  xRatioVarSummer = (xVarSummerBPF/xVarSummer)*100
  yRatioVarWinter = (yVarWinterBPF/yVarWinter)*100
  yRatioVarSummer = (yVarSummerBPF/yVarSummer)*100

  copy_VarCoords( xVarWinter, xRatioVarWinter)
  copy_VarCoords( xVarSummer, xRatioVarSummer)
  copy_VarCoords( yVarWinter, yRatioVarWinter)
  copy_VarCoords( yVarSummer, yRatioVarSummer)

;************************************************
; Plots
;************************************************

  plot = new ( 2, "graphic")
;************************************************
; resource list for first (color) data array: Ratios
;************************************************
  res1                      = True
  res1@gsnDraw              = False              ; don't draw
  res1@gsnFrame             = False              ; don't advance frame
  res1@gsnStringFontHeightF = 0.0125             ; make larger than default

  res1@lbLabelBarOn         = False              ; turn off individual cb's
  res1@tiMainOn             = False

  res1@cnFillPalette        = "amwg256"
  res1@cnLevelSelectionMode = "ManualLevels"     ; set manual contour levels
  res1@cnMinLevelValF       =  10.
  res1@cnMaxLevelValF       =  50.
  res1@cnLevelSpacingF      =   5. 
  res1@cnInfoLabelOn        = False              ; do not want for 1st (base) plot
  res1@cnLinesOn            = False              ; No lines for base plot
  res1@cnLineLabelsOn       = False              ; No line labels

  res1@mpMinLonF            =  30.               ; select a subregion
  res1@mpMaxLonF            = 300.
  res1@mpMinLatF            = -35. 
  res1@mpMaxLatF            =  35.
  res1@mpCenterLonF         = (res1@mpMinLonF + res1@mpMaxLonF)*0.5       

;************************************************  "$CMN$ TO $CMX$ BY $CIU$" 
; resource list for second (contour only) data array; contour lines only
;************************************************
  res2                      = True
  res2@gsnDraw              = False              ; don't draw
  res2@gsnFrame             = False              ; don't advance frame
  res2@tiMainOn             = False

  res2@cnFillOn             = False              ; no colors
  res2@cnInfoLabelOn        = True               ; default is True 
  res2@cnInfoLabelOrthogonalPosF = -0.11         ; move the label inside the plot
  res2@cnInfoLabelFontHeightF    = 0.008
  res2@cnInfoLabelString    =  "$CMN$ TO $CMX$ BY $CIU$" ; contour levels automatically generated  
  res2@cnLineLabelsOn       = True
  res2@cnLabelMasking       = True		 ; nicer plot but slow
  res2@cnLineLabelFontHeightF    = 0.008

;************************************************
; resource list for panel
;************************************************
  resP                     = True                ; modify the panel plot
  resP@gsnMaximize         = True                ; make large
  resP@gsnPanelLabelBar    = True                ; add common colorbar
  resP@lbLabelFontHeightF  = 0.0125
  resP@txFontHeightF       = 0.025               ; default = 0.50

;************************************************
; resource list for panel
;************************************************
  pltPath = pltDir+pltName
  wks     = gsn_open_wks(pltType, pltPath)        

;---Winter

  res1@gsnLeftString       =  x@long_name
  plot(0)   = gsn_csm_contour_map_overlay(wks,xRatioVarWinter,xVarWinter,res1,res2)

  res1@gsnLeftString       = y@long_name
  plot(1)   = gsn_csm_contour_map_overlay(wks,yRatioVarWinter,yVarWinter,res1,res2)

  resP@txString  = "Variance: Winter (Nov-Apr): "+ yrStrt+"-"+yrLast
  gsn_panel(wks,plot,(/2,1/),resP)               ; now draw as one plot

;---Summer

  res1@gsnLeftString        = x@long_name
  plot(0)   = gsn_csm_contour_map_overlay(wks,xRatioVarSummer,xVarSummer,res1,res2)

  res1@gsnLeftString        = y@long_name
  plot(1)   = gsn_csm_contour_map_overlay(wks,yRatioVarSummer,yVarSummer,res1,res2)

  resP@txString  = "Variance: Summer (Mar-Oct): "+ yrStrt+"-"+yrLast
  gsn_panel(wks,plot,(/2,1/),resP)               ; now draw as one plot
end
