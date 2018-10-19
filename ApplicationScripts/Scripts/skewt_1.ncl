;***********************************************
; skewt_1.ncl
;
; Concepts illustrated:
;   - Drawing a default Skew-T background
;   - Customizing the background of a Skew-T plot
;*************************************************
;
; This file is loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
;
; This file still has to be loaded manually
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/skewt_func.ncl"
;*************************************************
 begin

  wks  = gsn_open_wks ("png", "skewt")  ; send graphics to PNG file

; ---------------------(1) Draw Default Background ------------
  skewtOpts                  = True
  skewtOpts@tiMainString     = "Default Skew-T"

  skewt_bkgd     = skewT_BackGround (wks, skewtOpts)
  draw (skewt_bkgd)
  frame(wks)
  delete (skewtOpts)

; ---------------------(2) Draw Fancier Background ------------

  skewtOpts                  = True
  skewtOpts@DrawColAreaFill  = True    ; default is False
  skewtOpts@DrawHeightScale  = True    ; default is False
  skewtOpts@tiMainString     = "USAF Skew T, Log(p); DOD-WPC 9-16-1"
                             
  skewt_bkgd     = skewT_BackGround (wks, skewtOpts)
  draw (skewt_bkgd)
  frame(wks)
  delete (skewtOpts)

; ---------------------(2) Draw Fancier Background ------------

  skewtOpts                  = True
  skewtOpts@DrawColAreaFill  = True    ; default is False
  skewtOpts@DrawHeightScale  = True    ; default is False
  skewtOpts@DrawHeightScaleFt= False   ; default is True 
  skewtOpts@DrawFahrenheit   = False   ; default is True 
  
  skewtOpts@tiMainString     = "Centigrade - Meters"
                             
  skewt_bkgd     = skewT_BackGround (wks, skewtOpts)
  draw (skewt_bkgd)
  frame(wks)
  delete (skewtOpts)

 end
