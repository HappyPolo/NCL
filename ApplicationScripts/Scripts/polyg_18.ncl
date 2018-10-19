;----------------------------------------------------------------------
; polyg_18.ncl
;
; Concepts illustrated:
;   - Adding lines, markers, and polygons to a map
;   - Using drawNDCGrid to draw a nicely labeled NDC grid
;   - Using "unique_string" to generate unique ids for primitives
;   - Drawing lines, markers, polygons, and text in NDC space
;-----------------------------------------------------------------
;  This example is a variation of a script written by Karin 
;  Meier-Fleischer of DKRZ, who wrote it as part of the NCL 
;  Tutorial.
;-----------------------------------------------------------------
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl"

begin
  wks = gsn_open_wks("png","polyg")

;-- set resources
  res                       =  True  
  res@gsnDraw               =  False        ;-- don't draw the plot yet
  res@gsnFrame              =  False        ;-- don't advance the frame yet
  res@mpFillOn              =  True
  
  map = gsn_csm_map(wks,res)      ;-- create the map, but don't draw it yet

;-- polyline
  x = (/ 6.,  15.,  15.,   6.,   6./)
  y = (/47.5, 47.5, 54.5, 54.5, 47.5/)
  
;-- polyline resources
  plres                        =  True
  plres@gsLineThicknessF       =  2.0        ;-- set line thickness
  plres@gsLineColor            = "red"       ;-- set line color
  box_1 = gsn_add_polyline(wks, map, x, y, plres)  ;-- add polyline to map

;-- define polygon x- and y-arrays
  x = (/110., 160., 160., 110., 110./)
  y = (/-45., -45., -10., -10., -45./)
  
;-- polygon resources
  pgres                        =  True
  pgres@gsFillColor            = "green"      ;-- fill color
  pgres@gsFillOpacityF         =  0.3         ;-- set opacity of polygon
  gon_1 = gsn_add_polygon(wks, map, x, y, pgres)
                                              ;-- add filled polygon to map

;-- polymarker resources
  pmres                        =  True
  pmres@gsMarkerColor          = "blue"       ;-- marker color
  pmres@gsMarkerSizeF          =  0.03        ;-- set size of marker
  pmres@gsLineThicknessF       =  3.          ;-- marker line thickness

;-- draw all 16 markers on map using unique identifier name
;-- and additional map attribute settings
  x = -160.                                 ;-- x-position of first marker
  y =  -80.                                 ;-- y-position of first marker
  do i = 0,15                                      ;-- 16 different marker
     pmres@gsMarkerIndex = i+1
     str = unique_string("poly")            ;-- result is poly0-poly15
     map@$str$ = gsn_add_polymarker(wks, map, x+(i*20.), y+(i*10.), pmres) 
                                            ;-- add marker to map
  end do
  
;-- print map contents to see how unique_string works with map@$str$
;  print(map)

;-- draw the plot, draw an NDC grid, and advance the frame
  draw(map)
  drawNDCGrid(wks)
  frame(wks)

;-- write strings at the bottom of the plot
  txres               =  True
  txres@txFontHeightF =  0.014         ;-- default size is HUGE!

  xndc = 0.1
  yndc = 0.22
  txres@txFontColor   = "blue"
  txres@txJust        = "TopLeft"
  gsn_text_ndc(wks,"Marker (left justified text)", 0.1, yndc, txres)
  gsn_polymarker_ndc(wks,0.2,yndc-0.06,pmres)

  xndc = 0.5
  txres@txJust        = "TopCenter"
  txres@txFontColor   = "red"
  gsn_text_ndc(wks,"Polyline (centered text)",        xndc, yndc, txres)
  gsn_polyline_ndc(wks,(/xndc-0.1,xndc+0.1/),(/yndc-0.06,yndc-0.06/),plres)

  xndc = 0.9
  txres@txJust        = "TopRight"
  txres@txFontColor   = "forestgreen"
  gsn_text_ndc(wks,"Polygon (right justified text)", xndc, yndc, txres)
  gsn_polygon_ndc(wks,(/xndc,xndc-0.2,xndc-0.2,xndc,xndc/),\
                      (/yndc-0.04,yndc-0.04,yndc-0.08,yndc-0.08,yndc-0.04/),\
                      pgres)

;-- write big string at the top of the plot
  txres@txJust        = "BottomCenter"
  txres@txFontHeightF = 0.03
  txres@txFont        = "Helvetica-bold"
  txres@txFontColor   = "Black"
  gsn_text_ndc(wks,"Big centered title", 0.5, 0.72, txres)

  draw(map)
  frame(wks)
end

