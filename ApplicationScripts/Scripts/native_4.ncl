;**********************************************************
; native_4.ncl
;
; Concepts illustrated:
;   - Drawing filled contours over a stereographic map
;   - Overlaying contours on a map without having lat,lon coordinates
;   - Drawing grayscale filled contours
;   - Changing the color map using "setvalues"
;   - Turning on map tickmark labels with degree symbols
;   - Zooming in on a particular area on a stereographic map
;   - Reading data from several ASCII files
;  
;**********************************************************
; Wanli Wu (wwu@colorado.edu), coded in NCAR NCL workshop 
;                              May 12-15, 2003
;**********************************************************
;
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
;********************************************************
begin
;**********************************************************
;    some data parameters
;**********************************************************
; regional model dimension sizes:
  nlon = 54
  nlat = 46 

; regional model central latitude and longitude
  clat = 64.0
  clon =-145.0 

;**********************************************************
;    Input topography data
;**********************************************************
  data = asciiread("terrain.dat",(/nlat,nlon+1/),"float")

  topo           = data(:,1:nlon)        ; remove row number (column 1)
  topo           = topo(::-1,:)          ; flip the data in latitude if needed
  topo@units     = "m"
  topo@long_name = "topography"
;***************************************
;    Input 2-dimensional lat/lon data
;***************************************
  lat2d = asciiread("lat2d.dat",(/nlat,nlon+1/),"float")
  lat = lat2d(:,1:nlon)


  lon2d = asciiread("lon2d.dat",(/nlat,nlon+1/),"float")
  lon = lon2d(:,1:nlon)

;***************************************
;   Create plot
;***************************************
  wks  = gsn_open_wks ("png", "native")                  ; send graphics to PNG file
  setvalues wks            
  "wkColorMap"        : "gsltod"  
  "wkForegroundColor" : (/0.,0.,0./)  
  "wkBackgroundColor" : (/1.,1.,1./) 
  end setvalues 

 
  res                             = True                 ; plot mods desired
  
  res@cnFillOn                    = True                 ; turn on color
  
  res@cnLevelSelectionMode        = "ManualLevels"       ; manual levels
  res@cnMinLevelValF              = 0.
  res@cnMaxLevelValF              = 3000.               
  res@cnLevelSpacingF             = 300.
  
  res@pmTickMarkDisplayMode       = "Always"             ; turn on tick marks
  
  res@tiMainString                = "Regional Domain on Stereographic Proj"
  
  res@gsnAddCyclic                = False                ; regional data
  
; the following resources are REQUIRED to plot this projection correctly
  
  res@mpProjection                = "Stereographic"     ; projection
  res@mpLimitMode                 = "Corners"           ; method to zoom
  res@mpLeftCornerLatF            = lat(0,0)
  res@mpLeftCornerLonF            = lon(0,0)
  res@mpRightCornerLatF           = lat( nlat-1, nlon-1)
  res@mpRightCornerLonF           = lon( nlat-1, nlon-1)

; specify center longitude and latitude by which the domain was created
  res@mpRelativeCenterLon         = True                 ; set a center lon
  res@mpCenterLonF                = clon                 ; center lon
  res@mpRelativeCenterLat         = True	         ; set a center lat
  res@mpCenterLatF                = clat                 ; center lat
  res@tfDoNDCOverlay              = True                 ; don't transform 
  
  plot = gsn_csm_contour_map (wks,topo,res)


end 

