;
; godas_3.ncl
;
; Concepts illustrated:
;   - Reading multiple GODAS netCDF files
;   - Calculating a monthly climatology using user specified years
;   - Calculating global anomalies at each grid point   
;   - Calculating a regional (area averaged) anomaly time series
;   - Drawing a time series plot
;

load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
                                  
begin
;***************************************************************
; Read the variable which spans 30 netCDF files [1980-2009]
; Use 'short2flt' to unpack the variable which is type 'short'
;***************************************************************
  diri = "/project/cas/shea/GODAS/"
  fils = systemfunc ("cd "+diri+" ; ls pottmp.*.nc") ; file paths
  fils = systemfunc ("cd "+diri+" ; ls pottmp.*.nc") ; file paths
  f    = addfiles (fils, "r")   
  print(fils)

  x    = short2flt( f[:]->pottmp(:,{5},:,:) ) ; read/unpack from all yearly files
  printVarSummary (x)             ; [time| 354]x[lat| 418]x[lon| 360]

;***************************************************************
; Create a 1995-2004 monthly climatology
; Use cd_calendar to return 'human understandable' units      
;***************************************************************
  yrStrt = 1995
  yrLast = 2004

  time   = x&time                   ; time associated with "x"
  yyyymm = cd_calendar(time, -1)    ; units 'yyyymm' 
  yyyy   = yyyymm/100               ; truncate to get yyyy only
  ii     = ind(yyyy.ge.yrStrt .and. yyyy.le.yrLast)

  xClm   = clmMonTLL( x(ii,:,:) )
  xClm@time_span = yrStrt+"-"+yrLast
  printVarSummary(xClm)
  printMinMax(xClm, True)
   
;***************************************************************
; At each grid point calculate anomalies from 'xClm'
;***************************************************************
  jj     = ind(yyyy.le.2008)
  xAnom  = calcMonAnomTLL ( x(jj,:,:), xClm)

;***************************************************************
; "Trick" overwrite the "days since ..." with yyyymm
;***************************************************************
  xAnom&time = yyyymm(jj)

  printVarSummary(xAnom)          ; note time units
  printMinMax(xAnom, True)

;***************************************************************
; Specify a region and compute an areal average anomaly
; Use simple cosine weighting
;***************************************************************
  latS   = 10
  latN   = 20
  lonL   = 280
  lonR   = 360

  clat   = f[0]->lat
  clat   = cos(0.01745329*clat)
  
  xAnomRegion = wgt_areaave_Wrap(xAnom(:,{latS:latN},{lonL:lonR}) \
                                ,clat({latS:latN}), 1.0, 0)
  printVarSummary(xAnomRegion)
  printMinMax(xAnomRegion, True)

;********************************
; create map plots
;********************************    
  nmo = 0                                ; for demo, only plot Jan
  wks   = gsn_open_wks ("ps", "godas"  ) ; open workstation 
  gsn_define_colormap(wks, "amwg")

; add gray to colormap for continents  [optional]  
;
; This will not be necessary in V6.1.0 and later. Named colors can
; be used without having to first add them to the color map.
;
  i = NhlNewColor(wks,0.7,0.7,0.7)              ; medium grey  

  res   = True                                  ; plot mods desired
  res@gsnMaximize       = True
  res@gsnSpreadColors   = True
  res@gsnSpreadColorEnd = -2                    ; do not use gray for contours
;;res@gsnPaperOrientation = "portrait"          ; force portrait

  res@cnFillOn         = True                   ; color
  res@cnLinesOn        = False
  res@cnLineLabelsOn   = False
  res@mpLandFillColor  = "grey"                 ; color of land
  res@mpFillDrawOrder  = "PostDraw"
  res@lbLabelAutoStride= True                   ; let NCL choose stride

  res@tiMainString         = "January Clm: "+yrStrt+"-"+yrLast
  plot = gsn_csm_contour_map_ce(wks,xClm(nmo,:,:), res)  

;********************************
; create time series plot 
;********************************    
  yrfrac         = yyyymm_to_yyyyfrac(yyyymm(jj), 0.0)  ; plot axis

  resxy          = True                   ; plot mods desired
  resxy@gsnMaximize= True                 ; force ps/eps/pdf as large as possible
  resxy@vpHeightF= 0.4                    ; change aspect ratio of plot
  resxy@vpWidthF = 0.75                 
  
 ;resxy@trYMinF  = -1.0                   ; min value on y-axis
 ;resxy@trYMaxF  =  1.0                   ; max value on y-axis
  resxy@trXMinF  = 1980
  resxy@trXMaxF  = 2010                   ; Force to 2012          

  resxy@gsnLeftString   = "pottmp: Region 10N-20N  , 80W-0" 
  resxy@gsnRightString  =  x@units
  resxy@gsnYRefLine     = 0.0             ; create a reference line   

  resxy@gsnAboveYRefLineColor = "red"              ; above ref line fill red
  resxy@gsnBelowYRefLineColor = "blue"             ; below ref line fill blue

  plot = gsn_csm_xy (wks,yrfrac,xAnomRegion,resxy) ; create plot

end

