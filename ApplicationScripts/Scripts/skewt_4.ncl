;**************************************************
; skewt_4.ncl
;
; Concepts illustrated:
;   - Drawing Skew-T plots
;   - Drawing two raobs on the same Skew-T plot
;   - Customizing the background of a Skew-T plot
;**************************************************
;
; This file is loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
;
; This file still has to be loaded maually    
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/skewt_func.ncl" 

 begin

; --- Read Data ----------------------------------------;
 ;diri = "/fs/scd/home1/shea/ncldata_input/" 
  diri = "./"
  fili = "sounding_ATS.dat"
  nlvl = 65 
  ncol = 7 
  TestData = asciiread (diri+fili , (/nlvl,ncol/), "float") 

  p    = TestData (:,0)
  tc   = TestData (:,1)
  tdc  = TestData (:,2)
  q    = TestData (:,3)
  z    = TestData (:,4)
  wspd = TestData (:,5)
  wdir = TestData (:,6)

;*************************
; create plot
;*************************
  wks  = gsn_open_wks ("png", "skewt")  ; send graphics to PNG file

; --- Create background skew-T and plot sounding----------------

  skewtOpts                 = True
  skewtOpts@DrawColAreaFill = True    ; default is False
  skewtOpts@tiMainString    = "ATS Rawindsonde: Multiple Soundings" 

  skewt_bkgd = skewT_BackGround (wks, skewtOpts)
  draw (skewt_bkgd)

  dataOpts                  = True     ; options describing data and ploting
 ;dataOpts@DrawFahrenheit   = False    ; default is True
  dataOpts@PrintZ           = False    ; do not print Z 
  dataOpts@ThermoInfo       = False    ; print thermodynamic info

;*****************************************************************
; First sounding
;*****************************************************************
  dataOpts@colTemperature   = "black"
  dataOpts@colDewPt         = dataOpts@colTemperature
  dataOpts@linePatternDewPt = 1
 ;dataOpts@xpWind           = 42.     ; move to left [default is 45]
  skewt_data = skewT_PlotData   (wks, skewt_bkgd, p,tc,tdc,z \
                                    , wspd,wdir, dataOpts)
  draw (skewt_data)
                                       
;*****************************************************************
; Second sounding   [bogus data: original altered slightly]
;*****************************************************************
  tc   = TestData (:,1) + 5
  tdc  = TestData (:,2) - random_normal(5,1,nlvl)
  q    = TestData (:,3) 
 ;z    = TestData (:,4)    
  wspd = TestData (:,5)
  wdir = TestData (:,6)

  dataOpts@Wthin     = 3        ; plot every n-th wind barb
  dataOpts@xpWind    = 40.      ; new location for winds [default 45]
  dataOpts@colTemperature  = "magenta"
  dataOpts@colDewPt        = dataOpts@colTemperature
  dataOpts@colWindP        = dataOpts@colTemperature
  
  skewt_data = skewT_PlotData   (wks, skewt_bkgd, p,tc,tdc,z \
                                    , wspd,wdir, dataOpts)

  draw (skewt_data)
  frame(wks)

 end
