;----------------------------------------------------------------------
; overlay_12.ncl
;
; Concepts illustrated:
;   - Overlaying WRF "dbz" on a topographic map
;   - Using two different colormaps on one page
;   - Using cnFillPalette to assign a color palette to contours
;   - Using opacity to emphasize or subdue overlain features
;   - Using "overlay" to overlay multiple contours
;   - Drawing counties in the United States
;   - Removing a plot that has been overlaid on another plot so it can be reused
;   - Controlling whether the labelbar shows same opacity as contours 
;----------------------------------------------------------------------
; Important note: in NCL V6.3.0 and earlier, there's a bug in which the
; colors in the labelbar do not correctly reflect the opacity applied
; to the filled contours.  This bug has been fixed in NCL V6.4.0.
;
; This script has been updated to show how to control the opacity of
; the labelbar: the first plot has opaque labelbars for the terrain
; plot, and the second one doesn't.
;----------------------------------------------------------------------
;
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/wrf/WRFUserARW.ncl"

;----------------------------------------------------------------------
; Main code
;----------------------------------------------------------------------

begin
;---Open file. You may need to include ".nc" at the end.
  a = addfile("wrfout_d01_2003-07-15_00:00:00.nc","r")

;---Read variables directly (can also use "wrf_user_getvar")
  hgt = a->HGT(0,:,:)                 ; terrain, 0 is the first time step
  lat = a->XLAT(0,:,:)                ; latitude
  lon = a->XLONG(0,:,:)               ; longitude
  znu = a->ZNU                        ; eta values
  dbz = wrf_user_getvar(a,"dbz",0)    ; reflectivity

  nlev = 1
  print("Plotting at level " + znu(0,nlev))


;---Debug information
  print("------------------------------------------")
  printMinMax(hgt,0)
  printMinMax(dbz,0)

;---Open workstation
  wks = gsn_open_wks("png","overlay")  ; send graphics to PNG file

;---Set some common resources
  res                       = True
  res@gsnDraw               = False    ; turn off draw
  res@gsnFrame              = False    ; turn off frame
  res@cnFillOn              = True     ; turn on contour fill
  res@cnLinesOn             = False    ; turn off contour lines
  res@cnLineLabelsOn        = False    ; turn off contour line labels
  res@gsnLeftString         = ""       ; turn off subtitles
  res@gsnRightString        = ""
  res@gsnCenterString       = ""

;---labelbar stuff
  res@lbLabelFontHeightF       = 0.015

;
; Setting these four resources is necessary to keep
; the plot from running off the frame.
;
; The plot size will be slightly adjusted internally to
; keep the aspect ratio of the map.
;
  res@vpXF                  = 0.08
  res@vpYF                  = 0.88
  res@vpWidthF              = 0.80
  res@vpHeightF             = 0.60

;---Necessary to put data on map correctly.
  res@sfXArray              = lon
  res@sfYArray              = lat
  res@gsnAddCyclic          = False

;---Copy common resources to resource lists for terrain and dbz plots
  tres                       = res
  dres                       = res      

;---set resources specific to terrain plot
  tres@cnLevelSelectionMode  = "ExplicitLevels"
  tres@cnLevels              = ispan(1,3200,200)
  tres@cnFillPalette         = "OceanLakeLandSnow"
  tres@cnFillOpacityF        = 0.6

  tres@lbOrientation         = "horizontal"
  tres@lbTitleString         = hgt@description + " (" + hgt@units + ")"
  tres@lbTitleFontHeightF    = 0.015
  tres@lbLabelFontHeightF    = 0.01
  tres@lbTitleOffsetF        = -0.3
  tres@lbLabelAutoStride     = False
  tres@pmLabelBarOrthogonalPosF = 0.09    ; move labelbar away from plot
  tres@pmTickMarkDisplayMode = "Always"            ; nicer tickmarks

  tres@mpFillOn              = False               ; turn off map fill

  tres@mpDataBaseVersion     = "MediumRes"         ; better resolution
  tres@mpOutlineBoundarySets = "AllBoundaries"     ; more outlines
  tres@mpDataSetName         = "Earth..4"     

  tres@mpMinLatF             = min(lat)    ; zoom in on map
  tres@mpMaxLatF             = max(lat)
  tres@mpMinLonF             = min(lon) 
  tres@mpMaxLonF             = max(lon)

  tres@tiMainString          = "Reflectivity (" + dbz@units + \
                               ") at znu level = " + znu(0,nlev)
  tres@tiMainOffsetYF        = -0.04   ; moves title closer to plot.

;---set resources specific to dbz plot
  dres@cnLevelSelectionMode  = "ExplicitLevels"
  dres@cnLevels              = ispan(-28,40,2)
  dres@lbOrientation         = "Vertical"
  dres@pmLabelBarOrthogonalPosF = -0.02    ; move labelbar closer to plot

;
; Get RGBA values for WhViBlGrYeOrRe color map and 
; set first color to transparent (no color)
;
  cmap_r              = read_colormap_file("WhViBlGrYeOrRe")
  cmap_r(0,3)         = 0.0    ; first color fully transparent
  dres@cnFillPalette  = cmap_r

;----------------------------------------------------------------------
; First frame: this shows a filled contour plot of DBZ overlaid on a
; filled terrain plot. The labelbar for the terrain plot shows the
; same opaque colors as the filled terrain contours.
;----------------------------------------------------------------------

;---Create the two plots
  ter_plot = gsn_csm_contour_map(wks,hgt,tres)
  dbz_plot = gsn_csm_contour(wks,dbz(nlev,:,:),dres)

;---Overlay the dbz plot on the terrain plot
  overlay(ter_plot,dbz_plot)

;---Drawing the terrain plot will also draw dbz plot
  draw(ter_plot)
  frame(wks)

;----------------------------------------------------------------------
; Second frame: this also shows a filled contour plot of DBZ overlaid
; on a filled terrain plot, except now the labelbar colors are fully
; opaque.
;----------------------------------------------------------------------

;---Remove the dbz plot from terrain plot so we can re-overlay it on a new plot
  NhlRemoveOverlay(ter_plot,dbz_plot,False)


;---Recreate the terrain plot with a fully opaque labelbar
  tres@lbOverrideFillOpacity = True   ; don't apply opacity to labelbar colors
                                      ; (NCL V6.4.0 and later)
  ter_plot = gsn_csm_contour_map(wks,hgt,tres)

;--Re-overlay the dbz plot on the new terrain plot.
  overlay(ter_plot,dbz_plot)

;---Drawing the terrain plot will also draw dbz plot
  draw(ter_plot)
  frame(wks)
end
