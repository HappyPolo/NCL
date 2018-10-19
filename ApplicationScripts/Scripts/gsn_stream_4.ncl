;================================================;
;  gsn_stream_4.ncl
;================================================;
;
; This file is loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
; ================================================;
begin
;=================================================;
; open file and read in data
;=================================================;
 f1    = addfile("uvt.nc","r")
 u     = f1->U(0,0,:,:)    ; read in example data [2D only here]
 v     = f1->V(0,0,:,:)
 speed = sqrt(u^2+v^2)                
;=================================================;
; Create plot
;=================================================;
  wks  = gsn_open_wks("png","gsn_stream")          ; send graphics to PNG file

  res                  = True                      ; plot mods desired

  res@gsnMaximize      = True                      ; maximize plot in frame

  res@vfXArray         = u&lon
  res@vfYArray         = u&lat

  res@tiMainString     = "Basic Streamline/Scalar/Map Plot"

  res@stLineThicknessF = 2.0
  res@stLevelPalette   = "gui_default"             ; set color map

  res@pmTickMarkDisplayMode    = "Always"

  res@pmLabelBarDisplayMode    = "Always"
  res@pmLabelBarOrthogonalPosF = -0.02
  res@pmLabelBarWidthF         = 0.1
  res@lbPerimOn                = False

  res@mpLimitMode      = "LatLon"
  res@mpMinLatF        = min(u&lat)
  res@mpMaxLatF        = max(u&lat)
  res@mpMinLonF        = min(u&lon)
  res@mpMaxLonF        = max(u&lon)
  res@mpGridAndLimbOn  = False

  res@tiMainString     = "Streamlines colored by a scalar field"

  plot = gsn_streamline_scalar_map(wks,u,v,speed,res)

end
