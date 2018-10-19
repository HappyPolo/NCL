;********************************************************
; annotate_6.ncl
;
; Concepts illustrated:
;   - Attaching two XY plots to the outside of a map
;   - Maximizing plots after they've been created
;   - Resizing a plot
;   - Zooming in on Australia on a cylindrical equidistant map
;
;*************************************************
;
; These files are loaded in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"

begin
;---Generate some dummy XY data
  NPTS  = 500
  PI100 = 0.031415926535898
  EXP   = 2.7182818
  theta = PI100*ispan(0,NPTS-1,1)
  y1    = sin(theta)
  y2    = sin(theta * theta)

;---Start the graphics
  wks = gsn_open_wks("png","annotate") ; send graphics to PNG file

;---Resources for map plot
  mpres             = True
  mpres@gsnDraw     = False
  mpres@gsnFrame    = False

  mpres@vpWidthF      = 0.4   ; Make plots small enough to fit in 
  mpres@vpHeightF     = 0.4   ; unit square. Aspect ratio is preserved.

  mpres@mpDataBaseVersion = "Mediumres"  ; Medium resolution
  mpres@mpDataSetName     = "Earth..4"   ; Contains divisions for
                                       ; other countries.
  mpres@mpOutlineBoundarySets = "AllBoundaries"

  mpres@mpMinLatF             = -45
  mpres@mpMaxLatF             =  -6
  mpres@mpMinLonF             = 110
  mpres@mpMaxLonF             = 155

  mpres@tiMainString          = "Medium resolution map of Australia"

;---Create map plot
  base_map = gsn_csm_map_ce(wks,mpres)

;---Resources for XY plot
  xyres               = True
  xyres@gsnDraw       = False
  xyres@gsnFrame      = False

  xyres@vpWidthF      = 0.2   ; Make plots small enough to fit in 
  xyres@vpHeightF     = 0.2   ; unit square. We will resize later.

  xyres@xyLineColor   = "Brown"
  xyres@tiMainString  = "xy1 plot"

;---Create first XY plot
  xy1 = gsn_csm_y(wks,y1,xyres)

  xyres@xyLineColor   = "Orange"
  xyres@tiMainString  = "xy2 plot"

;---Create second XY plot
  xy2 = gsn_csm_y(wks,y2,xyres)

;---Resources for adding xy1/xy2 to base_map.
  amres                   = True
  amres@amJust            = "CenterLeft"

  amres@amParallelPosF    = -1.15  ; Left side
  amres@amOrthogonalPosF  = -0.4   ; Almost halfway up

;---Attach first XY plot
  amid1 = gsn_add_annotation(base_map,xy1,amres)

  amres@amOrthogonalPosF  =  0.4   ; Almost halfway down

;---Attach second XY plot
  amid2 = gsn_add_annotation(base_map,xy2,amres)

;---This will draw everything, but it won't be maximized in frame.
   draw(base_map)
   frame(wks)

;
; maximize_output will resize graphics to maximize them
; on the page. This only works for PDF/PS output. 
;
;  pres             = True
;  pres@gsnMaximize = True
;  maximize_output(wks,pres)
end

