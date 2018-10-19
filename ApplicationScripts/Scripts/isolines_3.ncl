;----------------------------------------------------------------------
;  isolines_3.ncl
;----------------------------------------------------------------------
; This script will only work with a beta version of NCL 6.5.0.
;----------------------------------------------------------------------
; Concepts illustrated:
;   - Using get_isolines to retrieve isolines from a WRF contour plot
;   - Culling isolines to get a less busy plot
;   - Attaching polylines to a map plot
;   - Using functions for cleaner code
;----------------------------------------------------------------------
; This script shows how to use get_isolines to retrieve the isolines
; created by NCL's contouring routine, and then redraw isolines that
; fall outside a minimum lat/lon range.  This is to get rid of
; some of the smaller "noisier" contours.
; 
; The function for culling the isolines is called add_isolines_by_range.
;
; This example calculates SLP from a WRF file because this is a good
; noisy field to work with. Usually WRF SLP is smoothed with
; wrf_smooth_2d, but for illustrative purposes, we're not doing
; that here.
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
; Set resources for plotting WRF curvilinear data, given the WRF
; file and a title
;----------------------------------------------------------------------
undef("set_resources_contour_map")
function set_resources_contour_map(f,title)
begin
  res                           = True
  res@gsnMaximize               = True
  res@gsnDraw                   = False
  res@gsnFrame                  = False
  res@cnMonoLineColor           = False    ; Color each line differently
  res@cnLineLabelsOn            = False
  res@cnInfoLabelOrthogonalPosF = 0.08
  res@cnLineThicknessF          = 2.5
  res@cnInfoLabelFontHeightF    = 0.01
  res@cnInfoLabelOrthogonalPosF = -0.03
  res@tiMainFontHeightF         = 0.018
  res@tiMainString              = title
  res@gsnRightString            = ""
  res@gsnLeftString             = ""
  res = wrf_map_resources(f,res)
  return(res)
end

;----------------------------------------------------------------------
; Set resources for creating a map plot based on the map parameters
; defined on a WRF file.
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
  res = wrf_map_resources(f,res)
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
; Main code
;----------------------------------------------------------------------
begin
;----------------------------------------------------------------------
; Calculate SLP from a WRF output file. 
; We chose SLP because it tends to be a noisy field.
;----------------------------------------------------------------------
  diri     = "./"
  filename = "wrfout_d03_2012-04-22_23_00_00.nc"
  a        = addfile(diri+filename,"r")
  slp      = wrf_user_getvar(a,"slp",0)
  slp@lat2d = wrf_user_getvar(a,"lat",0)
  slp@lon2d = wrf_user_getvar(a,"lon",0)
  printVarSummary(slp)
  printMinMax(slp,0)

;----------------------------------------------------------------------
; Start the graphics
;----------------------------------------------------------------------
  pltType = "png"  ; send graphics to PNG file
  pltType@wkWidth = 2000
  pltType@wkHeight = 2000

  wks = gsn_open_wks(pltType,"isolines")

;----------------------------------------------------------------------
; First plot is original SLP data drawn as line contours over a map.
;----------------------------------------------------------------------
  res1  = set_resources_contour_map(a,"Original contour plot")
  plot1 = gsn_csm_contour_map(wks,slp,res1)

;----------------------------------------------------------------------
; Second plot is a map with the isolines retrieved from the first plot
; drawn as polylines. This plot should be identical to plot1, except 
; for the title.
;----------------------------------------------------------------------
  res2  = set_resources_map(a,"All isolines drawn")
  plot2 = gsn_csm_map(wks,res2)
  plot2 = add_isolines_all(wks,plot1,plot2)

;----------------------------------------------------------------------
; Third plot is a map with the isolines from the first plot added,
; only if that isoline falls in an area larger than a minimal lat/lon 
; range. This is to rid of some of those really small contours.
;----------------------------------------------------------------------
  res3  = set_resources_map(a,"Isolines in too small of an area are removed")
  plot3 = gsn_csm_map(wks,res3)
  lon_range = 1.
  lat_range = 1.
  plot3 = add_isolines_by_range(wks,plot1,plot3,lon_range,lat_range)

;----------------------------------------------------------------------
; Panel 3 plots on one page for comparison.
;----------------------------------------------------------------------
  pres = True
  pres@gsnMaximize      = True
  pres@gsnPanelRowSpec  = True
  gsn_panel(wks,(/plot1,plot2,plot3/),(/2,1/),pres)

end
