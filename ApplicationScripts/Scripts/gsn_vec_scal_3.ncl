;================================================;
;  gsn_vec_scal_3.ncl
;================================================;
;
; This file is loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
; ================================================;
begin
;=================================================;
; open file and read in data
;=================================================;
 f1 = addfile("uvt.nc","r")
 u = f1->U(0,0,:,:)    ; read in example data [2D only here]
 v = f1->V(0,0,:,:)
 speed = sqrt(u^2+v^2)                
;=================================================;
; Create plot
;=================================================;
  wks  = gsn_open_wks("png","gsn_vec_scal")        ; send graphics to PNG file

  res                  = True                      ; plot mods desired

  res@vfXArray         = u&lon
  res@vfYArray         = u&lat

  res@tiMainString     = "Basic Vector/Scalar/Map Plot"
  res@vcRefMagnitudeF  = 15.0                      ; add a reference vector
  res@vcRefLengthF     = 0.045                     ; what the ref length is
  res@vcLevelPalette   = "gui_default"             ; set color map

  res@mpLimitMode      = "LatLon"
  res@mpMinLatF        = min(u&lat)
  res@mpMaxLatF        = max(u&lat)
  res@mpMinLonF        = min(u&lon)
  res@mpMaxLonF        = max(u&lon)

  res@vpXF             = 0.1
  res@vpWidthF         = 0.8
  res@vpHeightF        = 0.4

  res@tiMainString     = "Vectors colored by a scalar field"

  plot = gsn_vector_scalar_map(wks,u,v,speed,res)

  end
