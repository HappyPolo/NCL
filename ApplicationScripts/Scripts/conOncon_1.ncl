;*************************************************
; conOncon_1.ncl
;
; Concepts illustrated:
;   - Drawing pressure/height contours on top of another set of contours
;   - Drawing negative contour lines as dashed lines
;   - Drawing the zero contour line thicker
;   - Changing the color of a contour line
;   - Overlaying dashed contours on solid line contours
;*************************************************
;
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
;*************************************************

begin
  f     = addfile ("mxclim.nc" , "r")  
  u     = f->U(0,:,:)                             ; get u January
  v     = f->V(0,:,:)                             ; get v January
  
; note u is already on pressure levels. If this were ccsm model data, it
; would be necessary to interpolate from the hybrid coordinates to 
; pressure levels.
;*********************************
; first plot
;*********************************
  wks   = gsn_open_wks ("png", "conOncon" )       ; send graphics to PNG file
  
  res              = True                         ; plot mods desired
  res@gsnDraw      = False                        ; don't draw yet
  res@gsnFrame     = False                        ; don't advance frame yet
  res@tiMainString = "Ensemble Average 1987-89"   ; add title
  res@gsnContourZeroLineThicknessF = 2. 	  ; doubles thickness of zero contour
  res@gsnContourNegLineDashPattern = 1 		  ; sets negative contours to dash pattern 1
  res@cnLineColor  = "Red"                        ; color of first contour

  plotu  = gsn_csm_pres_hgt(wks, u, res )         ; draw 1st contour
;*********************************
; second plot
;*********************************
  res@cnLineColor      = "Blue"                   ; color of second contours
  res@cnLineThicknessF = 2.                       ; line thickness

; when using the gsn_csm plot templates and overlay, it is necessary to
; turn off the automatic label strings so that you don't get text on 
; top of text
  res@gsnRightString   = ""    
  res@gsnLeftString    = ""
  res@gsnCenterString  = ""
  
  plotv  = gsn_csm_contour(wks, v, res )          ; draw second plot
  overlay(plotu,plotv)                            ; now over lay plots
; the result of the overlay procedure is that the second argument is 
; placed on top of the first. The first plot (now combined) is returned.

; these two step are required!
  draw(plotu)                     ; note we are drawing the first one!
  frame(wks)
  
end
