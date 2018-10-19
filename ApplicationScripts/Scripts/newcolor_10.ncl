;----------------------------------------------------------------------
; newcolor_10.ncl
;
; Concepts illustrated:
;   - Overlaying WRF "dbz" on a topographic map
;   - Showing features of the new color display model
;   - Using cnFillPalette to assign a color palette to contours
;   - Using more than 256 colors per frame
;   - Making a contour fill color transparent
;   - Using "overlay" to overlay multiple contours
;   - Drawing counties in the United States
;----------------------------------------------------------------------
; NOTE: This example will only work with NCL V6.1.0 and later.
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
;
; Whether to loop across levels for an animation.
; Warning: this may create a large file (> 44 Mb).
;
  ANIMATE = False
 
;---Open file. You may need to include ".nc" at the end.
  a = addfile("wrfout_d01_2003-07-15_00:00:00.nc","r")

;---Read variables directly (can also use "wrf_user_getvar")
  hgt = a->HGT(0,:,:)                 ; terrain, 0 is the first time step
  lat = a->XLAT(0,:,:)                ; latitude
  lon = a->XLONG(0,:,:)               ; longitude
  znu = a->ZNU                        ; eta values
  dbz = wrf_user_getvar(a,"dbz",0)    ; reflectivity

;---Debug information
  print("------------------------------------------")
  printMinMax(hgt,0)
  printMinMax(dbz,0)

;---Open workstation
  wks = gsn_open_wks("png","newcolor") ; send graphics to PNG file

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
  res@pmLabelBarOrthogonalPosF = -0.02    ; move labelbar closer to plot

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

;---Copy common resources for terrain plot
  tres                       = res

  tres@cnLevelSelectionMode  = "ExplicitLevels"
  tres@cnLevels              = ispan(1,3200,200)
  tres@cnFillPalette         = "OceanLakeLandSnow"

  tres@lbLabelBarOn          = False               ; we don't need this
  tres@lbBoxLinesOn          = False               ; turn off labelbar lines

  tres@pmTickMarkDisplayMode = "Always"            ; nicer tickmarks
  tres@mpFillOn              = False               ; turn off map fill

  tres@mpDataBaseVersion     = "MediumRes"         ; better resolution
  tres@mpOutlineBoundarySets = "AllBoundaries"     ; more outlines
  tres@mpDataSetName         = "Earth..4"     

  tres@mpMinLatF             = min(lat)    ; zoom in on map
  tres@mpMaxLatF             = max(lat)
  tres@mpMinLonF             = min(lon) 
  tres@mpMaxLonF             = max(lon)

;---Copy common resources for dbz plot
  dres                       = res      

  dres@cnLevelSelectionMode  = "ExplicitLevels"
  dres@cnLevels              = ispan(-28,40,2)
  dres@lbOrientation         = "Vertical"

;
; Get RGBA values for WhViBlGrYeOrRe color map and 
; set first color to transparent (no color)
;
  cmap_r              = read_colormap_file("WhViBlGrYeOrRe")
  cmap_r(0,3)         = 0.0    ; Fully transparent
  dres@cnFillPalette  = cmap_r

;---For animation purposes, create arrays to hold plots.
  if(ANIMATE) then
    dims = dimsizes(dbz)
    nlev = dims(0)
  else
    nlev = 1
  end if

  ter_plot = new(nlev,graphic)
  dbz_plot = new(nlev,graphic)

  do n=0,nlev-1
;---Make sure we don't have a constant field.
    if(min(dbz(n,:,:)).ne.max(dbz(n,:,:))) then
      print("------------------------------------------")
      print("Plotting at level " + znu(0,n))

      tres@tiMainString   = "Reflectivity (dBZ) at level = " + znu(0,n)
      tres@tiMainOffsetYF = -0.04   ; moves title closer to plot.

;---Create the two plots
      ter_plot(n) = gsn_csm_contour_map(wks,hgt,tres)
      dbz_plot(n) = gsn_csm_contour(wks,dbz(n,:,:),dres)

;---Overlay the dbz plot on the terrain plot
      overlay(ter_plot(n),dbz_plot(n))

;---Drawing the terrain plot will also draw dbz plot
      draw(ter_plot(n))
      frame(wks)
    else
      print("------------------------------------------")
      print("Not plotting at level " + znu(0,n))
    end if
  end do

end
