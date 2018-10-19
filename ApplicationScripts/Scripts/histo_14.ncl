;*************************************************
; histo_14.ncl
;
; Concepts illustrated:
;   - Generating dummy data using "random_uniform"
;   - Adding minor X tickmarks to a histogram
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
  z      = new((/2,1000/),float)
  z(0,:) = random_uniform(0,320.,1000)
  z(1,:) = random_uniform(0,320.,1000)
;************************************************
; create plot
;************************************************
  wks = gsn_open_wks("png","histo")              ; send graphics to PNG file
  gsn_define_colormap(wks,"temp1")               ; Choose colormap

  res              = True
  res@gsnMaximize  = True                       ; Maximize plot in frame
  res@gsnFrame     = False                      ; Don't advance frame yet

  res@tiMainString = "Adding minor tickmarks on bottom axis"

  plot = gsn_histogram(wks,z(0,:),res)          ; Create and draw histogram

;
; Make sure plot is in the same place the second time around, by
; setting viewport resources.
;
  delete(res@gsnMaximize)  ; Don't maximize plot second time.

  getvalues plot
    "vpXF"      : vpx
    "vpYF"      : vpy
    "vpWidthF"  : vpw
    "vpHeightF" : vph
  end getvalues

  res@vpXF      = vpx
  res@vpYF      = vpy
  res@vpWidthF  = vpw
  res@vpHeightF = vph

;
; When you create a histogram, the return value will have attached
; to it the locations on the X axis of the bars. We can use this
; information to place new tickmarks.
;
  minor_tick_values = plot@MidBarLocs    ; middle of each bar.
  minor_tick_labels = new(dimsizes(minor_tick_values),string)
  minor_tick_labels = ""

  res@tmXBValues       = minor_tick_values
  res@tmXBLabels       = minor_tick_labels
  res@tmXBMajorLengthF = 0.01     ; Make these slightly smaller
;
; When you change a tickmark length, the tickmark lengths on the other
; sides want to change too, and also the right label will be slightly
; shifted to the right. This causes a slightly different-looking plot
; the second time. To avoid this, turn off the left tickmarks and label.
;
  res@tmYLOn           = False    ; Turn off left tickmarks
  res@tiYAxisString    = ""       ; Turn off Y axis label
  res@gsnFrame         = True     ; Turn frame advance back on.

  plot = gsn_histogram(wks,z(0,:),res)  ; Draw histogram again, this time
                                        ; with minor tickmarks.
end
