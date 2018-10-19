;*************************************************
; NCL Graphics: ice_1.ncl
;
; Concepts illustrated:
;   - Plotting ice data
;   - Drawing color-filled contours over a polar stereographic map
;   - Spanning part of a color map for contour fill
;   - Masking land in a map plot
;   - Using coordinate subscripting to read a specified geographical region
;
;************************************************
;
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"  
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"    
;************************************************
begin
;************************************************
; read in netCDF file
;************************************************
  a = addfile("ice001608.nc","r")
;************************************************
; read in ice coverage
;************************************************
  tmp = a->hice(0,:,:)                            ; read in data 
  ice = tmp                                       ; trick to retain cv's & atts
  ice = mask(tmp,(tmp.ne.0),True)                 ; mask out land
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

; note: since ice data is stored on a reduced grid with a data gap in
; latitude from -35 to +35 degrees, it is necessary to provide gsun
; with a sub-set of the data. Otherwise, an error will occur and the
; plot will not be correct. 


  plot = gsn_csm_contour_map_polar(wks,ice({20.:90.},:),res)

  end
