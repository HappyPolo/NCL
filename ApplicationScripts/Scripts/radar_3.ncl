;**************************************************************
; radar_3.ncl
;
; Concepts illustrated:
;   - Reading CF radial data
;   - Drawing a radial background plot
;   - Plotting radar (r,theta) data
;   - Creating a blank plot
;   - Drawing a scatter plot with markers of different colors and sizes
;   - Using "setvalues" to change the main title of an existing plot
;   - Attaching markers, text, and polylines to a blank plot
;   
;**************************************************************
; This script shows how to create a radial background plot that
; you can then attach other plot elements to. This particular
; example shows how to attach dummy markers.
;
; The following resources are recognized by the main "radial_plot"
; function, which is called in the main program below:
;
;  rdlRadius
;  rdlXCenter
;  rdlYCenter
;  rdlRadialLineAngle
;  rdlRadialLineColor
;  rdlRadialLineDashPattern
;  rdlRadialLineThicknessF
;  rdlOuterCircleLabelSpacing
;  rdlInnerCircleLineThickness
;  rdlInnerCircleSpacing
;  rdlInnerCircleLineDashPattern
;  rdlOuterCircleLineColor
;  rdlInnerCircleLineColor
;  
;**************************************************************
;
; These files are loaded by default in NCL V6.2.0 and newer
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"

DEGTORAD = 0.017453292519943
  
;----------------------------------------------------------------------
; add_radial_circles(wks,plot,res)
;     This procedure draws the outer solid circle and the inner dashed
;     circles for a radial background plot.
;
; Other radial procedures in this example script are:
;   add_radial_lines
;   add_radial_labels
; 
; Recognized resources:
;   rdlRadius
;   rdlXCenter
;   rdlYCenter
;   rdlOuterCircleLineThickness
;   rdlOuterCircleLineColor
;   rdlInnerCircleLineDashPattern
;   rdlInnerCircleLineThickness
;   rdlInnerCircleLineColor
;   rdlInnerCircleSpacing
;----------------------------------------------------------------------
procedure add_radial_circles(wks,plot,res)
local xcenter, ycenter, spacing, radius, degrees, xc, yc, \
lnres, dumstr, xcos, xsin, r, res2
begin
  res2 = res   ; Make copy of resources

;---Get customizations for circles.
  radius  = get_res_value_keep(res2,"rdlRadius",240)
  xcenter = get_res_value_keep(res2,"rdlXCenter",0)
  ycenter = get_res_value_keep(res2,"rdlYCenter",0)
  otrthck = get_res_value_keep(res2,"rdlOuterCircleLineThickness",2)
  inrthck = get_res_value_keep(res2,"rdlInnerCircleLineThickness",1)
  spacing = get_res_value_keep(res2,"rdlInnerCircleSpacing",45)
  dpattrn = get_res_value_keep(res2,"rdlInnerCircleLineDashPattern",2)
  otrcolr = get_res_value_keep(res2,"rdlOuterCircleLineColor",1)
  inrcolr = get_res_value_keep(res2,"rdlInnerCircleLineColor",1)

;---Calculate arrays for outer circle.
  degrees = ispan(0,360,5)
  xcos    = cos(DEGTORAD * degrees)
  xsin    = sin(DEGTORAD * degrees)
  xc      = xcenter + radius  * xcos
  yc      = ycenter + radius  * xsin 

;---Resources for outer circle
  lnres                  = True
  lnres@gsLineThicknessF = otrthck
  lnres@gsLineColor      = otrcolr

;---Attach circle to plot
  dumstr        = unique_string("outer_circle")
  plot@$dumstr$ = gsn_add_polyline(wks,plot,xc,yc,lnres)

  if(spacing.gt.radius) then
    print("add_radial_circles: spacing is > radius, can't draw inner circles.")
    return
  end if

;---Draw inner circles if desired
  if(spacing.gt.0) then
    count = 0
    do r = spacing,radius-spacing,spacing

;---Calculate arrays for inner circle.
      xc = xcenter + (r * xcos)
      yc = ycenter + (r * xsin)

;---Resources for inner circle
      delete(lnres@gsLineThicknessF)   ; Delete in case setting to 
      delete(lnres@gsLineColor)        ; new type.
      lnres@gsLineColor       = inrcolr
      lnres@gsLineThicknessF  = inrthck
      lnres@gsLineDashPattern = dpattrn

;---Attach inner circle to plot
      dumstr        = unique_string("inner_circle")+count
      plot@$dumstr$ = gsn_add_polyline(wks,plot,xc,yc,lnres)
      count = count + 1
    end do
  end if
