;*******************************************
; roms_1.ncl
;
; Concepts illustrated:
;   - Plotting ROMS data
;   - Overlaying contours on a map using two-dimensional lat,lon arrays
;   - Drawing a map using the high resolution map outlines
;
;*******************************************
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"  
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"  
begin
;*******************************************
; the data and the grid info are in two different files
;*******************************************
 grid = addfile ("CGOA_grid_3.nc", "r")
 lat2d  = grid->lat_rho
 lon2d  = grid->lon_rho

 f    = addfile ("ocean_his_005.nc", "r")
 x    = f->zeta

; since roms data has 2D lat/lon coordinates, we need to set these two 
;variables
 x@lat2d=lat2d
 x@lon2d=lon2d
;********************************************
; create plot
;********************************************
 wks  = gsn_open_wks ("ps", "roms")            ; open workstation
 gsn_define_colormap (wks,"testcmap")            ; choose color map

                                          
 res                        = True               ; plot mods desired
 res@cnFillOn               = True               ; color fill  
 res@cnLinesOn              = False              ; no contour lines
 res@cnLineLabelsOn         = False              ; no contour labels
 res@cnFillDrawOrder        = "PreDraw"          ; put continents on top
 res@gsnSpreadColorEnd      = -2                 ; don't use last color
 res@cnInfoLabelOn          = False              ; no contour info label

; The following resources are REQUIRED to properly display
; data zoomed on a lambert conformal grid.  
 
 res@mpProjection        = "LambertConformal"
 res@mpLambertParallel1F = grid->PLAT(0)
 res@mpLambertParallel2F = grid->PLAT(1)
 res@mpLambertMeridianF  = grid->PLONG
 
 res@mpLimitMode         = "Corners"             ; choose range of map
 res@mpLeftCornerLatF    = grid->P1
 res@mpLeftCornerLonF    = grid->P2
 res@mpRightCornerLatF   = grid->P3
 res@mpRightCornerLonF   = grid->P4

 res@mpDataBaseVersion      = "HighRes"          ; use high resolution coast
 res@pmTickMarkDisplayMode  = "Always"           ; turn on tickmarks

 plot = gsn_csm_contour_map(wks,x(0,:,:),res)     

end
