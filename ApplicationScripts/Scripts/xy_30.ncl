;----------------------------------------------------------------------
; xy_30.ncl
;
; Concepts illustrated:
;   - Overlaying an XY plot on a "blank" plot to force an irregularly-spaced Y axis
;   - Creating tickmark objects using gsn_csm_blank_plot
;   - Forcing the Y axis to be irregular
;   - Using "getvalues" to retrieve resource values
;   - Using "setvalues" to set resource values
;   - Reversing the Y axis
;   - Using functions for cleaner code
;   - Maximizing plots after they've been created
;
;----------------------------------------------------------------------
;
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"

;------------------------------------------------------------------------
; NOTE: this function will be part of NCL version 6.0.0 and you won't   ;
; need to include it here.                                              ;
;                                                                       ;
; Function : gsn_csm_blank_plot                                         ;
;               wks : workstation                                       ;
;               res : optional resources                                ;
;                                                                       ;
; This function creates a blank tickmark object that can be used for    ;
; drawing primitives. This function is similar to gsn_blank_plot        ;
; except the tickmarks point outward and the gsnXXXString resources are ;
; recognized.                                                           ;
;                                                                       ;
;------------------------------------------------------------------------
; undef("gsn_csm_blank_plot")
; function gsn_csm_blank_plot(wks:graphic,res:logical)
; local calldraw, callframe, center_string, font_height, height, left_string, \
; main_zone, major_length, maxbb, minor_length, point_outward, ratio, \
; res2, right_string, scale, shape, subres, ticks, title, tmres, width, \
; xfontf, xlength, xmlength, yfontf, ylength, ymlength;
; begin
;  res2          = res    ; Copy of resources.

;  point_outward = get_res_value(res2,"gsnTickMarksPointOutward",True)

;  calldraw      = get_res_value(res2,"gsnDraw", True)
;  callframe     = get_res_value(res2,"gsnFrame",False)
;  shape         = get_res_value(res2,"gsnShape",False)
;  scale         = get_res_value(res2,"gsnScale",shape)
;  ticks         = get_res_value(res2,"pmTickMarkDisplayMode","Always")
;  title         = get_res_value(res2,"pmTitleDisplayMode","Always")
;  maxbb         = get_bb_res(res2)

; Check for existence of the left, center, and right subtitles.

;  left_string   = new(1,logical)
;  center_string = new(1,logical)
;  right_string  = new(1,logical)

;  check_for_subtitles(res2,left_string,center_string,right_string)
;  if(left_string.or.center_string.or.right_string)
;    main_zone = 4
;  else
;    main_zone = 3
;  end if

;  canvas = create "canvas" irregularPlotClass wks
;    "pmTickMarkDisplayMode" : ticks
;    "pmTitleDisplayMode"    : title
;    "pmTitleZone"           : main_zone    ; Zone for main title
;  end create

;  attsetvalues_check(canvas,res2)

; If gsnShape was set to True, then resize the X or Y axis so that
; the scales are proportionally correct.

;  if(shape)
;    gsnp_shape_plot(canvas)
;  end if

; If gsnScale was set to True, then make sure the X and Y axis labels
; and tick marks are the same size.

;  if(scale)
;    gsnp_scale_plot(canvas,"",False)
;  end if

; Get title label sizes and tickmark lengths.
;  getvalues canvas
;    "vpWidthF"             : width
;    "vpHeightF"            : height
;    "tiXAxisFontHeightF"   : xfontf
;    "tiYAxisFontHeightF"   : yfontf

;    "tmYLMajorLengthF"     : ylength
;    "tmXBMajorLengthF"     : xlength
;    "tmYLMinorLengthF"     : ymlength
;    "tmXBMinorLengthF"     : xmlength
;  end getvalues

;  font_height = min((/xfontf,yfontf/))  ; Make label sizes a function of
                                        ; the size of the X/Y axis labels.
