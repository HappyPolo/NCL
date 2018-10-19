;**************************************************************
; moc_2.ncl
;
; Concepts illustrated:
;   - Plotting Meridional Overturning Circulation (MOC) from the NCOM model
;   - Changing the scale of the data
;   - Adding meta data (attributes and coordinates) to a variable
;   - Adding shading or color fill to areas on a contour plot with missing data
;   - Drawing a perimeter around areas on a contour plot with missing data
;   - Reversing the Y axis in a contour plot
;**************************************************************
;
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
begin
;**************************************************************
; read in data
;**************************************************************
  in = addfile("h_avg_Y2010_D000.00.nc","r")
  v  = in->V(0,:,:,{0:359})     ; remove cyclic points
  dz = in->dz
  dx = in->dxu(0)
  lat= in->lat_t
;**************************************************************
; some parameters
;**************************************************************
  nzt = getfilevardimsizes(in,"z_t")   ; z_t grid (25)
  nzw = nzt+1                         ; z_w grid (26)
  nlat = dimsizes(lat)
  
  d2rad = 0.017453         ; degrees to radians
;**************************************************************  
; calculate first intergral 
; int[lon1:lon2]v*cos(lat)*dx*dz
; this calculation is done on the z_t grid
;**************************************************************
  zone_int = new((/nlat,nzt/),typeof(v))     ; allocate space
  do k = 0, nzt-1
    do j = 0, nlat-1
      zone_int(j,k) = dim_sum(v(k,j,:)*cos(lat(j)*d2rad)*dx*dz(k))
    end do
  end do
;************************************************************** 
; calculate second integral (partial summation) over levels on z_w grid
; psi(k,y)=int[k:0]zone_int 
;**************************************************************
  moc      = new((/nzw,nlat/),typeof(v))      ; allocate space
  zone_int = zone_int(:,::-1)                 ; rearrange so bottom to top
  moc(0,:) = 0.                               ; bottom is zero 
  do k=1,nzw-2
    moc(k+1,:) = -1.0 * dim_sum(zone_int(:,0:k))
  end do
  moc(1,:) = moc(2,:) 
  moc = moc(::-1,:)                           ; put back in original order
;************************************************************** 
; scale to sverdrups
;**************************************************************
  moc = moc/1e12                              
;************************************************************** 
; assign meta data
;**************************************************************
  moc!0         = "depth"
  moc!1         = "lat"
  moc&depth     = in->z_w
  moc&lat       = lat
  moc@long_name = "eulerian meridional overturning"
  moc@units     = "SV"
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
  res@sfYArray                = moc&depth/100000 ; convert cm to km

  res@cnMissingValPerimOn     = True             ; turn on perimeter
  res@cnMissingValFillPattern = 3                ; choose a fill pattern
  res@cnMissingValFillColor   = "black"          ; choose a pattern color 

  res@cnLevelSelectionMode    = "ManualLevels"   ; manually set contour levels
  res@cnMinLevelValF          =  -90             ; min level
  res@cnMaxLevelValF          =   90             ; max level

  res@trYReverse              = True             ; reverses y-axis

  plot  = gsn_csm_contour(wks,moc,res)           ; create plot
end


  
