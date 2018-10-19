;***************************************
; rose_4.ncl
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
  spdBounds = (/ 10., 20., 30., 100. /)
  colorBounds = (/ "blue", "green", "yellow", "red" /)
;******************************
; generate panel plot
;******************************
  wks = gsn_open_wks("png","rose")  ; send graphics to PNG file
  plot = new (4, graphic)

  res          = True
  res@gsnDraw  = False
  res@gsnFrame = False
;******************************
; create first plot
;******************************
  res@tiMainString  = "Wind Rose: Basic"
  plot(0)           = WindRoseBasic (wks,wspd,wdir,numPetals,circFr,res)
;******************************
; create second plot
;******************************
  res@tiMainString  = "Wind Rose: Variable Line Thickness"
  plot(1)           = WindRoseThickLine (wks,wspd,wdir,numPetals \
                                         ,circFr,spdBounds,res)
;******************************
; create third plot
;******************************
  res@tiMainString  = "Wind Rose: Color + Variable Thickness"
  plot(2)           = WindRoseColor (wks,wspd,wdir,numPetals \
                          ,circFr,spdBounds,colorBounds,res)
;******************************
; create fourth plot
;******************************
  numPetals         =  4                    ; N, E, S, W
  res@tiMainString  = "Wind Rose: numPetals="+numPetals
  plot(3)           = WindRoseColor (wks,wspd,wdir,numPetals \
                          ,circFr,spdBounds,colorBounds,res)
;******************************
; create panel plot
;******************************
  gsn_panel (wks, plot, (/2,2/), False)
end
