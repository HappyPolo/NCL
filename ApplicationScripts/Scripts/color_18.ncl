;************************************************
; color_18.ncl
;
; Concepts illustrated:
;   - Drawing HSV color wedges
;   - Converting from HSV space to RGB space
;   - Drawing polylines and polygons in NDC space
;   - Drawing text strings in NDC space
;   - Increasing the font size of text
;   - Changing the font of a text string
;   - Formatting strings using "sprintf"
;
;************************************************
;
; This file is loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"

begin
;
;  File:
;    hsv_wheel.ncl
;
;  Synopsis:
;    Draws HSV color wedges and tests color conversion functions.
;
;  Category:
;    Colors
;
;  Author:
;    Fred Clare
;
;  Date of initial NCL publication:
;    July, 2007
;
;  Description:
;    Create color wheels in HSV (hue, saturation, value) space.  
;    Each wheel is produced with a different value of V (the value 
;    parameter in HSV space).  Each wheel is composed of 16 wedges.  
;    The value for the hue remains the same within each wedge, and 
;    the value for the saturation varies linearly from the center 
;    (saturation = 0.) to the outer rim (saturation = 1.) within each 
;    wedge.  The hues vary from 0. to 360. counterclockwise around 
;    the color wheel starting at pure red (hue = 0.) and returning 
;    to pure red.
;
;  Effects illustrated:
;    o  Colors drawn in HSV space.
;    o  Converting from HSV space to RGB space.
;    o  Drawing lines and polygons in NDC space.
;
;  Output:
;    o Three color wheels are drawn using three different settings
;      for the "value" component in HSV space.
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
;  Define the hues, and saturations, and values (the HSV) to be used.
;
  hues        = fspan(0., 337.5, 16)
  saturations = fspan(0., 1., 4)
  values      = (/0.50, 0.75, 1.00/)

;
;  Define the radian increment to be used for spacing the
;  color wedges around the wheels.
;
  num_hues = dimsizes(hues)
  pi = 3.14159265
  radian_inc = 2*pi/num_hues

;  
;  Specify the Y-coordinates for the saturation labels.
;
  slab_y = (/.375, .292, .217/)

;  
;  Define resource lists for the polygons and text.
;
  poly_res = True
  text_res = True

;  
;  Set up arrays to hold the polygon coordinates.
; 
  x = new(4,float)
  y = new(4,float)

;
;  Open a workstation with a black background and a white
;  foreground.
;
  wks  = gsn_open_wks("png","color") ; Send graphics to PNG file
  gsn_define_colormap(wks,(/"Black","White"/))

;
;  Loop on the values, drawing a picture for each value.
;
  do i = 0,dimsizes(values)-1
    value = values(i)

;
;  Loop on the hues.
; 
    do j = 0,dimsizes(hues)-1
      hue = hues(j)
       angle1 = (hue*num_hues/360. - 0.5) * radian_inc
       angle2 = (hue*num_hues/360. + 0.5) * radian_inc
       x(0) = 0.0
       x(3) = 0.0
       y(0) = 0.0
       y(3) = 0.0
;
;  Loop on the saturations.
;
       sindex = 0
       do k = 0,dimsizes(saturations)-1
         saturation = saturations(k)
         red_green_blue = hsvrgb((/hue,saturation,value/))
         r = red_green_blue(0)
         g = red_green_blue(1)
         b = red_green_blue(2)
         poly_res@gsFillColor = (/r,g,b/)
         rlen = 0.25*(3.*saturation + 1.)
         x(1) = cos(angle1) * rlen
         y(1) = sin(angle1) * rlen
         x(2) = cos(angle2) * rlen
         y(2) = sin(angle2) * rlen 
         xc = 0.1 + (x + 1.2)/3.  ;  Conceptual user space is [-1.2, 1.2] in
         yc = 0.1 + (y + 1.2)/3.  ;  X and Y -- map to [0.1, 0.9] NDC space.
         gsn_polygon_ndc(wks,xc,yc,poly_res)
         x(0) = x(1)
         x(3) = x(2)
         y(0) = y(1) 
         y(3) = y(2)
;
;  Label the saturation levels (the zero saturation
;  level at the center of the wheel is not labeled).
;    
         if (saturation .ne. 0.) then
           text_res@txFontHeightF = 0.022
           text_res@txJust = "CenterCenter" 
           text_res@txFont = "Helvetica"
           slabel = sprintf("S = %4.2f",saturation)
           gsn_text_ndc(wks, slabel, 0.5, slab_y(sindex),text_res)
           sindex = sindex+1
         end if
       end do   ; End of saturation loop.
    end do   ; End of hue loop.

;      
;  Add a main title specifying the "value".
;      
    text_res@txFontHeightF = 0.03
    text_res@txJust = "CenterCenter"
    vlabel = sprintf("Value = %4.2f",value)
    gsn_text_ndc(wks, vlabel, 0.5, 0.9, text_res)

;
;  Mark the hues.
;
    text_res@txFontHeightF = 0.025
    text_res@txJust = "CenterLeft"
    gsn_text_ndc(wks, "Hue = 0.", 0.86, 0.5, text_res)
    gsn_polyline_ndc(wks, (/0.827, 0.843/), (/0.5, 0.5/),False)
    gsn_text_ndc(wks, "Hue = 45.", 0.767, 0.747, text_res)
    gsn_polyline_ndc(wks, (/0.730, 0.750/), (/0.730, 0.747/),False)
    gsn_text_ndc(wks, "Hue = 315.", 0.767, 0.253, text_res)
    gsn_polyline_ndc(wks, (/0.733, 0.752/), (/0.267, 0.251/),False)
    text_res@txJust = "CenterRight"
    gsn_text_ndc(wks, "Hue = 135.", 0.233, 0.746, text_res)
    gsn_polyline_ndc(wks, (/0.270, 0.250/), (/0.731, 0.747/),False)
    gsn_text_ndc(wks, "Hue = 225.", 0.233, 0.254, text_res)
    gsn_polyline_ndc(wks, (/0.270, 0.250/), (/0.270, 0.253/),False)

;
;  Draw.
;
    frame(wks)
  end do    ; End of value loop.
end
