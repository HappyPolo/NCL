;--------------------------------------------------------------
; index_amo_1.ncl
;
; Concepts illustrated
; (1) Used coordinate subscripting to read a user specified 
;     geographical region.
; (2) Compute a climatology over a subset of years
; (3) Compute anomalies at each grid point 
; (4) Areal mean time series of anomalies (year-month)
; (5) Annual averages of (4)                                   
; (6) Calculate regression fit to annual anomalies
; (7) Create simple ascii text files containing the indices
; (8) Use decadal filter to smooth annual time series
; (9) Using gsn_attach_plots 
;--------------------------------------------------------------
; Generate the Atlantic Multi-decadal Oscillation (AMO) Index
;
; The AMO is a coherent pattern of variability in basin-wide 
; North Atlantic SSTs with a period of about 60-80 yrs.
;
; To isolate the actual AMO the background global annual
; sst means or anomalies are removed.
;--------------------------------------------------------------
;;load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl" 
;;load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"   
;;load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"   
;--------------------------------------------------------------
; Dataset Description:
; https://climatedataguide.ucar.edu/climate-data/merged-hadley-noaaoi-sea-surface-temperature-sea-ice-concentration-hurrell-et-al-2008
;--------------------------------------------------------------
;                User Input                             
;--------------------------------------------------------------

 ;diri       = "/ftp/archive/SSTICE/"
  diri       = "./"
  fili       = "MODEL.SST.HAD187001-198110.OI198111-201703.nc"

  latS       =   0.0        ; AMOregion
  latN       =  60.0
  lonL       = 280.0        ; 80W
  lonR       = 360.0        ; GM

  yrStrt_clm = 1901         ; climatological start
  yrLast_clm = 1970         ;                last

  yrStrt     = 1870         ; all data
  yrLast     = toint(str_get_cols(fili, 36, 39))-1    ; no partial years

  pltType    = "png"        ; "pdf", "x11", "ps", "png"
  pltDir     = "./"
;;pltName    = "AMO."+yrStrt+"-"+yrLast
  pltName    = "index_amo"
  pltRegion  = "0-60N, 80W-0"

  ASCII      = True         ; create ASCII
  ascDir     = "./"
  netCDF     = True
;--------------------------------------------------------------
;                End Input                             
;--------------------------------------------------------------
  nyrs      = yrLast-yrStrt+1
  year      = ispan(yrStrt, yrLast, 1)
  year@long_name = "YEAR"
  year!0    = "year"
  year&year = year                  

  f         = addfile(diri+fili, "r")
;;print(f)

  YYYYMM    = cd_calendar(f->time, -1) 

  iclmStrt  = ind(YYYYMM.eq.(yrStrt_clm*100+ 1))      ; start index for clm
  iclmLast  = ind(YYYYMM.eq.(yrLast_clm*100+12))      ; last
  iStrt     = ind(YYYYMM.eq.(yrStrt*100+ 1))          ; start index for ful years
  iLast     = ind(YYYYMM.eq.(yrLast*100+12))          ; last

;--- Global: only 60S-60N

  sstGlb    = f->SST(iStrt:iLast,{-60:60},:)          ; read Global data (limit 60S to 60N)
  printVarSummary(sstGlb)

  sstGlbClm = clmMonTLL(sstGlb(iclmStrt:iclmLast,:,:)); climatology for clm period
  printVarSummary(sstGlbClm)

  sstGlbAnom= calcMonAnomTLL ( sstGlb , sstGlbClm )   ; anomalies at each grid point
  printVarSummary(sstGlbAnom)                         ; from base climatology

;--- AMO region

  sst       = f->SST(iStrt:iLast,{latS:latN},{lonL:lonR}); read data in region and time
  printVarSummary(sst)

  sstClm = clmMonTLL(sst(iclmStrt:iclmLast,:,:))      ; climatology for clm period
  printVarSummary(sstClm)

  sstAnom= calcMonAnomTLL ( sst , sstClm )            ; anomalies at each grid point
  printVarSummary(sstAnom)

