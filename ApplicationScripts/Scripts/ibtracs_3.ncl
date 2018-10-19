;**********************************************************
;ibtracs_3.ncl
;IBTRACS: Storm Cyclogenesis 
;**********************************************************
;
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"

;**********************************************************

f = addfile("Basin.NI.ibtracs_all.v03r04.nc","r")
lat = short2flt(f->lat_for_mapping)
lon = short2flt(f->lon_for_mapping)

;---Using "newps" gives us better looking results with the grid lines.
  wks  = gsn_open_wks ("png", "ibtracs")        ; send graphics to PNG file

res                        = True               ; plot mods desired
res@gsnMaximize            = True
res@gsnFrame               = False
res@gsnDraw                = False

;
; You need the RANGS/GSHHS database to use HighRes:
;   http://www.ncl.ucar.edu/Document/Graphics/rangs.shtml
; Change to "MediumRes" or the default "LowRes" if you don't have the HighRes database.
;
;res@mpDataBaseVersion      = "MediumRes"
res@mpGridAndLimbOn        = True
res@pmTickMarkDisplayMode  = "Always"           ; turn on tickmarks
res@mpGridAndLimbDrawOrder = "PreDraw"          ; Draw grid before
                                                  ; map outlines
res@mpMinLatF              =  0
res@mpMaxLatF              =  28
res@mpMinLonF              =  50
res@mpMaxLonF              = 100

res@mpGridSpacingF         = 2.5
res@mpGridLineThicknessF   = 2.0
res@mpGridLineColor        = "Gray30"

  res@tiMainString           = "Location of Cyclogenesis over North Indian Ocean"
;---Create map with thin, gray lat/lon lines
  map_thin = gsn_csm_map(wks,res)

  res@mpGridSpacingF         = 10
  res@mpGridLineThicknessF   = 3.0
  res@mpGridLineColor        = "black"

;---Create map with thicker, black lat/lon lines
  map_thick = gsn_csm_map(wks,res)
;add polymarkers to plot
; first define markers setting with logical variable pmres
  pmres = True
  pmres@gsMarkerIndex = 16
  pmres@gsMarkerColor = "red"

; NOTE the (:,0), this is for the initial time only

  points = gsn_add_polymarker(wks,map_thin,lon(:,0),lat(:,0),pmres)

; If you don't set any annotation resources, then adding one
; plot as an annotation of another will simply make them
; both the same size.

  annoid = gsn_add_annotation(map_thin,map_thick,False)

  draw(map_thin)    ; Both maps will get drawn.
  frame(wks)

