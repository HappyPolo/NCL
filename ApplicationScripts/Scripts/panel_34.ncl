;----------------------------------------------------------------------
; panel_34.ncl
;
; Concepts illustrated:
;   - Drawing panel plots with two labelbars
;   - Drawing a custom labelbar based on existing plots.
;   - Adding a common title to paneled plots
;   - Generating dummy data using "generate_2d_array"
;   - Filling contours with multiple shaded patterns
;   - Retrieving contour resource values to create a labelbar
;   - Using "getvalues" to retrieve resource values
;----------------------------------------------------------------------
;
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"

;----------------------------------------------------------------------
; Function to create a labelbar on right side of frame, based on a
; top and bottom plot to span the height of the labelbar by.
;----------------------------------------------------------------------
function labelbar(wks,top_plot,bottom_plot)
local colors, levels, labels, nboxes
begin
  getvalues top_plot
   "pmOverlaySequenceIds" : am_ids
   "vpYF"                 : vpy_top
  end getvalues

  getvalues bottom_plot
   "vpYF"                 : vpy_bot
   "vpHeightF"            : vph_bot
  end getvalues

  do i=0,dimsizes(am_ids)-1
    if(NhlClassName(am_ids(i)).eq."contourPlotClass") then
      break
    end if
  end do
; Retrieve the contour levels and their associated colors.
  getvalues am_ids(i)
    "cnLevels"          : levels
    "cnFillColors"      : colors
  end getvalues

  nboxes = dimsizes(colors)
  labels = ""+levels    ; labels for the labelbar

; Set some labelbar resources.
  lbres                    = True

  lbres@vpXF               = 0.91
  lbres@vpWidthF           = 0.10
  lbres@vpYF               = vpy_top
  lbres@vpHeightF          = vpy_top-(vpy_bot-vph_bot)
  lbres@lbMonoFillPattern  = True
  lbres@lbMonoFillColor    = False
  lbres@lbFillColors       = colors

  lbres@lbPerimOn          = False            ; Turn off perimeter.
  lbres@lbLabelFontHeightF = 0.013            ; Label font height
  lbres@lbLabelAlignment   = "InteriorEdges"

  lbid = gsn_create_labelbar(wks,nboxes,labels,lbres)

  return(lbid)
end

;----------------------------------------------------------------------
; Function to generate dummy data with 1D lat/lon coordinate arrays
; attached.
;----------------------------------------------------------------------
undef("dummy_data")
function dummy_data(data_rng[2],lat_rng[2],lon_rng[2],dims[*]:integer)
local iseed
begin
  nlat = dims(1)
  nlon = dims(2)
  data = new(dims,float)
  do n=0,dims(0)-1
    iseed = toint(random_uniform(0,100,1))
    nlow  = toint(random_uniform(3,10,1))
    nhgh  = toint(random_uniform(7,10,1))
    data(n,:,:) = generate_2d_array(nlow,nhgh,data_rng(0),data_rng(1),\
                                    iseed,(/nlat,nlon/))
  end do
;---Assign dummy coordinate arrays
  data!0  = "dummy"
  data!1  = "lat"
  data!2  = "lon"
  lat = fspan(lat_rng(0),lat_rng(1),nlat)
  lon = fspan(lon_rng(0),lon_rng(1),nlon)
  lat@units = "degrees_north"
  lon@units = "degrees_east"

  data&dummy = ispan(1,dims(0),1)
  data&lat = lat
  data&lon = lon
  return(data)
end

;----------------------------------------------------------------------
; Main code
;----------------------------------------------------------------------

begin
;---Generate some dummy data with lat/lon coordinate arrays
  minlat = -20
  maxlat =  15
  minlon = -20
  maxlon =  30
  nlat   =  32
  nlon   =  64
  d1min  = 1.
  d1max  = 12.
  d2min  = -6
  d2max  = 6

  data1 = dummy_data((/d1min,d1max/),(/minlat,maxlat/),\
                      (/minlon,maxlon/),(/3,nlat,nlon/))
  data2 = dummy_data((/d2min,d2max/),(/minlat,maxlat/),\
                      (/minlon,maxlon/),(/2*3,nlat,nlon/))

;---Start the graphics
  wks = gsn_open_wks("png","panel")     ; send graphics to PNG file

;---Set common resources for all plots
  res                     = True
  res@gsnMaximize         = False    ; Maximize in frame
  res@gsnDraw             = False       ; Don't draw plots
  res@gsnFrame            = False       ; Don't advance frame
  res@cnFillOn            = True        ; Turn on contour fill
  res@cnInfoLabelOn       = False       ; Turn off info label
  res@cnLineLabelsOn      = False       ; Turn off line labels
  res@lbLabelBarOn        = False         ; Turn off labelbar
  res@cnLinesOn           = False        ; Turn off contour lines
  res@cnLevelSelectionMode = "ManualLevels"

  res@gsnAddCyclic        = False

  res@mpFillOn      = False  
  res@mpOutlineOn   = True

;---Zoom in on area of interest
  res@mpLimitMode   = "LatLon"
  res@mpMinLatF     = minlat
  res@mpMaxLatF     = maxlat
  res@mpMinLonF     = minlon
  res@mpMaxLonF     = maxlon

;---Contour resources for first three contour plots
  res1               = res
  res1@cnFillPalette = "precip3_16lev"
  res1@cnLevels      = ispan(15,117,9)/10.

;---Contour resources for rest of contour plots
  res2               = res
  cmap               = read_colormap_file("GMT_drywet")
  res2@cnFillPalette = cmap(0:40,:)
  res2@cnLevels      = ispan(-60,60,9)/5.

;---Create arrays to hold plots
  plots = new(9,graphic)

;---Loop through and create each plot and do the overlay
  do i=0,2
    plots(i) = gsn_csm_contour_map(wks,data1(i,:,:),res1)
  end do
  do i=0,5
    plots(i+3) = gsn_csm_contour_map(wks,data2(i,:,:),res2)
  end do

;---Panel resources
  pres                        = True
  pres@gsnMaximize            = True    ; Maximize in frame
  pres@gsnPanelMainString     = "Single (3 x 3) panel plot with two sets of labelbars"
  pres@gsnFrame               = False   ; Don't advance frame
  pres@gsnPanelRight          = 0.90    ; Leave room for labelbars on
                                        ; right, to be drawn later.
  pres@gsnPanelSave           = True    ; Don't resize plots to original size
;---Create and draw panelled plots
  gsn_panel(wks,plots,(/3,3/),pres)

;---Create two labelbars, based on plot objects
  lbid1 = labelbar(wks,plots(2),plots(2))    ; span one row of plots
  lbid2 = labelbar(wks,plots(5),plots(8))    ; span two rows of plots

  draw(lbid1)
  draw(lbid2)
  frame(wks)

end