;--- Areal Means

  lat_glb  = (/ sstGlb&lat /)                         
  clat_glb = cos(0.01745329*lat_glb)                  ; simple cosine(lat) wgt
  clat_glb@long_name = "wgt: cos(lat)"
  printVarSummary(clat_glb)

  lat_amo  = (/ sst&lat /)
  clat_amo = cos(0.01745329*lat_amo)                  ; simple cosine(lat) wgt
  clat_amo@long_name = "wgt: cos(lat)"
  printVarSummary(clat_amo)

  glbMonth   = wgt_areaave_Wrap(sstGlbAnom, clat_glb, 1.0, 1)   
  glbMonth@long_name = "Global: Monthly Anomalies"
  printVarSummary(glbMonth)                           ; glbMonth(time) => (nyrs*12)

  amoMonth   = wgt_areaave_Wrap(sstAnom, clat_amo, 1.0, 1)   
  amoMonth@long_name = "AMO: Monthly Anomalies"
  printVarSummary(amoMonth)                           ; amoMonth(time) => (nyrs*12)

  ntim   = dimsizes(amoMonth)
  amoAnn = new ( nyrs, typeof(sst), sst@_FillValue)   ; AMO_annual(nyrs)
  glbAnn = amoAnn

;--- Annual means (no monthly weighting, here)

  nyr   = -1
  do nmo=0,ntim-1,12
     nyr = nyr+1
     amoAnn(nyr) = avg(amoMonth(nmo:nmo+11))
     glbAnn(nyr) = avg(glbMonth(nmo:nmo+11))
  end do

  glbAnn@long_name = "Globe: Annual Mean Anomalies"
  glbAnn!0         = "year" 
  glbAnn&year      =  year
  printVarSummary(glbAnn)                             ; glbAnn(year)

  amoAnn@long_name = "AMO: Annual Mean Anomalies"
  amoAnn!0         = "year" 
  amoAnn&year      =  year
  printVarSummary(amoAnn)                             ; amoAnn(year)

;--- Trends of annual means: Only used for plotting
  
  rcGlb       = regline (year,glbAnn)                    ; regression coefficient
  glbAnnTrend = rcGlb*(year-rcGlb@xave) + rcGlb@yave 
  glbAnnTrend@long_name = "Globe: Regression Derived Anomalies"
  copy_VarCoords(glbAnn, glbAnnTrend)
  printVarSummary(glbAnnTrend)
                                                          ; smooth annual with *decadal* smoother
  rcAmo       = regline (year,amoAnn)                    ; regression coefficient
  amoAnnTrend = rcAmo*(year-rcAmo@xave) + rcAmo@yave 
  amoAnnTrend@long_name = "AMO: Regression Derived Anomalies"
  copy_VarCoords(amoAnn, amoAnnTrend)
  printVarSummary(amoAnnTrend)

;--- Smooth annual with *decadal* smoother. Also miscellaneous quantities.
  
  wgts_decade = (/ 1,6,19,42,71,96,106,96,71,42,19,6,1 /)*1.0
  wgts_decade    = wgts_decade/sum(wgts_decade)

  glbAnnSmth  = wgt_runave_Wrap(glbAnn, wgts_decade, 1)   ; kopt=1 reflective end pts
  glbAnnSmth@long_name = "Globe: Decadal Smooth Annual Mean Anomalies"

  amoAnnSmth  = wgt_runave_Wrap(amoAnn, wgts_decade, 1)   ; kopt=1 reflective end pts
  amoAnnSmth@long_name = "AMO: Decadal Smooth Annual Mean Anomalies"

  glbAnnNoTrend = glbAnn-glbAnnTrend
  glbAnnNoTrend@long_name = "Globe: Regional Linear Trend Removed"
  copy_VarCoords(glbAnn, glbAnnNoTrend)

  glbAnnNoTrendSmth  = wgt_runave_Wrap(glbAnnNoTrend, wgts_decade, 1) 
  glbAnnNoTrendSmth@long_name = "AMO: Annual Trend Removed"

  amoAnnNoTrend = amoAnn-amoAnnTrend
  amoAnnNoTrend@long_name = "AMO: Regional Trend Removed"
  copy_VarCoords(amoAnn, amoAnnNoTrend)

  amoAnnNoTrendSmth  = wgt_runave_Wrap(amoAnnNoTrend, wgts_decade, 1) 
  amoAnnNoTrendSmth@long_name = "AMO: Annual Trend Removed"

