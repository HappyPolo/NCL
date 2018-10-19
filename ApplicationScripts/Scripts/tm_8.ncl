;*************************************************
; tm_8.ncl
; Concepts illustrated:
;   - Using dummy data for an XY plot
;   - Setting resources for an XY plot
;   - Formatting an axis with alternate numeric formats
;
;************************************************
;
; This file is loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"

begin
  wks = gsn_open_wks("png","tm") ; send graphics to PNG file

  txres               = True
  txres@txFont        = "helvetica-bold"
  txres@txJust        = "BottomRight"
  txres@txFontHeightF = 0.02

  gsn_text_ndc(wks,"Format String",0.19,0.95,txres)

  txres@txJust = "BottomCenter"
  gsn_text_ndc(wks,"Resulting tickmark labels",0.55,0.95,txres)

;
; Create some dummy data for an XY plot. We are only doing this
; to create an object that has tickmarks.
;
   x = fspan(0,1,20)
   y = x
   y = 0.
;
; Turn off all tickmark axes and borders except the bottom x-axis.
; The main title is used to characterize the output.
; The Y axis title contains the format string used to generate the labels.
; Specify the viewport extent of the object.
;
  res = True
  res@gsnDraw              = False
  res@gsnFrame             = False

;
; Resources for main title and Y axis title.
;
  res@tiMainFont           = "Helvetica-Bold"
  res@tiMainFontHeightF    = 0.015
  res@tiMainJust           = "CenterLeft"
  res@tiMainPosition       = "Left"
  res@tiYAxisAngleF        = 0.0
  res@tiYAxisFont          = "Courier-Bold"
  res@tiYAxisFontAspectF   = 1.5
  res@tiYAxisFontHeightF   = 0.015
  res@tiYAxisFuncCode      = "\"
  res@tiYAxisJust          = "BottomRight"
	
;
; Resources for X and Y axes. The top, left, and right axes
; will be turned off.
;
  res@tmXTOn               = False      ; Turn off top tickmarks
  res@tmYLOn               = False      ; Turn off left tickmarks
  res@tmYROn               = False      ; Turn off bottom tickmarks
  res@tmXTBorderOn         = False      ; Turn off top border
  res@tmYLBorderOn         = False      ; Turn off left border
  res@tmYRBorderOn         = False      ; Turn off right border
;
; Resources for the tickmarks on the bottom axis.
;
  res@tmXBMode             = "Manual"
  res@tmXBTickSpacingF     = 2.5
  res@tmXBLabelFont        = "Helvetica-Bold"
  res@tmXBLabelFontHeightF = 0.015
  res@tmXBMajorLengthF     = 0.02
  res@tmXBMinorLengthF     = 0.01
  res@tmXBMinorPerMajor    = 4

;
; Control range of X and Y axis.
  res@trXMaxF              = 20.0
  res@trXMinF              = 0.0
  res@trYMinF              = 0.0

;
; Width, height, and position of X axis. Every time the
; axis is redrawn, the vpYF resource will be changed to change
; the position.
; 
  res@vpXF                 = 0.2
  res@vpYF                 = 0.9
  res@vpHeightF            = 0.02
  res@vpWidthF             = 0.7
  xy = gsn_xy(wks,x,y,res)

;
; Draw 9 different plots demonstrating control of the bottom x-axis 
; tickmark labels using the XBFormat string resource. See the description
; of the Floating Point Format Specification scheme in the HLU reference
; guide to learn about the semantics and syntax of the format string:
;
;    http://www.ncl.ucar.edu/Document/Graphics/format_spec.shtml
;
; There are links to this description in the TickMark reference pages under
; the entries for the format string resources (XBFormat, for example).
;

  setvalues xy
    "vpYF"          : 0.9
    "tiMainString"  : "Default format"
    "tiYAxisString" : "0@*+^sg"
  end setvalues
  draw(xy)

  setvalues xy
    "vpYF"          : 0.8
    "tiMainString"  : "Equal number of significant digits"
    "tiYAxisString" : "0f"
    "tmXBFormat"    : "0f" 
  end setvalues
  draw(xy)

  setvalues xy
    "vpYF"          : 0.7
    "tiMainString"  : "No unnecessary zeroes"
    "tiYAxisString" : "f"
    "tmXBFormat"    : "f" 
  end setvalues
  draw(xy)

  setvalues xy
    "vpYF"          : 0.6
    "tiMainString"  : "Force decimal point"
    "tiYAxisString" : "#f"
    "tmXBFormat"    : "#f" 
  end setvalues
  draw(xy)

;
; Note that when the XBFormat string specifies the precision (number
; of significant digits) explicitly (using the '.' conversion field),
; both XBAutoPrecision and XBPrecision are ignored.
;
  setvalues xy
    "vpYF"          : 0.5
    "tiMainString"  : "4 significant digits for maximum absolute value"
    "tiYAxisString" : "0@;*.4f"
    "tmXBFormat"    : "0@;*.4f" 
  end setvalues
  draw(xy)

  setvalues xy
    "vpYF"          : 0.4
    "tiMainString"  : "Zero fill 5 character field"
    "tiYAxisString" : "0@5;*.4f"
    "tmXBFormat"    : "0@5;*.4f" 
  end setvalues
 draw(xy)

  setvalues xy
    "vpYF"          : 0.3
    "tiMainString"  : "Field width 7; fill character *; decimal position 4"
    "tiYAxisString" : "&*0@7;*.4~4f" 
    "tmXBFormat"    : "&*0@7;*.4~4f" 
  end setvalues
draw(xy)

;
; Note that the tick spacing is set to a larger value because 
; the exponential notation takes up more space.
;
  setvalues xy
    "vpYF"             : 0.2
    "tiMainString"     : "Exponential format using superscript notation"
    "tmXBTickSpacingF" : 5.0
    "tiYAxisString"    : "0@!;*^se" 
    "tmXBFormat"       : "0@!;*^se" 
  end setvalues
  draw(xy)

  setvalues xy
    "vpYF"          : 0.1
    "tiMainString"  : "Exponential format using '**' notation"
    "tiYAxisString" : "0@!;*^ae" 
    "tmXBFormat"    : "0@!;*^ae" 
  end setvalues
  draw(xy)

  frame(wks)
end
