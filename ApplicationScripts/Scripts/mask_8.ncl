;*************************************************
; mask_8.ncl
;
; Concepts illustrated:
;   - Drawing the counties of Wisconsin
;   - Masking out particular areas in a map
;   - Using draw order resources to make sure filled map areas are drawn last
;   - Explicitly setting the areas in a map to fill
;   - Explicitly setting contour levels
;   - Explicitly setting the fill colors for land, ocean, and inland water
;   - Turning off tickmarks on the right and top axes
;   - Turning off the addition of a longitude cyclic point
;   - Increasing the thickness of map outlines
;
; This script was contributed by Dr. Michael Notaro, a scientist at the
; Center for Climatic Research, University of Wisconsin-Madison.
;*************************************************
; For a version of this script that uses dummy data, see 
; "mask_dummy_8.ncl"
;*************************************************
;
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"

begin

  a   = addfile("data_wi.nc","r")
  var = a->var
  lat = var&lat
  lon = var&lon

  wks = gsn_open_wks ("png", "mask")       ; send graphics to PNG file
  cmap = read_colormap_file("rainbow+white")     ; read color data

; Set up resource list for plot options.

  res                             = True

  res@gsnAddCyclic                = False
  res@gsnMaximize                 = True

  res@cnLevelSelectionMode        = "ExplicitLevels"
  res@cnLevels                    = (/4.4, 4.55, 4.7, 4.85, 5.0, 5.15, 5.3/)

  res@cnLinesOn                   = False  ; Turn off contour lines

  res@cnFillOn                    = True   ; Turn on contour fill
;  res@cnFillPalette               = cmap( (/44,78,100,130,176,188,203,237/),: )
  res@cnFillPalette               = cmap( (/42,76,98,128,174,186,201,235/),: )

  res@cnFillDrawOrder             = "PreDraw"  ; Make sure map fill happens
                                               ; last.

  res@lbOrientation               = "vertical"  ; default is horizontal

  res@mpDataBaseVersion           = "MediumRes"
  res@mpDataSetName               = "Earth..2"   ; For counties

; Zoom in on Wisconsin, United States
  res@mpMaxLatF                   = max(lat)
  res@mpMaxLonF                   = max(lon)
  res@mpMinLatF                   = min(lat)
  res@mpMinLonF                   = min(lon)
  res@mpCenterLonF                = avg(lon)

;
; Specify which areas to fill, and what to fill them with. This allows
; us to make sure Wisconsin is not filled (transparent).
;
  res@mpFillAreaSpecifiers        = (/"Land", "Wisconsin:counties","Water"/)
  res@mpSpecifiedFillColors       = (/"white","transparent",       "white"/)

  res@mpInlandWaterFillColor      = "white"
  res@mpLandFillColor             = "transparent"

  res@mpOutlineOn                 = True

  res@mpUSStateLineThicknessF     = 2.5  ; 2-1/2 times as thick.
  res@mpGeophysicalLineThicknessF = 2.5

  res@mpOutlineBoundarySets       = "GeophysicalAndUSStates"
  res@mpOutlineSpecifiers         = (/"Land","Wisconsin:counties"/)
  res@mpMaskOutlineSpecifiers     = (/"water"/)

  res@pmTickMarkDisplayMode       = "always"          ; nicer tick mark labels

  res@tiMainString                = "Change in Temperature"
  res@tiMainFontHeightF           =  0.035

  res@tmXTOn                      = False  ; Turn off top and right
  res@tmYROn                      = False  ; tickmarks.

  plot = gsn_csm_contour_map(wks,var, res)

end
