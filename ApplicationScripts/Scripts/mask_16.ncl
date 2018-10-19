;----------------------------------------------------------------------
; mask_16.ncl
;
; Concepts illustrated:
;   - Generating dummy data using "generate_2d_array", with randomly added missing data
;   - Masking out particular areas in a map by drawing a plot twice
;   - Using draw order resources to make sure filled map areas are drawn last
;   - Turning off tickmarks on the right and top axes
;   - Turning off the addition of a longitude cyclic point
;   - Increasing the thickness of map outlines
;----------------------------------------------------------------------
; This script shows how to draw filled contours over gray land, and 
; then mask the contours over the ocean by filling it in white.  
;
; This script draws a contour / map plot twice: 
;    - First, it draws a filled contour / map plot over gray land.
;    - Second, it creates a filled contour / map plot with transparent
;      contours, white ocean and transparent land. This has the effect
;      of making the filled contours visible only over land.
;
; For another version of this script that only creates the contour/map
; plot once, see mask_dummy_annotate_16.ncl. This might be a better
; script to use, if the contour/map plot takes a long time to be 
; generated.
;----------------------------------------------------------------------
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"

;----------------------------------------------------------------------
; Function to generate some dummy data over a map.
;----------------------------------------------------------------------
function dummy_data(dmin,dmax,nlat,nlon,minlat,maxlat,minlon,maxlon)
local nlat, nlon, lat, lon
begin
;---Generate some dummy lat/lon data over area that covers Georgia
  lat       = fspan(minlat,maxlat,nlat)
  lon       = fspan(minlon,maxlon,nlon)
  lat@units = "degrees_north"
  lon@units = "degrees_east"

  data     = generate_2d_array(10, 25, dmin, dmax, 0, (/nlat,nlon/))
  data!0   = "lat"
  data!1   = "lon"
  data&lat = lat
  data&lon = lon
  data@_FillValue = default_fillvalue("float")
  return(data)
end


;----------------------------------------------------------------------
; Main driver code
;----------------------------------------------------------------------
begin
;---Generate some dummy data over an area that covers South America area.
  minlat = -60
  maxlat =  20
  minlon = -90
  maxlon =  -30
  nlat   = 50
  nlon   = 50
  var    = dummy_data(-16,16,nlat,nlon,minlat,maxlat,minlon,maxlon)

;---Set some random grid points to missing
  lat_msg = toint(random_uniform(0,nlat-1,10))
  lon_msg = toint(random_uniform(0,nlon-1,10))
  var(lat_msg,lon_msg) = var@_FillValue

;---Start the graphics
  wks = gsn_open_wks ("png", "mask")

;---Set up resource list for plot options.
  res                             = True

  res@gsnAddCyclic                = False
  res@gsnMaximize                 = True

  res@cnLinesOn                   = False  ; Turn off contour lines
  res@cnFillOn                    = True   ; Turn on contour fill
  res@cnFillPalette               = "nrl_sirkes"

  res@cnLevelSelectionMode        = "ExplicitLevels"
  res@cnLevels                    = ispan(-16,16,2)

;---Turning off map tickmarks and labels
  res@tmXBOn                      = False
  res@tmXTOn                      = False
  res@tmYROn                      = False
  res@tmYLOn                      = False

  res@pmLabelBarWidthF            = 0.50      ; make labelbar wider
  res@pmLabelBarHeightF           = 0.05      ; make labelbar thinner
  res@pmLabelBarOrthogonalPosF    = -0.01     ; move closer to plot
  res@lbLabelFontHeightF          = 0.008     ; make labels smaller

;---Zoom in on South America
  res@mpMinLatF                   = minlat
  res@mpMaxLatF                   = maxlat
  res@mpMinLonF                   = minlon
  res@mpMaxLonF                   = maxlon

;---Set resources for better map outlines
  res@mpOutlineOn                 = True
  res@mpOutlineBoundarySets       = "AllBoundaries"
  res@mpDataBaseVersion           = "MediumRes"
  res@mpDataSetName               = "Earth..4"       ; gives us some provincial boundaries

;---Increase thickness of map outlines
  res@mpPerimOn                   = True
  res@mpPerimLineThicknessF       = 2.0
  res@mpNationalLineThicknessF    = 4
  res@mpProvincialLineThicknessF  = 4
  res@mpGeophysicalLineThicknessF = 4
; 
; In order to display filled contours over land and have the ocean
; white, but keep the gray filled land underneath, we have to draw
; the plot twice.  
;
; First, draw the filled contours with the gray land (the default).
; Second, we simply want to draw the ocean part in white, so we need
; to effectively turn off the land fill and the contour fill by
; setting them both to transparent.
;

;---Draw first plot but don't advance frame.
  res@gsnFrame                    = False
  plot = gsn_csm_contour_map(wks,var, res)

;---Draw second plot and this time advance frame.
  res@mpLandFillColor             = "transparent"
  res@mpOceanFillColor            = "white"
  res@cnFillOpacityF              = 1.0
  res@mpFillDrawOrder             = "PostDraw"
  res@gsnFrame                    = True
  plot = gsn_csm_contour_map(wks,var, res)


end


