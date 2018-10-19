;----------------------------------------------------------------------
; panel_30.ncl
;
; Concepts illustrated:
;   - Creating a panel of bar charts overlaid on maps
;   - Drawing bars up or down based on a Y reference value
;   - Drawing filled and transparent bars
;   - Paneling 32 plots with shared axes
;   - Setting the mininum/maximum value of the X and Y axis in a bar plot
;   - Using functions for cleaner code
;   - Generating dummy data using "random_uniform"
;   - Removing white space from paneled plots
;   - Removing tickmarks and labels from paneled plots so they can be drawn closer together
;----------------------------------------------------------------------
;
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"   
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"

;----------------------------------------------------------------------
; Function to create a global map that is divided into an nlat x nlon
; array of smaller maps.
;----------------------------------------------------------------------
function create_maps(wks,nlat,nlon)
local lat_spacing, lon_spacing, mpres, lon2d, lat2d, nlt, nln
begin 
  lat_spacing = toint(180/nlat)
  lon_spacing = toint(360/nlon)

;---Lat/lon values for the individual map plots
  lons  = ispan(-180,180-lon_spacing,lon_spacing)
  lats  = ispan( -90, 90-lat_spacing,lat_spacing)
  nlat  = dimsizes(lats)
  nlon  = dimsizes(lons)

;---Make lats/lons 2D for convenience
  lat2d  = conform_dims((/nlat,nlon/),lats,0)
  lon2d  = conform_dims((/nlat,nlon/),lons,1)

;---Create arrays to hold both map and bar plots
  nplots    = product(dimsizes(lon2d))
  map_plots = new((/nlat,nlon/),graphic)

;---Set some map resources to apply to all maps
  mpres                 = True
  mpres@gsnDraw         = False
  mpres@gsnFrame        = False

;---Turn off various tickmarks and labels
  mpres@tmYUseLeft      = False
  mpres@tmXUseBottom    = False
  mpres@tmXBOn          = False
  mpres@tmXBLabelsOn    = False
  mpres@tmXTLabelsOn    = False
  mpres@tmYRLabelsOn    = False
  mpres@tmYROn          = False

  mpres@mpFillDrawOrder = "PreDraw"    ; to draw under bar charts

;---Loop through each lat/lon subsection and create a zoomed in map
  do nlt=0,nlat-1
    if(nlt.eq.nlat-1) then
      mpres@tmXTOn = True
    else
      mpres@tmXTOn = False
    end if
    do nln=0,nlon-1
      mpres@mpMinLatF = lat2d(nlt,nln)
      mpres@mpMinLonF = lon2d(nlt,nln)
      mpres@mpMaxLatF = lat2d(nlt,nln)+lon_spacing
      mpres@mpMaxLonF = lon2d(nlt,nln)+lat_spacing
      if(nln.eq.0) then
        mpres@tmYLOn       = True
        mpres@tmYLLabelsOn = True
      else
        mpres@tmYLOn       = False
        mpres@tmYLLabelsOn = False
      end if
;
; Create maps starting with upper left map corner first, 
; going left-to-right. This is so when we panel them later,
; they will be in the right order.
     map_plots(nlat-1-nlt,nln) = gsn_csm_map_ce(wks,mpres)
    end do
  end do

  return(ndtooned(map_plots))
end

;----------------------------------------------------------------------
; Function to create two sets of XY bar charts for every map we have.
; The first set will be filled, the second set will be transparent.
;----------------------------------------------------------------------
function create_bar_charts(wks,nplots,nbars)
local x, y, xyres, nlt, nln
begin 
;---Create some dummy XY plots
  x        = ispan(1,nbars,1)
  y        = random_uniform(0,100,(/2,nplots,nbars/))
  xy_plots = new((/2,nplots/),graphic)    ; for filled and line bars

;---Resources for bar charts
  xyres                           = True

  xyres@gsnDraw                   = False
  xyres@gsnFrame                  = False

  xyres@tfDoNDCOverlay            = True    ; for overlaying on maps

;---Turn on bar chart
  xyres@gsnXYBarChart                   = True
  xyres@gsnYRefLine                     = min(y)
;  xyres@gsnXYBarChartOutlineThicknessF  = 3.0

;
; These four resources are necessary to make sure all 
; XY plots have the same range.
;
  xyres@trYMinF                   = min(y)
  xyres@trYMaxF                   = max(y)+2
;
; The first and last bars are only half-width by default.
; The mid-point of left bar is at min(x), and the mid-point
; of the right bar is at max(x). By adding some margins
; here, we get the whole bar.
;
  dx                              = (x(1)-x(0))/2.
  xyres@trXMinF                   = min(x)-dx
  xyres@trXMaxF                   = max(x)+dx

  do i=0,nplots-1
;---Filled bars
    xyres@gsnAboveYRefLineBarColors = "lightgoldenrod2"
    xy_plots(0,i) = gsn_csm_xy(wks,x,y(0,i,:),xyres)
;---Transparent bars
    xyres@gsnAboveYRefLineBarColors = "transparent"
    xy_plots(1,i) = gsn_csm_xy(wks,x,y(1,i,:),xyres)
  end do

  return(xy_plots)
end
  
;----------------------------------------------------------------------
; Main code
;----------------------------------------------------------------------
begin
  wks  = gsn_open_wks("png","panel")             ; send graphics to PNG file

;---Create array of maps.
  nlat      = 4     
  nlon      = 8
  nplots    = nlat*nlon
  map_plots = create_maps(wks,nlat,nlon)
  xy_plots  = create_bar_charts(wks,nplots,10)   ; 2 x nplots plots
                                                 ; 10 bars each

;---Overlay XY plots on map plots
  do i=0,nplots-1
    overlay(map_plots(i),xy_plots(0,i))
    overlay(map_plots(i),xy_plots(1,i))
  end do

;---Panel everything
  pres                            = True
  pres@gsnMaximize                = True
  pres@gsnPanelMainString         = "Maps with filled and transparent bars"
  pres@gsnPanelLeft               = 0.02   ; Leave room for leftmost labels.
  pres@gsnPanelScalePlotIndex     = 9      ; an innermost plot
  pres@gsnPanelXWhiteSpacePercent = 0.0    ; remove all white space
  pres@gsnPanelYWhiteSpacePercent = 0.0
  gsn_panel(wks,map_plots,(/nlat,nlon/),pres)
end