;+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
; The following is *the* AMO signal
;+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

  AMO = amoAnn-glbAnn                 ; Remove global influence
  copy_VarMeta(amoAnn, AMO)
  AMO@long_name = "AMO Signal: Global Means Removed"

  AMOSmth  = wgt_runave_Wrap(AMO, wgts_decade, 1) 
  AMOSmth@long_name = "Smoothed[AMO Signal: Global Means Removed]"

;*************************************************************************
; Create ASCII (text) file
;*************************************************************************
  if (ASCII) then
      ascName = "AMO."+yrStrt+"-"+yrLast+".txt"
      ascPath = ascDir+ascName
      system("/bin/rm -f "+ascPath)

      data_txt   = "year    AMO    AMO_ANN  TREND   SMTH   NoTrend  NoTrendSmth"
      data_amo   = sprinti("%0.4i", year)             \
                 + sprintf("%8.2f", AMO)              \
                 + sprintf("%8.2f", amoAnn)           \
                 + sprintf("%8.2f", amoAnnTrend)      \
                 + sprintf("%8.2f", amoAnnSmth)       \   
                 + sprintf("%8.2f", amoAnnNoTrend)    \ 
                 + sprintf("%8.2f", amoAnnNoTrendSmth) 
                                             ; merge the 2 string variables
      data_merge    = new (dimsizes(data_amo)+1, "string", "No_FillValue")
      data_merge(0) = data_txt
      data_merge(1:)= data_amo
      asciiwrite(ascPath,data_merge)         ; create text file

      delete(data_merge)

      ascName = "GLOBE."+yrStrt+"-"+yrLast+".txt"
      ascPath = ascDir+ascName
      system("/bin/rm -f "+ascPath)

      data_txt   = "year   GLOBE   TREND    SMTH  NoTrend  NoTrendSmth"
      data_glb   = sprinti("%0.4i", year)             \
                 + sprintf("%8.2f", glbAnn)           \
                 + sprintf("%8.2f", glbAnnTrend)      \
                 + sprintf("%8.2f", glbAnnSmth)       \   
                 + sprintf("%8.2f", glbAnnNoTrend)    \ 
                 + sprintf("%8.2f", glbAnnNoTrendSmth) 
                                             ; merge the 2 string variables
      data_merge    = new (dimsizes(data_glb)+1, "string", "No_FillValue")
      data_merge(0) = data_txt
      data_merge(1:)= data_glb

      asciiwrite(ascPath,data_merge)         ; create text file
  end if

;*************************************************************************
; Create netCDF file
;*************************************************************************
  if (netCDF) then
      cdfDir  = "./"
      cdfName = "AMO."+yrStrt+"-"+yrLast+".nc"
      cdfPath = cdfDir+cdfName
      system("/bin/rm -f "+cdfPath)
      ncdf = addfile(cdfPath ,"c")         ; open output netCDF file

;---Create global attributes of the file (optional)
      fAtt               = True            ; assign file attributes
      fAtt@title         = "AMO Index: "+yrStrt+"-"+yrLast
      fAtt@source_file   = fili 
      fAtt@Conventions   = "None"
      fAtt@creation_date = systemfunc ("date")
      fileattdef( ncdf, fAtt )             ; copy file attributes

; make time an UNLIMITED dimension; recommended  for most applications
;     filedimdef(ncdf,"time",-1,True) 

      ncdf->year = year
      ncdf->AMO  = AMO
      ncdf->amoAnn       = amoAnn
      ncdf->amoAnnTrend  = amoAnnTrend
      ncdf->amoAnnSmth   = amoAnnSmth 
      ncdf->amoAnnNoTrend= amoAnnNoTrend 
      ncdf->amoAnnNoTrendSmth= amoAnnNoTrendSmth 
      ncdf->glbAnn           = glbAnn
      ncdf->glbAnnTrend      = glbAnnTrend
      ncdf->glbAnnSmth       = glbAnnSmth 
      ncdf->glbAnnNoTrend    = glbAnnNoTrend     
      ncdf->glbAnnNoTrendSmth= glbAnnNoTrendSmth 
  end if
