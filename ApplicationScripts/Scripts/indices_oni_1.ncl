;----------------------------------------------------------------------
; indices_oni_1.ncl
;
; Concepts illustrated:
;   - Computing the Oceanic Nino Index
;   - Drawing a time series plot
;----------------------------------------------------------------------
;
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl" 
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl" 
;---------------------------------------------------------------------------
; NOAA's operational definitions of El Niño and La Niña conditions are based
; upon the Oceanic Niño Index [ONI]. The ONI is defined as the 3-month running
; means of SST anomalies in the Niño 3.4 region [5N-5S, 120-170W]. The anomalies
; are derived from the 1971-2000 SST climatology.
;
; The Niño 3.4 anomalies may be thought of as representing the average equatorial
; SSTs across the Pacific from about the dateline to the South American coast.
; To be classified as a full-fledged El Niño and La Niña episode the ONI must excee
; d +0.5 [El Niño] or -0.5 [La Niña] for at least five consecutive months. 
;---------------------------------------------------------------------------
;                         User input
;---------------------------------------------------------------------------

  latS   = -5.0
  latN   =  5.0
  lonL   = 190.0
  lonR   = 240.0
  
  nrun   = 3             ; length of running average

  ymStrt = 187001
  ymLast = 201112        ; last full year on file

  clStrt = 197101        ; climatology start    
  clLast = 200012        ;             last

  yrStrt = ymStrt/100
  yrLast = ymLast/100

  pltType = "png"       ; send graphics to PNG file
  pltDir  = "./"        ; dir to which plots are sent
 ;pltName = "ONI."+(ymStrt/100)+"-"+(ymLast/100)
  pltName = "indices_oni"

  pltTitle= "ONI: "+(ymStrt/100)+"-"+(ymLast/100) \
          + ": Base "+(clStrt/100)+"-"+(clLast/100)

;-------------------- End User Input ---------------------------------------

  diri  = "./"
  fili  = "MODEL.SST.HAD187001-198110.OI198111-201203.nc"
  in    = addfile(diri+fili,"r")

  YYYYMM= (in->date)/100             ; ALL dates on file
  tStrt = ind(YYYYMM.eq.ymStrt)      ; indices of selected times
  tLast = ind(YYYYMM.eq.ymLast)
  delete(YYYYMM)
                                     ; read only desired area & times
  x     = in->SST(tStrt:tLast,{latS:latN},{lonL:lonR})
  printVarSummary(x)

  date  = in->date(tStrt:tLast)
  yyyymm= date/100
  ntim  = dimsizes(date)

;*********************************
; time indices for base climatology 
;*********************************

  iClmStrt = ind(yyyymm.eq.clStrt)     
  iClmLast = ind(yyyymm.eq.clLast)    
 ;print(date(iClmStrt:iClmLast))

;*********************************
; Climatology and anomalies from base climatology   
;*********************************

  xClm     = clmMonTLL(x(iClmStrt:iClmLast,:,:))
  printVarSummary(xClm)

  xAnom    = calcMonAnomTLL (x,  xClm ) 
  xAnom@long_name = "SST Anomalies"
  printVarSummary(xAnom)

;*********************************
; Unweighted areal average anomalies (time series)
; Small latitudinal extent so no need to weight    
;*********************************

  xAnom_avg = wgt_areaave_Wrap(xAnom, 1.0, 1.0, 1)
  xAnom_avg@long_name = "areal avg anomalies"
  printVarSummary(xAnom_avg)

;*********************************
; Perform an unweighted 'nrun' month running average
;*********************************

   xAnom_avg = runave_n_Wrap (xAnom_avg, nrun, 1, 0)

;*********************************
; plot graph
;*********************************
  yrfrac = yyyymm_to_yyyyfrac(yyyymm, 0.0)

  wks = gsn_open_wks(pltType, pltDir+pltName)     

  res                  = True       
  res@gsnMaximize      = True
  res@gsnYRefLine      = 0.0            ; create a reference line 
  res@gsnAboveYRefLineColor = "red"              ; above ref line fill red
  res@gsnBelowYRefLineColor = "blue"             ; below ref line fill blue

  res@vpHeightF        = 0.4            ; change aspect ratio of plot
  res@vpWidthF         = 0.8            
  res@vpXF             = 0.1            ; start plot at x ndc coord 
  
  res@trYMinF          = -3.0           ; min value on y-axis
  res@trYMaxF          =  3.0           ; max value on y-axis

  res@tiMainString     = pltTitle                            
  
  res@tiYAxisString    = "Anomalies (C)"    ; y-axis label      
  plot = gsn_csm_xy (wks,yrfrac,xAnom_avg,res)

;*********************************
; plot table: about 40 years is the max for a page
;*********************************

  yrStrtTab = 1972
  yrLastTab = 2011

  wkstab = gsn_open_wks(pltType, pltDir+pltName+"_table")     

  nmos   = 12
  nyrs   = yrLastTab-yrStrtTab+1 ; number of rows (nrows) 
  ncols  = nmos+1                ; year and 12 monthly values
  nrc    = (/nyrs,ncols/)        ; (/nrows,ncols/)

  tStrtTab = ind(yyyymm.eq.(yrStrtTab*100 + 1))
  tLastTab = ind(yyyymm.eq.(yrLastTab*100 +12))

  data   = onedtond(xAnom_avg(tStrtTab:tLastTab), (/nyrs,nmos/)) 

  xx     = (/0.10 ,0.90 /)                          ; Start and End X
  yy     = (/0.005,0.995/)                          ; Start and End Y

  year   = ispan(yrStrtTab,yrLastTab,1)  

  tabtxt = new( nrc, "string")                      ; allocate space for table
  tabtxt(:,0) = sprinti("%0.4i", year)              ; 1st column (0) for 'year'

  do nyr=0,nyrs-1                                   ; each year (row)
     tabtxt(nyr,1:) = sprintf("%6.2f", data(nyr,:)) ; 12 values (col) for each year
                                                    ; ?missing? ... fill with spaces
     tabtxt(nyr,1:) = where(ismissing(data(nyr,:)), "    ", tabtxt(nyr,1:)) 
  end do

  tabcol = tabtxt                                   ; colors same size/shape as text
  tabcol = "transparent"                            ; initialize
                                                    ; change fill color if appropriate
  tabcol(:,1:) = where(data.le.-0.5 ,"DodgerBlue" , tabcol(:,1:))
  tabcol(:,1:) = where(data.ge. 0.5 ,"red"        , tabcol(:,1:))

  rest  = True
  rest@txFontHeightF = 0.0125
  rest@gsFillColor   = tabcol

  gsn_table(wkstab,nrc,xx,yy,tabtxt,rest)
  frame(wkstab)
