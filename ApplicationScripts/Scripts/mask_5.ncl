;*************************************************
; mask_5.ncl
;
; Concepts illustrated:
;   - Using "landsea_mask" to create a land/sea mask for your dataset
;   - Using "mask" to set land or ocean values in your data to missing
;   - Paneling two plots on a page
;   - Drawing raster contours
;   - Explicitly setting the fill colors for contours
;   - Drawing contours over land only
;   - Using draw order resources to mask areas in a plot
;   - Centering labels with respect to labelbar boxes
;   - Adding a title to a labelbar
;   - Turning off map tickmarks
;   - Turning off the gray-filled continents
;   - Adding white space around paneled plots
;
;************************************************
;
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
;
; This file still has to be loaded manually
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl"

;----------------------------------------------------------------------
; Function to generate some dummy data.
;----------------------------------------------------------------------
function dummy_data(nlat,nlon,minlat,maxlat,minlon,maxlon)
local nlat, nlon, lat, lon
begin
;---Generate some dummy lat/lon data over area that covers Georgia
  lat       = fspan(minlat,maxlat,nlat)
  lon       = fspan(minlon,maxlon,nlon)
  lat@units = "degrees_north"
  lon@units = "degrees_east"

  data     = generate_2d_array(10, 15, 235, 315, 0, (/nlat,nlon/))
  data@long_name = "temperature"
  data@units = "degK"
  data!0   = "lat"
  data!1   = "lon"
  data&lat = lat
  data&lon = lon
  
  return(data)
end

begin

;  Data file not available, dummy data being used instead
;  a = addfile("ts.t85.nc","r")     ; read in sample data file (resolution=T85)
;  t85 = a->TS(0,:,:)               ; grab the first timestep of the TS field
  
  t85 = dummy_data(90,180,-90,90,-179,179)

  b = addfile("landsea.nc","r")   ; read in land sea mask basemap file
  lsm_t85  = landsea_mask(b->LSMASK,t85&lat,t85&lon)         ; read in land sea mask, and pass it and
                                                             ; the t85 lat/lon arrays into landsea_mask 
  t85 = mask(t85,lsm_t85.eq.0,False)        ; mask out all ocean points from t85												 
;============================================================================
  wks = gsn_open_wks("png","mask")            ; send graphics to PNG file
  cmap = read_colormap_file("wh-bl-gr-ye-re") ; read color data
  
  res = True
  res@mpFillOn         = False                ; do not color-fill the map
  res@gsnTickMarksOn   = False                ; turn off all tick marks
  res@mpPerimOn        = True                 ; turn the map perimeter on
  res@mpPerimDrawOrder = "PostDraw"           ; draw the map perimeter last
  res@gsnDraw          = False                ; do not draw the plot
  res@gsnFrame         = False                ; do not advance the frame
  res@cnLinesOn        = False                ; turn off the contour lines
  res@cnLineLabelsOn   = False                ; turn off the contour line labels
  res@cnLevelSelectionMode = "ExplicitLevels" ; explicitly set the levels via cnLevels
  res@cnLevels         = (/1.,2.,3.,4./)      ; set the levels
  res@cnFillOn         = True                 ; turn on color fill
  res@cnFillPalette    = cmap( (/60,100,20,140,5/), :)     ; use subsetted color map
  res@cnFillMode       = "RasterFill"         ; use raster fill         
;  res@cnFillColors     = (/60,100,20,140,5/)  ; set the colors that will be used to color fill
  res@lbLabelStrings   = ispan(0,4,1)         ; labels for the labelbar boxes
  res@lbLabelAlignment = "BoxCenters"         ; put the labels in the center of the label bar boxes
  res@lbTitleString    = "0=ocean, 1=land, 2=lake, 3=small island, 4=ice shelf"  ; labelbar title
  res@lbTitleFontHeightF = 0.0125             ; labelbar title font height
  
  plot = new(2,graphic)
  res@gsnCenterString = "land sea mask @T85 resolution"
  plot(0) = gsn_csm_contour_map(wks,lsm_t85,res)

  res2 = True
  res2@mpFillOn         = False                ; do not color-fill the map
  res2@gsnTickMarksOn   = False                ; turn off all tick marks
  res2@mpPerimOn        = True                 ; turn the map perimeter on
  res2@mpPerimDrawOrder = "PostDraw"           ; draw the map perimeter last
  res2@gsnDraw          = False                ; do not draw the plot
  res2@gsnFrame         = False                ; do not advance the frame
  res2@cnLinesOn        = False                ; turn off the contour lines
  res2@cnLineLabelsOn   = False                ; turn off the contour line labels
  res2@cnFillOn         = True                 ; turn on color fill
  res2@cnFillPalette    = cmap                 ; use full color map
  res2@cnLinesOn        = False                ; turn the contour lines off 
  res2@gsnCenterString  = "Dummy TS Field (ocean-masked)" 
  plot(1) = gsn_csm_contour_map(wks,t85,res2)
  
  panres = True                                ; create a panel resource list
  panres@gsnMaximize = True                    ; maximize the size of the paneled plots
  panres@gsnPanelYWhiteSpacePercent = 1.0      ; leave space between the 2 plots
  gsn_panel(wks,plot,(/2,1/),panres)
end
