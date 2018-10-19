;----------------------------------------------------------------------
; tm_11.ncl
;
; Concepts illustrated:
;   - Adding additional tickmark labels to a plot using gsn_blank_plot
;   - Moving tickmark labels away from axis
;   - Explicitly labelling minor tickmarks
;----------------------------------------------------------------------
;
; This script shows how to label minor tickmarks, by overlaying
; a blank plot that contains the labeled minor tickmarks.
;
; This method creates a plot identical to tm_10.ncl, except
; a different, and potentially faster method is used.
;
; If the initial plot is time-consuming to create, then this
; method is the preferred one, because the plot isn't generated
; twice.
;
;
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"

begin
  arr   = random_uniform(-4.,4.,56)     ; Random data
  years = ispan(1950,2005,1)

  wks = gsn_open_wks("png","tm"); send graphics to PNG file

  res = True

  res@gsnMaximize = True        ; Maximize plot in frame; aspect ratio
                                ; will be preserved.

  res@vpWidthF  = 0.8           ; Set width and height of plot.
  res@vpHeightF = 0.3

  res@trYMinF = -4.0            ; Set minimum Y-axis value.
  res@trYMaxF =  4.0            ; set maximum Y-axis value.
  res@trXMinF = 1949            ; Set minimum X-axis value.
  res@trXMaxF = 2006            ; Set maximum X-axis value.

  res@tmYROn = False            ; Turn off right tickmarks.
  res@tmXTOn = False            ; Turn off top tickmarks.

  res@tiMainString = "Labeling major and minor tickmarks"

  res@gsnDraw  = False          ; Don't draw plot or advance frame.
  res@gsnFrame = False

  plot = gsn_csm_xy(wks,years,arr,res)
;
; We need to make sure second plot is drawn in same location, so
; retrieve the viewport coordinates and set them to the same
; values for the second plot.
;
  getvalues plot 
    "vpXF"      : vpxf
    "vpYF"      : vpyf
    "vpHeightF" : vpheightf
    "vpWidthF"  : vpwidthf
  end getvalues

  res2           = True

  res2@vpXF      = vpxf
  res2@vpYF      = vpyf
  res2@vpHeightF = vpheightf
  res2@vpWidthF  = vpwidthf

;
; Create the values that represent the locations of the minor tickmarks
; in the previous plot; we will use these values as our major
; tickmark values in the second plot.
;
  values = ispan(1950,2005,2)
;
; Create an array of labels for these locations. Since we already
; have labels at 1950, 1960, etc, set these to "".
;
; The sprinti call generates labels like '52, '62, '02, etc.
;
  labels = sprinti("'%0.2i",where(values.ge.2000,values-2000,values-1900))
  labels = where((values%10),labels,"")

  res2@tmXBMode                = "Explicit"
  res2@tmXBValues              = values
  res2@tmXBLabels              = labels
  res2@tmXBLabelFontHeightF    = 0.01    ; Make these labels smaller.
  res2@tmXBMajorOutwardLengthF = 0.0     ; Don't draw tickmarks b/c they
  res2@tmXBMajorLengthF        = 0.0     ; were drawn on previous plot.
  res2@tmXBLabelDeltaF         = 0.6     ; Move label away from tickmarks.

  res2@tmXBLabelFontColor      = "Brown"

  res2@tmYROn = False            ; Turn off right tickmarks.
  res2@tmXTOn = False            ; Turn off top tickmarks.
  res2@tmYLOn = False            ; Turn off left tickmarks.

  blank = gsn_blank_plot(wks,res2)    ; Create a blank plot.
  overlay(plot,blank)                 ; Overlay on existing plot.

  draw(plot)         ; Draw plot and its overlaid tickmarks,
  frame(wks)         ; and advance the frame.

end
