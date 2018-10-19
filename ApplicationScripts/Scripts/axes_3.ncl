;*************************************************
; axes_3.ncl           
;************************************************
;
; Concepts illustrated:
;   - Removing the border, tickmarks, and labels from an XY plot
;   - Drawing vertical grid lines on an XY plot
;   - Making an axis logarithmic in an XY plot
;   - Drawing four XY plots on the same page using viewport resources
;   - Drawing Y axis labels using exponents
;
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"

begin
;
; Modify the color map.  Color indices '0' and '1' are the background
; and foreground colors respectively.
;
  cmap = (/ (/1.0,1.0,1.0/), (/0.0,0.0,0.0/), \
           (/1.0,0.5,0.0/),  (/0.0,1.0,0.5/), \
           (/0.5,0.0,1.0/),  (/0.6,0.2,0.2/) /)

;
; Create some dummy data for XY plots.
;
  npts = 501

  x = 500.+.9*ispan(0,npts-1,1)*cos(0.031415926535898*ispan(0,npts-1,1))
  y = 500.+.9*ispan(0,npts-1,1)*sin(0.031415926535898*ispan(0,npts-1,1))

;
; Graphics code
;
  wks = gsn_open_wks("png","axes") ; send graphics to PNG file
  gsn_define_colormap(wks,cmap)

;
; "res" will contain the resources common to all four plots.
;
  res = True

  res@gsnFrame           = False   ; Don't advance the frame
  res@vpHeightF          = 0.32    ; Width and height of
  res@vpWidthF           = 0.32    ; each plot in NDC space.

  res@trYMinF            = 100.   ; Limits for Y axis.  The limits
  res@trYMaxF            = 1000.  ; for the X axis will be different
                                  ; fo each plot.
;
; Title resources
;
  res@tiMainFontHeightF  = 0.018
  res@tiXAxisFontHeightF = 0.018
  res@tiYAxisFontHeightF = 0.018

  res@xyLineThicknessF   = 3.0

; Create the four individual resource lists.
  res1 = True   ; These four lines are redundant.
  res2 = True
  res3 = True
  res4 = True

  res1 = res
  res2 = res
  res3 = res
  res4 = res

;-----------------------Begin first plot--------------------------

  res1@vpXF              = 0.1    ; X,Y position of first plot
  res1@vpYF              = 0.93

  res1@trXMinF           = 0.
  res1@trXMaxF           = 900.

  res1@tiMainString      = "Perimeter Background"
  res1@tiXAxisString     = "Linear"
  res1@tiYAxisString     = "Linear"

  res1@tmXBMinorPerMajor = 1
  res1@tmXBMode          = "Manual"
  res1@tmXBTickEndF      = 900.
  res1@tmXBTickSpacingF  = "100."
  res1@tmXBTickStartF    = "0."
  res1@tmYLMinorPerMajor = 1
  res1@tmYLMode          = "Manual"
  res1@tmYLTickEndF      = 1000.
  res1@tmYLTickSpacingF  = 100.
  res1@tmYLTickStartF    = 100.

  res1@xyLineColor       = 2

  plot = gsn_csm_xy(wks,x,y,res1)   ; First plot, upper left corner

;-----------------------Begin second plot--------------------------

  res2@vpXF              = 0.6    ; X,Y position of second plot
  res2@vpYF              = 0.93

  res2@trXMinF           = 0.
  res2@trXMaxF           = 900.

  res2@tiMainString      = "Grid Background"
  res2@tiXAxisString     = "Linear "
  res2@tiYAxisString     = "Logarithmic"

  res2@tmXBMinorPerMajor = 1
  res2@tmXBMode          = "Manual"
  res2@tmXBTickEndF      = 900.
  res2@tmXBTickSpacingF  = 100.
  res2@tmXBTickStartF    = 0.
  res2@tmXMajorGrid      = True
  res2@tmYLMinorPerMajor = 1
  res2@tmYMajorGrid      = True

  res2@xyLineColor       = 3
  res2@xyYStyle          = "Log"
  
  plot = gsn_csm_xy(wks,x,y,res2)   ; Second plot, upper right corner

;-----------------------Begin third plot--------------------------

  res3@vpXF              = 0.1    ; X,Y position of third plot
  res3@vpYF              = 0.45

  res3@trXMinF           = 10.
  res3@trXMaxF           = 1000.

  res3@tiMainString      = "Half-Axis Background"
  res3@tiXAxisString     = "Logarithmic"
  res3@tiYAxisString     = "Linear "

  res3@tmXBMinorPerMajor = 1
  res3@tmXBTickEndF      = 1000.
  res3@tmXBTickSpacingF  = 10.
  res3@tmXBTickStartF    = 10.
  res3@tmXTBorderOn      = False
  res3@tmXTOn            = False
  res3@tmXUseBottom      = False
  res3@tmYLMinorPerMajor = 1
  res3@tmYLMode          = "Manual"
  res3@tmYLTickEndF      = 1000.
  res3@tmYLTickSpacingF  = 100.
  res3@tmYLTickStartF    = 100.
  res3@tmYRBorderOn      = False
  res3@tmYROn            = False
  res3@tmYUseLeft        = False

  res3@xyLineColor       = 4
  res3@xyXStyle          = "Log"

  plot = gsn_csm_xy(wks,x,y,res3)   ; Third plot, lower left corner

;-----------------------Begin fourth plot--------------------------

  res4@vpXF              = 0.6    ; X,Y position of fourth plot
  res4@vpYF              = 0.45

  res4@trXMinF           = 31.628
  res4@trXMaxF           = 1000.

  res4@tiMainString      = "No Background"
  res4@tiXAxisString     = "Logarithmic"
  res4@tiYAxisString     = "Logarithmic"

  res4@tmXBBorderOn      = False
  res4@tmXBMinorPerMajor = 1
  res4@tmXBOn            = False
  res4@tmXTBorderOn      = False
  res4@tmXTOn            = False
  res4@tmYLBorderOn      = False
  res4@tmYLMinorPerMajor = 1
  res4@tmYLOn            = False
  res4@tmYRBorderOn      = False
  res4@tmYROn            = False

  res4@xyLineColor       = 5
  res4@xyXStyle          = "Log"
  res4@xyYStyle          = "Log"

  plot = gsn_csm_xy(wks,x,y,res4)   ; Fourt plot, lower right corner

  frame(wks)
end
