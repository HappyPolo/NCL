;----------------------------------------------------------------------
; panel_27.ncl
;
; Concepts illustrated:
;   - Drawing panel plots with two labelbars
;   - Drawing a custom labelbar
;   - Adding a common title to paneled plots
;   - Generating dummy data using "generate_2d_array"
;   - Zooming in on Australia on a cylindrical equidistant map
;   - Overlaying shaded contours and filled contours on a map
;   - Filling contours with multiple shaded patterns
;   - Retrieving contour resource values to create a labelbar
;----------------------------------------------------------------------
;
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"

;----------------------------------------------------------------------
; This function creates and draws a labelbar based on a given 
; contour plot.
;----------------------------------------------------------------------
function labelbar(wks,plot)
local colors, levels, labels, nboxes
begin

; Retrieve the contour levels and their associated colors.
  getvalues plot
    "cnLevels"          : levels
    "cnMonoFillPattern" : mono_pattern
    "cnMonoFillColor"   : mono_color
    "cnFillColors"      : colors
    "cnFillColor"       : color
    "cnFillPatterns"    : patterns
    "cnFillPattern"     : pattern
  end getvalues

  nboxes = dimsizes(colors)
  labels = ""+levels    ; labels for the labelbar

; Set some labelbar resources.
  lbres                    = True
  lbres@vpXF               = 0.90         ; Position labelbar at         
  lbres@vpYF               = 0.86         ; right of frame
  lbres@vpWidthF           = 0.10
  lbres@vpHeightF          = 0.70

  if(mono_pattern) then
    lbres@lbMonoFillPattern  = True
    lbres@lbFillPattern      = pattern
  else
    lbres@lbMonoFillPattern  = False
    lbres@lbFillPatterns     = patterns
  end if

  if(mono_color) then
    lbres@lbMonoFillColor  = True

;---This may look better as black, rather than color used in plot.
    lbres@lbFillColor      = "black"     ; color
  else
    lbres@lbMonoFillColor  = False
    lbres@lbFillColors     = colors
  end if

  lbres@lbPerimOn          = False            ; Turn off perimeter.
  lbres@lbLabelFontHeightF = 0.013            ; Label font height
  lbres@lbLabelAlignment   = "InteriorEdges"

  lbid = gsn_create_labelbar(wks,nboxes,labels,lbres)

  return(lbid)
end

;----------------------------------------------------------------------
; Main code
;----------------------------------------------------------------------

begin
  minlat = -45
  maxlat =  -6
  minlon = 110
  maxlon = 155

;---Generate dummy lat/lon data around Australia
  nplots    = 9
  nlat      = 130
  nlon      = 130
  lat       = fspan(minlat,maxlat,nlat)
  lon       = fspan(minlon,maxlon,nlon)
  rec       = ispan(1,nplots,1)
  lat@units = "degrees_north"
  lon@units = "degrees_east"
  rec@units = "plot_num"
  
;---Generate dummy data for plots.
  dims     = (/nplots,nlat,nlon/)
  psl_data = new(dims,float)
  pcp_data = new(dims,float)

;---Create some random mins/maxs, high/lows for generate_2d_arrayf function
  psl_min = random_uniform( 998,1002,nplots)
  psl_max = random_uniform(1027,1030,nplots)
  psl_low = toint(random_uniform( 2, 9,nplots))
  psl_hgh = toint(random_uniform(10,19,nplots))
  pcp_min = random_uniform(0.00,0.04,nplots)
  pcp_max = random_uniform(0.3,0.35,nplots)
  pcp_low = toint(random_uniform(3, 4,nplots))
  pcp_hgh = toint(random_uniform(3, 4,nplots))

;---Assign dummy coordinate arrays
  psl_data!0 = "rec"
  psl_data!1 = "lat"
  psl_data!2 = "lon"
  psl_data&rec = rec
  psl_data&lat = lat
  psl_data&lon = lon
  pcp_data!0 = "rec"
  pcp_data!1 = "lat"
  pcp_data!2 = "lon"
  pcp_data&rec = rec
  pcp_data&lat = lat
  pcp_data&lon = lon

  do i=0,nplots-1
    i2 = i*2
    psl_data(i,:,:) = generate_2d_array(psl_low(i), psl_hgh(i), \
                                        psl_min(i), psl_max(i),i2,dims(1:))
    pcp_data(i,:,:) = generate_2d_array(pcp_low(i), pcp_hgh(i), \
                                        pcp_min(i), pcp_max(i),i2+1,dims(1:))
  end do

