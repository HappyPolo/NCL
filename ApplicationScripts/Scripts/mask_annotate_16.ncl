;----------------------------------------------------------------------
; mask_annotate_16.ncl
;
; Concepts illustrated:
;   - Generating dummy data using "generate_2d_array", with randomly added missing data
;   - Masking out particular areas in a map by creating two different maps.
;   - Attaching a plot as an annotation of another plot
;   - Turning off tickmarks on the right and top axes
;   - Turning off the addition of a longitude cyclic point
;   - Increasing the thickness of map outlines
;----------------------------------------------------------------------
; This script shows how to draw filled contours over gray land, and 
; then mask the contours over the ocean by filling it in white.  
;
; This requires creating two plots: a contour / map plot with gray 
; land, and a map only plot with white ocean and transparent land.
;
; You can then simply draw the two plots, or you can add one as an
; annotation of the other, if you need to resize or panel them 
; later.
;
; For another version of this script that might be easier to
; understand, see mask_dummy_16.ncl.  This script simply creates
; the contour/map plot twice with the desired filled effects. This
; script could be significantly slower if the data being contoured
; is large.
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
  wks = gsn_open_wks ("png", "mask_annotate")

;---Set up resources common to contour/map plot and map plot.
  res                             = True
  res@gsnDraw                     = False
  res@gsnFrame                    = False

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

;----------------------------------------------------------------------
; Code for creating contour map plot.
;----------------------------------------------------------------------
  cnres                             = res            ; Make copy of resource list for contour/map plot

  cnres@gsnMaximize                 = True
  cnres@gsnAddCyclic                = False

  cnres@cnLinesOn                   = False  ; Turn off contour lines
  cnres@cnFillOn                    = True   ; Turn on contour fill
  cnres@cnFillPalette               = "nrl_sirkes"

  cnres@cnLevelSelectionMode        = "ExplicitLevels"
  cnres@cnLevels                    = ispan(-16,16,2)

;---Turning off map tickmarks and labels
  cnres@tmXBOn                      = False
  cnres@tmXTOn                      = False
  cnres@tmYROn                      = False
  cnres@tmYLOn                      = False

  cnres@pmLabelBarWidthF            = 0.50      ; make labelbar wider
  cnres@pmLabelBarHeightF           = 0.05      ; make labelbar thinner
  cnres@pmLabelBarOrthogonalPosF    = -0.01     ; move closer to plot
  cnres@lbLabelFontHeightF          = 0.008     ; make labels smaller

;
; Create a filled contour plot over a map with gray land and 
; transparent ocean (the default map colors for 
; gsn_csm_contour_map).
;
  contour_map_plot = gsn_csm_contour_map(wks,var,cnres)

;----------------------------------------------------------------------
; Code for creating map only plot.
;----------------------------------------------------------------------

;---Get size of contour/map plot
  getvalues contour_map_plot
    "vpXF"      : vpx
    "vpYF"      : vpy
    "vpWidthF"  : vpw
    "vpHeightF" : vph
  end getvalues

  mpres                  = res       ; Make copy of resource list for map plot
  mpres@vpXF             = vpx       ; Make sure map plot is same size
  mpres@vpYF             = vpy       ;   as contour/map plot.
  mpres@vpWidthF         = vpw
  mpres@vpHeightF        = vph
  mpres@gsnTickMarksOn   = False     ; Turn off since they are already drawn in contour/map plot.

;---Make the ocean white and land transparent. This will mask out the contour fill over ocean.
  mpres@mpOceanFillColor = "white"
  mpres@mpLandFillColor  = "transparent"

;---Create a map plot with the white ocean and transparent land.
  map_plot = gsn_csm_map(wks, mpres)

;
; METHOD 1: You can simply draw both plots, making sure to draw
; the contour map plot first:
;
   draw(contour_map_plot)
   draw(map_plot)
   frame(wks)
;
; METHOD 2: If you need to resize the plots later---for example, to
; use in a panel---then it's easier to make one plot an annotation of
; the other.
;
  annoid = gsn_add_annotation(contour_map_plot, map_plot, True)
  draw(contour_map_plot)   ; This draws both plots
  frame(wks)

end


