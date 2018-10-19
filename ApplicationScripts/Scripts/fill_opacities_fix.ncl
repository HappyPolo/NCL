;***********************************************************************;
; This script provides a fix for NCL V.6.1.0, 6.1.1, and 6.1.2,
; that allows you to use the new "gsnXYFillOpacities" resource.
; This fix will be available in V6.2.0 (or V6.1.3 if we do that release).
;
; You must load this script *after* you load the "gsn_csm.ncl" script.
;***********************************************************************;

;***********************************************************************;
; Function : fill_bw_xy                                                 ;
;                                                                       ;
; This function takes "n" Y or X curves, defined on the same set of X   ;
; or Y points, and fills the area between each adjacent curves with     ;
; some given color. Depending on options set by the user, the areas     ;
; between curves can be filled differently if one is greater than       ;
; another.                                                              ;
;                                                                       ;
;***********************************************************************;
undef("fill_bw_xy")
function fill_bw_xy(wks,plot,xx:numeric,yy:numeric,res:logical)
local y1_gt_y2, y1, y2, i, ab, bpt, ept, x, y, color, first, last, \
dsizes_y, rank_y, ncurves, npts, ppts, ppts2, res2, above_fill_colors, \
below_fill_colors, gsres, dum, fill_x, xi, yi, rgbArrayA, rgbArrayB, tmp
begin
;
; Determine whether we're filling between Y curves or X curves.
;
  ndimsx = dimsizes(xx)
  ndimsy = dimsizes(yy)
  rankx  = dimsizes(ndimsx)
  ranky  = dimsizes(ndimsy)

  if(rankx.eq.1.and.ranky.eq.2) then
    fill_x = False
    xi = xx
    yi = yy
  else
    if(rankx.eq.2.and.ranky.eq.1) then
      fill_x = True
      xi = yy
      yi = xx
    else
      print("fill_bw_xy: Error: If filling between two curves, one set must be 2D, and the other 1D.")
      return(plot)
    end if
  end if

; Check length of arrays.
;
  dsizes_y = dimsizes(yi)
  npts     = dimsizes(xi)
  ncurves  = dsizes_y(0)

  if(dsizes_y(1).ne.npts) then
    print("fill_bw_xy: Error: The rightmost dimension of both arrays must be the same.")
    return(plot)
  end if

  if(ncurves.le.1) then
    print("fill_bw_xy: Error: The leftmost dimension of input array must be at least 2.")
    return(plot)
  end if

  if(any(ismissing(xi)))
    print("fill_bw_xy: Error: The input array cannot contain any missing values")
    return(plot)
  end if

  if(.not.res) then
    return(plot)     ; No resources set, so just return.
  end if

  if(.not.isatt(res,"gsnXYFillColors").and. \
     .not.isatt(res,"gsnXYAboveFillColors").and. \
     .not.isatt(res,"gsnXYBelowFillColors").and. \
     .not.isatt(res,"gsnXYRightFillColors").and. \
     .not.isatt(res,"gsnXYLeftFillColors")) then
    return(plot)     ; No resources set, so just return.
  end if
;
; Check resources. There are five possible resources:
;    gsnXYFillColors
;    gsnXYAboveFillColors
;    gsnXYBelowFillColors
;    gsnXYRightFillColors
;    gsnXYLeftFillColors
;
; If the first one is set, it overwrites the others. If
; none of them are set, then no fill color will be used.
;
; To make things a little easier, above==right and below==left
;
  res2 = res       ; Make a copy
  if(res2) then
    if(isatt(res2,"gsnXYFillColors")) then
      above_fill_colors = get_res_value(res2,"gsnXYFillColors",-1)
      below_fill_colors = above_fill_colors
      dum               = get_res_value(res2,"gsnXYAboveFillColors",-1)
      dum               = get_res_value(res2,"gsnXYBelowFillColors",-1)
      dum               = get_res_value(res2,"gsnXYRightFillColors",-1)
      dum               = get_res_value(res2,"gsnXYLeftFillColors",-1)
    else
      if(fill_x) then
        above_fill_colors = get_res_value(res2,"gsnXYRightFillColors",-1)
        below_fill_colors = get_res_value(res2,"gsnXYLeftFillColors",-1)
      else
        above_fill_colors = get_res_value(res2,"gsnXYAboveFillColors",-1)
        below_fill_colors = get_res_value(res2,"gsnXYBelowFillColors",-1)
      end if
    end if
  end if
  if(isatt(res2,"gsnXYFillOpacities")) then
    fill_opacs = get_res_value(res2,"gsnXYFillOpacities",1.0)
  end if

  nacol = dimsizes(above_fill_colors)
  nbcol = dimsizes(below_fill_colors)

;
; This function originally assumed that if [above|below]_fill_colors were arrays,
; then they were arrays of color indices, and were indexed accordingly. 
; In the 32bit color scheme, an individual RGBa color is also an array (of floats), but should
; be treated as one logical entity. When we get a singular RGBa color, we'll convert it
; to a 1xN doubly dimensioned array, and we'll therefore always have 2D arrays when
; dealing with RGBa colors (either a 1xN or a MxN array of RGBa). Lastly, the original
; indexing scheme below will work as before if applied only to the first dimension of these
; 2D RGBa arrays. 
;
  rgbArrayA = False
  if (dimsizes(nacol).eq.1 .and. typeof(above_fill_colors).eq."float") then
    ;
    tmp = above_fill_colors
    delete(above_fill_colors)
    above_fill_colors = new((/1, nacol /), float)
    above_fill_colors(0,:) = tmp
    delete(tmp)
    delete(nacol)
    nacol = dimsizes(above_fill_colors)
  end if
  if (dimsizes(nacol).eq.2) then
    rgbArrayA = True    
    tmp = nacol(0) 
    delete(nacol)
    nacol = tmp
    delete(tmp)
  end if

  rgbArrayB = False
  if (dimsizes(nbcol).eq.1 .and. typeof(below_fill_colors).eq."float") then
    ;
    tmp = below_fill_colors
    delete(below_fill_colors)
    below_fill_colors = new((/1, nbcol /), float)
    below_fill_colors(0,:) = tmp
    delete(tmp)
    delete(nbcol)
    nbcol = dimsizes(below_fill_colors)
  end if 
  if (dimsizes(nbcol).eq.2) then
    rgbArrayB = True    
    tmp = nbcol(0) 
    delete(nbcol)
    nbcol = tmp
    delete(tmp)
  end if 

;
; Convert input arrays to double.
;
  x  = new(npts,double)
  y  = new(dsizes_y,double,1.e36)
  x  = (/xi/)
  y  = (/yi/)

;
; Create arrays for storing polygon points.
;
  first     = new(2,double)
  last      = new(2,double)
  polygon_x = new(2*npts+3,double)
  polygon_y = new(2*npts+3,double)

