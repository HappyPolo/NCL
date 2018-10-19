;----------------------------------------------------------------------
;  isolines_4.ncl
;----------------------------------------------------------------------
; This script will only work with a beta version of NCL 6.5.0.
;----------------------------------------------------------------------
; Concepts illustrated:
;   - Using get_isolines to retrieve isolines from a plot of MPAS data
;   - Culling isolines to get a less busy plot
;   - Attaching polylines to a map plot
;   - Using functions for cleaner code
;----------------------------------------------------------------------
; This script will only work with a beta version of NCL 6.5.0.
;----------------------------------------------------------------------
; This script shows how to use get_isolines to retrieve the isolines
; created by NCL's contouring routine, and then redraw the isolines
; yourself using gsn_add_polyline. 
; 
; This example uses data from an MPAS file.

; The purpose of drawing contours via the isolines is that it allows you
; to define a set of criteria for whether an isoline is drawn, or needs to
; be reduced (only have every n-th point drawn, for example).
;
; Three different functions are included here, for culling the isolines:
;
; add_isolines_reduced
; add_isolines_by_range
; add_isolines_reduced_and_by_range
;----------------------------------------------------------------------

;----------------------------------------------------------------------
; This function returns a nice span of indexes in a given range, and
; makes sure that 0 and nvals-1 are part of the range.
;----------------------------------------------------------------------
undef("span_range")
function span_range(maxix[1]:integer,nvals[1]:integer)
local minix,  fmin, fmax, fvals, ivals
begin
  minix = 0

  fmin = new(1,float)    ; to make sure we get a missing value (?)
  fmax = new(1,float)
  fmin = minix
  fmax = maxix
  fvals = fspan(fmin,fmax,nvals)
  ivals = tointeger(fvals + 0.5)
  return(ivals)
end

;----------------------------------------------------------------------
; Set resources for creating an orthographic map
;----------------------------------------------------------------------
undef("set_resources_map")
function set_resources_map(f,title)
begin
  res                   = True
  res@gsnDraw           = False
  res@gsnFrame          = False
  res@gsnMaximize       = True
  res@tiMainFontHeightF = 0.018
  res@tiMainString      = title
  res@mpProjection      = "orthographic"
  res@mpPerimOn         = False
  res@mpGridAndLimbOn   = True
  res@mpGridMaskMode    = "MaskLand" ; Don't draw lat/lon grid over land.
  res@mpGridLineColor   = "LightGray"
  res@mpCenterLatF      = 40.
  res@mpCenterLonF      = 60.
  return(res)
end


;----------------------------------------------------------------------
; Set resources for plotting MPAS data, given the MPAS file and a
; title.
;----------------------------------------------------------------------
undef("set_resources_contour_map")
function set_resources_contour_map(f,title)
begin
  lonCell = f->lonCell
  latCell = f->latCell
  RAD2DEG = get_r2d("double")      ; Radian to Degree
  lonCell = lonCell*RAD2DEG
  latCell = latCell*RAD2DEG

  res = set_resources_map(f,title)         ; Set some map resources
  res@cnMonoLineColor           = False    ; Color each line differently
  res@cnLineLabelsOn            = False
  res@cnInfoLabelOn             = False
  res@cnLineThicknessF          = 2.5
  res@gsnRightString            = ""
  res@gsnLeftString             = ""
  res@sfXArray                  = lonCell
  res@sfYArray                  = latCell
  res@gsnAddCyclic              = False
  return(res)
end

;----------------------------------------------------------------------
; Give a contour/map plot, retrieve the contour levels associated
; with it.
;----------------------------------------------------------------------
undef("get_contour_levels")
function get_contour_levels(plot)
begin
  getvalues plot@contour
    "cnLevels" : levels
  end getvalues
  return(levels)
end

;----------------------------------------------------------------------
; Give a contour/map plot, retrieve the contour colors associated
; with the levels
;----------------------------------------------------------------------
undef("get_contour_colors")
function get_contour_colors(plot)
begin
  getvalues plot@contour
    "cnLineColors" : colors
  end getvalues
  return(colors)
end

;----------------------------------------------------------------------
; Loop through each contour level, get isolines, and add them to the 
; plot.
;----------------------------------------------------------------------
undef("add_isolines_all")
function add_isolines_all(wks,plot_orig,plot_map)
local plres, i, j, b, e, x, y, i, nlevels, iso
begin
  levels = get_contour_levels(plot_orig)
  colors = get_contour_colors(plot_orig)
  nlevels = dimsizes(levels)

