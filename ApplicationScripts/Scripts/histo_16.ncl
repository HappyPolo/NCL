;*************************************************
; histo_16.ncl
;
; Concepts illustrated:
;   - Generating dummy data using "random_uniform"
;   - Labeling the top of histogram bars with the bin value
;
;************************************************
;
; This file is loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"   
;************************************************    
begin
;************************************************
; Generate some random data.
;************************************************
  z = random_uniform(-100,100.,500)

  wks = gsn_open_wks("png","histo")           ; send graphics to PNG file
  gsn_define_colormap(wks,"temp1")            ; choose colormap

; Create the histogram, but don't draw it yet.

  res             = True
  res@gsnMaximize = True
  res@gsnDraw     = False
  res@gsnFrame    = False

  plot = gsn_histogram(wks,z,res)

;
; Using information returned from the histogram, add a value
; at the top of each bar indicating the number of values in
; that bar.
;
   txres               = True
   txres@txJust        = "BottomCenter"
   txres@txFontHeightF = 0.015

   labels = "" + plot@NumInBins    ; The labels to add

;
; Use plot@MidBarLocs for the X values, and a value slightly higher
; than the height of each bar.
;
   dum1 = gsn_add_text(wks,plot,labels,plot@MidBarLocs,plot@NumInBins+1,txres)

; Drawing the plot will draw the attached text strings.
   draw(plot)
   frame(wks)

;
; Remove these text boxes so we can add some different ones.
;
   NhlRemoveAnnotation(plot,dum1)
;
; These text strings will appear inside each bar in a white box.
;
   txres@txJust                = "TopCenter"
   txres@txPerimOn             = True
   txres@txBackgroundFillColor = "white"

;
; Use plot@MidBarLocs for the X values, and a value slightly less
; than the height of each bar.
;
   dum2 = gsn_add_text(wks,plot,labels,plot@MidBarLocs,plot@NumInBins-2,txres)
    
   draw(plot)
   frame(wks)

end
