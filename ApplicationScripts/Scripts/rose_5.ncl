;***************************************
; rose_5.ncl
;
; Concepts illustrated:
;   - Drawing wind rose and adding a label bar.
;
;************************************************

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
  spdBounds         = (/ 10, 20, 30, 50, 100 /)*1.0
;******************************
; generate color plot
;******************************
  wks = gsn_open_wks("png","rose")  ; send graphics to PNG file
  res               = True
  res@tiMainString  = "Wind Rose: Color + Variable Thickness"
  colorBounds       = (/ "blue", "green", "yellow", "red", "orange" /)

  res@gsnFrame      = False         ; do not advance the frame

  wrColor           = WindRoseColor (wks,wspd,wdir,numPetals, \
                                     circFr,spdBounds,colorBounds,res)


; Set up resources for the labelbar.
   
  lbres                    = True          ; labelbar only resources
  lbres@lbAutoManage       = False         ; Necessary to control sizes
  lbres@vpWidthF           = 0.05          ; labelbar width
  lbres@vpHeightF          = 0.15          ; labelbar height
  lbres@vpXF               = 0.78          ; labelbar position in x direction 
  lbres@vpYF               = 0.58          ; labelbar position in y direction
  lbres@lbBoxMajorExtentF  = 0.80          ; puts space between color boxes
  lbres@lbFillColors       = colorBounds   ; labelbar colors        
  lbres@lbMonoFillPattern  = True          ; Solid fill pattern
  lbres@lbLabelFontHeightF = 0.015         ; font height. default is small
  lbres@lbPerimOn          = False
  lbres@lbTitleString      ="Wind Speed(m/s)" 
  lbres@lbTitleFontHeightF = 0.01

; Create labels

  nbar   = dimsizes(spdBounds)
  labels = new(nbar,string)
  labels(0) = 0 + "-" + spdBounds(0)
  do i=1,nbar-1
     labels(i) = spdBounds(i-1) + "-" +spdBounds(i)
  end do

  lbid = gsn_create_labelbar(wks,nbar,labels,lbres)
  
  draw(lbid)
  frame(wks)



  
end