;---Loop through each level, get isolines, and add them to the plot.
  plres = True
  plres@gsLineThicknessF = 2.5
  do i = 0, nlevels-1
    iso := get_isolines(plot_orig@contour,levels(i))
    plres@gsLineColor = colors(i)
    do j = 0, iso@segment_count -1
      b = iso@start_point(j)
      e = b + iso@n_points(j) - 1
      y := iso(0,b:e)
      x := iso(1,b:e)
      plot_map@$unique_string("isolines")$ = gsn_add_polyline(wks,plot_map,x,y,plres)
    end do
  end do

  return(plot_map)
end

;----------------------------------------------------------------------
; Loop through each contour level, get the isolines for that level, and
; add them to the plot. Any isolines that have more than ncrit values
; will be reduced by skipping nskip values in the list.
;----------------------------------------------------------------------
undef("add_isolines_reduced")
function add_isolines_reduced(wks,plot_orig,plot_map,ncrit,nskip)
local plres, i, j, b, e, x, y, i, nlevels, iso, x_skip, y_skip
begin
  levels = get_contour_levels(plot_orig)
  colors = get_contour_colors(plot_orig)
  nlevels = dimsizes(levels)

;---Loop through each level, get isolines, and add them to the plot.
  plres = True
  plres@gsLineThicknessF = 2.5
  do i = 0, nlevels-1
    iso := get_isolines(plot_orig@contour,levels(i))
    plres@gsLineColor = colors(i)
    do j = 0, iso@segment_count -1
      b = iso@start_point(j)
      e = b + iso@n_points(j) - 1
      y := iso(0,b:e)
      x := iso(1,b:e)
      npts = dimsizes(x)
      if(npts.gt.ncrit) then
;       print("Found isoline to reduce...")
        nvals = npts/nskip
        ii     := span_range(npts-1,nvals)
        x_trim := x(ii)
        y_trim := y(ii)
        plot_map@$unique_string("isolines")$ = gsn_add_polyline(wks,plot_map,x_trim,y_trim,plres)
      else
        plot_map@$unique_string("isolines")$ = gsn_add_polyline(wks,plot_map,x,y,plres)
      end if
    end do
  end do

  return(plot_map)
end

;----------------------------------------------------------------------
; Loop through each contour level, get the isolines for that level, and
; add them to the plot only if they fit in an area larger than the
; given X/Y range.
;----------------------------------------------------------------------
undef("add_isolines_by_range")
function add_isolines_by_range(wks,plot_orig,plot_map,x_range_min,y_range_min)
local plres, i, j, b, e, x, y, i, nlevels, iso
begin
  levels = get_contour_levels(plot_orig)
  colors = get_contour_colors(plot_orig)
  nlevels = dimsizes(levels)

;---Loop through each level, get isolines, and add them to the plot.
  plres = True
  plres@gsLineThicknessF = 2.5
  do i = 0, nlevels-1
    iso := get_isolines(plot_orig@contour,levels(i))
    plres@gsLineColor = colors(i)
    do j = 0, iso@segment_count -1
      b = iso@start_point(j)
      e = b + iso@n_points(j) - 1
      y := iso(0,b:e)
      x := iso(1,b:e)
      if((max(y)-min(y)).lt.y_range_min.and.\
         (max(x)-min(x)).lt.x_range_min) then
        continue
      end if
      plot_map@$unique_string("isolines")$ = gsn_add_polyline(wks,plot_map,x,y,plres)
    end do
  end do

  return(plot_map)
end

;----------------------------------------------------------------------
; This function is effectively a combination of add_isolines_reduced
; and add_isolines_by_range.
;
; Loop through each contour level, get the isolines for that level, and
; add them to the plot only if they fit in an area larger than the
; given X/Y range. Any isolines that have more than ncrit values will
; be reduced by skipping nskip values in the list.
;----------------------------------------------------------------------
undef("add_isolines_reduced_and_by_range")
function add_isolines_reduced_and_by_range(wks,plot_orig,plot_map,ncrit,\
                                           nskip,x_range_min,y_range_min)
local plres, i, j, b, e, x, y, i, nlevels, iso
begin
  levels = get_contour_levels(plot_orig)
  colors = get_contour_colors(plot_orig)
  nlevels = dimsizes(levels)

