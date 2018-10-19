;*****************************************************
; rotatedltln_1.ncl
;
; Concepts illustrated:
;   - Drawing filled contours over a rotated lat-lon grid
;   - Zooming in on a particular area on a map
;   - Drawing a map using the medium resolution map outlines
;   - Overlaying contours on a map without having lat,lon coordinates
;   - Reversing the Y axis
;*****************************************************
;
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"

begin
  f1  = addfile("MET9_IR108_cosmode_0909210000.grb2","r")
  sbt = f1->SBTMP_P31_GRLL0

  lat2d = f1->gridlat_0
  lon2d = f1->gridlon_0
  nlat  = dimsizes(lat2d(:,0))
  nlon  = dimsizes(lon2d(0,:))
 
;---Start the graphics section
  wks  = gsn_open_wks("png", "rotatedltln")     ; send graphics to PNG file

  res                        = True             ; plot mods desired

  res@gsnMaximize            = True             ; maxmize plot in frame

  res@cnFillOn               = True             ; turn on color 
  res@cnLinesOn              = False            ; no contour lines
  res@cnLineLabelsOn         = False            ; no contour labels
  res@cnFillPalette          = "BlGrYeOrReVi200"

  res@mpDataBaseVersion      = "MediumRes"      ; use finer database
  res@mpOutlineBoundarySets  = "National"

;---Turn on nicer tickmarks. 'conditional' prevents more than one tickmark object.
  res@pmTickMarkDisplayMode  = "conditional"

  res@gsnAddCyclic           = False
  res@gsnRightString         = ""

;
; Since the Y-Axis of these data goes from north to south, the Y-Axis
; needs to be reversed to plot it correctly in a "native" projection.
; 
  res@trYReverse             = True
;
; Setting tfDoNDCOverlay to True means you have specified the
; exact projection that your data is on, and thus no data
; transformation takes place when the contours are overlaid
; on the map.
; 
  res@tfDoNDCOverlay         = True

;---Zoom in on map
  res@mpLimitMode            = "Corners"
  res@mpLeftCornerLatF       = lat2d(nlat-1,0) 
  res@mpLeftCornerLonF       = lon2d(nlat-1,0)
  res@mpRightCornerLatF      = lat2d(0,nlon-1)      
  res@mpRightCornerLonF      = lon2d(0,nlon-1) 

  res@mpCenterLonF           = lon2d@Longitude_of_southern_pole 
  res@mpCenterLatF           = lon2d@Latitude_of_southern_pole + 90

  res@tiMainString           = "Native rotated lat/lon Projection"

  plot = gsn_csm_contour_map (wks,sbt,res)    ; Draw plot

;
; To draw these contours on another map projection, the 
; 2D (unrotated) lat/lon coordinates are required.
;
  res@tfDoNDCOverlay         = False    ; transform to standard lat/lon

  res@sfXArray               = lon2d
  res@sfYArray               = lat2d

;---Zoom in on map
  res@mpLimitMode            = "Corners"
  res@mpLeftCornerLatF       = lat2d(nlat-1,0) - 5
  res@mpLeftCornerLonF       = lon2d(0,0) -5
  res@mpRightCornerLatF      = lat2d(0,nlon-1) + 5    
  res@mpRightCornerLonF      = lon2d(nlat-1,nlon-1) + 5

;---Regular lat/lon plot when center lat is 0
  res@mpCenterLatF           = 0  

  res@tiMainString           = "Rotated data in standard lat/lon projection"

  plot = gsn_csm_contour_map (wks,sbt,res)    ; Draw plot
end 
