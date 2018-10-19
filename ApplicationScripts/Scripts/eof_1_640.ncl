; ==============================================================
; eof_1_640.ncl
;
; Concepts illustrated:
;   - Calculating EOFs
;   - Drawing a time series plot
;   - Using coordinate subscripting to read a specified geographical region
;   - Rearranging longitude data to span -180 to 180
;   - Calculating symmetric contour intervals
;   - Drawing filled bars above and below a given reference line
;   - Drawing subtitles at the top of a plot
; =============================================================
; This script uses functions eofunc_n and eofunc_ts_n, which
; were added in NCL V6.4.0
; =============================================================
; Calculate EOFs of the Sea Level Pressure over the North Atlantic.
; ==============================================================
; The slp.mon.mean file can be downloaded from:
; http://www.esrl.noaa.gov/psd/data/gridded/data.ncep.reanalysis.surface.html
; ==============================================================
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"

begin
; ==============================================================
; User defined parameters that specify region of globe and
; ==============================================================
  latS   =  25.
  latN   =  80. 
  lonL   = -70.
  lonR   =  40.

  yrStrt = 1979
  yrLast = 2003

  season = "DJF"    ; choose Dec-Jan-Feb seasonal mean

  neof   = 3        ; number of EOFs
  optEOF = True       
  optEOF@jopt = 0   ; This is the default; most commonly used; no need to specify.
;;optEOF@jopt = 1   ; **only** if the correlation EOF is desired

  optETS = False

; ==============================================================
; Open the file: Read only the user specified period
; ==============================================================
  f      = addfile ("slp.mon.mean.nc", "r")

  TIME   = f->time
  YYYY   = cd_calendar(TIME,-1)/100                 ; entire file
  iYYYY  = ind(YYYY.ge.yrStrt .and. YYYY.le.yrLast)

  slp    = f->slp(iYYYY,:,:)
  printVarSummary(slp)                              ; variable overview

; ==============================================================
; dataset longitudes span 0=>357.5
; Because EOFs of the North Atlantic Oscillation are desired
; use the "lonFlip" (contributed.ncl) to reorder 
; longitudes to span -180 to 177.5: facilitate coordinate subscripting
; ==============================================================
  slp    = lonFlip( slp )
  printVarSummary(slp)                              ; note the longitude coord

; ==============================================================
; compute desired global seasonal mean: month_to_season (contributed.ncl) 
; ==============================================================
  SLP    = month_to_season (slp, season)
  nyrs   = dimsizes(SLP&time)
  printVarSummary(SLP)

; =================================================================
; create weights:  sqrt(cos(lat))   [or sqrt(gw) ]
; =================================================================
  rad    = get_d2r("float")
  clat   = f->lat           
  clat   = sqrt( cos(rad*clat) )                 ; gw for gaussian grid

; =================================================================
; weight all observations 
; =================================================================
  wSLP   = SLP                                   ; copy meta data
  wSLP   = SLP*conform(SLP, clat, 1)
  wSLP@long_name = "Wgt: "+wSLP@long_name

; =================================================================
; Access the area of interest via coordinate subscripting
; Note that by using eofunc_n_Wrap and eofunc_ts_n_Wrap, we 
; don't have to reorder data first.
; =================================================================
  xw     = wSLP(time|:,{lat|latS:latN},{lon|lonL:lonR})

  eof    = eofunc_n_Wrap(xw, neof, optEOF, 0)
  eof_ts = eofunc_ts_n_Wrap (xw, eof, optETS, 0)

  printVarSummary( eof )                         ; examine EOF variables
  printVarSummary( eof_ts )

; =================================================================
; Normalize time series: Sum spatial weights over the area of used
; =================================================================
  dimxw  = dimsizes( xw )
  mln    = dimxw(1)
  sumWgt = mln*sum( clat({lat|latS:latN}) )
  eof_ts = eof_ts/sumWgt

; =================================================================
; Extract the YYYYMM from the time coordinate 
; associated with eof_ts [same as SLP&time] 
; =================================================================

  yyyymm = cd_calendar(eof_ts&time,-2)/100  
;;yrfrac = yyyymm_to_yyyyfrac(yyyymm, 0.0); not used here

;============================================================
; PLOTS
;============================================================
  wks = gsn_open_wks("png","eof")         ; send graphics to PNG file
  plot = new(neof,graphic)                ; create graphic array
                                          ; only needed if paneling
; EOF patterns

  res                      = True         
  res@gsnDraw              = False        ; don't draw yet
  res@gsnFrame             = False        ; don't advance frame yet

  res@gsnAddCyclic         = False        ; plotted dataa are not cyclic
 
  res@mpFillOn             = False        ; turn off map fill
  res@mpMinLatF            = latS         ; zoom in on map
  res@mpMaxLatF            = latN
  res@mpMinLonF            = lonL
  res@mpMaxLonF            = lonR

  res@cnFillOn             = True         ; turn on color fill
  res@cnLinesOn            = False        ; True is default
 ;res@cnLineLabelsOn       = False        ; True is default
  res@cnFillPalette        = "BlWhRe"     ; set color map
  res@lbLabelBarOn         = False        ; turn off individual lb's

                                          ; set symmetric plot min/max
  symMinMaxPlt(eof, 16, False, res)       ; contributed.ncl

; panel plot only resources
  resP                     = True         ; modify the panel plot
  resP@gsnMaximize         = True         ; large format
  resP@gsnPanelLabelBar    = True         ; add common colorbar

  yStrt                    = yyyymm(0)/100
  yLast                    = yyyymm(nyrs-1)/100
  resP@txString            = "SLP: "+season+": "+yStrt+"-"+yLast

;*******************************************
; first plot
;*******************************************
  do n=0,neof-1
     res@gsnLeftString  = "EOF "+(n+1)
     res@gsnRightString = sprintf("%5.1f", eof@pcvar(n)) +"%"
     plot(n)=gsn_csm_contour_map_ce(wks,eof(n,:,:),res)
  end do
  gsn_panel(wks,plot,(/neof,1/),resP)     ; now draw as one plot

;*******************************************
; second plot
;*******************************************
; EOF time series  [bar form]

  rts           = True
  rts@gsnDraw   = False       ; don't draw yet
  rts@gsnFrame  = False       ; don't advance frame yet
  rts@gsnScale  = True        ; force text scaling               

; these four rtsources allow the user to stretch the plot size, and
; decide exactly where on the page to draw it.

  rts@vpHeightF = 0.40        ; Changes the aspect ratio
  rts@vpWidthF  = 0.85
  rts@vpXF      = 0.10        ; change start locations
  rts@vpYF      = 0.75        ; the plot


  rts@tiYAxisString = "Pa"                    ; y-axis label      

  rts@gsnYRefLine           = 0.              ; reference line   
  rts@gsnXYBarChart         = True            ; create bar chart 
  rts@gsnAboveYRefLineColor = "red"           ; above ref line fill red
  rts@gsnBelowYRefLineColor = "blue"          ; below ref line fill blue

; panel plot only resources
  rtsP                      = True            ; modify the panel plot
  rtsP@gsnMaximize          = True            ; large format
  rtsP@txString             = "SLP: "+season+": "+yStrt+"-"+yLast

  year = yyyymm/100

; create individual plots
  do n=0,neof-1
     rts@gsnLeftString  = "EOF "+(n+1)
     rts@gsnRightString = sprintf("%5.1f", eof@pcvar(n)) +"%"
     plot(n) = gsn_csm_xy (wks,year,eof_ts(n,:),rts)
  end do
  gsn_panel(wks,plot,(/neof,1/),rtsP)     ; now draw as one plot
end