;*************************************************************************
; Plots
;*************************************************************************
  plot = new ( 3 , "graphic")

  wks          = gsn_open_wks (pltType, pltName)

  res          = True                   ; plot mods desired
  res@gsnDraw  = False                  ; don't draw yet      
  res@gsnFrame = False                  ; don't advance frame yet      

  res@vpHeightF= 0.4                    ; change aspect ratio of plot
  res@vpWidthF = 0.8                  
  res@vpXF     = 0.15                   ; start plot at x ndc coord 

  res@trXMinF  = yrStrt-1
  res@trXMaxF  = yrLast+1
  res@trYMinF  = -0.6      
  res@trYMaxF  =  0.8

  res@tmXBMode          = "Explicit"
  res@tmXBValues        = ispan(1870,2010,10)                          ; location of labels 
  res@tmXBLabels        = (/"","1880","","1900","","1920","","1940","","1960","","1980","","2000",""/)

 ;res@tiYAxisString    = "SST (C) "   
  
  res@gsnYRefLine      = 0.0
  res@xyLineThicknessF = 3.0
  res@gsnAboveYRefLineColor = "red"          ; above ref line fill red
  res@gsnBelowYRefLineColor = "blue"         ; below ref line fill blue
  res@tiMainString          = "Atlantic Multi-Decadal Oscillation: "+yrStrt+"-"+yrLast

  res@tmYLMode          = "Explicit"
  res@tmYLValues        = (/      -0.4, -0.2, 0.0 , 0.2, 0.4, 0.6, 0.8/)  ; location of 'top' labels 
  res@tmYLLabels        = ""+res@tmYLValues

  plot(0)  = gsn_csm_xy (wks,year, amoAnnSmth ,res)    

  txres               =  True
  txres@txFontHeightF = 0.02
  txres@txJust        = "CenterLeft"
  txres@txFontThicknessF = 2.0      ; default=1.00
  txres@txFontHeightF    = 0.025    ; default=0.05
  text_amo1 = gsn_add_text(wks,plot(0),"AMO: "+pltRegion, 1920, 0.60 ,txres)

  polyres                  = True
  polyres@gsLineThicknessF = 2.0
  line1 = gsn_add_polyline(wks,plot(0),year,(/amoAnn/),polyres) 

  polyres@gsLineDashPattern  = 1 
  line2 = gsn_add_polyline(wks,plot(0),year,(/amoAnnTrend/)  ,polyres)

;---
  delete(polyres@gsLineDashPattern)
  delete(res@tiMainString)
;---
                  ; middle tm labels;  prevent 'overwrite' by 'top' and 'bottom' labels
  res@tmYLValues := (/      -0.4, -0.2, 0.0 , 0.2, 0.4, 0.6     /)  
  res@tmYLLabels := ""+res@tmYLValues
  plot(1)         = gsn_csm_xy (wks,year, glbAnnSmth ,res)    
  text_amo2       = gsn_add_text(wks,plot(1),"Global SST", 1920, 0.60 ,txres)
  line3           = gsn_add_polyline(wks,plot(1),year,(/glbAnn/),polyres) 

                  ; bottom tm labels 
  res@tmYLValues := (/-0.6, -0.4, -0.2, 0.0 , 0.2, 0.4, 0.6     /)
  res@tmYLLabels := ""+res@tmYLValues

  plot(2)         = gsn_csm_xy (wks,year, AMOSmth ,res)    
  text_amo3       = gsn_add_text(wks,plot(2),"AMO Signal", 1920, 0.60 ,txres)
  line4           = gsn_add_polyline(wks,plot(2),year,(/AMO/),polyres) 

;********************************************
; create attached plots
;********************************************

; Set up resource lists for attaching the plot.  The res1 will apply to the base plot, 
; and the res2 to the plots being attached.  These resources lists are *not* for 
; changing things like line color, but for changing things like whether the plots
; are maximized, and which axis they are attached on.
 
  res1                     = True
  res2                     = True
  res2@gsnAttachPlotsXAxis = True
  amid = gsn_attach_plots(plot(0),(/plot(1),plot(2)/),res1,res2)
  draw(plot(0))            ; 'base' plot   
  frame(wks)


