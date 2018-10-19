;*************************************************
; histo_6.ncl
;
; Concepts illustrated:
;   - Comparing two sets of histograms
;   - Generating dummy data using "rand"
;   - Specifying the bar fill colors in a histogram
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
  x = new(1000,integer)
  y = new(1000,integer)
  do i=0,dimsizes(x)-1
    x(i) = rand()
    y(i) = rand()
  end do
  x = x/320
  y = y/320

;************************************************
; Set up a variable to hold both x and y.
;************************************************
  z = new((/2,dimsizes(x)/),integer)
  z(0,:) = x
  z(1,:) = y
;************************************************
; create plot
;************************************************
  wks = gsn_open_wks("png","histo")              ; send graphics to PNG file
  gsn_define_colormap(wks,"temp1")               ; choose colormap

  res                            = True          ; plot mods desired
  res@gsnHistogramCompare        = True
  res@tiMainString               = "Setting colors with 'temp1' colormap"
  plot = gsn_histogram(wks,z,res)

  colors = (/(/"maroon4","firebrick","yellow","paleturquoise1","darksalmon","darkkhaki"/),\
             (/ "orange","forestgreen","tan3","navyblue","hotpink","plum3"/)/)

;---NOTE: this example only works with NCL V6.4.0 and later.
  res@tiMainString          = "Setting colors with named colors"
  res@gsnHistogramBarColors = colors
  plot = gsn_histogram(wks,z,res)

end
