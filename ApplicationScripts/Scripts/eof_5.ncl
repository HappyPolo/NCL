; ==============================================================
; eof_5.ncl
;
; Concepts illustrated:
;   - Calculating standard EOFs
;   - Rotate EOFs via varimax method
;   - Reorder the varimax EOFs to be is descending order
;   - Using coordinate subscripting to read a specified geographical region
;   - Calculating symmetric contour intervals
;   - Drawing filled bars above and below a given reference line
;   - Drawing subtitles at the top of a plot
;
; ==============================================================
; NCL V6.4.0 has new functions eofunc_n_Wrap and 
; eofunc_ts_n_Wrap that allow you to calculate the EOFs without 
; first having to first reorder the data. See eof_3_640.ncl.
; ==============================================================
; Calculate Northern Hemisphere 500 hPa EOFs 
; ==============================================================
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"

; ==============================================================
; User defined parameters that specify region of globe and
; ==============================================================
  vname  = "hgt"               ; variable name
  fname  = "hgt.mon.mean.nc"   ; CDC: NCEP Reanalysis

  levP   = 500                 ; desired level

  latS   =  20.                ; N. Hemisphere
  latN   =  90. 

  yrStrt = 1979
  yrLast = 2011

  season = "DJF"               ; choose Dec-Jan-Feb seasonal mean

  neof   =  6                  ; number of standard EOFs to calculate
  optEOF = False      
  optETS = False

; ==============================================================
; Open the file: Read only the user specified period
; ==============================================================
  f      = addfile ("hgt.mon.mean.nc", "r")

  TIME   = f->time
  YYYY   = cd_calendar(TIME,-1)/100                 ; entire file
  iYYYY  = ind(YYYY.ge.yrStrt .and. YYYY.le.yrLast)

  VAR    = short2flt(f->$vname$(iYYYY,{levP},{latS:latN},:))
  printVarSummary(VAR)                              ; variable overview

; ==============================================================
; compute desired global seasonal mean: month_to_season (contributed.ncl) 
; ==============================================================
  var    = month_to_season (VAR, season)
  nyrs   = dimsizes(var&time)
  printVarSummary(var)

; =================================================================
; create weights:  sqrt(cos(lat))   [or sqrt(gw) ] for covariance
; =================================================================
  rad    = 4.0*atan(1.0)/180.0
  clat   = cos(rad*var&lat)           
  clat   = where(clat.lt.0, 0.0, clat)  ; avoid a potential numerical issue at pole
  clat   = sqrt( clat )  ; avoid a potential numerical issue at pole

; =================================================================
; weight all observations 
; =================================================================
  wvar   = var                                   ; copy meta data
  wvar   = var*conform(var, clat, 1)
  wvar@long_name = "Wgt: "+wvar@long_name

; =================================================================
; EOF
; Reorder (lat,lon,time) the *weighted* input data
; Access the area of interest via coordinate subscripting
; =================================================================
  x      = wvar(lat|:,lon|:,time|:)

  eof    = eofunc_Wrap(x, neof, optEOF)      
  eof_ts = eofunc_ts_Wrap (x, eof, optETS)

; =================================================================
; Perform varimax rotation
; =================================================================

  eof_rot = eofunc_varimax_Wrap( eof, 1 )
  printVarSummary( eof_rot )        
  print("eof_rot: min="+min(eof_rot)+"   max="+max(eof_rot) )

; =================================================================
; put into descending order
; =================================================================

  eofunc_varimax_reorder( eof_rot )
  printVarSummary( eof_rot )        

; =================================================================
; Normalize time series: Sum spatial weights over the area of used
; =================================================================

  dimx   = dimsizes( x )
  mln    = dimx(1)
  sumWgt = mln*sum( clat )
  eof_ts = eof_ts/sumWgt
  print("eof_ts: min="+min(eof_ts)+"   max="+max(eof_ts) )

; =================================================================
; Extract the YYYYMM from the time coordinate 
; associated with eof_ts [same as var&time] 
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
  res@gsnPolar             = "NH"

  res@mpFillOn             = False        ; turn off map fill
  res@mpMinLatF            = latS         ; zoom in on map
  res@mpMaxLatF            = latN

  res@cnFillOn             = True         ; turn on color fill
  res@cnFillPalette        = "BlWhRe"     ; choose colormap
  res@cnLinesOn            = False        ; True is default
  res@cnLineLabelsOn       = False        ; True is default
  res@lbLabelBarOn         = False        ; turn off individual lb's

                                          ; set symmetric plot min/max
  symMinMaxPlt(eof, 16, False, res)       ; contributed.ncl

; panel plot only resources
  resP                     = True         ; modify the panel plot
  resP@gsnMaximize         = True         ; large format
  resP@gsnPanelLabelBar    = True         ; add common colorbar

  yStrt                    = yyyymm(0)/100
  yLast                    = yyyymm(nyrs-1)/100
  resP@txString            = "Classic EOFs: "+vname+": "+season+": "+yStrt+"-"+yLast

;*******************************************
; Plot standard patterns
;*******************************************
  do n=0,neof-1
     res@gsnLeftString  = "EOF "+(n+1)
     res@gsnRightString = sprintf("%5.1f", eof@pcvar(n)) +"%"
     plot(n)=gsn_csm_contour_map_polar(wks,eof(n,:,:),res)
  end do
  gsn_panel(wks,plot(0:3),(/2,2/),resP)     ; only plot the 1st four
 ;gsn_panel(wks,plot,(/neof/2,2/),resP)     ; now draw as one plot

;*******************************************
; second plot
;*******************************************
; EOF time series  [bar form]

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

  rts@tiYAxisString = "m"                     ; y-axis label      

  rts@gsnYRefLine           = 0.              ; reference line   
  rts@gsnXYBarChart         = True            ; create bar chart 
  rts@gsnAboveYRefLineColor = "red"           ; above ref line fill red
  rts@gsnBelowYRefLineColor = "blue"          ; below ref line fill blue

; panel plot only resources
  rtsP                      = True            ; modify the panel plot
  rtsP@gsnMaximize          = True            ; large format
  rtsP@gsnPaperOrientation  = "portrait"      
  rtsP@txString             = vname+": "+season+": "+yStrt+"-"+yLast

  year = yyyymm/100

; create individual plots
  do n=0,neof-1
     rts@gsnLeftString  = "EOF "+(n+1)
     rts@gsnRightString = sprintf("%5.1f", eof@pcvar(n)) +"%"
     plot(n) = gsn_csm_xy (wks,year,eof_ts(n,:),rts)
  end do
  gsn_panel(wks,plot(0:3),(/2,2/),rtsP)          ; only plot 1st 4     
 ;gsn_panel(wks,plot,(/neof/2,2/),rtsP)     

;*******************************************
; Plot rotated patterns
;*******************************************
  resP@txString            = "Varimax EOFs: "+vname+": "+season+": "+yStrt+"-"+yLast
  do n=0,neof-1
     res@gsnLeftString  = "EOF "+(n+1)
     res@gsnRightString = sprintf("%5.1f", eof_rot@pcvar_varimax(n)) +"%"
     plot(n)=gsn_csm_contour_map_polar(wks,eof_rot(n,:,:),res)
  end do
                                       ; 
  gsn_panel(wks,plot(0:3),(/2,2/),resP)     ; now draw as one plot
 ;gsn_panel(wks,plot,(/neof/2,2/),resP)     
