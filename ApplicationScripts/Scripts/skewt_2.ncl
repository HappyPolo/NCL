;**************************************************
; skewt_2.ncl
;
; Concepts illustrated:
;   - Drawing Skew-T plots
;   - Drawing a Skew-T plot with and without wind barbs
;   - Customizing the background of a Skew-T plot
;*************************************************
;
; This file is loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
;
; This file still has to be loaded manually
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/skewt_func.ncl"
;***********************************************
 begin

; --- Read Data; no winds; set to _FillValue------------;
  diri = "./"
  fili = "sounding.testdata"
  nlvl = 30  
  ncol = 16
  TestData = asciiread (diri+fili , (/nlvl,ncol/), "float") 

  p    = TestData (:,1)
  z    = TestData (:,2)
  q    = TestData (:,4)
  tc   = TestData (:,5) + 2.    ; for demo purposes
  tdc  = TestData (:,9)
                                ; create BOGUS winds
  wspd = new ( nlvl, "float", -999.)  ; wspd@_FillValue = -999.
  wdir = new ( nlvl, "float", -999.)  ; wdir@_FillValue = -999.

;*************************
; create plot
;*************************
  wks  = gsn_open_wks ("png", "skewt")  ; send graphics to PNG file

; --- Create background skew-T; plot sounding ---------------------

  skewtOpts                 = True
  skewtOpts@DrawColAreaFill = True    ; default is False
  skewtOpts@tiMainString    = "Raob Data; No Winds" 

  dataOpts   = False        ; no options

;  dataOpts@PrintZ = False
  skewt_bkgd = skewT_BackGround (wks, skewtOpts)
  skewt_data = skewT_PlotData   (wks, skewt_bkgd, p,tc,tdc,z \
                                    , wspd,wdir, dataOpts)
  draw (skewt_bkgd)
  draw (skewt_data)
  frame(wks)

; --- Create background skew-T and plot sounding + winds----------------
                                ; Create winds for demo
  wspd = fspan (0., 150., nlvl) ; wind speed at each level
  wdir = fspan (0., 360., nlvl) ; wind direction

                                ; Create a few "pibal" reports
  hght = (/ 1000., 3000., 7000., 25000. /)/3.208  ; hgt in M  
  hspd = (/   50.,   27.,  123.,    13. /) ;speed at each height
  hdir = (/   95.,  185.,  275.,   355. /) ;direction

  dataOpts           = True     ; options describing data and ploting
  dataOpts@PlotWindH = True     ; if available, plot wind barbs at height lvls
  dataOpts@HspdHdir  = True     ; wind speed and dir [else: u,v]

  dataOpts@Height    = hght     ; height of wind reports
  dataOpts@Hspd      = hspd     ; speed [or u component]
  dataOpts@Hdir      = hdir     ; dir   [or v component]

  skewtOpts@tiMainString = "Raob; [Wind Reports]" 
  skewtOpts@DrawColAreaFill = True    ; default is False

  skewtOpts                 = True
  skewtOpts@DrawColAreaFill = True    ; default is False

  skewt_bkgd = skewT_BackGround (wks, skewtOpts)
  skewt_data = skewT_PlotData   (wks, skewt_bkgd, p,tc,tdc,z \
                                    , wspd,wdir, dataOpts)
  draw (skewt_bkgd)
  draw (skewt_data)
  frame(wks)


; --- Make the wind barbs thicker (NCL 6.4.0)

  skewtOpts@tiMainString   = "Raob; Thicker Wind Barbs"
  dataOpts@DrawWindBarbThk = 1.5  ; default value is 1.0 (may be fractional) 

  skewt_bkgd = skewT_BackGround (wks, skewtOpts)
  skewt_data = skewT_PlotData   (wks, skewt_bkgd, p,tc,tdc,z \
                                    , wspd,wdir, dataOpts)
  draw (skewt_bkgd)
  draw (skewt_data)
  frame(wks)

 end
