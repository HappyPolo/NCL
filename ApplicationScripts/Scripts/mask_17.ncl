;----------------------------------------------------------------------
; mask_16.ncl
;
; Concepts illustrated:
;   - Plotting precipitation data
;   - Using "transparent" as a contour fill color
;   - Masking out particular areas in a map by drawing a plot twice
;   - Using draw order resources to make sure filled map areas are drawn last
;   - Explicitly setting contour levels
;   - Explicitly setting contour fill colors
;   - Zooming in on South America on a cylindrical equidistant map
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
; plot once, see mask_annotate_16.ncl. This might be a better script
; to use, if the contour/map plot takes a long time to be generated.
;----------------------------------------------------------------------
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"

;----------------------------------------------------------------------
; Main driver code
;----------------------------------------------------------------------
begin
;
; The data is ordered lon x lat; you must reorder before plotting
; using transpose. You can also use reordering syntax:
;
;  p = f->/Grid/precipitation(lat|:,lon|:)
;
; but the grid is large and this takes a significant amount of time.
;
  fname = "3B-MO.MS.MRG.3IMERG.20140701-S000000-E235959.07.V03D.HDF5"
  f     = addfile(fname, "r")
  var   = transpose(f->/Grid/precipitation)

  printVarSummary(var)
  printMinMax(var,0)

;---Select an area that covers South America
  minlat = -60
  maxlat =  20
  minlon = -90
  maxlon =  -30

;---Start the graphics
  wks = gsn_open_wks ("png", "mask")

;---Set up resource list for plot options.
  res                             = True

  res@gsnMaximize                 = True

  res@cnLinesOn                   = False        ; Turn off contour lines
  res@cnFillOn                    = True         ; Turn on contour fill
  res@cnFillMode                  = "RasterFill" ; "AreaFill" is the default and can be slow for large grids.

;---Define the contour leves and the colors for each.
  res@cnLevelSelectionMode        = "ExplicitLevels"
  res@cnLevels                    = (/ 0.01, 0.02, 0.04, 0.08, 0.16, \
                                       0.32, 0.64, 0.96/)
  res@cnFillColors                = (/"transparent","cyan", "green","yellow",\
                                      "darkorange","red","magenta","purple",\
                                      "black"/)

  res@pmLabelBarHeightF           = 0.08      ; make labelbar thinner
  res@pmLabelBarWidthF            = 0.50      ; make labelbar wider
  res@lbLabelFontHeightF          = 0.012     ; make labels smaller

  res@gsnAddCyclic                = False     ; don't add longitude cyclic point

  res@pmTickMarkDisplayMode       = "Always"  ; nicer tickmarks

  res@gsnLeftString               = "precipitation"   ; data doesn't have a "long_name" attribute
  res@gsnStringFontHeightF        = 0.015
  res@gsnLeftStringOrthogonalPosF = 0.02
  res@gsnRightStringOrthogonalPosF= 0.02

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

;---Zoom in on South America
  res@mpMinLatF                   = minlat
  res@mpMaxLatF                   = maxlat
  res@mpMinLonF                   = minlon
  res@mpMaxLonF                   = maxlon

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
  plot = gsn_csm_contour_map(wks, var, res)

;---Draw second plot and advance frame.
  res@cnFillOpacityF              = 1.0         ; make all contours transparent
  res@mpLandFillColor             = "transparent"
  res@mpOceanFillColor            = "white"
  res@mpFillDrawOrder             = "PostDraw"  ; draw map fill last
  res@gsnFrame                    = True
  plot = gsn_csm_contour_map(wks, var, res)
end