end

;----------------------------------------------------------------------
; add_radial_lines(wks,plot,res)
;     This procedure draws the radial lines for a radial background plot.
;
; Other radial procedures in this example script are:
;   add_radial_circles
;   add_radial_labels
;
; Recognized resources:
;   rdlRadius
;   rdlXCenter
;   rdlYCenter
;   rdlRadialLineAngle
;   rdlRadialLineColor
;   rdlRadialLineDashPattern
;   rdlRadialLineThicknessF
;----------------------------------------------------------------------
procedure add_radial_lines(wks,plot,res)
local xcenter, ycenter, spacing, radius, degrees, angle, res2, \
degrees, xl, yl, lnres, dumstr, nlines, i, d
begin
  res2 = res   ; Make copy of resources

;---Get customizations for radial lines.
  radius  = get_res_value_keep(res2,"rdlRadius",240)
  xcenter = get_res_value_keep(res2,"rdlXCenter",0)
  ycenter = get_res_value_keep(res2,"rdlYCenter",0)
  angle   = get_res_value_keep(res2,"rdlRadialLineAngle",30)
  lcolor  = get_res_value_keep(res2,"rdlRadialLineColor",1)
  dpattrn = get_res_value_keep(res2,"rdlRadialLineDashPattern",2)
  thcknss = get_res_value_keep(res2,"rdlRadialLineThicknessF",1.)

;---Error checking
  if(angle.le.0.or.angle.ge.360) then
    print("add_radial_lines: angle must be between 0 and 360.")
    print("                  Can't draw radial lines.")
    return
  end if

;---Resources for radial lines
  lnres                   = True
  lnres@gsLineDashPattern = dpattrn
  lnres@gsLineColor       = lcolor
  lnres@gsLineThicknessF  = thcknss

;---Calculate arrays for lines
  xlines  = 360./angle 
  nlines  = toint(ceil(xlines))
  if(xlines.ne.nlines) then
    degrees = fspan(0,360,nlines)
  else
    degrees = fspan(0,360-angle,nlines)
  end if

  nlines  = dimsizes(degrees)
  do i = 0,nlines-1
    xl = (/xcenter, xcenter + (radius  * cos(DEGTORAD * degrees(i)))/)
    yl = (/ycenter, ycenter + (radius  * sin(DEGTORAD * degrees(i)))/)

;---Attach line to plot
  dumstr        = unique_string("radial_lines")+i
  plot@$dumstr$ = gsn_add_polyline(wks,plot,xl,yl,lnres)

  end do
end

;----------------------------------------------------------------------
; add_radial_labels(wks,plot,res)
;     This procedure draws the degree labels around the outer circle
;     for a radial background plot.
;
; Other radial procedures in this example script are:
;   add_radial_lines
;   add_radial_labels
;
; Recognized resources:
;   rdlRadius
;   rdlXCenter
;   rdlYCenter
;   rdlOuterCircleLabelSpacing (in degrees) 
;----------------------------------------------------------------------
procedure add_radial_labels(wks,plot,res)
local xcenter, ycenter, spacing, radius, res2, \
angles, labels, nlabels, txres, txid, amid, delta, \
xt, yt, quad1, quad2, quad3, quad4, xmin, xmax, ymin, ymax, xp, yp
begin
  res2 = res   ; Make copy of resources

;---Get customizations for labels
  radius  = get_res_value_keep(res2,"rdlRadius",240)
  xcenter = get_res_value_keep(res2,"rdlXCenter",0)
  ycenter = get_res_value_keep(res2,"rdlYCenter",0)
  spacing = get_res_value_keep(res2,"rdlOuterCircleLabelSpacing",30)

;---Generate angle spacings and labels
  angles  = ispan(0,360-spacing,spacing)
  labels  = tostring(angles) + "~S~o"
  nlabels = dimsizes(labels)

;---Locations for labels
  xt = xcenter + (radius  * cos(DEGTORAD * angles))
  yt = ycenter + (radius  * sin(DEGTORAD * angles))

;---Get the current axes limits
  getvalues plot
    "trXMinF" : xmin
    "trXMaxF" : xmax
    "trYMinF" : ymin
    "trYMaxF" : ymax
  end getvalues

;---Add a little more space to axes limits for labels.
  delta = (xmax - xmin)/20.
  setvalues plot
    "trXMinF"               : xmin - delta
    "trXMaxF"               : xmax + delta
    "trYMinF"               : ymin - delta
    "trYMaxF"               : ymax + delta
  end setvalues

