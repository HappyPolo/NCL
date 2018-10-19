;----------------------------------------------------------------------
; overlay_9.ncl
;
; Concepts illustrated:
;   - Overlaying two contour plots that are in different data spaces
;   - Generating a bullseye pattern for contours
;   - Overlaying line contours on filled contours
;   - Attaching a plot as an annotation of another plot
;   - Using "setvalues" to change the main title of an existing plot
;   - Using cnFillPalette to assign a color palette to contours
;----------------------------------------------------------------------
;
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"

begin
;----------------------------------------------------------------------
; Generate dummy data for 1st contour plot
;----------------------------------------------------------------------
  M     = 25
  ispn  = conform_dims((/M,M/),ispan(-M/2,M/2,1)^2,1)
  jspn  = conform_dims((/M,M/),ispan(-M/2,M/2,1)^2,0)
  data1 = 100. - sqrt(64*(jspn + ispn))

;---Add dummy coordinate arrays
  data1!0 = "y"
  data1!1 = "x"
  data1&x = ispan(1,M,1)
  data1&y = fspan(1000,10,M) 

;----------------------------------------------------------------------
; Generate dummy data for 2nd contour plot
;----------------------------------------------------------------------
  data2 = generate_2d_array(10, 10, -19.,16., 0, (/M,M/))

;---Add dummy coordinate arrays in a different data space
  data2!0 = "y"
  data2!1 = "x"
  data2&x = data1&x          ; Same as first dataset
  data2&y = ispan(1,M,1)     ; Different than first dataset

;----------------------------------------------------------------------
; Start the graphics
;----------------------------------------------------------------------
  wks = gsn_open_wks("png","overlay")         ; send graphics to PNG file

;----------------------------------------------------------------------
; First contour plot
;----------------------------------------------------------------------
  cnres                        = True
; cnres@gsnDraw                = False
; cnres@gsnFrame               = False

  cnres@cnFillOn                = True        ; filled contours
  cnres@cnFillPalette           = "BlueYellowRed"
  cnres@cnLinesOn               = False
  cnres@cnLineLabelsOn          = False
  cnres@lbOrientation           = "Horizontal"

;---Titles
  cnres@tiMainString            = "Filled contour plot"
  cnres@tiYAxisString           = "Filled contour Y axis string"

  cnres@tmYROn                  = False    ; Turn off right tickmarks
  cnres@trYReverse              = True     ; Just for fun

;---Create filled contour plot
  contour_base = gsn_csm_contour(wks,data1,cnres)

;----------------------------------------------------------------------
; Second contour plot
;----------------------------------------------------------------------

;---Retrieve size, so we can set second plot to same size
  getvalues contour_base
    "vpXF"      : vpx
    "vpYF"      : vpy
    "vpWidthF"  : vpw
    "vpHeightF" : vph
  end getvalues

;---Set second contour plot resources
  cnres@gsnMaximize   = False    ; Don't maximize this one!

  cnres@vpXF          = vpx
  cnres@vpYF          = vpy
  cnres@vpWidthF      = vpw
  cnres@vpHeightF     = vph

  cnres@cnLinesOn     = True      ; Line contours
  cnres@cnLineColor   = "DarkOrchid4"
  cnres@cnFillOn      = False
  cnres@cnLineLabelsOn= True
  cnres@cnLineThicknessF = 2.0

;---tickmarks and titles
  cnres@tmYLOn        = False      ; Turn off left tickmarks and labels
  cnres@tmYRLabelsOn  = True       ; Turn on right tickmark labels 
  cnres@tmYROn        = True       ; Turn on right tickmark labels 

  cnres@tiYAxisSide   = "Right"
  cnres@tiYAxisString = "Line contour Y axis string"
  cnres@tiMainString  = "Line contour plot"

  cnres@cnInfoLabelOrthogonalPosF = -0.13    ; Move into plot

  cnres@trYReverse                = False    

;---Create line contour plot
  contour_ovly = gsn_csm_contour(wks,data2,cnres)

;----------------------------------------------------------------------
; Add line contour as annotation of filled contour.
;
; We do this instead of using "overlay", because "overlay"
; removes tickmarks from the overlaid plot, which we don't
; want.
;----------------------------------------------------------------------

;---First change title of the base plot and remove it from overlay plot
  setvalues contour_base
    "tiMainString" : "Overlaying two datasets w/different Y axes"
  end setvalues
  setvalues contour_ovly
    "tiMainOn" : False
  end setvalues

  annoid = gsn_add_annotation(contour_base,contour_ovly,True)

  maximize_output(wks,True) ; This draws everything on the frame 
                            ; and maximizes it
end