;---Loop through each level, get isolines, and add them to the plot.
  plres = True
  plres@gsLineThicknessF = 2.5
  do i = 0, nlevels-1
    iso := get_isolines(plot_orig@contour,levels(i))
    plres@gsLineColor = colors(i)
    do j = 0, iso@segment_count -1
      b = iso@start_point(j)
      e = b + iso@n_points(j) - 1
      y := iso(0,b:e)
      x := iso(1,b:e)
      if((max(y)-min(y)).lt.y_range_min.and.\
         (max(x)-min(x)).lt.x_range_min) then
        continue
      end if
      npts = dimsizes(x)
      if(npts.ge.ncrit) then
        nvals = npts/nskip
        ii     := span_range(npts-1,nvals)
        x_trim := x(ii)
        y_trim := y(ii)
        plot_map@$unique_string("isolines")$ = gsn_add_polyline(wks,plot_map,x_trim,y_trim,plres)
      else
        plot_map@$unique_string("isolines")$ = gsn_add_polyline(wks,plot_map,x,y,plres)
      end if
    end do
  end do

  return(plot_map)
end

;----------------------------------------------------------------------
; Main code
;----------------------------------------------------------------------
begin
;----------------------------------------------------------------------
; Read data off an MPAS file.
;----------------------------------------------------------------------
  diri     = "./"
  filename = "MPAS.nc"
  a        = addfile(diri+filename,"r")
  sp       = a->surface_pressure(0,:) 
  sp       = sp/1000.   ; Not sure what the pressure units are, there's
                        ; not much metadata info on this file
  printVarSummary(sp)
  printMinMax(sp,0)

;----------------------------------------------------------------------
; Start the graphics
;----------------------------------------------------------------------
  wks = gsn_open_wks("png","isolines")
; gsn_define_colormap(wks,"MPL_StepSeq")

;----------------------------------------------------------------------
; First plot is original SP data drawn as line contours over a map.
;----------------------------------------------------------------------
  print("Creating original contour plot")
  res1  = set_resources_contour_map(a,"Original contour plot")
  plot1 = gsn_csm_contour_map(wks,sp,res1)

;----------------------------------------------------------------------
; Second plot is a map with the isolines retrieved from the first plot
; drawn as polylines. This plot should be identical to plot1, except 
; for the title.
;----------------------------------------------------------------------
  print("Map with all isolines added")
  res2  = set_resources_map(a,"All isolines drawn")
  plot2 = gsn_csm_map(wks,res2)
  plot2 = add_isolines_all(wks,plot1,plot2)

;----------------------------------------------------------------------
; Third plot is a map with the isolines retrieved from the first plot 
; drawn as polylines, but any isoline segment that has more than ncrit 
; values will first be reduced by skippingnskip values from the 
; segment.
;----------------------------------------------------------------------
  print("Map with some isolines reduced")

  ncrit = 100    ; Critical number of points that we'll use later
  nskip = 10     ; Number of points to skip if lines have more than ncrit points

  res3  = set_resources_map(a,"Isolines with > " + ncrit + \
                            " pts reduced by a factor of " + nskip)
  plot3 = gsn_csm_map(wks,res3)
  plot3 = add_isolines_reduced(wks,plot1,plot3,ncrit,nskip)

;----------------------------------------------------------------------
; Fourth plot is a map with the isolines from the first plot added,
; only if that isoline falls in an area larger than a minimal lat/lon 
; range. This is to rid of some of those really small contours.
;----------------------------------------------------------------------
  print("Map with some isolines removed")
  res4  = set_resources_map(a,"Isolines in too small of a range are removed")
  plot4 = gsn_csm_map(wks,res4)
  lon_range = 5.
  lat_range = 5.
  plot4 = add_isolines_by_range(wks,plot1,plot4,lon_range,lat_range)

;----------------------------------------------------------------------
; Fifth plot is basically a combination of what was done for the 
; third and fourth plots: any isoline that doesn't meet the minimal
; range requirement will be remoed, and any isoline segment that has
; more than ncrit values will first be reduced by skipping roughly 
; nskip values from the segment.
;----------------------------------------------------------------------
  print("Map with some isolines reduced and removed")
  res5  = set_resources_map(a,"Isolines reduced by range and # of points")
  plot5 = gsn_csm_map(wks,res5)
  plot5 = add_isolines_reduced_and_by_range(wks,plot1,plot5,ncrit,nskip,\
                                            lon_range,lat_range)
;----------------------------------------------------------------------
; Draw all 5 plots on one page for comparison.
;----------------------------------------------------------------------
  pres = True
  pres@gsnMaximize      = True
  pres@gsnPanelRowSpec  = True
  gsn_panel(wks,(/plot1,plot2,plot3,plot4,plot5/),(/2,3/),pres)

end
