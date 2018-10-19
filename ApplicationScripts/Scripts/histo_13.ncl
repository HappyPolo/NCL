;*************************************************
; histo_13.ncl
;
; Concepts illustrated:
;   - Generating dummy data using "random_uniform"
;   - Reformatting the X axis labels in a histogram
;
;************************************************
;
; This file is loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
begin

; Generate some random data.
  x = floattointeger(random_uniform(0,33,150))
  y = floattointeger(random_uniform(0,33,150))

  wks = gsn_open_wks("png","histo")             ; send graphics to PNG file
  gsn_define_colormap(wks,"default")

  res = True 

  res@gsnMaximize                     = True    ; Maximize plot in frame.
  res@gsnDraw                         = False   ; Don't draw
  res@gsnFrame                        = False   ; Don't advance frame

  res@gsnHistogramSelectNiceIntervals = False
  res@gsnHistogramNumberOfBins        = 11

  plot = gsn_histogram(wks,x,res)

; Reformat the tickmark labels so we don't have so many decimal places.
  labels = sprintf("%.3g",plot@BinLocs)

; Set these new labels, and make the font smaller.
  setvalues plot
    "tmXBLabelFontHeightF" : 0.02
    "tmXBLabels"           : labels
  end setvalues

; Now draw plot and advance frame.
  draw(plot)
  frame(wks)

end
