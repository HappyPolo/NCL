;****************************************************************
; axes_4.ncl           
;****************************************************************
; Concepts illustrated:
;   - Drawing a cartesian coordinate system
;   - Attaching customized axes to an existing plot
;   - Creating tickmark objects using gsn_blank_plot
;   - Removing the border, tickmarks, and labels from an XY plot
;   - Forcing tickmarks to cross the axis
;   - Creating a blank plot
;   - Using "setvalues" to set resource values
;   - Using "getvalues" to retrieve resource values
;   - Changing the length of tickmarks
;   - Changing the color of tickmarks
;   - Changing the size of tickmark labels
;   - Drawing epitrochoids
;
;****************************************************************
; This script removes the axes from an existing plot and 
; recreates a cartesian-style set of axes.
;****************************************************************
;
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"

;**********************************************************************
; Function for calculating an epitrochoid - a roulette traced by a 
; point attached to a circle of radius "r" rolling around the outside
; of a fixed circle of radius "R", where the point is a distance "d"
; from the center of the exterior circle. -- From Wikipedia
;
;  rr    : scalar, radius of smaller circle
;  RR    : scalar, radius of larger circle
;  dd    : scalar, distance from center of interior circle
;  npts  : number of points to generate in epitrochoid
;  deg_spcng : degree spacing
;**********************************************************************
function epitrochoid(rr[1]:numeric,RR[1]:numeric,dd[1]:numeric, \
                     npts[1]:integer, deg_spcng[1]:numeric)
local rad, degrees, dtor
begin
  rad     = 57.295779d
  degrees = ispan(0,npts-1,1) * deg_spcng
  dtor    = degrees/rad

  xyepit      = new((/2,npts/),double)
  xyepit(0,:) = (RR + rr)*cos(dtor) - dd * cos(((RR+rr)/rr)*dtor)
  xyepit(1,:) = (RR + rr)*sin(dtor) - dd * sin(((RR+rr)/rr)*dtor)

  xyepit@title = "epitrocycloid: npts=" + npts + ", r=" + rr + \ 
                 ", R=" + RR + ", d=" + dd + ", spacing="+deg_spcng
  return(xyepit)
end

function multiple_epitrochoids(nepis[1]:integer,opt[1]:logical)
local npts, RADIUS, dspcng, radius, distance
begin
  npts   = 500
  RADIUS = 5.
  dspcng = 1
  radius = new(nepis,float)
  radius = 1.
  distance = fspan(2,10,10)

  epi = new((/nepis,2,npts/),double)
  do i=0,nepis-1
    epi(i,:,:) = epitrochoid(radius(0), RADIUS, distance(i), npts, dspcng)
  end do

;
; This code forces all epitrochoids to be scale to the range
; of  the epitrochoid with the biggest range. It gives a
; different look to the curves.
;
  if(opt.and.isatt(opt,"MaxScale").and.opt@MaxScale) then
    xmins = dim_min_n(epi(:,0,:),1)
    xmaxs = dim_max_n(epi(:,0,:),1)
    ymins = dim_min_n(epi(:,1,:),1)
    ymaxs = dim_max_n(epi(:,1,:),1)
    xrange = xmaxs-xmins
    yrange = ymaxs-ymins
    max_xrange = max(xrange)
    max_yrange = max(yrange)
    ii = maxind(xrange)  ; should be same for yrange
    do i=0,nepis-1
      epi(i,0,:) = (epi(i,0,:)*max_xrange)/xrange(i)
      epi(i,1,:) = (epi(i,1,:)*max_yrange)/yrange(i)
    end do
  end if
  return(epi)
end

;**********************************************************************
; This function attaches a single vertical Y axis in the
; center of the given plot.
;**********************************************************************
function attach_vert_axis(wks,plot)
local vres, amres, xmin, xmax, ymin, ymax, vpx, vpy, vpw, vph, \
mj_length, mjo_length, mn_length, mno_length, font_height
begin

