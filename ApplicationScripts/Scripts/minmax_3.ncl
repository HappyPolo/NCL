;************************************************
;  minmax_3.ncl 
;
; Concepts illustrated:
;   - Calculating the local minima/maxima of your data
;   - Adding text strings at local minima/maxima locations
;   - Generating dummy data using "generate_2d_array"
;   - Setting the background color for a text box
;   - Turning on the perimeter of a text box
;************************************************
;
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
;************************************************
begin
;---Generate dummy data
  data = generate_2d_array(10, 10, -19., 16., 0, (/100,100/))

;---plot original data

  wks  = gsn_open_wks("png","minmax")           ; send graphics to PNG file

  res  = True

  res@gsnMaximize          = True               ; Maximize size of plot in frame.

  res@gsnFrame             = False              ; Turn off, because we'll want
  res@gsnDraw              = False              ; to attach text strings first.

  res@cnFillOn             = True               ; turn on color fill
  res@cnFillPalette        = "BlueYellowRed"    ; set color map
  res@lbOrientation        = "Vertical"

  res@tiMainString         = "Adding your own minima/maxima text strings"

  plot = gsn_csm_contour(wks,data,res)

;---Calculate min/max extrema
  lmin = local_min(data,False,0.)
  lmax = local_max(data,False,0.)

;---Only get min values < -10 and  max values > 12 
  ii_l = ind(lmin@minval.lt.-10)
  ii_h = ind(lmax@maxval.gt. 12)

;---Format strings to put on plot
  lmin_str = sprintf("L%0.1f",lmin@minval(ii_l))
  lmax_str = sprintf("H%0.1f",lmax@maxval(ii_h))

  lmin_xi  = lmin@xi(ii_l)            ; index values of minima
  lmin_yi  = lmin@yi(ii_l)
  lmax_xi  = lmax@xi(ii_h)            ; index values of maxima
  lmax_yi  = lmax@yi(ii_h)

;---Set some text resources
  txres                       = True          
  txres@txFontHeightF         = 0.015
  txres@txPerimOn             = True
  txres@txBackgroundFillColor = "white"

;---Attach text strings to plot
  txid_l = gsn_add_text(wks,plot,lmin_str,lmin_xi,lmin_yi,txres)
  txid_h = gsn_add_text(wks,plot,lmax_str,lmax_xi,lmax_yi,txres)

;---Drawing the plot will also cause text strings to be drawn.
  draw(plot)
  frame(wks)

end




