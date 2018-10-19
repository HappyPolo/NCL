;****************************************************
; xy_27.ncl
;
; Concepts illustrated:
;   - Drawing an XY plot with four different Y axes
;   - Attaching a plot as an annotation of another plot
;   - Attaching a Y axis line as an annotation of another plot
;   - Maximizing plots after they've been created
;   - Using "getvalues" to retrieve resource values
;   - Generating "nice" values for tickmarks on an axis
;   - Drawing grid lines on an XY plot
;   - Removing the border, tickmarks, and labels from an XY plot
;   - Turning off minor tickmarks
;   - Retrieving the axes mins and maxs of a plot
;
; This script was originally from Michel Mesquita of the 
; Bjerknes Centre for Climate Research. He gave us 
; permission to include it here.
;
;****************************************************
;
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"   
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"   
;****************************************************
begin
;***************************
; read in data
;***************************
; storm 2015 from trkdat.sepoct92 file

  p    = (/1003.320,1004.550,1004.610,1005.550,1007.930,1007.960,1005.730, \
           1009.190,1009.080,1007.120,1003.440,1002.590,998.290,996.700, \
           991.490,989.250,987.150,986.190,984.170,984.630,981.370,977.380, \
           971.930,968.540,968.350,969.460,971.250,974.220,977.250,979.970, \
           982.410,984.520,987.150,990.110,992.370,994.340,996.670, \
           997.800,998.410,998.090,997.670,996.850/); pressure
  t    = (/5.759,8.058,8.227,6.377,6.078,6.284,6.391,3.418,6.962,7.552, \
           5.578,7.077,9.291,9.510,11.345,10.766,10.951,10.685,4.155,12.198, \
           20.743,20.828,20.149,21.017,23.210,19.957,18.388,17.946,16.812, \
           14.959,13.303,12.129,11.138,8.901,7.324,5.921,4.487,4.128,2.053, \
           1.704,2.709,3.211/); depth
  l = (/1.264,1.103,1.164,1.537,1.263,1.122,0.696,0.750,1.340,1.187,0.834, \
           0.770,1.097,0.965,1.107,1.558,1.465,1.333,0.786,1.197,1.634, \
           1.565,2.080,2.595,2.538,2.637,2.769,2.676,2.471,2.294,2.083, \
           2.061,1.736,1.531,1.284,0.844,0.736,0.642,0.531,0.448,0.277, \
           0.464/); laplacian
  time = ispan(1,42,1)                ; this is our x

  velocity =  (/53.5799,57.7655,73.9979,45.7520,10.4800,37.0623,47.6186, \
           62.3650,18.1371,44.9589,59.6955,37.3489,42.9335,36.4932,49.3756, \
           41.2208,38.0938,15.7781,53.0114,55.4751,55.7179,47.8898,34.0085, \
           43.0788,34.4275,20.7378,15.9455,14.0553,5.5624,3.7506,6.9101, \
           6.1102,8.2420,14.2949,3.9589,8.9817,18.3183,6.8383,5.7446, \
           6.0786,11.4981/)
;***************************
; plot parameters
;***************************
  wks = gsn_open_wks("png","xy")   ; send graphics to PNG file

; left variable
  resL           = True 

  resL@gsnFrame  = False           ; Don't draw plot or advance frame
  resL@gsnDraw   = False

  resL@vpXF      = 0.15
  resL@vpWidthF  = 0.58            ; Set width and height of plot.
  resL@vpHeightF = 0.2

  resL@trXMinF = 1.                 ; Set min/max of X axis.
  resL@trXMaxF = 42.

  resL@xyLineColor       = "NavyBlue"   ; To distinguish the lines
  resL@xyLineThicknesses = 2.      ; thicker line

; tickmarks:
  resL@tmXTOn              = False   ; Turn off top tickmarks

  resL@tmYLMinorOn         = False   ; Turn off left minor tickmarks

  resL@tmXBMode            = "Explicit"
  resL@tmXBValues          = ispan(2,42,4)
  resL@tmXBLabels          = (/"01OCT","02OCT","03OCT","04OCT","05OCT", \
                               "06OCT","07OCT","08OCT","09OCT","10OCT", \
                               "11OCT"/)
  resL@tmXBLabelFontHeightF = 0.01

  resL@tmXMajorGrid                = True
  resL@tmYMajorGrid                = True
  resL@tmXMajorGridThicknessF      = 1.0
  resL@tmYMajorGridThicknessF      = 1.0
  resL@tmXMajorGridLineDashPattern = 2
  resL@tmYMajorGridLineDashPattern = 2

  resL@tiMainString                = "Four curves with four separate Y axes"

  resL@tiYAxisString               = "Depth (hPa)"  ; axis string
  resL@tiYAxisFontColor            = resL@xyLineColor
  resL@tiYAxisFontHeightF          = 0.01


; right variable
  resR                        = True                      
  resR@xyLineColor            = "Brown"
  resR@xyDashPatterns         = 1                   ; dashed line for 2nd
  resR@xyLineThicknesses      = 2                   ; thicker line

  resR@trXMinF = resL@trXMinF
  resR@trXMaxF = resL@trXMaxF

  resR@tiYAxisString    = "Pressure (hPa)"   ; axis string
  resR@tiYAxisFontColor = resR@xyLineColor

  resR@tmYRMinorOn         = False   ; Turn off right minor tickmarks

