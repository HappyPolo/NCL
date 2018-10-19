;*********************************************
; box_4.ncl
;
; Concepts illustrated:
;   - Drawing box plots
;   - Adding text to a box plot
;   - Setting the color of individual boxes in a box plot
;   - Setting the width of individual boxes in a box plot
;
;*********************************************
;
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
;
; This file still has to be loaded manually
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl"
;*********************************************
begin
;**********************************************
; Create some fake data
;**********************************************
  yval = new((/3,5/),"float",-999.)
  yval(0,0) = -3.
  yval(0,1) = -1.
  yval(0,2) = 1.5
  yval(0,3) = 4.2
  yval(0,4) = 6.
  
  yval(1,0) = -1.
  yval(1,1) = 0.
  yval(1,2) = 1.
  yval(1,3) = 2.5
  yval(1,4) = 4.
  
  yval(2,0) = -1.5
  yval(2,1) = 0.
  yval(2,2) = .75
  yval(2,3) = 2.
  yval(2,4) = 6.5

  x = (/-3., -1., 1./)		
;**********************************************
; create plot
;**********************************************
  wks = gsn_open_wks("png","box")               ; send graphics to PNG file
;**********************************************
; resources for plot background
;**********************************************
  res            = True                         ; plot mods desired
  res@tmXBLabels = (/"Control","-2Xna","2Xna"/) ; labels for each box
  res@tiMainString = "Box Plot with Text on the side"
;**********************************************
; resources for polylines that draws the boxes
;**********************************************  
  llres                   = True			
  llres@gsLineThicknessF  = 2.5                 ; line thickness 
;**********************************************
; resources that control color and width of boxes
;**********************************************  
  opti          = True			
  opti@boxWidth = 1.2				; Width of box (x units)
  opti@boxColors = (/"blue","red","green"/)  	; Color of box(es)
;***********************************************
  plot = boxplot(wks,x,yval,opti,res,llres)	; All 3 options used...
;**********************************************
; adding additional text to the plot
;**********************************************  
  tres               = True                    ; text mods desired
  tres@txFontHeightF = 0.024                   ; change font height
  gsn_text_ndc(wks,"May",0.85,0.75, tres)      ; add text in ndc coordinates

  tres@txFontHeightF = 0.015
  gsn_text_ndc(wks,"CTL",0.77,0.71, tres)
  gsn_text_ndc(wks,"-2Xna",0.85,0.71, tres)
  gsn_text_ndc(wks,"2Xna",0.93,0.71, tres)

  tres@txFontHeightF = 0.018
  gsn_text_ndc(wks,"Random Numbers",0.85,0.67, tres)

  tres@txFontHeightF = 0.015
  gsn_text_ndc(wks,"3.21",0.77,0.63, tres)
  gsn_text_ndc(wks,"3.45",0.85,0.63, tres)
  gsn_text_ndc(wks,"3.63",0.93,0.63, tres)
  draw(plot)
  frame(wks)
  
end

	