;
; Loop through each set of two curves, filling them as we go.
;
  gsres = True
  do n=0,ncurves-2
    y1 = yi(n,:)    ; Grab the current curve
    y2 = yi(n+1,:)  ; and the next curve.
  
    iacol = n % nacol
    ibcol = n % nbcol
;
; Compute a delta that will be used to determine if two points are
; actually the same point. 
;
    range_y1 = max(y1) - min(y1)
    range_y2 = max(y2) - min(y2)

    delta_y1 = 0.01 * range_y1
    delta_y2 = 0.01 * range_y2
    if(delta_y1.eq.0)
      delta = delta_y2
    else
      if(delta_y2.eq.0)
        delta = delta_y1
      else
        delta = min((/delta_y1,delta_y2/))
      end if
    end if

    npoly = 0     ; Number of polygons
;
; First fill in polygons where y1 is above y2, and then fill in
; polygons where y2 is above y1.
;
    do ab = 0,1
      if (rgbArrayA.eq.True) then
        gsres@gsFillColor    = above_fill_colors(iacol,:)
        gsres@gsFillOpacityF = fill_opacs(iacol,:)
      else
        gsres@gsFillColor    = above_fill_colors(iacol)
        gsres@gsFillOpacityF = fill_opacs(iacol)
      end if
      if(ab.eq.1)
        y1 = (/yi(n+1,:)/)
        y2 = (/yi(n,:)/)
; Color for when first curve is > second curve
        delete(gsres@gsFillColor)    ; just in case
        delete(gsres@gsFillOpacityF)
        if (rgbArrayB.eq.True) then
          gsres@gsFillColor    = below_fill_colors(ibcol,:)
          gsres@gsFillOpacityF = fill_opacs(ibcol,:)
        else
          gsres@gsFillColor    = below_fill_colors(ibcol)
          gsres@gsFillOpacityF = fill_opacs(ibcol)
        end if
      end if
;
; Get areas where y1 > y2.
;
      y1_gt_y2 = y1.gt.y2

      bpt = -1    ; Index of first point of polygon.
      ept = -1    ; Index of last point of polygon.
;
; Loop through points.
;
      do i=0,npts-1
        if(bpt.lt.0)
          if(.not.ismissing(y1_gt_y2(i)).and.y1_gt_y2(i))
            bpt = i
            ept = i
          end if
        else
          if(.not.ismissing(y1_gt_y2(i)).and.y1_gt_y2(i))
            ept = i
          end if
          if(ismissing(y1_gt_y2(i)).or..not.y1_gt_y2(i).or.ept.eq.(npts-1))
;
; Draw polygon. If bpt is the very first point or ept is the
; very last point, then these are special cases we have to
; handle separately.
;
            if(bpt.eq.0.or.(bpt.gt.0.and.(ismissing(y1(bpt-1)).or.\
                                          ismissing(y2(bpt-1)).or.\
                                          ismissing(x(bpt-1)))))
              first(0) = (/ x(bpt) /)
              first(1) = (/ y2(bpt)/)
            else
              if(fabs(y1(bpt-1)-y2(bpt-1)).le.delta)
;
; If the two points are within delta of each other, then we'll
; consider them to be the same point.
;
                first(0) = (/  x(bpt-1) /)
                first(1) = (/ y1(bpt-1) /)
              else
;
; Otherwise, find the intersection where the two curves cross.
;
                first = find_cross_xy(x(bpt-1),x(bpt),y1(bpt-1), \
                                      y1(bpt),y2(bpt-1),y2(bpt))
              end if
            end if
            if(ept.eq.(npts-1).or.(ept.lt.(npts-1).and.(ismissing(y1(ept+1)).or.\
                                                    ismissing(y2(ept+1)).or.\
                                                    ismissing(x(ept+1)))))
              last(0) = (/  x(ept) /)
              last(1) = (/ y2(ept) /)
            else
              if(fabs(y1(ept+1)-y2(ept+1)).le.delta)
;
; If the two points are within delta of each other, then we'll
; consider them to be the same point.
;
                last(0) = (/  x(ept+1) /)
                last(1) = (/ y1(ept+1) /)
              else
;
; Otherwise, find the intersection where the two curves cross.
;
                last = find_cross_xy(x(ept),x(ept+1),y1(ept),y1(ept+1), \
                                     y2(ept),y2(ept+1))
              end if
            end if
;
; Initialize polygon.
;
            ppts  = ept - bpt + 1
            ppts2 = ppts * 2
            polygon_x(0)              = (/first(0)/)
            polygon_y(0)              = (/first(1)/)
            polygon_x(1:ppts)         = x(bpt:ept)
            polygon_y(1:ppts)         = y1(bpt:ept)
            polygon_x(ppts+1)         = (/last(0)/)
            polygon_y(ppts+1)         = (/last(1)/)
            polygon_x(ppts+2:ppts2+1) = x(ept:bpt)
            polygon_y(ppts+2:ppts2+1) = y2(ept:bpt)
            polygon_x(ppts2+2)        = (/first(0)/)
            polygon_y(ppts2+2)        = (/first(1)/)
;
; Make sure polygons get drawn *after* the plot gets drawn.
;
            if(npoly.eq.0)
              setvalues plot
                "tfPolyDrawOrder" : "Predraw"
              end setvalues
            end if
;
; Add polygon to XY plot.
;
            var_string = unique_string("fill_polygon"+npoly)

            if(fill_x) then
              plot@$var_string$ = gsn_add_polygon(wks,plot, \
                                                  polygon_y(0:ppts2+2), \
                                                  polygon_x(0:ppts2+2),gsres)
            else
              plot@$var_string$ = gsn_add_polygon(wks,plot, \
                                                  polygon_x(0:ppts2+2), \
                                                  polygon_y(0:ppts2+2),gsres)
            end if
;
; Advance polygon counter.
;
            npoly = npoly + 1
            bpt = -1            ; Reinitialize
            ept = -1
          end if
        end if
      end do
    end do
  end do
  return(plot)
