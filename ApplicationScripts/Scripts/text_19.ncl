;----------------------------------------------------------------------
; text_19.ncl
;
; Concepts illustrated:
;   - Drawing text strings on a map that follow the curve of lat/lon line
;   - Changing the center latitude and longitude for an orthographic projection
;   - Drawing markers, text, lines, and filled polygons on a map
;----------------------------------------------------------------------
; NOTE: we discovered a bug in NCL that causes this script not to work
; with NCL versions 6.2.0, 6.2.1, or 6.3.0. We have a ticket on this
; (NCL-2262), and hope to fix it for version 6.4.0.
;----------------------------------------------------------------------
;
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"

begin
  wks = gsn_open_wks("png","text")

;---Resources for the map
  res                  = True
  res@gsnMaximize      = True
  res@gsnFrame         = False            ; don't advance frame
  res@mpProjection     = "orthographic"

;---Change rotation of map
  res@mpCenterLatF     = 30.
  res@mpCenterLonF     = 160.
  res@mpCenterRotF     = 60.
  res@mpPerimOn        = False     ; remove rectangular boundary around plot

  plot = gsn_csm_map(wks,res)      ; Draw the map, but don't advance frame yet

;---Resource list for markers, lines, and polygons
  gsres                        = True
  gsres@gsLineColor            = "black" 
  gsres@gsLineThicknessF       = 2.0
  gsres@gsLineLabelFontHeightF = 0.02
  gsres@gsLineLabelFontColor   = "black"  ; the default

  gsres@gsMarkerIndex          = 15     ; circle with an "x"
  gsres@gsMarkerSizeF          = 0.02
  gsres@gsMarkerThicknessF     = 2.0    ; double thick circle and x outline
;
; Draw polygons representing the 5 major zones of the globe, beginning
; with the tropical zone.
; Turn edges off and set the marker color.
;
  gsres@gsMarkerColor = "black"   ; black is the default

  pxp = (/360.,360.,0.,0.,360./)
  pyp = (/-23.5,23.5,23.5,-23.5,-23.5/)

  gsres@gsFillColor = "green"
  gsn_polygon(wks,plot,pxp,pyp,gsres)

;---Draw the north and south temperate zones
  gsres@gsFillColor   = "red"
  py := (/ 23.5 , 66.5 , 66.5 , 23.5 , 23.5/)
  px := (/ 360. , 360. , 0. , 0. , 360./)

  gsn_polygon(wks,plot,px,py,gsres)

  py = (/ -23.5 , -66.5 , -66.5 , -23.5 , -23.5 /)
  px = (/ 360. , 360. ,  0. , 0.  , 360. /)
  gsn_polygon(wks,plot,px,py,gsres)

;---Draw the frigid zones
  gsres@gsFillColor = "lightblue"
  py = (/ 90. , 66.5 , 66.5 , 90. , 90. /)
  px = (/ 360.  , 360. , 0. , 0. , 360. /)
  gsn_polygon(wks,plot,px,py,gsres)

  py = (/ -90. , -66.5 , -66.5 , -90. , -90./)
  px = (/ 360. , 360.  , 0.    , 0.   , 360./)
  gsn_polygon(wks,plot,px,py,gsres)

;---Draw markers at each pole
  px(0:1) = 0.
  py(0:1) = (/90., -90./)
  gsn_polymarker(wks,plot,px(:1),py(:1),gsres)

;
; Draw polylines at each of the major latitudinal boundary lines,
; beginning with the equator. Use the line label to name each of the
; lines. The '|' character is inserted between each label character 
; to allow the labels to track the curve of each line more precisely.
;
  gsres@gsLineLabelString = "e|q|u|a|t|o|r"

  px(0:2) = (/360.,180.,0/)
  py(0:2) = 0.
  gsn_polyline(wks,plot,px(:2),py(:2),gsres)

;---Tropic of cancer
  gsres@gsLineLabelString = "t|r|o|p|i|c o|f c|a|n|c|e|r"

  px(0:2) = (/360., 180, 0./)
  py(0:2) = 23.5
  gsn_polyline(wks,plot,px(:2),py(:2),gsres)

;
; Tropic of capricorn (Note: currently there is a limit on the 
; number of characters in a line label that prevents the '|'
; character from being used between each letter in a label 
; of this length).
;
  gsres@gsLineLabelString = "tr|o|p|ic of c|a|p|r|i|c|o|rn"

  py(0:2) = -23.5
  gsn_polyline(wks,plot,px(:2),py(:2),gsres)

;---Arctic circle
  gsres@gsLineLabelString = "a|r|c|t|i|c c|i|r|c|l|e"
  py(0:2) = 66.5
  gsn_polyline(wks,plot,px(:2),py(:2),gsres)

;---Antarctic circle
  gsres@gsLineLabelString = "|a|n|t|a|r|c|t|i|c c|i|r|c|l|e"

  py(0:2) = -66.5
  gsn_polyline(wks,plot,px(:2),py(:2),gsres)

  frame(wks)
end

