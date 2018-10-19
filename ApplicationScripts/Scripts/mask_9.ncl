;*************************************************
; mask_9.ncl
;
; Concepts illustrated:
;   - Drawing the Mississippi River Basin using data from a shapefile
;   - Masking a data array based on a geographical area
;   - Attaching markers to a map
;   - Attaching polylines to a map plot
;   - Drawing a lat/lon grid using markers
;   - Copying coordinate arrays from one variable to another
;
;*************************************************
;
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"

begin
  MASK_INSIDE = False    ; Whether to mask data inside or outside the
                         ; given geographical area.

;---Generate some dummy data over map
  minlat      =   20
  maxlat      =   60
  minlon      = -125
  maxlon      =  -60

  nlat            = 32
  nlon            = 64
  data            = generate_2d_array(10, 10, 0., 100., 0, (/nlat,nlon/))
  data@_FillValue = -9999

;---Create dummy 1D lat/lon arrays
  lat1d       = fspan(minlat,maxlat,nlat)
  lon1d       = fspan(minlon,maxlon,nlon)
  lat1d@units = "degrees_north"
  lon1d@units = "degrees_east"

;---Attach lat/lon coordinate array information.
  data!0      = "lat"
  data!1      = "lon"
  data&lat    = lat1d
  data&lon    = lon1d

;---Open shapefile and read Mississippi River Basin lat/lon values.
  dir     = ncargpath("data") + "/shp/"
  f       = addfile(dir + "mrb.shp", "r")
  mrb_lon = f->x
  mrb_lat = f->y
  nmrb    = dimsizes(mrb_lon)

  min_mrb_lat = min(mrb_lat)
  max_mrb_lat = max(mrb_lat)
  min_mrb_lon = min(mrb_lon)
  max_mrb_lon = max(mrb_lon)

;
; Create new data to mask. Depending on whether you want to
; mask data inside or outside the geographical outline,
; start off with your data grid all missing, or filled in.
;
  if(MASK_INSIDE) then
;---Start with data filled in.
    data_mask = data
  else
;---Start with data all missing
    data_mask = new(dimsizes(data),typeof(data),data@_FillValue)
    copy_VarCoords(data,data_mask)
  end if
;
; Get the approximate index values that contain the
; Mississippi River Basin area. We'll use this to
; narrow in on the area that we need to figure out
; the masking for. Any lat/lon values outside this
; area we don't care about.
;
; This will make our gc_inout loop below go almost 4x
; faster, because we're not checking every single
; lat/lon point to see if it's within the area of
; interest.
;
  ilt_mn = ind(min_mrb_lat.gt.lat1d)
  ilt_mx = ind(max_mrb_lat.lt.lat1d)
  iln_mn = ind(min_mrb_lon.gt.lon1d)
  iln_mx = ind(max_mrb_lon.lt.lon1d)
  ilt1   = ilt_mn(dimsizes(ilt_mn)-1)    ; Start of lat box
  iln1   = iln_mn(dimsizes(iln_mn)-1)    ; Start of lon box
  ilt2   = ilt_mx(0)                     ; End of lat box
  iln2   = iln_mx(0)                     ; End of lon box

  if(MASK_INSIDE) then
;---Put missing values in the areas that we want masked.
    do ilt=ilt1,ilt2
      do iln=iln1,iln2
        if(gc_inout(lat1d(ilt),lon1d(iln),mrb_lat,mrb_lon)) then
          data_mask(ilt,iln) = data_mask@_FillValue
        end if
      end do
    end do
  else
;---Put data back in the areas that we don't want masked.
    do ilt=ilt1,ilt2
      do iln=iln1,iln2
        if(gc_inout(lat1d(ilt),lon1d(iln),mrb_lat,mrb_lon)) then
          data_mask(ilt,iln) = data(ilt,iln)
        end if
      end do
    end do
  end if

;---Start the graphics
  wks  = gsn_open_wks("png","mask")        ; send graphics to PNG file

  res                     = True

  res@gsnMaximize         = True           ; maximize plot in frame
  res@gsnDraw             = False          ; don't draw plot yet
  res@gsnFrame            = False          ; don't advance frame yet

  res@gsnAddCyclic        = False          ; Don't add a cyclic point.

  res@mpDataBaseVersion   = "MediumRes"    ; slightly better resolution

;---Zoom in on North America.
  res@mpMinLatF           = minlat
  res@mpMaxLatF           = maxlat
  res@mpMinLonF           = minlon
  res@mpMaxLonF           = maxlon

  res@tiMainString        = "Full data with Mississippi River Basin outlined"

;---Create contours over map.
  map_data = gsn_csm_contour_map(wks,data,res)

;---Resources for polyline
  lnres                  = True
  lnres@gsLineColor      = "blue"
  lnres@gsLineThicknessF = 2.0            ; 2x thickness

;---Attach MRB outline to map.
  mrb_line = gsn_add_polyline(wks, map_data, mrb_lon, mrb_lat, lnres)

;---Draw plot and advance frame
  draw(map_data)
  frame(wks)

;---Draw contours of masked data
  res@tiMainString = "Masked data with Mississippi River Basin outlined"

  map_mask      = gsn_csm_contour_map(wks,data_mask,res)
  mrb_line_mask = gsn_add_polyline(wks, map_mask, mrb_lon, mrb_lat, lnres)

  draw(map_mask)
  frame(wks)

;---Draw the part of the lat/lon grid that was masked out. 
;   Only draw the map this time (no contours).

  delete(res@gsnAddCyclic)

  res@tiMainString = "Area where lat/lon values were masked"
  map = gsn_csm_map(wks,res)

;---Generate the lat/lon values over the masked area.

  lat2d = conform_dims((/nlat,nlon/),lat1d,0)
  lon2d = conform_dims((/nlat,nlon/),lon1d,1)
  lat2d@_FillValue = -9999
  lon2d@_FillValue = -9999
  lat_markers = ndtooned(where(ismissing(data_mask),lat2d,lat2d@_FillValue))
  lon_markers = ndtooned(where(ismissing(data_mask),lon2d,lon2d@_FillValue))

;---Set up resources for markers
  mkres               = True
  mkres@gsMarkerIndex = 16    ; Filled dots
  mkres@gsMarkerSizeF = 0.003

  latlon_markers = gsn_add_polymarker(wks,map,lon_markers,lat_markers,mkres)
  mrb_line_map   = gsn_add_polyline(wks,map,mrb_lon,mrb_lat,lnres)

  draw(map)
  frame(wks)
end

