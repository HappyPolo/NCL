;----------------------------------------------------------------------
; shapefiles_14.ncl
;
; Concepts illustrated:
;   - Reading shapefiles
;   - Adding shapefile outlines to an existing WRF contour/map plot
;----------------------------------------------------------------------
; This example shows how to add shapefile outlines to a WRF map.
; See shapefiles_14_mask.ncl for an example of using shapefile outlines
; to mask data.
;
; The "USA_adm2.shp" shapefile was downloaded from 
; http://www.gadm.org/country/
;----------------------------------------------------------------------
;
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/wrf/WRFUserARW.ncl"

begin
  filename = "wrfout_d01_2002-07.nc"
  a        = addfile(filename,"r")

  ter = a->HGT(0,:,:)                        ; Read the variable to memory

  wks = gsn_open_wks("png","shapefiles")     ; send graphics to PNG file

  res                   = True               ; Contour options
  res@cnFillOn          = True               ; Create a color fill plot
  res@cnFillPalette     = "OceanLakeLandSnow"; set color map
  res@ContourParameters = (/1,1100,20/)      ; Contour levels

  contour = wrf_contour(a,wks,ter,res)       ; Create contour plot

  pltres            = True   ; Basic overlay plot options
  pltres@PanelPlot  = True   ; Tells wrf_map_overlays not to remove overlays

  mpres             = True   ; Set map options
  mpres@mpOutlineOn = False  ; Turn off map outlines
  mpres@mpFillOn    = False  ; Turn off map fill

;---Create the contours over the WRF map (nothing will be drawn yet).
  plot = wrf_map_overlays(a,wks,contour,pltres,mpres) 

;---Attach the shapefile polylines using files read off gadm.org/country.
  usa_shp_name    = "USA_adm/USA_adm2.shp"
  canada_shp_name = "CAN_adm/CAN_adm2.shp"

  lnres                  = True
  lnres@gsLineColor      = "gray25"
  lnres@gsLineThicknessF = 0.5   

  usa_id = gsn_add_shapefile_polylines(wks,plot,usa_shp_name,lnres)
  can_id = gsn_add_shapefile_polylines(wks,plot,canada_shp_name,lnres)

  draw(plot)       ; This will draw the map and the shapefile outlines.
  frame(wks)       ; Advance the frame

end
