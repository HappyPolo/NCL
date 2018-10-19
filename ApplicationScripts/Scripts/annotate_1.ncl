;*************************************************
; annotate_1.ncl
;
; Concepts illustrated:
;   - Adding a map to another map as an annotation
;   - Drawing a map using the high resolution map outlines
;   - Drawing a map using the medium resolution map outlines
;   - Attaching a plot as an annotation of another plot
;   - Resizing a plot
;
;************************************************
;
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"   

begin
  min_lat =  2.0
  max_lat = 14.5
  min_lon =  8.0
  max_lon = 16.25

  wks  = gsn_open_wks("png", "annotate")  ; send graphics to PNG file

;
; Set some resources for the base map plot.
  res                   = True

; Generic stuff. 
  res@gsnMaximize       = True
  res@gsnFrame          = False
  res@gsnDraw           = False

; Map stuff
;
; Note: in order to use the high-resolution coastal database
; (mpDataBaseVersion = "HighRes"), you must download and install RANGS
; (Regionally Accessible Nested Global Shorelines), the multi-resolution
; coastline database, developed by Rainer Feistel from Wessel and
; Smith's GSHHS (Global Self-consistent Hierarchical High-resolution
; Shoreline) database. For more information, visit:
;
;    http://www.ncl.ucar.edu/Document/Graphics/rangs.shtml
;
; If you don't have this database, or don't want to install it, 
; change this resource value to "MediumRes".
;
  res@mpDataBaseVersion ="HighRes"
  res@mpFillOn          = False

  res@mpMinLatF         = min_lat
  res@mpMaxLatF         = max_lat
  res@mpMinLonF         = min_lon
  res@mpMaxLonF         = max_lon

  base_map = gsn_csm_map_ce(wks,res)

; Resources for a second smaller map.
  mpres                   = True

  mpres@gsnFrame          = False
  mpres@gsnDraw           = False

; Tickmark stuff
  mpres@pmTickMarkDisplayMode = "Always"
  mpres@tmXBLabelFontHeightF  = 0.01

; Map stuff
  mpres@mpDataBaseVersion  ="MediumRes"
  mpres@mpOutlineOn       = True
  mpres@mpMinLatF         = -35.0
  mpres@mpMaxLatF         =  35.0
  mpres@mpMinLonF         = -20.0
  mpres@mpMaxLonF         =  50.0
 
; Width/height
  mpres@vpHeightF         = 0.2    ; Make this second map much smaller.
  mpres@vpWidthF          = 0.2

  map2 = gsn_csm_map_ce(wks,mpres)

;
; Set up some resources to indicate where the smaller map
; will be (upper left edge of plot).
;
  amres                  = True
  amres@amParallelPosF   = -0.4    ; -0.5 is the left edge of the plot.
  amres@amOrthogonalPosF = -0.45   ; -0.5 is the top edge of the plot.
  amres@amJust           = "TopLeft"

  map_anno = gsn_add_annotation(base_map, map2, amres)  ; Attach map to map.

;
; "map2" is now attached to "base_map", so drawing "base_map" will cause
; both maps to be drawn.
;
  draw(base_map)
  frame(wks)
end


