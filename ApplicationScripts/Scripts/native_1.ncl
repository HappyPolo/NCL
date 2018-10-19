;*****************************************************
; native_1.ncl
;
; Concepts illustrated:
;   - Drawing filled contours over a stereographic map
;   - Overlaying contours on a map without having lat,lon coordinates
;   - Setting the view of a stereographic map
;   - Turning on map tickmark labels with degree symbols
;   - Using fbindirread to read in fortran binary data
;   - Selecting a different color map
;   - Turning off the addition of a longitude cyclic point
;   - Zooming in on a particular area on a stereographic map
;   - Setting a nice stride for labelbar labels
;
;*****************************************************
;
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
;*****************************************************
begin
;***************************************
;    Input topo data from MC2 model
;***************************************
setfileoption("bin","ReadByteOrder","BigEndian")
nlat = 293
nlon = 343
topo = fbindirread(f1,0,(/nlat,nlon/),"float")

topo@units     = "m"
topo@long_name = "topography"
;***************************************
;    Input lat lon data. Not used in
;    this example, but see end of script.
;***************************************
f2  = "latlon.bin"
lat = fbindirread(f2,0,(/nlat,nlon/),"float")
lon = fbindirread(f2,1,(/nlat,nlon/),"float")

;*********************************************************************
; Note: if you don't have lat,lon coordinates for your data, you can
; still overlay data on a map as long as you know the exact projection
; that the data were measure on.
;*********************************************************************
 wks  = gsn_open_wks ("png", "native")                  ; send graphics to PNG file

 res                             = True                 ; plot mods desired

 res@cnFillOn                    = True                 ; turn on color
 res@cnLinesOn                   = False                ; no contour lines
 res@cnFillPalette               = "WhViBlGrYeOrReWh"   ; set color map

 res@cnLevelSelectionMode        = "ManualLevels"       ; manual levels
 res@cnMinLevelValF              = 0.
 res@cnMaxLevelValF              = 3000.
 res@cnLevelSpacingF             = 300.

 res@pmTickMarkDisplayMode       = "Always"             ; turn on tick marks

 res@tiMainString                = "Native Stereographic Example"

 res@gsnAddCyclic                = False                ; regional data

; The following resources are Required to plot this projection correctly

 res@mpProjection                = "Stereographic"     ; projection

 res@mpLimitMode                 = "Corners"           ; method to zoom
 res@mpLeftCornerLatF            = lat(0,0)
 res@mpLeftCornerLonF            = lon(0,0)
 res@mpRightCornerLatF           = lat(nlat-1,nlon-1)
 res@mpRightCornerLonF           = lon(nlat-1,nlon-1)

 res@mpRelativeCenterLon         = True                 ; set a center lon
 res@mpCenterLonF                = lon((nlat/2)+1,(nlon/2)+1)  ; center lon
 res@mpRelativeCenterLat         = True		        ; set a center lat
 res@mpCenterLatF                = 90.                  ; center lat
 res@tfDoNDCOverlay              = True                 ; do not transform data

 plot = gsn_csm_contour_map (wks,topo,res)

;
; Since you have the 2-dimensional lat/lon data, you can also
; plot this without knowing the exact projection.   Use
; the special "lat2d", "lon2d" attributes recognized by the
; gsn_csm_xxx_map suite of scripts.
;
; delete(res@tfDoNDCOverlay)
; topo@lat2d = lat
; topo@lon2d = lon
; plot = gsn_csm_contour_map (wks,topo,res)

end 
