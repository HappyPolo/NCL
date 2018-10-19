;**************************************************
; skewt_5.ncl
;
; Concepts illustrated:
;   - Paneling Skew-T plots
;**************************************************
; At this time the 'wmvect' can not yet be paneled.
; Hence, no windbards. 
;**************************************************
;
; This file is loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
;
; This file still has to be loaded manually
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/skewt_func.ncl"
;**************************************************
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
; create plot: sample  ... repeat 4 times
;*************************
  wks  = gsn_open_wks ("png", "skewt"); send graphics to PNG file

; --- Create background skew-T; plot sounding ---------------------

  skewtOpts                 = True
  skewtOpts@DrawColAreaFill = True    ; default is False
  skewtOpts@DrawWind        = False   ; not possible with panel
  skewtOpts@Panel           = True    ; Default is False

  dataOpts   = False        ; no options

  nplt = 5
  plot = new (nplt, "graphic")
  do np=0,nplt-1
     skewtOpts@tiMainString    = "Raob Data: "+(np+1) 
     skewt_bkgd = skewT_BackGround (wks, skewtOpts)
     plot(np)   = skewT_PlotData   (wks, skewt_bkgd, p,tc,tdc,z \
                                       , wspd,wdir, dataOpts)
     delete(skewt_bkgd)
  end do

;************************************************
; create panel
;************************************************
  resP            = True              ; modify the panel plot
  resP@txString   = "Panel: No Wind Barbs"
  resP@gsnPanelRowSpec = True         ; tell panel what order to plt

  gsn_panel(wks,plot,(/2,1,2/),resP)        ; now draw as one plot

 end

