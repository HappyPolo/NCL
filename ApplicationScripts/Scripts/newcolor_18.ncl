;----------------------------------------------------------------------
; newcolor_18.ncl
;
; Concepts illustrated:
;   - Drawing partially transparent filled contours using two methods
;   - Having the labelbar reflect partially transparent contours
;   - Using span_color_rgba function to span a colormap
;----------------------------------------------------------------------
; This example shows a work-around for getting the labelbar to
; display the same transparency as the filled contours.  This is only
; an issue in NCL V6.3.0 or earlier, when "cnFillOpacityF" is used
; to set the opacity. This bug was fixed in NCL V6.4.0.
;
; If you have NCL 6.4.0 or greater and you do not want the labelbar 
; to show any transparency, then set res@lbOverrideFillOpacity = True.
;
; The work-aroud is to set cnFillPalette with an RGBA array, where the
; "A" part of the array is set to the desired opacity. This will 
; automatically affect the labelbar.
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
;---Open file and read data.
  in    = addfile("80.nc","r")
  TS    = in->TS(0,:,:)

  colormap = "GMT_hot"    ; Desired color map to use

;---Desired contour levels
  levels  = (/232.7,234.2,238,240,244,248.4,252, \
              258.3,276,286.5,292.1,300,306/)
  nlevels = dimsizes(levels)

  wks = gsn_open_wks("png","newcolor")          ; send graphics to PNG file

  res                      = True               ; plot mods desired
  res@gsnMaximize          = True               ; maximize plot on page

  res@cnFillOn             = True               ; turn on color fill
  res@cnLinesOn            = False              ; turn off contour lines
  res@cnFillPalette        = colormap

  res@cnLevelSelectionMode = "ExplicitLevels"   ; set explicit contour levels
  res@cnLevels             = levels

;---Draw fully opaque plot
  res@tiMainString         = "Fully opaque contours"
  plot = gsn_csm_contour_map_ce(wks,TS, res)   ; create plot

;---Draw fully opaque plot using cnFillOpacityF
  res@tiMainString         = "Partially opaque contours via cnFillOpacityF"
  res@cnFillOpacityF       = 0.5
  plot = gsn_csm_contour_map_ce(wks,TS, res)   ; create plot


;---Draw partially opaque plot using cnFillColors
  delete(res@cnFillOpacityF)
;
; Given the # of desired colors and a color map, return an 
; RGBA array that spans the color map.
;
  colors =  span_color_rgba (colormap,nlevels+1)
  colors(:,3) = 0.5   ; Set the same opacity for all contours

  res@cnFillPalette := colors
  res@tiMainString = "Partially opaque contours via RGBA array"
  plot = gsn_csm_contour_map_ce(wks,TS, res)   ; create plot

end
