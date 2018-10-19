;----------------------------------------------------------------------
; France_3.ncl
;
; Concepts illustrated:
;   - Reading shapefiles
;   - Plotting data from shapefiles
;   - Using shapefile data to fill various boundaries for France
;   - Using special "gsSegments" resource for faster primitive draws
;   - Using special "gsColors" resource to specify an array of polygon colors
;----------------------------------------------------------------------
; The purpose of this script is to demonstrate the speed-up of
; attaching shapefile polylines to an existing NCL map, using NCL
; V6.2.0.
;
; This script uses gsn_add_polygon,  and the "gsSegments" and
; "gsColors" resources added in NCL V6.2.0 and higher.
;----------------------------------------------------------------------
; The "FRA_adm1.shp" shapefile was downloaded from 
; http://www.gadm.org/country/
;----------------------------------------------------------------------
;
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"

begin
  shapefile_name = "./FRA_adm1.shp"
  colors = (/"antiquewhite3","brown3","navyblue","orange",\
             "cadetblue2","tan1","forestgreen","royalblue",\
             "darkslategray4","sandybrown","plum3","lemonchiffon",\
             "palegreen","khaki3","slateblue4","yellow","violetred",\
             "wheat1","purple","mediumspringgreen","peachpuff2",\
             "orchid4"/)

  wks = gsn_open_wks("png","France")  ; send graphics to PNG file

  res              = True    ; Set some plot options

  res@gsnMaximize  = True     ; maximize plot in frame
  res@gsnDraw      = False
  res@gsnFrame     = False

  res@mpMinLatF    = 41
  res@mpMaxLatF    = 51.1
  res@mpMinLonF    = -5.15
  res@mpMaxLonF    = 9.6

  res@mpFillOn     = False             ; Turn off gray-filled land
  res@mpOutlineOn  = False             ; Turn off map outlines

  res@pmTickMarkDisplayMode = "Always" ; nicer tickmarks

;---Set some options for the polylines
  lnres                   = True         
  lnres@gsLineThicknessF  = 2.0          ; default is 1.0
  lnres@gsLineColor       = "NavyBlue"   ; default is black

;---Create the map
  res@tiMainString = shapefile_name    ; Main title
  plot = gsn_csm_map(wks,res)

;---Open shapefile
  f = addfile(shapefile_name,"r")
  dims = getfilevardimsizes(f,"geometry")

;---Attach the France filled polygons
  lnres@gsSegments = f->segments(:,0)
  lnres@gsColors   = colors

  id = gsn_add_polygon(wks, plot, f->x, f->y, lnres)

;---Draw everything
  draw(plot)
  frame(wks)
end
