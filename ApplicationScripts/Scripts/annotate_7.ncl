;********************************************************
; annotate_7.ncl
;
; Concepts illustrated:
;   - Attaching two smaller map plots to the outside of a larger map
;   - Drawing lines between plots
;   - Maximizing plots after they've been created
;   - Resizing a plot
;   - Zooming in on Australia on a cylindrical equidistant map
;   - Drawing polylines in NDC space
;   - Drawing polymarkers in lat/lon space
;   - Converting lat/lon values to NDC values
;*************************************************
;
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"

begin
;---Start the graphics
  wks = gsn_open_wks("png","annotate") ; send graphics to PNG file

;---Resources for map plot
  mpres             = True
  mpres@gsnDraw     = False
  mpres@gsnFrame    = False

  mpres@vpWidthF      = 0.35   ; Make plots small enough to fit in 
  mpres@vpHeightF     = 0.35   ; unit square. Aspect ratio is preserved.

  mpres@mpDataBaseVersion = "Mediumres"  ; Medium resolution
  mpres@mpDataSetName     = "Earth..4"   ; Contains divisions for
                                         ; other countries.
  mpres@mpOutlineBoundarySets = "AllBoundaries"

  mpres@mpMinLatF             = -45
  mpres@mpMaxLatF             =  -6
  mpres@mpMinLonF             = 110
  mpres@mpMaxLonF             = 155

  mpres@pmTickMarkDisplayMode = "Always"   ; "nice" tickmarks

;---Create "big" map plot
  base_map = gsn_csm_map_ce(wks,mpres)

;---Set some resources for the smaller map plots
  mpres@vpWidthF             = 0.2      ; Make sub plots even smaller
  mpres@vpHeightF            = 0.2
  mpres@tmXBLabelFontHeightF = 0.005    ; Make tickmark labels smaller
  mpres@tmYLLabelFontHeightF = 0.005

;---Zoom in on southeast Australia
  mpres@mpMinLatF             = -40
  mpres@mpMaxLatF             = -30
  mpres@mpMinLonF             = 140
  mpres@mpMaxLonF             = 152

  map_se = gsn_csm_map_ce(wks,mpres)    ; Create map of SE Australia

;---Zoom in on southwest Australia
  mpres@mpMinLatF             = -36
  mpres@mpMaxLatF             = -30
  mpres@mpMinLonF             = 114
  mpres@mpMaxLonF             = 120

  map_sw = gsn_csm_map_ce(wks,mpres)    ; Create map of SW Australia

;---Resources for adding map_se/map_sw to base_map.
  amres                   = True
  amres@amJust            = "CenterLeft"

;---Attach SE map plot
  amres@amParallelPosF    = -1.23    ; Left side
  amres@amOrthogonalPosF  = -0.4     ; Almost halfway up
  amid1 = gsn_add_annotation(base_map,map_se,amres)


;---Attach SW map plot
  amres@amOrthogonalPosF =  0.4   ; Almost halfway down
  amid2 = gsn_add_annotation(base_map,map_sw,amres)

  draw(base_map)
;
; "maximize_output" will resize graphics to maximize them
; on the page. This only works for PDF/PS output. 
;
; Do this before we draw the markers and lines in NDC space.
;
; pres             = True
; pres@gsnMaximize = True
; pres@gsnFrame    = False
; maximize_output(wks,pres)

;---Resource lists for polylines and polymarkers
  lnres                  = True
  mkres                  = True

  lnres@gsLineThicknessF = 1.5  ; default is 1.5
  lnres@gsLineColor      = "red"
  mkres@gsMarkerIndex    = 16   ; filled dot

;---Variables to hold NDC coordinate values that we have to calculate.
  xndc_beg = new(1,float)
  yndc_beg = new(1,float)
  xndc_end = new(1,float)
  yndc_end = new(1,float)

;---Midpoint location for southwest plot
  xlat = -32.
  xlon = 117.

;---Convert lon/lat to X/Y NDC coordinates
  datatondc(map_sw,   xlon, xlat, xndc_beg, yndc_beg)
  datatondc(base_map, xlon, xlat, xndc_end, yndc_end)

;---Draw line in NDC space, and markers in lat/lon space
  gsn_polyline_ndc(wks,  (/xndc_beg,xndc_end/),(/yndc_beg,yndc_end/),lnres)
  gsn_polymarker(wks,base_map,xlon,xlat,mkres)
  gsn_polymarker(wks,map_sw,  xlon,xlat,mkres)

;---Midpoint location for southeast plot
  xlat = -35.
  xlon = 146.

;---Convert lon/lat to X/Y NDC coordinates
  datatondc(map_se,   xlon, xlat, xndc_beg, yndc_beg)
  datatondc(base_map, xlon, xlat, xndc_end, yndc_end)

;---Draw line in NDC space, and markers in lat/lon space
  gsn_polyline_ndc(wks,  (/xndc_beg,xndc_end/),(/yndc_beg,yndc_end/),lnres)
  gsn_polymarker(wks,base_map,xlon,xlat,mkres)
  gsn_polymarker(wks,map_se,  xlon,xlat,mkres)

  frame(wks)     ; Advance the frame
end