;  major_length = min((/ylength,xlength/))
;  minor_length = min((/ymlength,xmlength/))

; If the plot is close to square in size, then make the 
; three top titles smaller.

;  ratio = height/width
;  if(ratio.gt.1) 
;    ratio = 1./ratio
;  end if
;  if(ratio.gt.0.5)
;    font_height  = 0.75 * font_height
;    major_length = 0.75 * major_length
;    minor_length = 0.75 * minor_length
;  end if

;  tmres = get_res_eq(res2,"tm")
;  gsnp_point_tickmarks_outward(canvas,tmres,xlength,ylength,xmlength, \
;                               ymlength,major_length,minor_length, \
;                               point_outward)

; Set up three subtitles at top, if they exist.
;  subres = get_res_eq(res2,(/"tx","am"/))  ; Get textitem resources
;  subres                  = True
;  set_attr(subres,"txFontHeightF",font_height)
;  add_subtitles(wks,canvas,left_string,center_string,\
;                right_string,subres)

;  draw_and_frame(wks,canvas,calldraw,callframe,False,maxbb)

;  return(canvas)
; end


;----------------------------------------------------------------------
; This function takes a regular XY plot with a linear Y axis, and 
; given a new set of Y axis values, changes the scale of the Y 
; axis to an irregular scale. 
;----------------------------------------------------------------------
undef("make_yaxis_irregular")
function make_yaxis_irregular(wks,plot,yvals)
local xaxis_type, xmin, xmax, ymin, ymax, yreverse
begin
;
; First retrieve some resource values from original plot so we
; can make sure new overlay object has same values.
;
; Depending on what axis you want to make "irregular", you may
; need to change which resources are retrieved and/or set.
;
  getvalues plot
    "trXAxisType"    : xaxis_type
    "trXMinF"        : xmin
    "trXMaxF"        : xmax
    "trYMinF"        : ymin
    "trYMaxF"        : ymax
    "trXReverse"     : xreverse
    "trYReverse"     : yreverse
  end getvalues

;
; Create a blank plot. This will enable us to make the Y axis
; of our existing plot irregular by overlaying our plot on the
; irregular object.
;
  bres                = True
  bres@gsnDraw        = False
  bres@trXAxisType    = xaxis_type
  bres@trXMinF        = xmin
  bres@trXMaxF        = xmax
  bres@trYMinF        = ymin
  bres@trYMaxF        = ymax
  bres@trXReverse     = xreverse
  bres@trYReverse     = yreverse

;---These two resources will change the Y axis to an irregular one.
  bres@trYAxisType    = "IrregularAxis"
  bres@trYCoordPoints = yvals

  blank_plot = gsn_csm_blank_plot(wks,bres)

;
; Overlay original plot on irregular object. This will cause a
; transformation to take place, and Y axis will be irregular.
;
  overlay(blank_plot,plot)

  return(blank_plot)
end

;------------------------------------------------------------------------
; MAIN CODE
;------------------------------------------------------------------------
begin
;---Read in data
 f     = addfile ("atmos.nc","r")
 u     = f->U                                      ; get u data

;---plotting parameters
 wks   = gsn_open_wks ("png","xy")                  ; send graphics to PNG file

 res                   = True                       ; plot mods desired
 res@gsnMaximize       = True

 res@tiMainString      = "Linear Y axis"
 res@trYReverse        = True                       ; reverse Y-axis
 plot  = gsn_csm_xy (wks,u(0,:,{30},{0}),u&lev,res) ; create plot

;---Create some dummy irregular values to use on Y axis. 
  ypts = (/0,50,100,150,200,300,400,600,800,1000/)

;---Change the title of original plot.
  setvalues plot
    "tiMainString" : "Irregular Y axis"
  end setvalues

;---Create a new plot with an irregular Y axis.
  
  irregular_plot = make_yaxis_irregular(wks,plot,ypts)

;---Make sure output is still maximized in frame.
  pres = True
  maximize_output(wks,pres)
end
