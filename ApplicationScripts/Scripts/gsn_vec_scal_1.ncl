;================================================;
;  gsn_vec_scal_1.ncl
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
  res@tiMainString     = "Basic Vector/Scalar Plot"
  res@vcRefMagnitudeF  = 15.0                      ; add a reference vector
  res@vcRefLengthF     = 0.045                     ; what the ref length is
  res@vcLevelPalette   = "gui_default"             ; set color map

  res@vpWidthF         = 0.8                       ; change the aspect ratio
  res@vpHeightF        = 0.4
  res@vpXF             = .1                        ; loc of where plot starts
  res@vpYF             = .7

  res@tmXBLabelFontHeightF = 0.025
  res@tmYLLabelFontHeightF = 0.025

  res@tiMainString     = "Vectors colored by a scalar field"

  plot = gsn_vector_scalar(wks,u,v,speed,res)          ; contour the variable

  end
