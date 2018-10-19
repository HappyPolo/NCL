;
; overlay_5.ncl
;
; Concepts illustrated:
;   - Overlaying shaded contours on filled contours
;   - Filling contours with multiple shaded patterns
;   - Generating dummy data using "generate_2d_array"
;
;
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"

begin
;
; Generate some dummy data.
;
  data1 = generate_2d_array(10, 12, -20., 17., 0, (/129,129/))
  data2 = generate_2d_array(13, 13, -25., 15., 1, (/129,129/))
  data2 = data2(::-1,:)    ; Reverse one dimension just for something different

  wks = gsn_open_wks("png","overlay")   ; send graphics to PNG file

; Set up resources.
  res			= True
  res@gsnDraw		= False		; Don't draw plots
  res@gsnFrame		= False		; Don't advance frame
  res@cnFillOn		= True		; Turn on contour fill
  res@cnLinesOn		= False		; Turn off contour lines
  res@cnFillPalette     = "testcmap"

  res@tiMainString        = "Overlaying shaded contours on filled contours"

  plot1 = gsn_csm_contour(wks,data1,res)  ; Create filled contours

  res@cnFillOn = False
  plot2 = gsn_csm_contour(wks,data2,res)  ; Create data2 contour plot
;  
; use pattern fill #2 to fill all areas less than the first contour
; less than or equal to -10, and use pattern fill #17 to fill all areas greater 
; than the first contour greater than or equal to 5. 
;
  opt = True
  opt@gsnShadeFillType = "pattern"      ; pattern fill
  opt@gsnShadeHigh = 2			; use pattern #2   
  opt@gsnShadeLow = 17			; use pattern #17
  plot2 = gsn_contour_shade(plot2,-8,4.,opt)  
  overlay(plot1,plot2)
  draw(plot1)
  frame(wks)
end
