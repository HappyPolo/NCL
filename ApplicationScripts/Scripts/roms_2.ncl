;***********************************************
; roms_2.ncl
;
; Concepts illustrated:
;   - Plotting ROMS data
;   - Overlaying contours on a map using two-dimensional lat,lon arrays
;   - Zooming in on a particular area on a Lambert Conformal map using map corners
;***********************************************
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"  
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"  
begin
;***********************************************
; open file and read in data
;***********************************************
 grid = addfile ("CGOA_grid_3.nc", "r")
 lat2d  = grid->lat_rho
 lon2d  = grid->lon_rho

 f    = addfile ("ocean_his_005.nc", "r")
 t    = f->zeta

 t@lat2d=lat2d
 t@lon2d=lon2d
;************************************************
; get some parameters
;************************************************
 nlat = dimsizes(lat2d(:,0))
 nlon = dimsizes(lon2d(0,:))
;************************************************
; create plot
;************************************************
 wks  = gsn_open_wks ("ps", "roms")              ; open workstation
 gsn_define_colormap (wks,"testcmap")            ; choose color map
                                          
 res                        = True               ; plot mods desired
 res@cnFillOn               = True               ; color fill  
 res@cnLinesOn              = False              ; no contour lines
 res@cnLineLabelsOn         = False              ; no contour labels
 res@cnFillDrawOrder        = "PreDraw"          ; put continents on top
 res@cnInfoLabelOn          = False              ; no contour info label
 res@gsnSpreadColorEnd      = -2                 ; don't use last color
 res@mpGridAndLimbOn        = True               ; turn on lat/lon lines

 res@gsnMaximize            = True               ; biggest plot possible

; The following resources are REQUIRED to properly display
; data zoomed on a lambert conformal grid.  
 
 res@mpProjection        = "LambertConformal"
 res@mpLambertParallel1F = grid->PLAT(0)
 res@mpLambertParallel2F = grid->PLAT(1)
 res@mpLambertMeridianF  = grid->PLONG
 
 res@mpLimitMode         = "Corners"             ; choose range of map
 res@mpLeftCornerLatF    =   45
 res@mpLeftCornerLonF    = -160
 res@mpRightCornerLatF   =   60
 res@mpRightCornerLonF   = -130

 res@mpDataBaseVersion      = "HighRes"          ; use high resolution coast
 res@pmTickMarkDisplayMode  = "Always"           ; turn on tickmarks

 plot = gsn_csm_contour_map(wks,t(0,:,:),res)     

end
