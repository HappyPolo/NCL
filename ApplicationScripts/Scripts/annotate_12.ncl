;----------------------------------------------------------------------
; annotate_12.ncl
;
; Concepts illustrated:
;   - Attaching text strings to the outside of a plot
;   - Attaching annotations to plot
;   - Rotating text 90 degrees
;   - Creating a color map using RGB values
;   - Customizing a labelbar
;   - Generating dummy data using "generate_2d_array"
;   - Explicitly setting contour levels
;----------------------------------------------------------------------
;
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"  
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"  

;----------------------------------------------------------------------
; Function to read in 22 x 3 RGB array for use in a color map
;----------------------------------------------------------------------
undef ("read_rgb")
function read_rgb()
begin
  rgb = (/ (/ 25,  12, 243 /), (/ 36,  12, 243 /), (/ 56,  73, 245 /), \
           (/ 85, 156, 246 /), (/111, 233, 179 /), (/ 93, 201,  97 /), \
           (/ 80, 170,  40 /), (/ 81, 164,  25 /), (/115, 195,  29 /), \
           (/152, 220,  31 /), (/255, 255, 255 /), (/255, 255, 255 /), \
           (/249, 254,  41 /), (/233, 222,  36 /), (/227, 194,  33 /), \
           (/219, 161,  32 /), (/202,  96,  26 /), (/192,  49,  24 /), \
           (/189,   3,  23 /), (/133,   0,  28 /), (/ 73,   1,  63 /), \
           (/ 44,   4,  94 /) /) 
  return(rgb)
end

;----------------------------------------------------------------------
; Main code
;----------------------------------------------------------------------
begin
;---Read in RGB triplets to use for color bar
  rgb = read_rgb()/255.

;---Create some dummy data that goes from -50 to 50
  data = generate_2d_array(20, 20, -50, 50, 0, (/50,50/))

;---Start the graphics
  wks = gsn_open_wks("png","annotate")  ; Send graphics to PNG file
 
  res                      = True
  res@gsnMaximize          = True
  res@gsnDraw              = False
  res@gsnFrame             = False

  res@cnFillOn             = True
  res@cnLinesOn            = False
  res@cnLineLabelsOn       = False
  res@cnFillPalette        = rgb
  res@cnLevelSelectionMode = "ExplicitLevels"
  res@cnLevels             = (/-50,-30,-20,-10,-7,-5,-3,-2,-1,-0.25,0,\
                               0.25,1,2,3,5,7,10,20,30,50/)

;---Customize labelbar
  res@lbOrientation        = "Vertical"
  res@lbLabelJust          = "CenterLeft"   ; Default is "CenterCenter"
  res@lbLabelFontHeightF   = 0.01           ; Default is a big large
  res@pmLabelBarWidthF     = 0.05           ; Make labelbar thinner

  plot = gsn_csm_contour(wks,data,res)      ; Create the plot (it won't be drawn yet)

;---Create some text strings to attach outside of plot.
  text_str = "Altitude [km]"

  txres               = True
  txres@txFontHeightF = 0.01
  txres@txAngleF      = 90     ; Rotate 90 degrees

  txid1 = gsn_create_text(wks,text_str,txres)
  txid2 = gsn_create_text(wks,text_str,txres)
  txid3 = gsn_create_text(wks,text_str,txres)

;----------------------------------------------------------------------
; Use gsn_add_annotation to attach text string to outside of plot. 
; This is useful if you need to resize the plot later, like in
; a panel plot.
;----------------------------------------------------------------------
  amres                  = True
  amres@amJust           = "CenterLeft"  ; Center string
  amres@amParallelPosF   =  0.54         ; Move to the outside right of plot
  amres@amOrthogonalPosF =  0.0          ; Move to center (in Y direction)
  annoid1 = gsn_add_annotation(plot, txid1, amres)

  amres@amJust           = "TopLeft"     ; Right justify string
  amres@amParallelPosF   =  0.54         ; Move to the outside right of plot
  amres@amOrthogonalPosF =  -0.5         ; Move to top (in Y direction)
  annoid2 = gsn_add_annotation(plot, txid2, amres)

  amres@amJust           = "BottomLeft"  ; Left justify string.
  amres@amParallelPosF   =  0.54         ; Move to the outside right of plot
  amres@amOrthogonalPosF =  0.5          ; Move to bottom (in Y direction)
  annoid3 = gsn_add_annotation(plot, txid3, amres)

;---Drawing the plot will draw the three attached strings
  draw(plot)
  frame(wks)
end