;---Determine which quadrant each label is in.
  quad1 = ind(  0.lt.angles.and.angles.lt. 90)
  quad2 = ind( 90.lt.angles.and.angles.lt.180)
  quad3 = ind(180.lt.angles.and.angles.lt.270)
  quad4 = ind(270.lt.angles.and.angles.lt.360)
  rgt   = ind(angles.eq.  0)
  top   = ind(angles.eq. 90)
  lft   = ind(angles.eq.180)
  bot   = ind(angles.eq.270)

;---Justifcations for text strings.
  just        = new(nlabels,string)
  just(quad1) = "BottomLeft"  ; "CenterLeft"
  just(quad2) = "BottomRight" ; "CenterRight"
  just(quad3) = "TopRight"    ; "CenterRight"
  just(quad4) = "TopLeft"     ; "CenterLeft"
  if(.not.any(ismissing(rgt))) then
    just(rgt) = "CenterLeft"
    xt(rgt) = xt(rgt) + delta/10.
  end if
  if(.not.any(ismissing(top))) then
    just(top) = "BottomCenter"
    yt(top)   = yt(top) + delta/10.
  end if
  if(.not.any(ismissing(lft))) then
    just(lft) = "CenterRight"
    xt(lft)   = xt(lft) - delta/10.
  end if
  if(.not.any(ismissing(bot))) then
    just(bot) = "TopCenter"
    yt(bot)   = yt(bot) - delta/10.
  end if

;---Resources for radial lines
  txres               = True
  txres@txFontHeightF = 0.02

;---Array to hold text objects
  txid = new(nlabels,graphic)

;---Loop across labels and attach to plot.
  do i = 0,nlabels-1
    txres@txJust  = just(i)
    txid(i)       = gsn_add_text(wks,plot,labels(i),xt(i),yt(i),txres)
  end do
end

;----------------------------------------------------------------------
; This is the main function for creating a radial plot. It checks
; resources, and calls these three routines:
;
;   add_radial_circles
;   add_radial_lines
;   add_radial_labels
;----------------------------------------------------------------------
function radial_plot(wks,res)
local bres, rres, res2, bplot, radius, xcenter, ycenter
begin
  res2 = res   ; Make copy of resources

;---Get customizations for radial plot
  radius  = get_res_value(res2,"rdlRadius",240)
  xcenter = get_res_value(res2,"rdlXCenter",0)
  ycenter = get_res_value(res2,"rdlYCenter",0)

;---Set resources for a "blank" plot that will become the radial plot
  bres              = get_res_ne(res2,"rdl")
  bres              = True                       ; plot mods desired
  bres@gsnMaximize  = True

  bres@trXMinF      = xcenter - radius
  bres@trXMaxF      = xcenter + radius
  bres@trYMinF      = ycenter - radius
  bres@trYMaxF      = ycenter + radius

  bres@pmTickMarkDisplayMode = "Never"  ; Turn off tickmarks.

  bplot = gsn_blank_plot(wks,bres)

  if(res2) then
    rres = res2       ; Copy attributes
  end if

;---Make sure radius and center are set.
  rres            = True
  rres@rdlRadius  = get_res_value_keep(res2,"rdlRadius",radius)
  rres@rdlXCenter = get_res_value_keep(res2,"rdlXCenter",xcenter)
  rres@rdlYCenter = get_res_value_keep(res2,"rdlYCenter",ycenter)

  add_radial_circles(wks,bplot,rres)
  add_radial_lines(wks,bplot,rres)
  add_radial_labels(wks,bplot,rres)

  return(bplot)
end

;----------------------------------------------------------------------
; This procedure adds markers to an existing radial plot, given:
;
;
;   plot  : the radial background plot created with radial_plot
;   dvals : the values used to determine marker size and color
;   xarr, yarr: the x and y location
;  
;
;----------------------------------------------------------------------
procedure add_markers_to_radial_plot(wks,plot,dvals,ranges,angles,levels,res)
local radius, radius, xcenter, ycenter, nlevels, sizes, colors,
mkres, dum_fill, dum_hollow, i, ii, tmpstr, xarr, yarr
begin
  res2    = res
  radius  = get_res_value_keep(res2,"rdlRadius",240)
  xcenter = get_res_value_keep(res2,"rdlXCenter",0)
  ycenter = get_res_value_keep(res2,"rdlYCenter",0)
  nlevels = dimsizes(levels)

