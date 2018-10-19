;***************************************
; rose_3.ncl
;***************************************
;
; This file is loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
;
; This file still has to be loaded manually 
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/wind_rose.ncl"
;***************************************
begin
;***************************************
; generate test data and add attributes
;***************************************
  wrData = wr_GenBogusData (200)
  wspd   = wrData(0,:)
  wdir   = wrData(1,:)
                                  
  wspd@long_name = "Wind Speed"
  wspd@units     = "m/s"
  wdir@long_name = "Wind Direction"

;******************************
; specify plot arguments
;******************************
  numPetals =  8                    ; N, NE, E, SE, S, SW, W, NW
  circFr    = 10. 
  spdBounds         = (/ 10., 20., 30., 100. /)
;******************************
; generate color plot
;******************************
  wks = gsn_open_wks("png","rose")  ; send graphics to PNG file
  res               = True
  res@tiMainString  = "Wind Rose: Color + Variable Thickness"
  colorBounds       = (/ "blue", "green", "yellow", "red" /)
  wrColor           = WindRoseColor (wks,wspd,wdir,numPetals, \
                                     circFr,spdBounds,colorBounds,res)
  
end
