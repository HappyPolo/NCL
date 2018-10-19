;**************************************************
; skewt_8.ncl
;**************************************************
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"   
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"  
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
  wspd = fspan (0., 150., nlvl) ; wind speed at each level
  wdir = fspan (0., 360., nlvl) ; wind direction

                                ; Create a few "pibal" reports
  hght = (/ 1000., 3000., 7000., 25000. /)/3.208  ; hgt in M  
  hspd = (/   50.,   27.,  123.,    13. /) ;speed at each height
  hdir = (/   95.,  185.,  275.,   355. /) ;direction

;*************************
; create plot: sample  ... repeat 4 times with different options
;*************************
  wks  = gsn_open_wks ("png", "skewt")  ; send graphics to PNG file

; --- Create background skew-T; plot sounding ---------------------

  skewtOpts                 = True
  skewtOpts@DrawColAreaFill = True    ; default is False
  skewtOpts@DrawWind        = True    ; not possible with panel
  skewtOpts@tiMainOffsetXF  = 0.0     ; skewT default is -0.1
  skewtOpts@tmXBLabelFontHeightF = 0.0125   ; 0.14 is default
  skewtOpts@tmYLLabelFontHeightF = 0.0125   ; 0.14 is default
  skewtOpts@tiMainFontHeightF    = 0.0175   ; 0.025 is default

  dataOpts                  = True     ; options describing data and ploting
  dataOpts@PlotWindH        = True     ; if available, plot wind barbs at height lvls
  dataOpts@HspdHdir         = True     ; wind speed and dir [else: u,v]

  dataOpts@Height           = hght     ; height of wind reports
  dataOpts@Hspd             = hspd     ; speed [or u component]
  dataOpts@Hdir             = hdir     ; dir   [or v component]

  skewtOpts@vpWidthF        = 0.38   ; skewT default is 0.85
  skewtOpts@vpHeightF       = 0.38   ;                  0.85

  nplt = 4
  plot = new (nplt, "graphic")
  do np=0,nplt-1
    
     if (np.eq.0) then
         skewtOpts@vpXF      = 0.08        ; upper left
         skewtOpts@vpYF      = 0.95
         skewtOpts@DrawFahrenheit = True   ; default is True 
         skewtOpts@tiXAxisString  = ""
     end if
    
     if (np.eq.1) then
         skewtOpts@vpXF      = 0.56        ; upper right
         skewtOpts@vpYF      = 0.95
         skewtOpts@DrawFahrenheit = False  ; default is True 
         skewtOpts@tiYAxisString  = ""
         skewtOpts@tiXAxisString  = ""
     end if
    
     if (np.eq.2) then
         skewtOpts@vpXF      = 0.08        ; lower left
         skewtOpts@vpYF      = 0.46
         skewtOpts@DrawFahrenheit = True   ; default is True 
         skewtOpts@tiXAxisString  = "Temperature (F)"
         skewtOpts@tiYAxisString  = "P (hPa)"
     end if
    
     if (np.eq.3) then
         skewtOpts@vpXF      = 0.57        ; lower Right
         skewtOpts@vpYF      = 0.46
         skewtOpts@DrawFahrenheit = False  ; default is True 
         skewtOpts@tiXAxisString  = "Temperature (C)"
         skewtOpts@tiYAxisString  = ""   
     end if

     skewtOpts@tiMainString    = "Raob Data: "+(np+1) 
     skewt_bkgd = skewT_BackGround (wks, skewtOpts)
     draw (skewt_bkgd)
     
     plot(np)   = skewT_PlotData   (wks, skewt_bkgd, p,tc,tdc,z \
                                       , wspd,wdir, dataOpts)

  end do

  frame(wks)

 end
