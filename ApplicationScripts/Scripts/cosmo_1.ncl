;----------------------------------------------------------------------
; cosmo_1.ncl
;
; Concepts illustrated:
;   - Plotting COSMO model data from MeteoSwiss
;   - Plotting data from a rotated lat-lon grid
;----------------------------------------------------------------------
;
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"

begin

 ; open file
 cname = "lfff00000000c"
 ftype = "nc"
 cfile = addfile(cname+"."+ftype,"r")

 ; read topography and land-fraction
 if (ftype .eq. "grb") then
   topo = cfile->HH_GDS10_SFC
   frland = cfile->FR_LAND_GDS10_SFC
 end if
 if (ftype .eq. "nc") then
   topo = cfile->HSURF(0,:,:)
   frland = cfile->FR_LAND(0,:,:)
 end if
 if (.not. isvar("topo")) then
   print("Only grb or nc file type is supported!")
   exit
 end if

 ; read lat/lon arrays
 latlon = str_split(topo@coordinates, " ")
 if (ftype .eq. "nc") then
   lat2d = cfile->$latlon(0)$
   lon2d = cfile->$latlon(1)$
 end if
 if (ftype .eq. "nc") then
   lat2d = cfile->$latlon(1)$
   lon2d = cfile->$latlon(0)$
 end if

 ; get position of rotated North pole
 if (ftype .eq. "grb") then
   pole_lon = lat2d@Longitude_of_southern_pole - 180.0
   pole_lat = -lat2d@Latitude_of_southern_pole
 end if
 if (ftype .eq. "nc") then
   pole = cfile->rotated_pole
   pole_lon = pole@grid_north_pole_longitude
   pole_lat = pole@grid_north_pole_latitude
 end if

 ; close file
 delete(cfile)

 ; get dimensions
 nlat = dimsizes(lat2d(:,0))
 nlon = dimsizes(lon2d(0,:))

 ; set water points to -1.0 elevation
 topo = where(topo .lt. 0.0, 0.0, topo)
 topo = where(frland .gt. 0.5, topo, -1.0)

 ; geo-reference data
 topo@lat2d = lat2d
 topo@lon2d = lon2d

 ; rename topography (for correct plot title)
 topo@long_name = "Topography"

 ; open graphic port
 ptype = "png"              ; send graphics to PNG file
 wks = gsn_open_wks(ptype,"cosmo")

 ; setup map resources
 res = True
 res@mpProjection           = "CylindricalEquidistant"
 res@mpCenterLonF           = pole_lon + 180.
 res@mpCenterLatF           = 90. - pole_lat
 res@mpLimitMode            = "Corners"
 res@mpLeftCornerLatF       = lat2d(0,0) 
 res@mpLeftCornerLonF       = lon2d(0,0)
 res@mpRightCornerLatF      = lat2d(nlat-1,nlon-1)      
 res@mpRightCornerLonF      = lon2d(nlat-1,nlon-1) 

;; ; no re-projection (we are on the "native" grid)
;; res@tfDoNDCOverlay         = True
;; res@sfXArray               = lon2d
;; res@sfYArray               = lat2d

 ; setup contour plot resources
 res@gsnMaximize            = True             ; maxmize plot in frame
 res@cnFillOn               = True             ; turn on color 
 res@cnFillPalette          = "topo_15lev"     ; set color map
 res@cnLinesOn              = False            ; no contour lines
 res@cnLineLabelsOn         = False            ; no contour labels
 res@cnLevelSelectionMode   = "ManualLevels"   ; manual level selection
 res@cnMinLevelValF         = 0.0              ; water (blue) is below 0.0m
 res@cnMaxLevelValF         = 3000.0           ; snow/ice (white) is at 3000.0m
 res@mpDataBaseVersion      = "MediumRes"      ; use finer database
 res@mpOutlineBoundarySets  = "National"
 res@pmTickMarkDisplayMode  = "conditional"
 res@gsnAddCyclic           = False
 res@lbLabelFontHeightF     = 0.015
 res@lbLabelStride          = 2

 ; make contour + map plot
 pl = gsn_csm_contour_map(wks, topo, res)
 delete(res)

 ; cleanup
 delete(wks)

end
