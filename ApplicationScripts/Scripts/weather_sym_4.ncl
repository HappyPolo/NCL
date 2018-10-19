;*****************************************
; weather_sym_4.ncl
;
; Concepts illustrated:
;   - Creating dummy data
;   - Setting parameters for weather routines
;   - Drawing weather symbols
;*****************************************
;
; This file is loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"

;
;  Draw a weather front and a couple of "High" symbols
;  on a satellite view map projection.
;
begin

;
;  Create a color map and an X11 workstation.
;
  cmap = (/                      \
            (/ 1., 1., 1. /),    \  ; 0 - White background.
            (/ 0., 0., 0. /),    \  ; 1 - Black foreground.
            (/ 1., 0., 0. /),    \  ; 2 - Red.
            (/ 0., 0., 1. /),    \  ; 3 - Blue.
            (/ 0., 1., 1. /),    \  ; 4 - Cyan.
            (/ 1., 0., 1. /)     \  ; 5 - Magenta.
         /)
  wks = gsn_open_wks("png","weather_sym")  ; send graphics to PNG file
  gsn_define_colormap(wks,cmap)

;
;  Create a satellite view projection.
;
  res  = True
  res@gsnFrame              = False
;
; Define size of map in frame.
;
  res@vpXF                  = 0.06
  res@vpYF                  = 0.90
  res@vpWidthF              = 0.88
  res@vpHeightF             = 0.88
;
; Set some map resources.
;
  res@mpFillOn              = False
  res@mpOutlineBoundarySets = "National"
  res@mpNationalLineColor   = 1
  res@mpGridAndLimbOn       = True
  res@mpCenterLatF          =   40.
  res@mpCenterLonF          = -105.

  map = gsn_map(wks,"Satellite",res)

;
;  Draw a stationary front.
;
  wmsetp("ezf",1)           ; Tell wmap we are using an existing map projection.
  wmsetp("lin",1.0)         ; Line width of front curve.
  wmsetp("fro","stationary"); Specify stationary front.
  wmsetp("cfc",3)           ; Use blue for the triangles.
  wmsetp("wfc",2)           ; Use red for the bumps.
  wmsetp("swi",0.04)        ; Increase the size of the bumps and triangles.
  xlat = (/  20.,   30.,   35.,   40.,  45. , 50./)   ; Latitudes.
  xlon = (/-195., -125., -115., -105., -95., -85./)   ; Longitudes.
  wmdrft(wks, xlat, xlon)   ; Draw front.

;
;  Draw a couple of High symbols.
;
  wmsetp("hib",4)              ; Cyan for background.
  wmsetp("his",1)              ; Black for shadow.
  wmsetp("hic",5)              ; Magenta for bounding circle.
  wmsetp("sht",0.02)           ; Increase size.
  xl = (/  50.,  50./)         ; Latitudes.
  yl = (/-105.,-145./)         ; Longitudes.
  wmlabs(wks, xl, yl, "HI")    ; Draw symbols.
  frame(wks)

end
