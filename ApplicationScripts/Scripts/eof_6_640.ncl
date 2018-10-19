;================================================
; eof_6_640.ncl
;
; Concepts illustrated:
;   - Calculating EOFs
;   - Drawing a black-and-white XY plot
;   - Applying spatial weighting
;   - Writing EOFs to a NetCDF file
;   - Labeling the X axis with nicely-formatted time labels
;   - Drawing a time series plot
;================================================
; This script uses functions eofunc_n_Wrap and 
; eofunc_ts_n_Wrap, which were added in NCL V6.4.0.
;================================================
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"

;*******************************************
; Read data
;*******************************************
  diri   = "./"
  fili   = "erai_1989-2009.mon.msl_psl.nc"                                                    ; rectilinear
  f      = addfile(diri+"erai_1989-2009.mon.msl_psl.nc","r")   ; open file                 
  p      = f->SLP(::12,{0:90},:)                      ; p(time,latitude,longtitude)       
  printVarSummary(p)                                  ; p(21,61,240)
  
;*******************************************
; Calculate EOFs
;*******************************************
  w      = sqrt(cos(0.01745329*p&latitude))           ; weights(61)                   
  wp     = p*conform(p, w, 1)                         ; wp(21,61,240)
  copy_VarCoords(p, wp)                               ; wp(time,lat,lon)
  printVarSummary(wp)  ; [time | 21] x [latitude | 61] x [longitude | 240]
  
  neof   = 4                                          ; user specified (commonly <=5) 
  eof    = eofunc_n_Wrap(wp, neof, False, 0)
  eof_ts = eofunc_ts_n_Wrap (wp, eof, False, 0)
  
  printVarSummary( eof )                              ; examine EOF variables                 
  printVarSummary( eof_ts )
  
;*******************************************
; Create netCDF: simple approach                                               
;*******************************************
  
  fnc          = "EOF.erai_1989-2009.Jan.nc"
  system("/bin/rm -f "+fnc)               ; rm any pre-existing file            
  fout         = addfile(fnc, "c")   ; new netCDF file                   
  
  fout@title   = "EOF of SLP: January 1989-2009"
  fout->EOF    = eof
  fout->EOF_TS = eof_ts
  
;*******************************************
; North significance test: any pcvar, eval_transpose, eval can be used
;*******************************************
  print("---")
  print("--- eofunc_north ---")
  print("---")
  
  dimp   = dimsizes(p)
  ntim   = dimp(0)                                            ; max # eigenvalues possible
  
  prinfo = True
  sig    = eofunc_north(eof@pcvar, ntim, prinfo)            
                                                              
  print("---")
;*******************************************
;  Create a 'time' axis for plot
;*******************************************

  yyyymm = cd_calendar(eof_ts&time,-1)  
  yrfrac = yyyymm_to_yyyyfrac(yyyymm, 0.0); not used here

;*******************************************
;  plots
;*******************************************

  pltType = "png"                         ; send graphics to PNG file

  wks = gsn_open_wks(pltType,"eof")
;
  plot = new(neof,graphic)                ; create graphic array
                                          ; only needed if paneling
  res                      = True         
  res@gsnDraw              = False        ; don't draw yet
  res@gsnFrame             = False        ; don't advance frame yet
  res@gsnPolar             = "NH"         ; specify the hemisphere
 
  res@mpCenterLonF         = 0.           ; default is 0 [GM]
  res@mpMinLatF            = min(wp&latitude)
  res@mpMaxLatF            = max(wp&latitude)

  res@cnFillOn             = True         ; turn on color fill
  res@cnFillPalette        = "BlWhRe"     ; choose colormap
  res@cnLinesOn            = True         ; True is default
  res@cnLineLabelsOn       = False        ; True is default
  res@lbLabelBarOn         = False        ; turn off individual lb's
                                          ; set symmetric plot min/max
  symMinMaxPlt(eof, 16, False, res); contributed.ncl

; panel plot only resources

  resP                     = True         ; modify the panel plot
  resP@gsnMaximize         = True         ; large format
  resP@gsnPanelLabelBar    = True         ; add common colorbar
  resP@txString            = "SLP: January 1979-2014: eofunc_north"

  do n=0,neof-1
     res@gsnLeftString  = "EOF "+(n+1)
     res@gsnCenterString= "NORTH="+sig(n)
     res@gsnRightString = sprintf("%5.1f", eof@pcvar(n)) +"%"

     plot(n) = gsn_csm_contour_map_polar(wks,eof(n,:,:),res)
  end do
  gsn_panel(wks,plot,(/2,2/),resP)     ; draw all 'neof' as one plot

;*******************************************
; time series (principal component) plot
;*******************************************

  eof_ts@long_name = "Amplitude"

  rts           = True
  rts@gsnDraw   = False       ; don't draw yet
  rts@gsnFrame  = False       ; don't advance frame yet

  rts@vpHeightF = 0.40        ; Changes the aspect ratio
  rts@vpWidthF  = 0.85
  rts@vpXF      = 0.10        ; change start locations
  rts@vpYF      = 0.75        ; the plot

  rts@gsnYRefLine           = 0.              ; reference line   
  rts@gsnAboveYRefLineColor = "red"           ; above ref line fill red
  rts@gsnBelowYRefLineColor = "blue"          ; below ref line fill blue

; panel plot only resources
  rtsP                      = True             ; modify the panel plot
  rtsP@gsnMaximize          = True             ; large format
  rtsP@txString             = "SLP: January 1979-2014: eofunc_north"
      
  do n=0,neof-1
     rts@gsnLeftString  = "EOF "+(n+1)
     rts@gsnCenterString= "NORTH="+sig(n)
     rts@gsnRightString = sprintf("%5.1f", eof@pcvar(n)) +"%"

     plot(n) = gsn_csm_xy (wks,yrfrac,eof_ts(n,:),rts)
  end do
  gsn_panel(wks,plot,(/2,2/),rtsP)        ; draw all 'neof' as one plot


