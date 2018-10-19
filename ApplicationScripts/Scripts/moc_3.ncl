;**************************************************************
; moc_3.ncl
;
; Concepts illustrated:
;   - Plotting Meridional Overturning Circulation (MOC) from the FOAM model
;   - Adding meta data (attributes and coordinates) to a variable
;   - Adding shading or color fill to areas on a contour plot with missing data
;   - Drawing a perimeter around areas on a contour plot with missing data
;**************************************************************
; does calculation for FOAM ocean model. 
;**************************************************************
;
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
begin
;**************************************************************
; read in data
;**************************************************************
  in = addfile("foam.ocean.nc","r")
  v  = in->V(0,:,:,:)   

  lat= in->lat
  lon= in->lon
  lev= v&lev

  nlev = dimsizes(lev)
  nlat = dimsizes(lat)

  dx = 0.313084e6

; the foam data does not have an _FillValue, it must be assigned
  v@_FillValue = v@missing_value  

; calculate dz array since not on file
  dz = new(nlev,typeof(lev))
  do k = 0,nlev-2
    dz(k) = lev(k+1)-lev(k)
  end do
  dz(nlev-1) = 0 
;**************************************************************
; some parameters
;**************************************************************
  d2rad = 0.017453         ; degrees to radians
;**************************************************************  
; calculate first intergral 
; int[lon1:lon2]v*cos(lat)*dx*dz
; this calculation is done on the z_t grid
;**************************************************************
  zone_int = new((/nlat,nlev/),typeof(v))     ; allocate space
  do k = 0, nlev-1
    do j = 0, nlat-1
      zone_int(j,k) = dim_sum(v(k,j,:)*cos(lat(j)*d2rad)*dx*dz(k))
    end do
  end do
;************************************************************** 
; calculate second integral (partial summation) over levels on z_w grid
; psi(k,y)=int[k:0]zone_int 
;**************************************************************
  moc      = new((/nlev,nlat/),typeof(v))      ; allocate space
  moc(0,:) = 0.                                ; bottom is zero 
  do k=1,nlev-1
    moc(k,:) = -1.0 * dim_sum(zone_int(:,0:k))
  end do
;************************************************************** 
; assign meta data
;**************************************************************
  moc!0         = "depth"
  moc!1         = "lat"
  moc&depth     = v&lev
  moc&lat       = v&lat
  moc@long_name = "eulerian meridional overturning"
  moc@units     = "m~S~3~N~/s"
;*********************************
; create plot
;*********************************
  wks = gsn_open_wks("png","moc")                ; send graphics to PNG file
  res                         = True             ; plot mods desired
  
  res@cnFillOn                = True             ; turn on color fill
  res@cnFillPalette           = "ViBlGrWhYeOrRe" ; set color map
  res@cnLineLabelsOn          = False            ; turns off contour line labels
  res@cnLinesOn               = False            ; turn off contour lines
  res@cnInfoLabelOn           = False            ; turns off contour info label
  res@lbOrientation           = "vertical"       ; vertical label bar
  
  res@sfXArray                = moc&lat          ; uses lat_t as plot x-axis
  res@sfYArray                = moc&depth/1000   ; convert cm to km
  res@tiXAxisString           = "depth (m)"

  res@cnMissingValPerimOn     = True             ; turn on perimeter
  res@cnMissingValFillPattern = 3                ; choose a fill pattern
  res@cnMissingValFillColor   = "black"          ; choose a pattern color 

  res@cnLevelSelectionMode    = "ManualLevels"   ; manually set contour levels
  res@cnMinLevelValF          =  -1.4e8             ; min level
  res@cnMaxLevelValF          =   1.4e8             ; max level

  plot  = gsn_csm_contour(wks,moc,res)           ; create plot
end


  