end
;***********************************************************************;
; Function : gsn_csm_xy                                                 ;
;                     wks: workstation object                           ;
;                       x: X values                                     ;
;                       y: X values                                     ;
;               resources: optional resources                           ;
;                                                                       ;
; This function creates and draws a titled XY plot to the workstation   ;
; "wks" (the variable returned from a previous call to "gsn_open_wks"). ;
; "resources" is an optional list of  resources. The Id of the map plot ;
; is returned.                                                          ;
;                                                                       ;
; This function behaves differently from gsn_xy in that it will         ;
; add additional titles to the top of the plot if any of the special    ;
; GSUN resources "gsnLeftString," "gsnCenterString," and/or             ;
; "gsnRightString" are set, They are used to title the top left, center,;
; and right of the plot (in addition, the regular resource              ;
; "tiMainString" can be set to create a regular title).                 ;
;                                                                       ;
; If gsnYRefLine is set to some value(s), then reference line(s) will be;
; drawn at this value(s). In addition, if gsnAboveYRefLineColor and/or  ;
; gsnBelowYRefLineColor is set, the polygons above and below the        ;
; reference line will be filled in these colors.                        ;
;                                                                       ;
; If gsnXRefLine is set to some value, then a reference line will be    ;
; drawn at this value.                                                  ;
;                                                                       ;
; If gsnXYBarChart is set to True, then a bar chart will be drawn       ;
; instead of a line plot. You can also set gsnYRefLine to have your     ;
; bars point up or down from the reference line.                        ;
;                                                                       ;
; The resource gsnXYBarChartColors can be used to specify an array of   ;
; bar colors. This resource was not implemented very smartly. These     ;
; colors will apply independently to both the above ref line bars, and  ;
; the below ref line bars. So, if you give this resource the colors     ;
; "red", "green", and "blue", then all the colors above the ref line    ;
; will cycle b/w these three colors, and independently, the colors below;
; the ref line will cycle b/w these colors. If you want to have one     ;
; resource that specifies the color for each bar, not caring whether it ;
; is above or below the ref line, use the "gsnXYBarChartColors2"        ;
; resource.                                                             ;
;                                                                       ;
; Same for the gsnXYBarChartPatterns/gsnXYBarChartPatterns2 resource.   ;
;                                                                       ;
; The resource gsnXYBarChartBarWidth can be used to specify the width   ;
; of each bar. The smallest dx is used by default.                      ;
;                                                                       ;
; The resource gsnAbove/BelowYRefLineBarColors can be used to specify   ;
; an array of bar colors.                                               ;
;                                                                       ;
; Tick marks will be made to point outwards.                            ;
;                                                                       ;
; If the user sets lgLabelFontHeightF to change the size of the legend  ;
; labels, then lgAutoManage will be set to False (unless it is being    ;
; set explicitly by the user.                                           ;
;                                                                       ;
;***********************************************************************;
undef("gsn_csm_xy")
function gsn_csm_xy(wks:graphic,x:numeric,y:numeric,resources:logical)
local res, xy_object, res2, xfontf, yfontf, font_height, calldraw, nlines, \
callframe, left_string, center_string, right_string, main_zone, ncurves, \
yabove, ybelow, ya_ind, yb_ind, xinterp, yinterp, bar_chart
begin

; Initialize.
    main_zone     = 2         ; Zone for main title (may change later)
    xref_line_on  = False     ; X reference line flag
    yref_line_on  = False     ; Y reference line flag
    yref_fill_on  = False     ; Whether to fill above/below Y ref line.
    bar_chart     = False     ; Whether we want bars
    fill_xy_res   = False     ; Whether we want to fill b/w curves
    res2          = get_resources(resources)
;
; Write data and plot resource information to a file so we can 
; reconstruct plot if desired, without all the computational
; code beforehand.
;
    if(isatt(res2,"gsnDebugWriteFileName")) then
      gsnp_write_debug_info(x,y,new(1,float),"gsn_csm_xy",res2,2)
    end if

    left_string   = False
    center_string = False
    right_string  = False
    tm_scale      = get_res_value_keep(res2,"gsnScale",True)
    point_outward = get_res_value(res2,"gsnTickMarksPointOutward",True)

; Check if frame and/or draw are not supposed to be called.

    calldraw  = get_res_value(res2,"gsnDraw", True)
    callframe = get_res_value(res2,"gsnFrame",True)
    maxbb     = get_bb_res(res2)

; Calculate number of Y points.

    ndimsy = dimsizes(dimsizes(y))
    ndimsx = dimsizes(dimsizes(x))

    if(ndimsy.eq.1)
      ncurves = 1
      npts    = dimsizes(y)
    else
      ncurves = dimsizes(y(:,0))
      npts    = dimsizes(y(0,:))
    end if

    if(ndimsx.eq.1)
      nptsx = dimsizes(x)
    else
      nptsx = dimsizes(x(0,:))
    end if
;
; Test dimensions. They must both either be the same, or have the
; same rightmost dimension.
;
    if( (ndimsx.gt.1.and.ndimsy.gt.1.and.(ndimsx.ne.ndimsy.or. \
         .not.all(dimsizes(x).eq.dimsizes(y)))).or.\
        ((ndimsx.eq.1.or.ndimsy.eq.1).and.nptsx.ne.npts))
      print("gsn_csm_xy: Fatal: X and Y must have the same dimensions sizes, or one must be one-dimensional and both have the same rightmost dimension.")
    end if

; This section tests for more special resources: those that start
; with "gsn."

    if((res2).and..not.any(ismissing(getvaratts(res2))))
;
; Check if gsnShape set.
;
      if(isatt(res2,"gsnShape").and.res2@gsnShape)
        main_zone     = main_zone+1 ; Zone for main title
      end if

; Check if filling between curves is desired. This can be
; specified via gsnXYFillColors, gsnXYAboveFillColors,  
; gsnXYBelowFillColors, gsnXYLeftFillColors, gsnXYRightFillColors.

      fill_atts = (/"gsnXYFillColors", "gsnXYAboveFillColors", \
                    "gsnXYBelowFillColors","gsnXYLeftFillColors", \
                    "gsnXYRightFillColors","gsnXYFillOpacities"/)
      if(any(isatt(res2,fill_atts))) then
;
; Make sure you collect the appropriate resources to pass
; to fill_bw_xy later.
;
        fill_xy_res = True
        do na = 0,dimsizes(fill_atts)-1
          if(isatt(res2,fill_atts(na))) then
            fill_xy_res@$fill_atts(na)$ = get_res_value(res2,fill_atts(na),1)
          end if
        end do
;
; This next requirement is mostly out of laziness. It wouldn't be that 
; hard to let both X and Y be multi-dimensional. Or would it?
;
        if(ndimsx.ne.1.and.ndimsy.ne.1) then
          print("gsn_csm_xy: Warning: to fill between curves, either X or Y must be 1D.")
          fill_xy_res = False
        end if
      end if

; Check if gsnYRefLine set.

      if(isatt(res2,"gsnYRefLine"))
        yref_line_on = True
        yref_line    = res2@gsnYRefLine
        nyref        = dimsizes(yref_line)
        delete(res2@gsnYRefLine)
;
; Determine color of fill above reference line(s).
;
        if(isatt(res2,"gsnAboveYRefLineColor"))
          if(.not.(dimsizes(res2@gsnAboveYRefLineColor).eq.nyref.or.\
                   dimsizes(res2@gsnAboveYRefLineColor).eq.1))
            print("gsn_csm_xy: Fatal: there must either be an above-line fill color for every reference line, or one global above-line fill color specified")
            return
          end if
          yref_line_above = res2@gsnAboveYRefLineColor
          yref_fill_on    = True
          delete(res2@gsnAboveYRefLineColor)
        else
          if(any(isatt(res2,(/"gsnXYBarChartPatterns", \
                              "gsnXYBarChartPatterns2", \
                              "gsnAboveYRefLineBarPatterns"/)))) then
            yref_line_above = 1    ; defaults to foreground.
          else
            yref_line_above = -1    ; defaults to no fill.
          end if
        end if
;
; Determine color of fill below reference line(s).
;
        if(isatt(res2,"gsnBelowYRefLineColor"))
          if(.not.(dimsizes(res2@gsnBelowYRefLineColor).eq.nyref.or.\
                   dimsizes(res2@gsnBelowYRefLineColor).eq.1))
            print("gsn_csm_xy: Fatal: there must either be an below-line fill color for every reference line, or one global below-line fill color specified ")
            return
          end if
          yref_line_below = get_res_value(res2,"gsnBelowYRefLineColor",1)
          yref_fill_on    = True
        else
          if(any(isatt(res2,(/"gsnXYBarChartPatterns", \
                              "gsnXYBarChartPatterns2", \
                              "gsnBelowYRefLineBarPatterns"/)))) then
            yref_line_below = 1    ; defaults to foreground.
          else
            yref_line_below = -1    ; defaults to no fill.
          end if
        end if
;
; If yref_fill_on is True, and we have more than one curve, then there
; should be the same number of reference lines as curves.
;
        if(yref_fill_on.and.ncurves.gt.1.and.ncurves.ne.nyref.and.nyref.ne.1)
          print("gsn_csm_xy: Fatal: if you plan to fill above and/or below reference lines, then the number of reference lines must either equal the number")
          print("of curves, or be one.")
          return
        end if
;
; Determine color of Y reference line(s).
;
        set_yref_line_color = False
        if(isatt(res2,"gsnYRefLineColors"))
          yref_line_color = get_res_value(res2,"gsnYRefLineColors","foreground")
          set_yref_line_color = True
        else
          if(isatt(res2,"gsnYRefLineColor"))
            yref_line_color = get_res_value(res2,"gsnYRefLineColor","foreground")
            set_yref_line_color = True
          else
            yref_line_color = "foreground"
          end if
        end if
        if(set_yref_line_color) then
          if(.not.(dimsizes(yref_line_color).eq.nyref.or.\
                   dimsizes(yref_line_color).eq.1))
            print("gsn_csm_xy: Warning: you must specify either one Y reference line color")
            print("or the same number of colors as there are reference lines.")
            print("Will use the foreground color.") 
            yref_line_color = "foreground"
          end if
        end if
;
; Determine dash pattern of Y reference line(s).
;
        if(isatt(res2,"gsnYRefLineDashPattern"))
          yref_line_pattern = res2@gsnYRefLineDashPattern(0)
          delete(res2@gsnYRefLineDashPattern)
        else
          if(isatt(res2,"gsnYRefLineDashPatterns"))
            yref_line_pattern = res2@gsnYRefLineDashPatterns
            delete(res2@gsnYRefLineDashPatterns)
            if(.not.(dimsizes(yref_line_pattern).eq.nyref.or.\
                     dimsizes(yref_line_pattern).eq.1))
              print("gsn_csm_xy: Warning: you must specify either one Y reference line dash pattern")
              print("or the same number of dash patterns as there are reference lines.")
              print("Will use a solid line.") 
              yref_line_pattern = 0  ; defaults to solid
            end if
          else
            yref_line_pattern = 0  ; defaults to solid
          end if
        end if
;
; Determine thickness of Y reference line(s).
;
        if(isatt(res2,"gsnYRefLineThicknessF"))
          yref_line_thickness = res2@gsnYRefLineThicknessF(0)
          delete(res2@gsnYRefLineThicknessF)
        else
          if(isatt(res2,"gsnYRefLineThicknesses"))
            yref_line_thickness = res2@gsnYRefLineThicknesses
            delete(res2@gsnYRefLineThicknesses)
            if(.not.(dimsizes(yref_line_thickness).eq.nyref.or.\
                     dimsizes(yref_line_thickness).eq.1))
              print("gsn_csm_xy: Warning: you must specify either one Y reference line thickness")
              print("or the same number of line thicknesses as there are reference lines.")
              print("Will use a thickness of 1.") 
              yref_line_thickness = 1.0
            end if
          else
            yref_line_thickness = 1.0
          end if
        end if
      end if                            ; Check if gsnYRefLine set.
;
; Check if we want a bar chart.
;
      bar_chart        = get_res_value(res2,"gsnXYBarChart",False)
      bar_outline_only = get_res_value(res2,"gsnXYBarChartOutlineOnly",False)

      if(bar_chart.and..not.bar_outline_only)
        if(.not.yref_line_on) then
;
; If no ref line specified, but bar fill is on, then set the reference
; line to the minimum y value.
;
          yref_line           = get_res_value_keep(res2,"trYMinF",min(y))
          nyref               = 1 
          yref_line_on        = True
          yref_line_color     = "foreground"
          yref_line_pattern   = 0
          yref_line_thickness = 1.
        else
          if((ncurves.gt.1.and.nyref.gt.1.and.ncurves.ne.nyref).or. \
             (ncurves.eq.1.and.nyref.ne.1))
            print("gsn_csm_xy: Fatal: if you plan to draw a bar chart with values above")
            print("and/or below reference lines, then the number of reference lines")
            print("must either equal the number of curves, or be one.")
            return
          end if
        end if          ; Check for Y ref line.
      end if            ; Check for bar chart settage.

; Check if gsnXRefLine set.

      if(isatt(res2,"gsnXRefLine"))
        xref_line_on = True
        xref_line    = get_res_value(res2,"gsnXRefLine",0.)
        nxref        = dimsizes(xref_line)

        xref_line_color     = get_res_value(res2,"gsnXRefLineColor","foreground")
        xref_line_pattern   = get_res_value(res2,"gsnXRefLineDashPattern",0)
        xref_line_thickness = get_res_value(res2,"gsnXRefLineThicknessF",1.)
      end if

; Check for existence of the left, center, and right subtitles.

      check_for_subtitles(res2,left_string,center_string,right_string)
      if(left_string.or.center_string.or.right_string)
        main_zone   = main_zone+1
      end if
;
; These resources allow you to control the look of the fill patterns
; in the bars. You can change the fill line thickness, the density of
; the fill pattern, the thickness of the stippled dots, or the opacity
; of the bar colors.
;
      bar_outline_thickness = get_res_value(res2,"gsnXYBarChartOutlineThicknessF",1.0)
      bar_fill_line_thickness = get_res_value(res2,"gsnXYBarChartFillLineThicknessF",1.0)
      bar_fill_opacity = get_res_value(res2,"gsnXYBarChartFillOpacityF",1.0)
      bar_fill_scale = get_res_value(res2,"gsnXYBarChartFillScaleF",1.0)
      bar_fill_dot_size = get_res_value(res2,"gsnXYBarChartFillDotSizeF",0.0)
    end if                  ; Done checking special resources.

    res2          = True
    res2@gsnDraw  = False     ; Internally, don't draw plot or advance
    res2@gsnFrame = False     ; frame since we take care of that later.
    res2@gsnScale = tm_scale  ; Force labels and ticks to be same.

; If user explicitly sets X or Y tick marks, then don't label the X 
; or Y axis automatically.

    if(check_attr(res2,"tmXBMode","Explicit",True).or.\
       check_attr(res2,"tmXBMode",2,True))
      set_attr(res2,"tiXAxisString","")
    end if

    if(check_attr(res2,"tmYLMode","Explicit",True).or.\
       check_attr(res2,"tmYLMode",2,True))
      set_attr(res2,"tiYAxisString","")
    end if

;
; The following code is going to create new X,Y arrays, depending
; on whether the user wants:
;
;   - a regular XY plot
;   - a regular XY plot with curves above and below a given reference
;     line filled in
;   - a bar plot without any fill
;   - a bar plot with filling above and below a given Y reference value.

;
; This is the regular XY plot with the curve above and below a given
; reference line filled in with some color.
;
    if(yref_fill_on.and..not.bar_chart) then
;
; Create new X and Y arrays to hold new data values.  Wherever the curve
; crosses the reference line, an interpolation needs to be done to create 
; a point *on* that reference line.
;
      xinterp = new((/nyref,2*npts/),double,1e36)
      yinterp = new((/nyref,2*npts/),double,1e36)

      copy_var_atts(x,xinterp,"")
      copy_var_atts(y,yinterp,"")

      new_npts = ref_line_interp(x,y,xinterp,yinterp,yref_line)
    else
      if(bar_chart) then
;
; This is the bar XY plot with outlined bars only.
;
        if(bar_outline_only)
;
; For each old y point, we need two new y points to represent
; the horizontal line.
;
          nyb = 2 * (npts-1) + 1

          yinterp = new((/ncurves,nyb/),double,1e36)
          xinterp = new((/ncurves,nyb/),double,1e36)

          copy_var_atts(x,xinterp,"")
          copy_var_atts(y,yinterp,"")

          outlined_bars(x,y,xinterp,yinterp)
        else
;
; This is the bar XY plot with filled bars.
;
; Get bar widths.  They are either set by user via a resource, or 
; from the smallest dx.
;
          bar_widths = get_bar_widths(x,ncurves,res2)
          if(any(ismissing(bar_widths)).or.any(bar_widths.le.0))
            print("gsn_csm_xy: Fatal: The x array is not monotonically increasing.")
            print("Cannot draw a bar chart.")
            return
          end if
;---Special test for just one point.
        if(npts.eq.1) then
          if(isatt(y,"_FillValue")) then
            ybarmsg = y@_FillValue
          else
            ybarmsg = 1e20
          end if
;---If just one point, add some dummy missing vals before and after.
          xbar = (/x-bar_widths,x,x+bar_widths/)
          ybar = (/ybarmsg,y,ybarmsg/)
          nptsbar = 3
          ybar@_FillValue = ybarmsg
         else
           xbar = x
           ybar = y
           nptsbar = npts
        end if
;
; Figure out if we want to fill bars.  Three resources can be used to
; specify fill colors, in this order:
;
;     gsnAbove/BelowYRefLineBarColors     gsnAbove/BelowYRefLineBarPatterns
;     gsnXYBarChartColors                 gsnXYBarChartPatterns
;     gsnXYBarChartColors2                gsnXYBarChartPatterns2
;
          mlt_above_bar_colors = False
          mlt_below_bar_colors = False
          mlt_above_bar_pttrns = False
          mlt_below_bar_pttrns = False
          mlt_above_bar_scales = False
          mlt_below_bar_scales = False
          colors2              = False      ; Flag to indicate whether the
          pttrns2              = False      ; 3rd resource is being used.
;
; First check for above reference line bar fill colors.
;
          if(isatt(res2,"gsnAboveYRefLineBarColors")) then
            yref_fill_on         = True
            mlt_above_bar_colors = True
            bar_colors_above = get_res_value(res2,"gsnAboveYRefLineBarColors",1)
;
; If gsnXYBarChartColors or gsnXYBarChartColors2 are set, then
; delete them.
;
            if(isatt(res2,"gsnXYBarChartColors")) then
              delete(res2@gsnXYBarChartColors)
            end if
            if(isatt(res2,"gsnXYBarChartColors2")) then
              delete(res2@gsnXYBarChartColors2)
            end if
          end if  
;
; Now check for below reference line bar fill colors.
;
          if(isatt(res2,"gsnBelowYRefLineBarColors")) then
            yref_fill_on         = True
            mlt_below_bar_colors = True
            bar_colors_below = get_res_value(res2,"gsnBelowYRefLineBarColors",1)
;
; If gsnXYBarChartColors and/or gsnXYBarChartColors2 are set,
; then delete them.
;
            if(isatt(res2,"gsnXYBarChartColors")) then
              delete(res2@gsnXYBarChartColors)
            end if
            if(isatt(res2,"gsnXYBarChartColors2")) then
              delete(res2@gsnXYBarChartColors2)
            end if
          end if  
;
; If neither gsnBelow/AboveYRefLineBarColors were set, then the
; second choice is to check for gsnXYBarChartColors.
;
          if(isatt(res2,"gsnXYBarChartColors")) then
            yref_fill_on         = True
            mlt_above_bar_colors = True
            mlt_below_bar_colors = True
            bar_colors_above = get_res_value(res2,"gsnXYBarChartColors",1)
            bar_colors_below = bar_colors_above
;
; If gsnXYBarChartColors2 is set, then delete it.
;
            if(isatt(res2,"gsnXYBarChartColors2")) then
              delete(res2@gsnXYBarChartColors2)
            end if
          end if

;
; If none of gsnBelow/AboveYRefLineBarColors/gsnXYBarChartColors were
; set, then the third choice is to use gsnXYBarChartColors2.
;
          if(isatt(res2,"gsnXYBarChartColors2")) then
            colors2              = True
            yref_fill_on         = True
            mlt_above_bar_colors = True
            mlt_below_bar_colors = True
            bar_colors_above = get_res_value(res2,"gsnXYBarChartColors2",1)
            bar_colors_below = bar_colors_above
          end if
;
; Now that we've exhausted all the possible ways that bar colors can
; be set for the above ref line, check that the array is a valid size.
;
          if(mlt_above_bar_colors) then
            bac_rank = dimsizes(dimsizes(bar_colors_above))
            if(bac_rank.gt.2.or. \
              (bac_rank.eq.2.and.dimsizes(bar_colors_above(:,0)).ne.nyref)) then
              print("gsn_csm_xy: Fatal: The resource for specifying bar colors must either be 1D, or 2D where the first dimension is equal to the number of Y reference lines or curves.")
              print("Will not fill your bar chart.")
              mlt_above_bar_colors = False
            end if            
          end if
          if(mlt_below_bar_colors) then
            bbc_rank = dimsizes(dimsizes(bar_colors_below))
            if(bbc_rank.gt.2.or. \
              (bbc_rank.eq.2.and.dimsizes(bar_colors_below(:,0)).ne.nyref)) then
              print("gsn_csm_xy: Fatal: The resource for specifying bar colors must either be 1D, or 2D where the first dimension is equal to the number of Y reference lines or curves.")
              print("Will not fill your bar chart.")
              mlt_below_bar_colors = False
            end if            
          end if
;
; Check for above reference line fill patterns.
;
          if(isatt(res2,"gsnAboveYRefLineBarPatterns")) then
            yref_fill_on         = True
            mlt_above_bar_pttrns = True
            bar_pttrns_above = get_res_value(res2,"gsnAboveYRefLineBarPatterns",1)
;
; If gsnXYBarChartPatterns or gsnXYBarChartPatterns2 are set,
; then delete them.
;
            if(isatt(res2,"gsnXYBarChartPatterns")) then
              delete(res2@gsnXYBarChartPatterns)
            end if
            if(isatt(res2,"gsnXYBarChartPatterns2")) then
              delete(res2@gsnXYBarChartPatterns2)
            end if
          end if  
;
; Now check for below reference line fill patterns.
;
          if(isatt(res2,"gsnBelowYRefLineBarPatterns")) then
            yref_fill_on         = True
            mlt_below_bar_pttrns = True
            bar_pttrns_below = get_res_value(res2,"gsnBelowYRefLineBarPatterns",1)
;
; If gsnXYBarChartPatterns or gsnXYBarChartPatterns2 are set,
; then delete them.
;
            if(isatt(res2,"gsnXYBarChartPatterns")) then
              delete(res2@gsnXYBarChartPatterns)
            end if
            if(isatt(res2,"gsnXYBarChartPatterns2")) then
              delete(res2@gsnXYBarChartPatterns2)
            end if
          end if  

;
; If the gsnAbove/BelowYRefLineBarPatterns resources are not set, then
; the second choice is to use gsnXYBarChartPatterns.
;
          if(isatt(res2,"gsnXYBarChartPatterns")) then
            yref_fill_on         = True
            mlt_above_bar_pttrns = True
            mlt_below_bar_pttrns = True
            bar_pttrns_above = get_res_value(res2,"gsnXYBarChartPatterns",1)
            bar_pttrns_below = bar_pttrns_above
;
; If gsnXYBarChartPatterns2 is set, then delete it.
;
            if(isatt(res2,"gsnXYBarChartPatterns2")) then
              delete(res2@gsnXYBarChartPatterns2)
            end if
          end if  
;
; If gsnAbove/BelowYRefLineBarPatterns and gsnXYBarChartPatterns are
; not set, then the third choice is to use gsnXYBarChartPatterns2.
;
          if(isatt(res2,"gsnXYBarChartPatterns2")) then
            pttrns2              = True
            yref_fill_on         = True
            mlt_above_bar_pttrns = True
            mlt_below_bar_pttrns = True
            bar_pttrns_above = get_res_value(res2,"gsnXYBarChartPatterns2",1)
            bar_pttrns_below = bar_pttrns_above
          end if  
;
; Now that we've exhausted all the possible ways that bar patterns can
; be set for the above ref line, check that the array is a valid size.
;
          if(mlt_above_bar_pttrns) then
            bap_rank = dimsizes(dimsizes(bar_pttrns_above))
            if(bap_rank.gt.2.or. \
              (bap_rank.eq.2.and.dimsizes(bar_pttrns_above(:,0)).ne.nyref)) then
              print("gsn_csm_xy: Fatal: The resource for specifying bar patterns must either be 1D, or 2D where the first dimension is equal to the number of Y reference lines or curves.")
              print("Will not fill your bar chart.")
              mlt_above_bar_pttrns = False
            end if            
          end if
          if(mlt_below_bar_pttrns) then
            bbp_rank = dimsizes(dimsizes(bar_pttrns_below))
            if(bbp_rank.gt.2.or. \
              (bbp_rank.eq.2.and.dimsizes(bar_pttrns_below(:,0)).ne.nyref)) then
              print("gsn_csm_xy: Fatal: The resource for specifying bar patterns must either be 1D, or 2D where the first dimension is equal to the number of Y reference lines or curves.")
              print("Will not fill your bar chart.")
              mlt_below_bar_pttrns = False
            end if            
          end if
;
; Check for fill scales above and below.
;
          if(isatt(res2,"gsnAboveYRefLineBarFillScales")) then
            mlt_above_bar_scales = True
            bar_scales_above = get_res_value(res2,"gsnAboveYRefLineBarFillScales",1)
          end if  
          if(isatt(res2,"gsnBelowYRefLineBarFillScales")) then
            mlt_below_bar_scales = True
            bar_scales_below = get_res_value(res2,"gsnBelowYRefLineBarFillScales",1)
          end if  

;
; Loop across curves and figure out which points are above, below,
; and equal to the references lines.  First create arrays to hold points
; above, below, and equal to reference lines.
;
          xabove = new((/ncurves,5*nptsbar/),double,1e36)
          yabove = new((/ncurves,5*nptsbar/),double,1e36)
          xbelow = new((/ncurves,5*nptsbar/),double,1e36)
          ybelow = new((/ncurves,5*nptsbar/),double,1e36)
          xequal = new((/ncurves,5*nptsbar/),double,1e36)
          yequal = new((/ncurves,5*nptsbar/),double,1e36)
;
; Arrays to hold number of points in each set of above/below points,
; and the index values where points fall above, below, and equal
; to the Y ref value.
;
          nabove   = new(ncurves,integer)
          nbelow   = new(ncurves,integer)
          nequal   = new(ncurves,integer)
          indabove = new((/ncurves,nptsbar/),integer)
          indbelow = new((/ncurves,nptsbar/),integer)
          indequal = new((/ncurves,nptsbar/),integer)
;
; Fill in values for filled bars (that will be filled later).
;
          filled_bars(xbar,ybar,xabove,yabove,xbelow,ybelow,xequal,yequal, \
                      nabove,nbelow,nequal,indabove,indbelow,indequal, \
                      yref_line,bar_widths)
;
; Combine the above/below/equal arrays into one X/Y array so that we can
; pass to gsn_xy routine. Make the 5th point missing, since the 5th point
; closes the polygon, and we only want an outline here.
;
          na_max   = max(nabove)
          nb_max   = max(nbelow)
          ne_max   = max(nequal)
          nabe_max = na_max + nb_max + ne_max

          if(na_max.le.0.and.nb_max.le.0)
            print("gsn_csm_xy: Fatal: There are no values above or below the chosen reference line.")
            print("Cannot draw a bar chart.")
            xinterp = x
            yinterp = y
          else
            ncurves3 = 3*ncurves
            xinterp  = new((/ncurves3,nabe_max/),double,xabove@_FillValue)
            yinterp  = new((/ncurves3,nabe_max/),double,yabove@_FillValue)

            copy_var_atts(xbar,xinterp,"")
            copy_var_atts(ybar,yinterp,"")

            if(na_max.gt.0)
              xinterp(0:ncurves3-1:3,0:na_max-1)   = xabove(:,0:na_max-1)
              yinterp(0:ncurves3-1:3,0:na_max-1)   = yabove(:,0:na_max-1)
              yinterp(0:ncurves3-1:3,4:na_max-1:5) = yinterp@_FillValue
            end if
            if(nb_max.gt.0)
              xinterp(1:ncurves3-1:3,0:nb_max-1)   = xbelow(:,0:nb_max-1)
              yinterp(1:ncurves3-1:3,0:nb_max-1)   = ybelow(:,0:nb_max-1)
              yinterp(1:ncurves3-1:3,4:nb_max-1:5) = yinterp@_FillValue
            end if
            if(ne_max.gt.0)
              xinterp(2:ncurves3-1:3,0:ne_max-1)   = xequal(:,0:ne_max-1)
              yinterp(2:ncurves3-1:3,0:ne_max-1)   = yequal(:,0:ne_max-1)
              yinterp(2:ncurves3-1:3,4:ne_max-1:5) = yinterp@_FillValue
            end if
;
; Make sure all lines are solid, and not dashed as is the default
; with the second curve drawn.
; 
            res2@xyDashPatterns = get_res_value(res2,"xyDashPatterns",0)
          end if
        end if
      else
;
; This is just a regular XY plot.
;
        xinterp = x
        yinterp = y
      end if
    end if

    if(xref_line_on)
      set_attr(res2,"trYMinF",min(yinterp))
      set_attr(res2,"trYMaxF",max(yinterp))
    end if

    if(yref_line_on)
      set_attr(res2,"trXMinF",min(xinterp))
      set_attr(res2,"trXMaxF",max(xinterp))
    end if

;
; If user sets lgLabelFontHeightF, then lgAutoManage needs to
; be False in order for this resource to have any affect.
;
    if(isatt(res2,"lgLabelFontHeightF"))
      set_attr(res2,"lgAutoManage",False)
    end if

; Create XY plot
    xyres = get_res_ne(res2,(/"tx"/))
    xy_object = gsn_xy(wks,xinterp,yinterp,xyres)
   
; Fill between two curves if desired
    if(fill_xy_res) then
      xy_object = fill_bw_xy(wks,xy_object,xinterp,yinterp,fill_xy_res)
    end if

; Add lat/lon labels to X/Y axes if appropriate units exist.

    res2@gsnXYPlot = True
    res2@gsnXAxis = True

    add_latlon_labels(xy_object,x,res2)
    delete(res2@gsnXAxis)
    res2@gsnYAxis = True
    add_latlon_labels(xy_object,y,res2)
    delete(res2@gsnYAxis)
    delete(res2@gsnXYPlot)

; Fill above/below Y reference line.

    if(yref_fill_on.and..not.bar_chart)
;
; Make sure polygons get filled before xy plot is drawn. This way,
; any lines will be drawn *after* the fill. This makes the filled 
; polygons look better if the lines are drawn thicker.
;
      xyres_tmp = True
      xyres_tmp@tfPolyDrawOrder =  "Predraw"
      attsetvalues_check(xy_object,xyres_tmp)
      delete(xyres_tmp)

      fill_above = yref_line_above(0)
      fill_below = yref_line_below(0)

      do i=0,max((/ncurves,nyref/))-1
        if(dimsizes(yref_line_above).gt.1)
          fill_above = yref_line_above(i)
        end if
        if(dimsizes(yref_line_below).gt.1)
          fill_below = yref_line_below(i)
        end if
        var_string = unique_string("polygons"+i)
        xy_object@$var_string$=fill_xy_ref(wks,xy_object, \
                                     xinterp(i,0:new_npts(i)-1), \
                                     yinterp(i,0:new_npts(i)-1),\
                                     yref_line(i),fill_above,fill_below)
      end do
    end if

; Fill bars with either a single color for above and below, or with
; individual colors.

    if(yref_fill_on.and.bar_chart.and..not.bar_outline_only)
      gsres = True
      if(bar_outline_thickness.gt.0.and.bar_outline_thickness.ne.1) then
        gsres@gsEdgesOn        = True
        gsres@gsEdgeThicknessF = bar_outline_thickness
      end if
      gsres@gsFillLineThicknessF = bar_fill_line_thickness
      gsres@gsFillOpacityF       = bar_fill_opacity
      gsres@gsFillScaleF         = bar_fill_scale
      gsres@gsFillDotSizeF       = bar_fill_dot_size
      do i=0,ncurves-1 
        var_string = unique_string("polygons"+i)
;
; Fill above reference line.
;
        if(nabove(i).gt.0)
;
; Single bar color for each above and below bars.
;
          if(.not.mlt_above_bar_colors)
            gsres@gsFillColor = yref_line_above(0)
            if(dimsizes(yref_line_above).gt.1)
              gsres@gsFillColor = yref_line_above(i)
            end if
          end if
;
; Single bar fill scale for each above and below bars.
;
          if(mlt_above_bar_scales) then
            gsres@gsFillScaleF = bar_scales_above(0)
            if(dimsizes(yref_line_above).gt.1)
              gsres@gsFillScaleF = bar_scales_above(i)
            end if
          end if
;
; Multiple bar colors and/or patterns.
;
          if(mlt_above_bar_colors.or.mlt_above_bar_pttrns) then
            if(mlt_above_bar_colors) then
              if(bac_rank.eq.1) then
                nca = dimsizes(bar_colors_above)
              else
                nca = dimsizes(bar_colors_above(0,:))
              end if
            end if
            if(mlt_above_bar_pttrns) then
              if(bap_rank.eq.1) then
                npa = dimsizes(bar_pttrns_above)
              else
                npa = dimsizes(bar_pttrns_above(0,:))
              end if
            end if
            do ii = 0,nabove(i)/5-1
              var_string2 = var_string + "above" + ii
              if(mlt_above_bar_colors) then
                if(colors2) then 
                  ci = indabove(i,ii) % nca
                else
                  ci = ii % nca
                end if
                if(bac_rank.eq.1) then
                  gsres@gsFillColor = bar_colors_above(ci)
                else
                  gsres@gsFillColor = bar_colors_above(i,ci)
                end if
              end if
              if(mlt_above_bar_pttrns) then
                if(pttrns2) then 
                  pi = indabove(i,ii) % npa
                else
                  pi = ii % npa
                end if
                if(bap_rank.eq.1) then
                  gsres@gsFillIndex = bar_pttrns_above(pi)
                else
                  gsres@gsFillIndex = bar_pttrns_above(i,pi)
                end if
              end if
              xy_object@$var_string2$ = gsn_add_polygon(wks,xy_object, \
                                                     xabove(i,ii*5:ii*5+4), \
                                                     yabove(i,ii*5:ii*5+4), \
                                                     gsres)
            end do
          else
            var_string2 = var_string + "above"
            xy_object@$var_string2$ = gsn_add_polygon(wks,xy_object, \
                                                     xabove(i,:), \
                                                     yabove(i,:),gsres)
          end if
        end if
;
; Fill below reference line.
;
        if(nbelow(i).gt.0)
          if(.not.mlt_below_bar_colors) then
            gsres@gsFillColor = yref_line_below(0)
            if(dimsizes(yref_line_below).gt.1)
              gsres@gsFillColor = yref_line_below(i)
            end if
          end if
;
; Single bar fill scale for each above and below bars.
;
          if(mlt_below_bar_scales) then
            gsres@gsFillScaleF = bar_scales_below(0)
            if(dimsizes(yref_line_below).gt.1)
              gsres@gsFillScaleF = bar_scales_below(i)
            end if
          end if
;
; Multiple bar colors and/or patterns.
;
         if(mlt_below_bar_colors.or.mlt_below_bar_pttrns) then
            if(mlt_below_bar_colors) then
              if(bbc_rank.eq.1) then
                ncb = dimsizes(bar_colors_below)
              else
                ncb = dimsizes(bar_colors_below(0,:))
              end if
            end if
            if(mlt_below_bar_pttrns) then
              if(bbp_rank.eq.1) then
                npb = dimsizes(bar_pttrns_below)
              else
                npb = dimsizes(bar_pttrns_below(0,:))
              end if
            end if
            do ii = 0,nbelow(i)/5-1
              var_string2 = var_string + "below" + ii
              if(mlt_below_bar_colors) then
                if(colors2) then 
                  ci = indbelow(i,ii) % ncb
                else
                  ci = ii % ncb
                end if
                if(bbc_rank.eq.1) then
                  gsres@gsFillColor = bar_colors_below(ci)
                else
                  gsres@gsFillColor = bar_colors_below(i,ci)
                end if
              end if
              if(mlt_below_bar_pttrns) then
                if(pttrns2) then 
                  pi = indbelow(i,ii) % npb
                else
                  pi = ii % npb
                end if
                if(bbp_rank.eq.1) then
                  gsres@gsFillIndex = bar_pttrns_below(pi)
                else
                  gsres@gsFillIndex = bar_pttrns_below(i,pi)
                end if
              end if
              xy_object@$var_string2$ = gsn_add_polygon(wks,xy_object, \
                                                     xbelow(i,ii*5:ii*5+4), \
                                                     ybelow(i,ii*5:ii*5+4), \
                                                     gsres)
            end do
          else
            var_string2 = var_string + "below"
            xy_object@$var_string2$ = gsn_add_polygon(wks,xy_object, \
                                                     xbelow(i,:), \
                                                     ybelow(i,:), gsres)
          end if
        end if
      end do
;
; Make sure polygons get drawn first, so that XY lines are drawn on top.
;
      setvalues xy_object
        "tfPolyDrawOrder" : "Predraw"
      end setvalues

      delete(gsres)    
    end if

; Draw X reference line.

    if(xref_line_on)
      getvalues xy_object
        "trYMinF"  : ymin
        "trYMaxF"  : ymax
      end getvalues

      gsres             = True

      yline = (/ymin,ymax/)

      gsres@gsLineColor       = xref_line_color(0)
      gsres@gsLineDashPattern = xref_line_pattern(0)
      gsres@gsLineThicknessF  = xref_line_thickness(0)

      do i=0,nxref-1
        if(dimsizes(xref_line_color).gt.1)
          gsres@gsLineColor = xref_line_color(i)
        end if
        xline = fspan(xref_line(i),xref_line(i),2)
        var_string = unique_string("xpolyline"+i)
        xy_object@$var_string$ = gsn_add_polyline(wks,xy_object,xline,yline, \
                                                  gsres)
      end do
      delete(xline)
      delete(yline)
    end if

; Draw Y reference line.

    if(yref_line_on)
      getvalues xy_object
        "trXMinF"  : xmin
        "trXMaxF"  : xmax
      end getvalues

      gsres             = True

      xline = (/xmin,xmax/)

      gsres@gsLineColor       = yref_line_color(0)
      gsres@gsLineDashPattern = yref_line_pattern(0)
      gsres@gsLineThicknessF  = yref_line_thickness(0)

      do i=0,nyref-1
        if(dimsizes(yref_line_color).gt.1)
          gsres@gsLineColor = yref_line_color(i)
        end if
        if(dimsizes(yref_line_pattern).gt.1)
          gsres@gsLineDashPattern = yref_line_pattern(i)
        end if
        if(dimsizes(yref_line_thickness).gt.1)
          gsres@gsLineThicknessF = yref_line_thickness(i)
        end if
        yline = fspan(tofloat(yref_line(i)),tofloat(yref_line(i)),2)
        var_string = unique_string("ypolyline"+i)

        xy_object@$var_string$ = gsn_add_polyline(wks,xy_object,xline, \
                                                  yline,gsres)
      end do

      delete(xline)
      delete(yline)
    end if

; Get title label sizes and tickmark lengths.
    getvalues xy_object
      "vpWidthF"             : width
      "vpHeightF"            : height
      "tiXAxisFontHeightF"   : xfontf
      "tiYAxisFontHeightF"   : yfontf

      "tmYLMajorLengthF"     : ylength
      "tmXBMajorLengthF"     : xlength
      "tmYLMinorLengthF"     : ymlength
      "tmXBMinorLengthF"     : xmlength
    end getvalues

    font_height = min((/xfontf,yfontf/))  ; Make label sizes a function of
                                          ; the size of the X/Y axis labels.
    major_length = min((/ylength,xlength/))
    minor_length = min((/ymlength,xmlength/))

; If the plot is close to square in size, then make the 
; three top titles and the tick marks smaller.

    ratio = height/width
    if(ratio.gt.1) 
      ratio = 1./ratio
    end if
    if(ratio.gt.0.5)
      font_height = 0.75 * font_height
      major_length = 0.75 * major_length
      minor_length = 0.75 * minor_length
    end if

; Make tick marks same length and point outward.

    tmres = get_res_eq(res2,"tm")
    gsnp_point_tickmarks_outward(xy_object,tmres,xlength,ylength,xmlength, \
                                 ymlength,major_length,minor_length, \
                                 point_outward)

; Set up three subtitles at top, if they exist.
    subres = get_res_eq(res2,(/"tx","am"/))  ; Get textitem resources
    subres               = True
    set_attr(subres,"txFontHeightF",font_height)
    add_subtitles(wks,xy_object,left_string,center_string,right_string, \
                  subres)

; Draw all this stuff: XY plot and subtitles.
    draw_and_frame(wks,xy_object,calldraw,callframe,0,maxbb)

; Return XY plot object.

    return(xy_object)
end
