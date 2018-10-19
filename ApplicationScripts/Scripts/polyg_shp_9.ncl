;======================================================================
; polyg_shp_9.ncl
;
; Concepts illustrated:
;   - Drawing the meteorological subdivisions of India using a shapefile
;   - Drawing the outlines of India using a shapefile
;   - Paneling two plots on a page
;   - Attaching polylines to a map plot
;   - Attaching filled polygons to a map plot
;   - Changing the color and thickness of polylines
;   - Zooming in on India on a cylindrical equidistant map
;======================================================================
; This example is similar to polyg_9.ncl, except a shapefile is used 
; to plot the meteorological subdivisions of India using a shapefile.
; The "indian_met_zones v2.shp" shapefile was found on the web by googling
; "Meteorological Subdivisions of India shapefile". The IND_adm2.shp
; shapefile can be downloaded from gadm.org/country, which provides
; outlines for many countries.
;======================================================================
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"

begin
     wks  = gsn_open_wks("png","polyg_shp")
     gsn_define_colormap(wks,"amwg")

     res                         = True
     res@mpFillOn                = False
     res@mpOutlineOn             = False    ; will add our own outlines
     res@mpMaxLatF               = 38
     res@mpMinLatF               = 6
     res@mpMaxLonF               = 100
     res@mpMinLonF               = 65
     res@gsnFrame                = False
     res@gsnDraw                 = False
     res@gsnMaximize             = True
     res@pmTickMarkDisplayMode   = "Always"    ; better tickmarks

     plot    = new(2,graphic)
     plot(0) = gsn_csm_map(wks,res)             ; create blank map for met division outlines
     plot(1) = gsn_csm_map(wks,res)  		; create blank map for met division filling

;---Attach outlines from two different shapefiles
     lnres                  = True
     lnres@gsLineColor      = "Red"
     lnres@gsLineThicknessF = 3.0
     ind_met1 = gsn_add_shapefile_polylines(wks,plot(0),"indian_met_zones.v2.shp",lnres)
     ind_met2 = gsn_add_shapefile_polygons(wks,plot(1), "indian_met_zones.v2.shp",lnres)

     lnres@gsLineThicknessF = 1.0
     lnres@gsLineColor      = "Black"
     ind_adm1 = gsn_add_shapefile_polylines(wks,plot(0),"IND_adm1.shp",lnres)
     ind_adm2 = gsn_add_shapefile_polylines(wks,plot(1),"IND_adm1.shp",lnres)

;---Panel both plots
     resP              = True
     resP@gsnMaximize  = True
     resP@txString     = "India meteorological subdivisions and map outlines from shapefiles"
     gsn_panel(wks,plot,(/1,2/),resP)
end