;---Retrieve information from original plot
  getvalues plot
    "vpXF"     : vpx
    "vpYF"     : vpy
    "vpWidthF" : vpw
    "vpHeightF": vph

    "trXMinF"  : xmin
    "trXMaxF"  : xmax
    "trYMinF"  : ymin
    "trYMaxF"  : ymax

    "tmYLLabels" : labels
    "tmYLValues" : values

    "tmYLMinorValues" : mvalues

    "tmYLLabelFontHeightF"    : font_height
    "tmYLMajorLengthF"        : mj_length
    "tmYLMinorLengthF"        : mn_length
    "tmYLMajorOutwardLengthF" : mjo_length
    "tmYLMinorOutwardLengthF" : mno_length
  end getvalues

;---Turn off the dead center tickmark label
  nlabels = dimsizes(labels)
  if((nlabels % 2).eq.1) then
    labels((nlabels-1)/2) = ""
  end if

  vres              = True

;---Don't draw or advance frame
  vres@gsnDraw      = False
  vres@gsnFrame     = False

;---Make sure blank plot has same axis limits as original plot
  vres@trXMinF      = xmin 
  vres@trXMaxF      = xmax
  vres@trYMinF      = ymin
  vres@trYMaxF      = ymax

;---Make sure blank plot has same size as original plot
  vres@vpXF         = vpx
  vres@vpYF         = vpy
  vres@vpWidthF     = vpw
  vres@vpHeightF    = vph

;---Turn off top, bottom, and right axis.
  vres@tmYROn       = False
  vres@tmXTOn       = False
  vres@tmXBOn       = False
  vres@tmYRBorderOn = False
  vres@tmXTBorderOn = False
  vres@tmXBBorderOn = False

;---Make tickmarks cross the axis.
  vres@tmYLMajorLengthF        = mj_length
  vres@tmYLMinorLengthF        = mn_length
  vres@tmYLMajorOutwardLengthF = mjo_length/2.
  vres@tmYLMinorOutwardLengthF = mno_length/2.

  vres@tmBorderLineColor       = "Gray40"
  vres@tmYLMajorLineColor      = "Gray40"
  vres@tmYLMinorLineColor      = "Gray40"

;---Make axis label font smaller
  vres@tmYLLabelFontHeightF    = 0.60 * font_height

;---Reset the labels w/o the "0" value labeled
  vres@tmYLMode                = "Explicit"
  vres@tmYLLabels              = labels
  vres@tmYLValues              = values
  vres@tmYLMinorValues         = mvalues

;---Create the blank plot with just a single vertical axis.
  vaxis = gsn_blank_plot(wks,vres)

;---Attach this axis to the original plot.
  amres                = True
  amres@amParallelPosF =  0.5     ; Shift right to center of plot
  vamid = gsn_add_annotation(plot,vaxis,amres)

  return(vamid)
end

;**********************************************************************
; This function attaches a single horizontal X axis in the
; center of the given plot.
;**********************************************************************
function attach_horiz_axis(wks,plot)
local hres, amres, xmin, xmax, ymin, ymax, vpx, vpy, vpw, vph, \
mj_length, mjo_length, mn_length, mno_length, font_height
begin

;---Retrieve information from original plot
  getvalues plot
    "vpXF"     : vpx
    "vpYF"     : vpy
    "vpWidthF" : vpw
    "vpHeightF": vph

    "trYMinF"  : ymin
    "trYMaxF"  : ymax
    "trXMinF"  : xmin
    "trXMaxF"  : xmax

    "tmXBLabelFontHeightF"    : font_height

    "tmXBLabels" : labels
    "tmXBValues" : values
    "tmXBMinorValues" : mvalues

    "tmXBMajorLengthF"        : mj_length
    "tmXBMinorLengthF"        : mn_length
    "tmXBMajorOutwardLengthF" : mjo_length
    "tmXBMinorOutwardLengthF" : mno_length
  end getvalues

;---Turn off the dead center tickmark label
  nlabels = dimsizes(labels)
  if((nlabels % 2) .eq. 1) then
    labels((nlabels-1)/2) = ""
  end if

  hres           = True

;---Don't draw or advance frame
  hres@gsnDraw      = False
  hres@gsnFrame     = False

