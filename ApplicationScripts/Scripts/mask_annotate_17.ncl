;----------------------------------------------------------------------
; mask_annotate_17.ncl
;
; Concepts illustrated:
;   - Plotting precipitation data
;   - Using "transparent" as a contour fill color
;   - Masking out particular areas in a map by creating two different maps.
;   - Attaching a plot as an annotation of another plot
;   - Explicitly setting contour levels
;   - Explicitly setting contour fill colors
;   - Zooming in on South America on a cylindrical equidistant map
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
; understand, see mask_16.ncl. This script simply creates the
; contour/map plot twice with the desired filled effects. This
; script could be significantly slower if the data being contoured
; is large.
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

;---Zoom in on South America
  res@mpMinLatF                   = minlat
  res@mpMaxLatF                   = maxlat
  res@mpMinLonF                   = minlon
  res@mpMaxLonF                   = maxlon

;----------------------------------------------------------------------
; Code for creating contour map plot.
;----------------------------------------------------------------------
  cnres                             = res            ; Make copy of resource list for contour/map plot

  cnres@gsnMaximize                 = True

  cnres@cnLinesOn                   = False        ; Turn off contour lines
  cnres@cnFillOn                    = True         ; Turn on contour fill
  cnres@cnFillMode                  = "RasterFill" ; "AreaFill" is the default and can be slow for large grids.

;---Define the contour leves and the colors for each.
  cnres@cnLevelSelectionMode        = "ExplicitLevels"
  cnres@cnLevels                    = (/ 0.01, 0.02, 0.04, 0.08, 0.16, \
                                         0.32, 0.64, 0.96/)
  cnres@cnFillColors                = (/"transparent","cyan", "green","yellow",\
                                        "darkorange","red","magenta","purple",\
                                        "black"/)

  cnres@pmLabelBarHeightF           = 0.08      ; make labelbar thinner
  cnres@pmLabelBarWidthF            = 0.50      ; make labelbar wider
  cnres@lbLabelFontHeightF          = 0.012     ; make labels smaller

  cnres@gsnAddCyclic                = False     ; don't add longitude cyclic point

  cnres@pmTickMarkDisplayMode       = "Always"  ; nicer tickmarks

  cnres@gsnLeftString               = "precipitation"   ; data doesn't have a "long_name" attribute
  cnres@gsnStringFontHeightF        = 0.015
  cnres@gsnLeftStringOrthogonalPosF = 0.02
  cnres@gsnRightStringOrthogonalPosF= 0.02

;
; Create a filled contour plot over a map with gray land and 
; transparent ocean (the default map colors for 
; gsn_csm_contour_map).
;
  contour_map_plot = gsn_csm_contour_map(wks, var, cnres)

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


