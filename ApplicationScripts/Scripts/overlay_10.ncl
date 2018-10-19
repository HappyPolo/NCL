;----------------------------------------------------------------------
; overlay_10.ncl
;
; Concepts illustrated:
;   - Overlaying shaded contours on filled contours
;   - Filling contours with multiple shaded patterns
;   - Generating dummy data using "generate_2d_array"
;   - Creating horizontal and vertical labelbars
;   - Drawing two labelbars on the same plot
;----------------------------------------------------------------------
;
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"

begin
;---Generate some dummy data.
  data1 = generate_2d_array(10, 12, -20., 17., 0, (/129,129/))
  data2 = generate_2d_array(13, 13, -25., 15., 1, (/129,129/))

  wks = gsn_open_wks("png","overlay")   ; send graphics to PNG file

;---Set up resources for color-filled plot
  res			= True

  res@gsnMaximize       = True          ; maximize size in frame

  res@gsnDraw		= False		; Don't draw plots
  res@gsnFrame		= False		; Don't advance frame

  res@cnFillOn		= True		; Turn on contour fill
  res@cnLinesOn		= False		; Turn off contour lines

  res@lbOrientation     = "Horizontal"

  res@tiMainString      = "Overlaying shaded contours on filled contours"

  plot_fill = gsn_csm_contour(wks,data1,res)  ; Create filled contours

;---Resources for shaded plot
  res@cnMonoFillPattern = False        ; Use multiple fill patterns
  res@cnMonoFillColor   = True         ; Use same color for shading
  res@lbOrientation     = "Vertical"

  plot_shade = gsn_csm_contour(wks,data2,res)  ; Create shaded contours

;---Overlay will transform plot_shade into data space of plot_fill
  overlay(plot_fill,plot_shade)

;---This call resizes plot so it fits in frame
  pres = True
  maximize_output(wks,pres)

end
