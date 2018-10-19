;*************************************************
; text_9.ncl
;
; Concepts illustrated:
;   - Attaching text strings to a plot
;   - Increasing the font size of text
;   - Attaching annotations to plot
;   - Rotating text 90 degrees
;   - Setting the background color for a text box
;   - Turning on the perimeter of a text box
;   - Using "setvalues" to set resource values
;   - Resizing a plot
;************************************************
;
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
;************************************************
begin
;************************************************
; read in netCDF file
;************************************************
  a = addfile("$NCARG_ROOT/lib/ncarg/data/cdf/uv300.nc","r")
  u = a->U(0,:,8)
;************************************************
; create plot
;************************************************
  wks = gsn_open_wks("png","text")            ; send graphics to PNG file
  
  res              = True                     ; plot mods desired
  res@gsnMaximize  = True
  res@gsnDraw      = False                    ; Turn off draw and frame so
  res@gsnFrame     = False                    ; we can attach some text.

  plot = gsn_csm_xy(wks,u&lat,u,res)               ; create xy plot

  txres                       = True
  txres@txPerimOn             = True
  txres@txBackgroundFillColor = "Salmon"
  txres@txFontHeightF         = 0.03

  txid = gsn_create_text(wks, "default text settings", txres)

  amres = True
  annoid = gsn_add_annotation(plot, txid, amres)  ; Attach string to plot
                                                  ; using default values.
  draw(plot)
  frame(wks)

  setvalues plot
    "vpXF"      : 0.15
    "vpYF"      : 0.85
    "vpWidthF"  : 0.7
    "vpHeightF" : 0.7
  end setvalues

;
; Remove this text string, and create some new ones to add.
;
  NhlRemoveAnnotation(plot,annoid)

  txres@txBackgroundFillColor = "Cyan"
  txres@txFont                = "helvetica-bold"
  txid1 = gsn_create_text(wks, "String 1", txres)

  amres@amParallelPosF   = 0.5    ; This is the right edge of the plot.
  amres@amOrthogonalPosF = 0.5    ; This is the bottom edge of the plot.
;
; By default, the center of the string is what's placed at the position
; indicated by amParallelPosF and amOrthogonalPosF. You can use amJust
; to change this to any one of 9 positions: "CenterCenter" (default),
; "TopCenter", "TopRight", "CenterRight", "BottomRight", "BottomCenter",
; "BottomLeft", "CenterLeft", "TopLeft".
;
  amres@amJust           = "BottomRight"

  annoid1 = gsn_add_annotation(plot, txid1, amres)

;
; Add another text string.
;
  txres@txBackgroundFillColor = "Orange"
  txres@txFont                = "times-bold"
  txid2 = gsn_create_text(wks, "String 2", txres)

  amres@amParallelPosF   = -0.5    ; This is the left edge of the plot.
  amres@amOrthogonalPosF =  0.0    ; This is the bottom edge of the plot.
  amres@amJust           = "CenterLeft"
  annoid2 = gsn_add_annotation(plot, txid2, amres)
;
; Add the third text string.
;
  txres@txBackgroundFillColor = "Green"
  txres@txFont                = "courier-bold"
  txid3 = gsn_create_text(wks, "String 3", txres)

  amres@amParallelPosF   =  0.0    ; This is the center of the plot.
  amres@amOrthogonalPosF = -0.5    ; This is the top edge of the plot.
  amres@amJust           = "BottomCenter"
  annoid3 = gsn_add_annotation(plot, txid3, amres)

;
; Add the fourth text string.
;
  txres@txAngleF              = 90
  txres@txBackgroundFillColor = "Purple"
  txid4= gsn_create_text(wks, "String 4", txres)

  amres@amParallelPosF   =  0.55
  amres@amOrthogonalPosF = -0.0
  amres@amJust           = "CenterLeft"
  annoid4 = gsn_add_annotation(plot, txid4, amres)

  draw(plot)
  frame(wks)

  setvalues plot
    "vpWidthF"  : 0.4
    "vpHeightF"  : 0.4
  end setvalues

  draw(plot)
  frame(wks)
 
end
