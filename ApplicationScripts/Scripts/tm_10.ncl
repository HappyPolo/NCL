;----------------------------------------------------------------------
; tm_10.ncl
;
; Concepts illustrated:
;   - Labelling both minor and major tickmarks
;   - Changing the width and height of a plot
;   - Setting the mininum/maximum value of the X and Y axis in an XY plot
;   - Using "getvalues" to retrieve the size of a plot
;----------------------------------------------------------------------
;
; tm_10.ncl
;
; Concepts illustrated:                                                         
;   - Labelling both minor and major tickmarks                                  
;   - Changing the width and height of a plot                                   
;   - Setting the mininum/maximum value of the X and Y axis in an XY plot       
;   - Using "getvalues" to retrieve the size of a plot  
;
;
; This script shows how to label minor tickmarks, by drawing
; the tickmarks again with the minor ones treated as major
; tickmarks.
;
; This method creates a plot identical to tm_11.ncl, except
; a different and potentially slower method is used.
;
; If the initial plot is not time-consuming to create, then this
; method might be the preferred one.
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

  res@gsnFrame = False          ; Draw plot, but don't advance frame.

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

  res@vpXF      = vpxf
  res@vpYF      = vpyf
  res@vpHeightF = vpheightf
  res@vpWidthF  = vpwidthf

  delete(res@tiMainString)
  delete(res@gsnMaximize)      ; If gsnMaximize is True, this will cause
                               ; the viewport coords to get recalculated.
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

  res@tmXBMode                = "Explicit"
  res@tmXBValues              = values
  res@tmXBLabels              = labels
  res@tmXBLabelFontHeightF    = 0.01    ; Make these labels smaller.
  res@tmXBMajorOutwardLengthF = 0.0     ; Don't draw tickmarks b/c they
  res@tmXBMajorLengthF        = 0.0     ; were drawn on previous plot.

  res@tmXBLabelFontColor      = "Brown"


  res@tmYLOn = False        ; Turn off left tickmarks since we already
                            ; have them.

  plot = gsn_csm_xy(wks,years,arr,res)

  frame(wks)
end
