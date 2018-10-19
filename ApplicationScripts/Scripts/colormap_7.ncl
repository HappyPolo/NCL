;************************************************
; colormap_7.ncl
;
; Concepts illustrated:
;   - Creating a color map using the HSV color model
;   - Drawing HSV color wedges
;   - Drawing a custom labelbar
;   - Adding a title to a labelbar
;   - Adding a carriage return to a text string using a function code
;   - Changing the font size of the labelbar's labels
;   - Turning off the perimeter around a labelbar
;   - Setting a nice stride for labelbar labels
;
; This example shows how to use hsvrgb to generate a color map.  You
; change the values for ncolors, beg_hue, end_hue, beg_sat, end_sat, 
; beg_val, and end_val and it will generate a labelbar showing the color map.
;
;
; This file is loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"

begin
   wks = gsn_open_wks("png","colormap") ; send graphics to PNG file

   ncolors    = 24     ; Number of colors
   ii         = ispan(1,ncolors-2,1)
   hsv_colors = new((/ncolors,3/),float)

   hsv_colors(0,0) = 0.  ;
   hsv_colors(0,1) = 0.  ;  White background.
   hsv_colors(0,2) = 1.  ;
     
   hsv_colors(1,0) = 0.  ;
   hsv_colors(1,1) = 0.  ;  Black foreground. 
   hsv_colors(1,2) = 0.  ;

;
; Generate a span of colors from blue to pink to salmon.
;
   beg_hue = 225.    ; begin HUE value
   end_hue = 360.    ; end HUE value
   beg_sat = 0.67    ; begin SAT value
   end_sat = 0.67    ; end SAT value
   beg_val = 1.0     ; begin VAL value
   end_val = 1.0     ; end VAL value

   hsv_colors(2:,0) = beg_hue + ii*((end_hue-beg_hue)/(ncolors-2))
   hsv_colors(2:,1) = beg_sat + ii*((end_sat-beg_sat)/(ncolors-2))
   hsv_colors(2:,2) = beg_val + ii*((end_val-beg_val)/(ncolors-2))

   cmap = hsvrgb(hsv_colors) ; Generate smooth range of RGB values.

   gsn_define_colormap(wks,cmap)      ; Set the color map.

;
; Define some labelbar resources.
;
   lbres                   = True
   lbres@vpWidthF          = 0.80    ; Width of labelbar
   lbres@vpHeightF         = 0.20    ; Height of labelbar

   lbres@lbAutoManage      = False   ; Allows us to set more 
                                     ; labelbar resources

   lbres@lbOrientation     = "Horizontal"

   lbres@lbMonoFillPattern = True
   lbres@lbFillColors      = ispan(0,ncolors-1,1)

   lbres@lbPerimOn         = False   ; Turn off box around labelbar.

   lbres@lbTitleFontHeightF= 0.02    ; Font heights for main title
   lbres@lbLabelFontHeightF= 0.015   ; and box labels

   labels = "Color ~C~   " + ispan(0,ncolors-1,1)   ; Labels for boxes.

; Main title
   lbres@lbTitleString     = "ncolors = " + ncolors + \
                           ", hue (" + beg_hue + "," + end_hue + \
                           "), sat (" + beg_sat + "," + end_sat + \
                           "), val (" + beg_val + "," + end_val + ")"

   gsn_labelbar_ndc(wks,ncolors,labels,0.08,0.80,lbres)  ; Draw a labelbar

;
; Generate a more muted span of colors from green to brown.
;
   beg_hue =  20.    ; begin HUE value
   end_hue = 135.    ; end HUE value
   beg_sat = 1.00    ; begin SAT value
   end_sat = 1.00    ; end SAT value
   beg_val = 0.5     ; begin VAL value
   end_val = 0.5     ; end VAL value

   hsv_colors(2:,0) = beg_hue + ii*((end_hue-beg_hue)/(ncolors-2))
   hsv_colors(2:,1) = beg_sat + ii*((end_sat-beg_sat)/(ncolors-2))
   hsv_colors(2:,2) = beg_val + ii*((end_val-beg_val)/(ncolors-2))

   cmap = hsvrgb(hsv_colors) ; Generate smooth range of RGB values.

   gsn_define_colormap(wks,cmap)      ; Set the color map.

   lbres@lbTitleString     = "ncolors = " + ncolors + \
                           ", hue (" + beg_hue + "," + end_hue + \
                           "), sat (" + beg_sat + "," + end_sat + \
                           "), val (" + beg_val + "," + end_val + ")"

   gsn_labelbar_ndc(wks,ncolors,labels,0.08,0.55,lbres)  ; Draw a labelbar

   frame(wks)  ; Advance the frame.
end
