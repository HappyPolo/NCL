;----------------------------------------------------------------------
; newcolor_15.ncl
;
; Concepts illustrated:
;   - Selecting a different color map
;   - Explicitly setting contour levels to uneven levels
;   - Changing the center longitude for a cylindrical equidistant projection
;   - Turning off contour lines
;   - Spanning the full color map for contour fill
;   - Spanning part of a color map for contour fill
;----------------------------------------------------------------------
;
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl" 
;
; This file still has to be loaded manually
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl" 

begin
;---Read the file
  in    = addfile("80.nc","r")
  TS    = in->TS

;---Create plot
  wks = gsn_open_wks("png","newcolor")          ; send graphics to PNG file

  res                      = True               ; plot mods desired
  res@gsnMaximize          = True               ; maximize plot on page

  res@cnFillOn             = True               ; turn on color fill
  res@cnLinesOn            = False              ; turn off contour lines

  res@lbOrientation        = "vertical"         ; vertical label bars

  res@cnLevelSelectionMode = "ExplicitLevels"   ; set explicit contour levels
  res@cnLevels            = (/232.7,234.2,238,240,244,248.4,252,\
                              258.3,276,286.5,292.1,300,306/)

  res@mpFillOn             = False              ; turn off gray continents
  res@mpCenterLonF         = 180                ; Centers the plot at 180 

  res@cnFillPalette        = "BlueYellowRed"
  res@tiMainString         = "Full colormap spanned"
  plot = gsn_csm_contour_map_ce(wks,TS(0,:,:), res)   ; create plot

  res@cnSpanFillPalette    = False
  res@tiMainString         = "Colormap not spanned"
  plot = gsn_csm_contour_map_ce(wks,TS(0,:,:), res)   ; create plot

;---Read in the color map so we can subset it
  delete(res@cnFillPalette)

  cmap = read_colormap_file("BlueYellowRed")
  res@cnFillPalette        = cmap(129:247,:)      ; Grab the yellow/red parts of the color map

  res@cnSpanFillPalette    = True
  res@tiMainString         = "'Red/Yellow' subset of color map spanned"
  plot = gsn_csm_contour_map_ce(wks,TS(0,:,:), res)   ; create plot
  
end
