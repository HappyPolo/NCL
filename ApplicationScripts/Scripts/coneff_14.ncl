;
; coneff_14.ncl
;
; Concepts illustrated:
;   - Overlaying shaded contours on filled contours
;   - Filling contours with multiple shaded patterns
;   - Generating labelbars representing two different sets of contours
;   - Generating dummy data using "generate_2d_array"
;   - Maximizing plots after they've been created
;   - Setting a nice stride for labelbar labels
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

  wks = gsn_open_wks("png","coneff")     ; Send graphics to PNG file

; Set up resources.
  res                     = True
  res@gsnDraw             = False       ; Don't draw plots
  res@gsnFrame            = False       ; Don't advance frame

  res@cnFillOn            = True        ; Turn on contour fill
  res@cnLinesOn           = False       ; Turn off contour lines
  res@cnFillPalette       = "testcmap"  ; Set color map

  res@tiMainString        = "Overlaying shaded contours on filled contours"

  plot1 = gsn_csm_contour(wks,data1,res)  ; Create filled contours

  res@cnMonoFillPattern    = False        ; Use multiple fill patterns
  res@cnMonoFillColor      = True         ; Use single pattern color
  res@cnLinesOn            = True         ; Turn lines back on
  res@lbOrientation        = "Vertical"   ; Rotate labelbar

  plot2 = gsn_csm_contour(wks,data2,res)  ; Create shaded contours

  overlay(plot1,plot2)

; You can't use gsnMaximize above to maximize plots in the frame,
; because you will be maximizing the individual plots, and not
; the two of them together.
;
; Instead, after the plots have been created and attached (via "overlay")
; maximize them with the maximize_output procedure.
;
  psres = True
  maximize_output(wks,psres)

end
