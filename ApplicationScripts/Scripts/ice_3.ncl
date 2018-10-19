;*************************************************
; ice_3.ncl
;
; Concepts illustrated:
;   - Plotting ice data
;   - Overlaying contours on a map using two-dimensional lat,lon arrays
;   - Drawing contours over a polar stereographic map
;   - Zooming in on a particular area on a polar stereographic map
;
;*****************************************************
;
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"  
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"    
;************************************************
begin
;************************************************
; read in netCDF file
;************************************************
  f = addfile("iceh_mavg.0014-02.nc","r")
;************************************************
; read in ice coverage
;************************************************
  hi         = f->hi

  lat2d      = f->TLAT                          ; read in 2D lat/lon
  lon2d      = f->TLON
  hi@lon2d   = lon2d                            ; assign required attributes
  hi@lat2d   = lat2d
;************************************************
; create plot
;************************************************
  wks = gsn_open_wks("png","ice")               ; send graphics to PNG file
  cmap = read_colormap_file("BlAqGrYeOrReVi200"); choose colormap

  res                      = True               ; plot mods desired
  res@cnFillOn             = True               ; turn on color
  res@cnFillPalette        = cmap(18:191,:)     ; subset color map
  res@gsnPolarNH           = True               ; specify the hemisphere
  res@mpMinLatF            = 65                 ; specify min lat

  plot = gsn_csm_contour_map_polar(wks,hi(0,:,:),res)

  end
