;*************************************************
; NCL Graphics: lsm_2.ncl
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
  a = addfile("lsmh_01153.nc","r")
;************************************************
; read in soil moisture
;************************************************
  h2o = a->H2OSOI(0,0,:,:) 
; note, in LSM files, it is safer to copy the missing value from the
; file than try to write it out, since the number of decimal points on the
; file may not be the same number NCL reads. (9.99999e29)

  h2o@_FillValue = a->TAM@missing_value
  h2o@long_name=h2o@Title                   ; no long_name on this file
  h2o!0="lat"                               ; coordinate vars are called
  h2o!1="lon"                               ; "latitude" etc. plots want "lat"
;************************************************
; create plot
;************************************************
  wks = gsn_open_wks("png","lsm")               ; send graphics to PNG file

  res                      = True               ; plot mods desired
  res@mpMinLonF            = -140               ; set min lon
  res@mpMaxLonF            =  -65               ; set max lon
  res@mpMinLatF            =  10.               ; set min lat
  res@mpFillColors         = (/"white","cyan", \
  "gray","chartreuse2"/)                        ; colors to draw (default map)
  plot = gsn_csm_contour_map(wks,h2o, res)      ; create plot


  end
