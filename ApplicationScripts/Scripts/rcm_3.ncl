;********************************************************************
; rcm_3.ncl
;*******************************************
; rcm_3.ncl
;
; Concepts illustrated:
;   - Plotting RCM precipitation data
;   - Drawing color-filled contours over a lambert conformal map
;   - Using a filter to convert Cray COS block binary data to netCDF 
;********************************************************************
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"   
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"    

begin
;*************************
; read in precip data (units cm)
;*************************
  a = addfile("prc.1982112500-1983030500.nc","r")
  x = a->prc  

; don't plot any zeros. since this data doesn't actually contain any missing
; data, we can do the following to avoid plotting zero.
  x@_FillValue =  0.0
  x@_FillValue = -999.

  LAT2D = a->lat2d
  LON2D = a->lon2d
;*************************
; set some parameters and read in date
;************************* 
  date_start    = 1982120100    ; pick start and end dates
  date_end      = 1983010100
  data_per_day  = 4
  date          = a->date                        ; read in date   
                      
  index_start = ind(date.eq.date_start) ; get array index of desired times
  index_end   = ind(date.eq.date_end  )
  
  nday = (index_end-index_start)/data_per_day
;***************************************
; compute monthly average units: mm/day               
;***************************************
  dims = dimsizes(x)                                     ; get dimension sizes
  nlat = dims(1)                            
  nlon = dims(2)
  y    = new((/nlat,nlon/),float)                           ; allocate memory
  y    = (/x(index_end,:,:) - x(index_start,:,:)/)*10./nday ; compute
  y!0  ="lat"                                             ; name dimensions
  y!1  ="lon"
;*******************************************************
; prepare data for ploting pull out all data except 
; last value in x and y (bad points)
;*******************************************************
  precip           = y(lat|0:nlat-2,lon|0:nlon-2)             
  precip@long_name = "Precipitation"   ; give data long_name and units,
  precip@units     = "mm/day"          ; so plotted automatically. 
;***********************
; plot
;***********************
  wks = gsn_open_wks("ps","rcm")           ; open a workstation
  gsn_define_colormap(wks,"gui_default")   ; choose colormap
  
  res            = True                    ; plot mods desired
; !!!!! any plot of data that is on a native grid, must use the "corners"
; method of zooming in on map.
  
  res@mpLimitMode       = "Corners"            ; choose range of map
  res@mpLeftCornerLatF  = LAT2D(0,0)
  res@mpLeftCornerLonF  = LON2D(0,0)
  res@mpRightCornerLatF = LAT2D(nlat-2,nlon-2)
  res@mpRightCornerLonF = LON2D(nlat-2,nlon-2)
  
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
  
  res@tfDoNDCOverlay         = True        ; do not transform
  
  
  res@cnFillOn               = True        ; color plot desired
  res@cnLinesOn              = False	   ; no contour lines
  
  res@mpGeophysicalLineColor = "red"       ; color of continental outlines
  res@mpPerimOn              = True        ; draw box around map
  res@mpGridLineDashPattern  = 2           ; lat/lon lines as dashed
  res@mpOutlineBoundarySets  = "GeophysicalAndUSStates" ; add state boundaries
  res@mpUSStateLineColor     = "red"       ; make them red
  
  res@tiMainString           = "RCM2-82nmc03,Starting 19821121"  ;title

  res@gsnAddCyclic           = False       ; regional data don't add
  
  plot = gsn_csm_contour_map(wks,precip,res) 

end
