;****************************************************
; native_2.ncl
;
; Concepts illustrated:
;   - Drawing filled contours over a mercator map
;   - Overlaying contours on a map without having lat,lon coordinates
;   - Drawing a map using the medium resolution map outlines
;   - Turning on map tickmark labels with degree symbols
;   - Selecting a different color map
;   - Turning off the addition of a longitude cyclic point
;   - Zooming in on a particular area on a mercator map
;   - Adding a color to an existing color map
;
;*****************************************************
;
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
;*****************************************************
begin
 f1 = addfile("1994_256_FSD.nc","r")
 fsd=f1->FSD

 lat  = fsd&lat
 lon  = fsd&lon
 nlat = dimsizes(lat)
 nlon = dimsizes(lon)
;**************************************
;   Create plot
;***************************************
 wks  = gsn_open_wks("png", "native")               ; send graphics to PNG file

 res                             = True             ; plot mods desired

 res@cnFillOn                    = True             ; turn on color 
 res@cnLinesOn                   = False            ; no contour lines
 res@cnFillPalette               = "BlGrYeOrReVi200"; set color map

 res@cnLevelSelectionMode        = "ManualLevels"   ; set manual contour levels
 res@cnMinLevelValF              = 0                ; set min contour level
 res@cnMaxLevelValF              = 70               ; set max contour level
 res@cnLevelSpacingF             = 5                ; contour spacing

 res@lbOrientation               ="vertical"        ; vertical label bar

 res@mpDataBaseVersion           = "MediumRes"      ; use finer database
 res@pmTickMarkDisplayMode       = "Always"         ; turn on tickmarks

 res@gsnAddCyclic                = False            ; regional data, don't add pt

 res@mpProjection                = "mercator"       ; projection
 res@mpLimitMode                 = "Corners"        ; method to zoom
 res@mpLeftCornerLatF            = min(lat)
 res@mpLeftCornerLonF            = min(lon)
 res@mpRightCornerLatF           = max(lat)       
 res@mpRightCornerLonF           = max(lon)
 res@tfDoNDCOverlay              = True             ; do not transform data

 res@tiMainString                ="Native Mercator Projection"
 plot = gsn_csm_contour_map (wks,fsd(0,:,:),res)    ; create plot

end 



