;================================================;
;  poprast_2.ncl
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
  wks  = gsn_open_wks("ps","poprast")             ; open a ps file
  gsn_define_colormap(wks,"BkBlAqGrYeOrReViWh200")


  res                      = True
  res@cnFillOn             = True                 ; turn on color
  res@cnFillMode           = "RasterFill"         ; turn on raster mode
  res@cnLinesOn            = False                ; turn off contour lines
  res@gsnSpreadColors      = True                 ; use full colormap
  res@gsnSpreadColorStart  = 16                   ; start at color 16
  res@gsnSpreadColorEnd    = 191                  ; end at color 191
  res@lbLabelAutoStride    = True                 ; auto skip labels as req.

; zoom in on map
  res@mpMaxLatF            = 60              
  res@mpMinLatF            = 40
  res@mpMaxLonF            = 350
  res@mpMinLonF            = 330

; one way we can ensure that the label bar reflects only the data within
; a zoomed region is to pass the plot routine a subset of the data using
; coordinate subscripting e.g. 
; plot= gsn_csm_contour_map_ce(wks,t(0,0,{60:40},{350,330}),res). This
; data, however ever does not have coordinate variables because its lat/lon
; information is 2D. To make this technique work with this data, the user
; must know the actual array indices that correspond to the lat/lon ranges of
; interest. Then, in addition to subscripting the main data, the 2D lat/lon
; arrays would also have to be limited.

; a much simplier method, is to just set the contour range of the data within
; the zoomed area specified above. This may require several iterations. 
; Note that since we are still passing the full global array to the plot 
; routine, we do not need to set gsnAddCyclic to False like we normally do
; for regional data.

  res@cnLevelSelectionMode = "ManualLevels"
  res@cnMinLevelValF       = 5
  res@cnMaxLevelValF       = 15
  res@cnLevelSpacingF      = 0.5

  res@tiMainString         = "A zoom raster plot" 
  plot = gsn_csm_contour_map_ce(wks,t(0,0,:,:),res)

end
  