;---Calculate cartesian coordinates given angle and range.
  xarr = xcenter+(ranges*cos(DEGTORAD*angles))
  yarr = ycenter+(ranges*sin(DEGTORAD*angles))

;
; For each level, we want a different size and color for the marker.
; You may need to change sizes and/or colors if they do not have
; enough values to represent all of your levels.
;
  sizes  = ispan(25,75,5)/1000.    ; 0.0025 to 0.0075
  colors = (/"limegreen","orange","green","red","yellow","purple","blue",\
             "red","brown","red2","skyblue"/)
  nsizes  = dimsizes(sizes)
  ncolors = dimsizes(colors)

;---Error checking.
  if(any((/ncolors,nsizes/).lt.(nlevels-1))) then
     print("add_markers_to_radial_plot: warning: you don't have enough colors (" + \
           ncolors + ") and/or marker sizes (" + nsizes + \
           ") for the number of levels (" + (nlevels-1) + ").")
  end if

;---Arrays for attaching two sets of markers
  dum_fill   = new(nlevels-1,graphic)
  dum_hollow = new(nlevels-1,graphic)

;---Resource list for customizing markers.
  mkres = True

  mkres@gsMarkerThicknessF = 2.0      ; Twice as thick
;
; For each set of levels, gather the data that falls
; between two levels, and draw the set of markers at those
; locations.
;
  do i=0,nlevels-2
    ii = ind(levels(i).le.dvals.and.dvals.lt.levels(i+1))

    print("There are " + dimsizes(ii) + " points b/w levels " + \
           levels(i) + " and " + levels(i+1))
    
;---Filled dots
    mkres@gsMarkerIndex = 16
    mkres@gsMarkerSizeF = sizes(i)
    mkres@gsMarkerColor = colors(i)

    tmpstr = unique_string("fill")
    plot@$tmpstr$ = gsn_add_polymarker(wks,plot,xarr(ii),yarr(ii),mkres)

;---Hollow dots (to get outlines of the solid dots)
    mkres@gsMarkerIndex = 4           ; Hollow dots
    mkres@gsMarkerColor = "black"

    tmpstr = unique_string("hollow")
    plot@$tmpstr$ = gsn_add_polymarker(wks,plot,xarr(ii),yarr(ii),mkres)
    delete(ii)
  end do
end


;----------------------------------------------------------------------
; Main code
;----------------------------------------------------------------------
begin
  dir = "./"
  f  = addfile(dir + "cfrad.20080604_002217.nc","r")

;---Read in information about data.
  dsizes = dimsizes(f->DBZ) 
  ntime  = dsizes(0)           ; 4343
  nrange = dsizes(1)           ;  996

;---Set radius and center.
  xcenter  = 0.0
  ycenter  = 0.0
  radius   = max(f->range)

;---Start the graphics
  wks = gsn_open_wks("png","radar")              ; send graphics to PNG file

;---Resources for creating a radial background plot.
  res                             = True
  res@rdlRadius                   = radius
  res@rdlOuterCircleLabelSpacing  = 45           ; in degrees
  res@rdlOuterCircleLineThickness = 2            ; default is 1.0
  res@rdlInnerCircleSpacing       = radius/5     ; in units of the radius
  res@rdlInnerCircleLineColor     = "gray32"     ; default is "foreground"
  res@rdlRadialLineColor          = "gray32"     ; default is "foreground"
  res@rdlRadialLineAngle          = 45           ; in degrees

  res@tiMainString                = "Radial background"

;---Create radial background plot
  rbkgrnd = radial_plot(wks,res)

  draw(rbkgrnd)
  frame(wks)

;
; Now that we have a radial background plot, we can add stuff
; to it, like markers. The "add_markers_to_radial_plot"
; procedure will likely need to be modified to
; customize the markers.
;
;---Create some dummy angle, range, and data values for the markers.
  npts   = 100
  dvals  = random_uniform(0,100,npts)
  angles = random_uniform(0,360,npts)
  ranges = random_uniform(0,radius-radius/10.,npts)

;---Generate some dummy levels to group the data values by.
  levels  = ispan(0,100,10)

;---Attach markers to radial plot, using information passed here.
  add_markers_to_radial_plot(wks,rbkgrnd,dvals,ranges,angles,levels,res)

;---Change the title
  setvalues rbkgrnd
    "tiMainString" : "Radial background with markers"
  end setvalues

;---Drawing the background will draw the attached markers and new title.
  draw(rbkgrnd)
  frame(wks)
end
