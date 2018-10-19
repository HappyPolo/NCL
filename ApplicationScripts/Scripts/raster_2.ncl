;***********************************************
; raster_2.ncl
;
; Concepts illustrated:
;   - Drawing raster contours over a polar stereographic map
;   - Drawing map outlines in white
;
;************************************************
;
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl" 
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
;
; This file still has to be loaded manually
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl"
;************************************************
begin
;************************************************
; open and read
;************************************************
  a = addfile("jun13_world_n2o_stream.nc","r")
  N2O = a->N2O
;************************************************
; the units attribute of the coordinate variables
; must be degrees_north and degrees_east for the
; gsn_csm templates.
;************************************************
  N2O&latitude@units  = "degrees_north"         
  N2O&longitude@units = "degrees_east"
;************************************************
; create plot
;************************************************
  wks = gsn_open_wks("png","raster")         ; send graphics to PNG file


  res                     = True             ; Use plot options
  res@cnFillOn            = True             ; Turn on color fill
  res@cnFillMode          = "RasterFill"     ; Turn on raster color
  res@cnLinesOn           = False            ; Turn off contourn lines
  res@cnFillPalette       = "wgne15"         ; choose colormap

  res@cnLevelSelectionMode = "ManualLevels"    ; Manual contour invtervals
  res@cnMinLevelValF       = 306.              ; Min level
  res@cnMaxLevelValF       = 312.              ; Max level
  res@cnLevelSpacingF      = 0.5               ; interval

  res@mpFillOn                    = False          ; turn off gray continents
  res@mpMaxLatF                   = -30.           ; set max lat
  res@mpGeophysicalLineColor      = "white"        ; color of outlines
  res@mpGeophysicalLineThicknessF = 2              ; line thickness
  res@gsnPolarSH                  = True           ; Select southern hemisphere

  res@tiMainString                = "Mahlman (Science,97)" 

  plot = gsn_csm_contour_map_polar(wks, N2O({-90:-30},:) , res)
end
