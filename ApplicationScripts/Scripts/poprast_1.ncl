;================================================;
;  poprast_1.ncl
;================================================;
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"   
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"   
begin
  f         = addfile("TEMP.nc","r")

  tmp_lon   = f->ULONG                   ; read in original lat/lon data
  tmp_lat   = f->ULAT
; ================================================;
; when a coordinate array contains one more element than the corresponding 
; dimension in the data array, the cell boundary is automatically turned on, 
; which causes discrete rasterization to use the coordinate values as 
; divisions between data cells, rather than to treat each coordinate value 
; as a cell center.
; ================================================; 
  dims      = dimsizes(tmp_lon)         ; get dimension sizes
  dims(1)   = dims(1) + 1               ; increase longitude by 1
  nlat      = dims(0)
  nlon      = dims(1)

  lon      = new(dims,typeof(tmp_lon)) ; create new arrays
  lat      = new(dims,typeof(tmp_lat))

  lat(:,1:nlon-1)  = tmp_lat        ; fill in arrays
  lon(:,1:nlon-1)  = tmp_lon
  lon(:,0)         = tmp_lon(:,nlon-2)
  lat(:,0)         = tmp_lat(:,nlon-2)
;************************************************************
; now elimininate the 0th element in the latitudinal direction for the
; data. This means that lon and lat have one more element along both 
; dimensions of the data array. This will automatically cause the
; discrete raster fill to treat X and Y coordianate arrays as cell bounds
;************************************************************
  t         = f->TEMP(:,:,1:nlat-1,:)
  t@lat2d   = lat 
  t@lon2d   = lon
;=================================================;
; Create plot
;=================================================;
  wks  = gsn_open_wks("ps","poprast")            ; open a ps file
  gsn_define_colormap(wks,"BlAqGrYeOrRe")         ; choose colormap


  res                      = True
  res@cnFillOn             = True                 ; turn on color
  res@cnFillMode           = "RasterFill"         ; turn on raster mode
  res@cnLinesOn            = False                ; turn off contour lines
  res@gsnSpreadColors      = True                 ; use full colormap
  res@gsnSpreadColorStart  = 10                   ; start at color 10
  res@gsnSpreadColorEnd    = 96                   ; end at color 96

  plot = gsn_csm_contour_map_ce(wks,t(0,0,:,:),res)

end
  
