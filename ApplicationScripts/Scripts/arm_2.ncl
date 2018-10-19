;=======================================================
; arm_2.ncl
;=======================================================
;
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
; load "./contributed.ncl"

begin
;=======================================================
; Import all the file names
; .  The standard (simple) approach is to use the unix 'ls' 
; .  but this results in a system error "Argument list too long"
; .  Use the slightly more complicated form below.
; .  Also, ARM sends a txt file will the file names.
;=======================================================
  diri = "./"
  fili = "ARM_SGP.2005-2009.cdf"
  
;=======================================================
; Read the cloud fraction and quality flags from all the files
;=======================================================
  f      = addfile(diri+fili, "r")
  x      = f->cloudfraction
  xqc    = f->qc_cloudfraction 
  printVarSummary(x)

;=======================================================
; Read the time_offset and use it to overwrite the 'time' coordinate
;=======================================================
  timeo    = f->time_offset

  x&time   = timeo
  xqc&time = timeo
  printVarSummary(x)

;=======================================================
; "For fun" print out dates: Use the time_offset 
;=======================================================
 ;ymdhm    = cd_calendar(x&time, -5)
 ;print(sprinti("%0.4i", ymdhm(:,0)) + "  " + \  ; year
 ;      sprinti("%0.2i", ymdhm(:,1)) + "  " + \  ; month
 ;      sprinti("%0.2i", ymdhm(:,2)) + "  " + \  ; day
 ;      sprinti("%0.2i", ymdhm(:,3)) + "  " + \  ; hour
 ;      sprinti("%0.2i", ymdhm(:,4)) + "  " + \  ; min
 ;      sprinti("%0.4i", ymdhm(:,5)) )           ; sec

;=======================================================
; Data exploration: What is the average/biggest temporal gap?
; Results: avg(tDiff)=36.147 minutes ; max(tDiff)=1050 minutes: 17.5 hours
;=======================================================
  ntim     = dimsizes(timeo)
  tDiff    = (timeo(1:)-timeo(:ntim-2))/60       ; minutes
  tDiffMax = max(tDiff)                          ; minutes
  tDiffAvg = avg(tDiff)
  
  print(" ")
  print("avg(tDiff)="+tDiffAvg+" minutes")
  print("max(tDiff)="+tDiffMax+" minutes: "+(tDiffMax/60)+" hours")
  print(" ")
;=======================================================
; Use the quality flags to eliminate 'bad' values
; Basically, any non-zero value.
;=======================================================
  x      = mask(x, xqc.ne.0, False)

;=======================================================
; [1] Data exploration: 'stat_dispersion'[~25% of all values missing]
; [2] Average all the values at each time. Arithmetic regional avg. 
;     No spatial wgting. Small area.
;     Making the assumption that these are highly correlated. 
;     This reduces the number of missing values to 0.5%.
; [3] Linearly interpolate [2] to equally spaced time intervals.    
; [4] Perform a 97-pt running average. 
;     Since the values are not equally spaced this is technically
;     not the right thing to do.  
;=======================================================
  
  opt     = True                   
  opt@PrintStat = True
 ;xStat   = stat_dispersion(x, opt )    ; can be slow for *big* arrays

  xAvg    = dim_avg_n_Wrap(x, (/1,2/))  ; regional averages (arithmetic)
  printVarSummary(xAvg)                 ; xAvg(time)
  xStat   = stat_dispersion(xAvg, opt ) 

  tInt    = toint((timeo(ntim-1)-timeo(0))/(30*60))   ; seconds [30 min intervals]
  TIME    = fspan(timeo(0),timeo(ntim-1),tInt) ; equally spaced time
  TIME@units = timeo@units

  xAvgTim = linint1_n_Wrap (xAvg&time,xAvg, False, TIME, 0, 0)
  printVarSummary(xAvgTim)
 ;xStat   = stat_dispersion(xAvgTim, opt )    

  nwgt    = 181                         ; arbitrary
;  xRun    = wgt_runave_n_Wrap(xAvgTim, fspan(1,1,nwgt), 0, 0)
  xRun    = wgt_runave_n_Wrap(xAvgTim, 1., 0, 0)
  printVarSummary(xRun)
 ;xStat   = stat_dispersion(xRun, opt )    

;************************************************
; plotting parameters
;************************************************
 wks   = gsn_open_wks ("png","arm")              ; send graphics to PNG file

 res                  = True                     ; plot mods desired
 res@gsnMaximize      = True                     ; make ps, pdf, eps large
 res@tiMainString     = fili                     ; add title
 res@vpHeightF        = 0.4                      ; change aspect ratio of plot 
 res@vpWidthF         = 0.75                                     
;res@vpXF             = 0.125                    ; start plot at x ndc coord 
 res@xyLineThicknessF = 2                        ; make twice the default

 tplot                = timeo/86400              ; change to days
 tplot@long_name      = "days since 2005-01-01 15:00:00"
                                                 ; Thin for visual reasons
 res@gsnCenterString  = "Original Regional Averages; Original time_offset; Thinned"
 plot  = gsn_csm_xy (wks,tplot(::3),xAvg(::3),res) 

 TPLOT                = TIME/86400               ; change to days
 TPLOT@long_name      = "days since 2005-01-01 15:00:00"
 res@gsnCenterString  = " Regional Running Averages"
 plot  = gsn_csm_xy (wks,TPLOT,xRun,res) 
end
