;----------------------------------------------------------------------
; This script was created by Pierre Nabat during the NCL Workshop
; at CERFACS, October 4-5, 2012.
;
; It creates an XY plot of averaged temperature and pressure on the
; same page, using different labels on the right and left Y axis.
;----------------------------------------------------------------------
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"  
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"  

begin
;*******************************************
; open file and read in data
;*******************************************
  f    = addfile ("PLPNM50-1.75.M2006.nc", "r")

  REC    = f->tsur
  REC2   = f->mslp
 
  LAT2D= f->lat
  LON2D= f->lon
  
   
;********************************************
; subscript arrays
;********************************************
  
  rec = REC(0:11,8:70,8:108)
  rec2 = REC2(0:11,8:70,8:108)
 
  lon2d=LON2D(8:70,8:108)
  lat2d=LAT2D(8:70,8:108)
   
  
;********************************************
; get some parameters
;********************************************
  nlat = dimsizes(lat2d&y)
  nlon = dimsizes(lon2d&x)
  tdims    = dimsizes(rec)
  ntim     = tdims(0)
;********************************************
; create plot
;********************************************

;---Send output to A4-sized PDF file.
 wtype             = "pdf"
 wtype@wkPaperSize = "A4"
 wks  = gsn_open_wks (wtype, "ALADIN_tsur_mslp")
 
; DATA
;---Create array to hold both average curves
  data = new((/2,ntim/),typeof(rec))
  
  data(0,:)		     = dim_avg_n(rec,(/1,2/))
  data(1,:) 		     = dim_avg_n(rec2,(/1,2/))
  printVarSummary(data)

  
; TAILLE ET LIMITES  
  resL            = True
  resR            = True

  resL@gsnDraw    = False
  resL@gsnFrame   = False
  resR@gsnDraw    = False
  resR@gsnFrame   = False

  resL@vpHeightF  = 0.4               ; change aspect ratio of plot
  resL@vpWidthF   = 0.6

  resL@trXMinF    = min(rec&time)
  resL@trXMaxF    = max(rec&time)
  resR@trXMinF    = min(rec&time)
  resR@trXMaxF    = max(rec&time)
  
  resL@trYMinF    = min(data(0,:))
  resL@trYMaxF    = max(data(0,:))
  resR@trYMinF    = min(data(1,:))
  resR@trYMaxF    = max(data(1,:))

; COURBES
  resL@xyMonoDashPattern = True               ; all lines solid
  resL@xyLineColors      = (/"red"/)   ; line colors
  resL@xyLineThicknessF  = 2                  ; twice as thick
 ; resL@xyLineColor      = "red"

  resR@xyLineColor      = "NavyBlue"
  resR@xyDashPattern    = 2              ; Dashed line for 2nd curve
  resR@xyLineThicknessF = 2.0


; TITRES
  agrave  = "a~H-13V2F35~A~FV-2H3~"   ; 'A' is a back tick (`)
  aacute  = "a~H-13V2F35~B~FV-2H3~"
  eacute  = "e~H-13V2F35~B~FV-2H3~"   ; 'B' is a regular tick (')
  egrave  = "e~H-13V2F35~A~FV-2H3~"
  cedil   = "c~H-13F35~K~FH2~"
  iuml    = "i~H-09V2F35~H~FV-2H3~"
  ocirc   = "o~H-14V2F35~C~FV-2H3~"

  resL@tiMainString    = "Premi" + egrave + "res courbes"
  resL@tiYAxisString   = "Temperature (degC)"
  resR@tiYAxisString   = "Pressure (hPa)"
  resL@tiXAxisString   = "Month"
  
; TICK MARKS
  resL@tmXBMode  = "Explicit"
;  resL@tmXBTickSpacingF = 1.0
;  resL@tmXBTickStartF   = 25
;  resL@tmXBTickEndF   = 36
  resL@tmXBValues = ispan(25,36,1)
  resL@tmXBLabels = (/ "Jan","Feb","Mar","Apr","May","Jun","Jul","Aug","Sep","Oct","Nov","Dec" /)
  resL@tmYLMinorPerMajor = 1

;  LEGENDE
  resL@pmLegendDisplayMode    = "Always"            ; turn on legend
  resL@pmLegendSide           = "Top"               ; Change location of 
  resL@pmLegendParallelPosF   = 0.1              ; move units right
  resL@pmLegendOrthogonalPosF = -0.3                ; move units down
  resL@lgJustification       = "BottomLeft"
  resL@pmLegendWidthF         = 0.10                ; Change width and
  resL@pmLegendHeightF        = 0.10                ; height of legend.
  resL@lgPerimOn              = False               ; turn off box around
  resL@lgLabelFontHeightF     = .02                 ; label font height
  resL@xyExplicitLegendLabels = (/"Tsur"/)         ; create explicit labels

  resR@pmLegendDisplayMode    = "Always"            ; turn on legend
  resR@pmLegendSide           = "Top"               ; Change location of 
  resR@pmLegendParallelPosF   = 0.1                  ; move units right
  resR@pmLegendOrthogonalPosF = -0.5                ; move units down
  resR@lgJustification       = "BottomLeft"
  resR@pmLegendWidthF         = 0.10                ; Change width and
  resR@lgPerimOn              = False               ; turn off box around
  resR@lgLabelFontHeightF     = .02                 ; label font height
  resR@xyExplicitLegendLabels = (/"Ps"/)         ; create explicit labels


   ;---Create average-across-all-values plot
  plot = gsn_csm_xy2(wks,rec&time,data(0,:),data(1,:),resL,resR) 

;---Maximize plots in the frame. They will also get drawn here.
  maximize_output(wks,True)
end