; Laplacian variable
  resLa                        = True

  resLa@trXMinF                = resL@trXMinF
  resLa@trXMaxF                = resL@trXMaxF

  resLa@xyDashPatterns         = 2                   ; dashed line for 2nd
  resLa@xyLineThicknesses      = 2                   ; thicker line
  resLa@xyLineColor            = "Purple"

  resLa@tiYAxisString    = "Laplacian (hPa (~S~o~N~lat)~S~-2~N~)"   ; axis string
  resLa@tiYAxisFontColor = resLa@xyLineColor

  resLa@tmYRMinorOn = False   ; Turn off right minor tickmarks

  resLa@amOrthogonalPosF = 0.65 ; Move "l" axis to right a little

;
; Create the plot with the three variables and three different axes.
; Nothing is drawn at this point.
;
  plot = gsn_csm_xy3(wks,time,t,p,l,resL,resR,resLa)

;
; We want to add a fourth curve that has it's own Y axis, and put
; this Y axis as a single line to the left of the current plot.
;
; Retrieve some values from the plot so we can make sure the new
; (fourth) curve is drawn with the same limits and font sizes.
;
   getvalues plot
     "vpHeightF"            : vph
     "vpWidthF"             : vpw
     "vpXF"                 : vpx
     "vpYF"                 : vpy
     "trXMinF"              : xmin
     "trXMaxF"              : xmax
     "tiYAxisFontHeightF"   : yaxis_fh
     "tmYLLabelFontHeightF" : ylab_fh
   end getvalues
;
; Set up some resources so we can add a fourth Y curve to the
; previous plot in the same location as the first three curves,
; but without any tickmarks.
;
; First create the curve only, with no tickmarks or labels.
;
  res4             = True
  res4@gsnFrame    = False
  res4@gsnDraw     = False

  res4@vpHeightF   = vph    ; Use same width, height and
  res4@vpWidthF    = vpw    ; XY locations as previous plot.
  res4@vpXF        = vpx
  res4@vpYF        = vpy

  res4@trXMinF     = xmin   ; Use same min/max values for X axis.
  res4@trXMaxF     = xmax
;
; Pick some "nice" values for the velocity axis, so we can
; make sure we use these same nice values for the single Y 
; axis line.
;
  mnmxint       = nice_mnmxintvl(min(velocity), max(velocity), 10, True)
  res4@trYMinF  = mnmxint(0)
  res4@trYMaxF  = mnmxint(1)

  res4@tmXTOn      = False   ; Turn off tickmarks and labels
  res4@tmXBOn      = False
  res4@tmYROn      = False
  res4@tmYLOn      = False
  res4@tmYLMinorOn = False   ; Turn off left minor tickmarks
  res4@tiYAxisOn   = False
  res4@tiXAxisOn   = False

  res4@xyLineColor = "red"   ; Just to make new curve stand out.

; The new curve is just created at this point, and not drawn.
  xy4 = gsn_csm_xy(wks, time(0:40), velocity, res4)

;
; Add this fourth curve as annotation of the original plot.
; This way, if we resize the plot, all the curves will resize
; accordingly.
;
  anno1 = NhlAddAnnotation(plot,xy4)
  setvalues anno1
    "amZone"         : 0     ; Zone 0 centers tick marks over map.
    "amResizeNotify" : True  ; Resize tick marks if map resized.
  end setvalues

; Last step is to attach a single vertical line that will
; represent the Y axis for the fourth curve.  Make the width
; of this plot basically 0, so we can then use the amZone
; resource to attach the left edge of this plot to the left side
; of the previous plot, outside of the tickmarks and labels.
;
  res4@vpHeightF    = vph      ; Same height as plot.
  res4@vpWidthF     = 0.0001   ; Width of plot close to 0.0
  res4@trXMinF      = xmin
  res4@trXMaxF      = xmax

; Turn off all but the left tickmarks and labels
  res4@tmXBOn              = False
  res4@tmXBBorderOn        = False
  res4@tmXTOn              = False
  res4@tmXTBorderOn        = False
  res4@tmYROn              = False
  res4@tmYLOn              = True
  res4@tmYLLabelFontHeightF  = ylab_fh

  res4@tiYAxisOn           = True
  res4@tiYAxisFontColor    = "red"
  res4@tiYAxisString       = "Velocity"
  res4@tiYAxisFontHeightF  = yaxis_fh
;
; Generate a dummy vertical line for this plot.
;
  xdummy    = new( 2, double)
  ydummy    = new( 2, double)

  ydummy(0) = res4@trYMinF   ; dummy for vertical line
  ydummy(1) = res4@trYMaxF
  xdummy(0) = xmax
  xdummy(1) = xmax
;
; Create the vertical line.
;
  line = gsn_csm_xy(wks,xdummy,ydummy,res4)

;
; Add this line as an annotation of the original plot.
;
; An orthogonal value of 0.63 will move the line to the left of the
; original plot.
;
  anno4 = NhlAddAnnotation(plot,line)
  setvalues anno4
    "amZone"           : 0     ; Zone 2 is outside the tickmarks
    "amResizeNotify"   : True  ; Resize tick marks if plot resized.
    "amJust"           : "CenterRight"
    "amOrthogonalPosF" : .63   ; Just to left of original plot
    "amSide"           : "Left" 
  end setvalues

;
; Maximize all of this output on the frame. The plot will be
; drawn and the frame advanced.
; 
  psres = True
  maximize_output(wks,psres)

end
