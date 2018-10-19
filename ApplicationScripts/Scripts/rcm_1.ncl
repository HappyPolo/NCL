;*******************************************
; rcm_1.ncl
;
; Concepts illustrated:
;   - Plotting RCM data
;   - Plotting Cray binary data
;   - Drawing filled contours over a Lambert Conformal map
;   - Drawing U.S. states
;********************************************************************
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"   
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"   

begin
   file1 = "OUT.1983050030"
   t = craybinrecread(file1,5,(/121,78/),"float")  ; read in data

   t!0 ="lon"                                  ; assign named coordinates
   t!1 ="lat"                                  ; so we can reorder
   dims=dimsizes(t)                            ; get dimensions
   nlon=dims(0)                                ; assign # lat/lon points
   nlat=dims(1)

; here we do two things:
;   a) swap the dimensions from lon,lat to lat,lon
;   b) pull out all data except last value in x and y (bad points)

   t2=t(lat|0:nlat-2,lon|0:nlon-2)             ; reorder

; get lat lon data and reorder

   file2 = "OUT.1982110010"
   LAT2D = craybinrecread(file2,6,(/121,78/),"float") ;  read in lat
   LON2D = craybinrecread(file2,7,(/121,78/),"float") ;  read in lon

   LAT2D!0 ="lon"                                  ; assign named coordinates
   LAT2D!1 ="lat"                                  ; so we can reorder

   LON2D!0 ="lon"                                  ; assign named coordinates
   LON2D!1 ="lat"                                  ; so we can reorder

   lon2d=LON2D(lat|:,lon|:)
   lat2d=LAT2D(lat|:,lon|:)
;********************************
; plot
;********************************
   wks = gsn_open_wks("ps","rcm")          ; open a workstation
   gsn_define_colormap(wks,"gui_default")   ; choose colormap

   res                 = True                    ; plot mods desired
   res@cnLinesOn       = False
   res@cnFillOn        = True               ; color plot desired
   res@cnLineLabelsOn  = False              ; turn off contour lines

; !!!!! any plot of data that is on a native grid, must use the "corners"
; method of zooming in on map.
   
   res@mpLimitMode       = "Corners"            ; choose range of map
   res@mpLeftCornerLatF  = lat2d(0,0)
   res@mpLeftCornerLonF  = lon2d(0,0)
   res@mpRightCornerLatF = lat2d(nlat-2,nlon-2)
   res@mpRightCornerLonF = lon2d(nlat-2,nlon-2)
   
; The following 4 pieces of information are REQUIRED to properly display
; data on a native lambert conformal grid.  This data should be specified
; somewhere in the model itself.
   
; WARNING: our local RCM users could not provide us with this information,
; so this is our best guess as to the correct numbers. Use at your own risk.
   
   res@mpProjection        = "LambertConformal"
   res@mpLambertParallel1F = 30
   res@mpLambertParallel2F = 58
   res@mpLambertMeridianF  = 260
   
; usually, when data is placed onto a map, it is TRANSFORMED to the specified
; projection. Since this model is already on a native lambert conformal grid,
; we want to turn OFF the tranformation.
   
   res@tfDoNDCOverlay = True

   
   res@mpGeophysicalLineColor = "red"                   ; color of continental outlines
   res@mpPerimOn              = True                    ; draw box around map
   res@mpGridLineDashPattern  = 2                       ; lat/lon lines as dashed
   res@mpOutlineBoundarySets = "GeophysicalAndUSStates" ; add state boundaries
   res@mpUSStateLineColor    = "red"                    ; make them red
   res@pmTickMarkDisplayMode = "Always"                 ; turn on tickmarks 

   
   map = gsn_csm_contour_map(wks,t2,res)    ; Draw contours over a map.

end