;---Start the graphics
  wks = gsn_open_wks("png","panel")     ; send graphics to PNG file

;---Set common resources for all plots
  res                     = True
  res@gsnDraw             = False       ; Don't draw plots
  res@gsnFrame            = False       ; Don't advance frame
  res@cnFillOn            = True        ; Turn on contour fill
  res@cnInfoLabelOn       = False       ; Turn off info label
  res@cnLineLabelsOn      = False       ; Turn off line labels
  res@lbLabelBarOn        = False         ; Turn off labelbar

  pslres = res
  pcpres = res


;---Contour resources for filled contours
  cmap = read_colormap_file("precip2_17lev")
  pslres@cnFillPalette        = cmap(2:14,:)   ; don't span full color map

  pslres@cnLinesOn            = False          ; Turn off contour lines
  pslres@cnLevelSelectionMode = "ManualLevels"
  pslres@cnMinLevelValF       = 1000
  pslres@cnMaxLevelValF       = 1027
  pslres@cnLevelSpacingF      = 3

;---Contour resources for shaded contours
  pcpres@cnMonoFillPattern   = False        ; Use multiple fill patterns
  pcpres@cnMonoFillColor     = True         ; Use same fill color
  pcpres@cnFillColor         = "gray65"
  pcpres@cnLinesOn           = True         ; Turn on contour lines
  pcpres@lbOrientation       = "Vertical"   ; Rotate labelbar

  pcpres@cnLevelSelectionMode = "ManualLevels"
  pcpres@cnMinLevelValF       = 0.05
  pcpres@cnMaxLevelValF       = 0.3
  pcpres@cnLevelSpacingF      = 0.05

  pcpres@cnFillPatterns       = (/-1,3,4,5,6,7,8/)   ; First one is no pattern

;---Set map resources
  mapres               = True

  mapres@gsnDraw       = False
  mapres@gsnFrame      = False

  mapres@mpFillOn      = False  
  mapres@mpOutlineOn   = True

;---Zoom in on area of interest
  mapres@mpLimitMode   = "LatLon"
  mapres@mpMinLatF     = minlat
  mapres@mpMaxLatF     = maxlat
  mapres@mpMinLonF     = minlon
  mapres@mpMaxLonF     = maxlon

;---Create arrays to hold plots
  fillplots  = new(nplots,graphic)
  shadeplots = new(nplots,graphic)
  mapplots   = new(nplots,graphic)

;---Loop through and create each plot and do the overlay
  do i=0,nplots-1
    fillplots(i)  = gsn_csm_contour(wks,psl_data(i,:,:),pslres)
    shadeplots(i) = gsn_csm_contour(wks,pcp_data(i,:,:),pcpres)
    mapplots(i)   = gsn_csm_map(wks,mapres)

    overlay(mapplots(i),fillplots(i))
    overlay(mapplots(i),shadeplots(i))
  end do

;---Panel resources
  pres                        = True
  pres@gsnMaximize            = True    ; Maximize in frame
  pres@gsnFrame               = False   ; Don't advance frame
  pres@gsnPanelLabelBar       = True    ; Add color labelbar
  pres@pmLabelBarHeightF      = 0.10    ; Default kind of thin
  pres@pmLabelBarWidthF       = 0.80
  pres@gsnPanelRight          = 0.90    ; Leave room for shaded labelbar on
                                        ; right, to be created below.

  pres@gsnPanelMainString     = "Panel plot with two labelbars"

;---Create and draw panelled plots
  gsn_panel(wks,mapplots,(/3,3/),pres)

;---Create a labelbar based on shaded plot and draw.
  lbid = labelbar(wks,shadeplots(0))
  draw(lbid)
  frame(wks)
end