;---Make sure blank plot has same size as original plot
  hres@vpXF         = vpx
  hres@vpYF         = vpy
  hres@vpWidthF     = vpw
  hres@vpHeightF    = vph

;---Make sure blank plot has same axis limits as original plot
  hres@trXMinF      = xmin 
  hres@trXMaxF      = xmax
  hres@trYMinF      = ymin
  hres@trYMaxF      = ymax


;---Turn off left, right, and top axis.
  hres@tmYLOn       = False
  hres@tmYROn       = False
  hres@tmXTOn       = False
  hres@tmYLBorderOn = False
  hres@tmYRBorderOn = False
  hres@tmXTBorderOn = False

;---Make tickmarks cross the axis.
  hres@tmXBMajorLengthF       = mj_length
  hres@tmXBMinorLengthF       = mn_length
  hres@tmXBMajorOutwardLengthF= mjo_length/2.
  hres@tmXBMinorOutwardLengthF= mno_length/2.

  hres@tmBorderLineColor       = "Gray40"
  hres@tmXBMajorLineColor      = "Gray40"
  hres@tmXBMinorLineColor      = "Gray40"

;---Make axis label font smaller
  hres@tmXBLabelFontHeightF   = 0.60 * font_height

;---Reset the labels w/o the "0" value labeled
  hres@tmXBMode                = "Explicit"
  hres@tmXBLabels              = labels
  hres@tmXBValues              = values
  hres@tmXBMinorValues         = mvalues

;---Create the blank plot with just a single horizontal axis.
  haxis = gsn_blank_plot(wks,hres)

;---Attach this axis to the original plot.
  amres                  = True
  amres@amOrthogonalPosF = -0.5     ; Shift up to center of plot
  hamid = gsn_add_annotation(plot,haxis,amres)

  return(hamid)
end

;**********************************************************************
; This function removes the existing axes from an NCL plot and
; reattaches a cartesian-style axis.
;**********************************************************************
function cartesian_axis(wks,plot)
begin
  setvalues plot
    "tiMainString"      : "Cartesian Coordinate System"

;---Turn off all default axes.
    "tmXBBorderOn"      : False
    "tmXTBorderOn"      : False
    "tmYLBorderOn"      : False
    "tmYRBorderOn"      : False
    "tmXBOn"            : False
    "tmXTOn"            : False
    "tmYLOn"            : False
    "tmYROn"            : False
    "tmXUseBottom"      : False
    "tmYUseLeft"        : False

;---Turn off all labels
    "tmXBLabelsOn"      : False
    "tmXTLabelsOn"      : False
    "tmYLLabelsOn"      : False
    "tmYRLabelsOn"      : False
  end setvalues

;---Attach single X and Y axis in center of plot.
  hid = attach_horiz_axis(wks,plot)
  vid = attach_vert_axis(wks,plot)

;---Be sure to return the ids of the axes we just attached.
  plot@haxis = hid
  plot@vaxis = vid
  return(plot)
end

;**********************************************************************
; Main code.
;**********************************************************************

begin
;---Generate values for one or more epitrochoids.
 NEPI         = 7
 opt          = True
 opt@MaxScale = True
 epitroxy = multiple_epitrochoids(NEPI,opt)

;
; Graphics code
;

  wks = gsn_open_wks("png","axes")       ; send graphics to PNG file
  gsn_define_colormap(wks,"rainbow+gray")
  getvalues wks
    "wkColorMapLen" : cmaplen
  end getvalues

  res = True

  res@gsnMaximize        = True         ; Maximize plot in frame

  col_step          = tointeger((cmaplen-3)/(NEPI-1))
  res@xyLineColors  = 2 + ispan(0,NEPI-1,1)*col_step

  res@tiMainString       = "Epitrochoid with default axes"

  res@xyMonoDashPattern  = True

  plot = gsn_csm_xy(wks,epitroxy(:,0,:),epitroxy(:,1,:),res)

;---Change to a cartesian axis.
  caxis = cartesian_axis(wks,plot)

  draw(plot)
  frame(wks)
end
