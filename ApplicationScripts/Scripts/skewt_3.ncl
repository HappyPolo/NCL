;**************************************************
; skewt_3.ncl
;
; Concepts illustrated:
;   - Drawing Skew-T plots
;   - Thinning the wind barbs in a Skew-T plot
;   - Customizing the background of a Skew-T plot
;**************************************************
;
; This file is loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
;
; This file still has to be loaded manually
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/skewt_func.ncl"
;**************************************************
 begin

; --- Read Data ----------------------------------------;
  diri = "./"
  fili = "sounding_ATS.dat"
  nlvl = 65 
  ncol = 7 
  TestData = asciiread (diri+fili , (/nlvl,ncol/), "float") 
; order: Surface is 'bottom'  eg: 1000,950,935,897,...  
                            
  p    = TestData (:,0)    ; pressure     [mb / hPa] 
  tc   = TestData (:,1)    ; temperature  [C]    
  tdc  = TestData (:,2)    ; dew pt temp  [C]   
  z    = TestData (:,4)    ; geopotential [gpm] 
  wspd = TestData (:,5)    ; wind speed   [knots or m/s]    
  wdir = TestData (:,6)    ; meteorological wind dir   
;*************************
; create plot
;*************************
  wks  = gsn_open_wks ("png", "skewt")  ; send graphics to PNG file

; --- Create background skew-T and plot sounding----------------

  skewtOpts                 = True
  skewtOpts@DrawColAreaFill = True    ; default is False
  skewtOpts@tiMainString    = "ATS Rawindsonde: default dataOpts" 

  dataOpts                  = False    ; options describing data and ploting

  skewt_bkgd = skewT_BackGround (wks, skewtOpts)
  skewt_data = skewT_PlotData   (wks, skewt_bkgd, p,tc,tdc,z \
                                    , wspd,wdir, dataOpts)
  draw (skewt_bkgd)
  draw (skewt_data)
  frame(wks)

  dataOpts           = True     ; options describing data and ploting
  dataOpts@Wthin     = 3        ; plot every n-th wind barb

  skewtOpts@tiMainString    = "ATS Rawindsonde: degC + Thin wind" 
  skewtOpts@DrawFahrenheit  = False   ; default is True

  skewt_bkgd = skewT_BackGround (wks, skewtOpts)
  skewt_data = skewT_PlotData   (wks, skewt_bkgd, p,tc,tdc,z \
                                    , wspd,wdir, dataOpts)
  draw (skewt_bkgd)
  draw (skewt_data)
  frame(wks)


 end
