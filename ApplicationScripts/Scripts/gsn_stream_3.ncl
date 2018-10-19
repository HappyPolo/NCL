;================================================;
;  gsn_stream_3.ncl
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

  res@tiMainString     = "Basic Streamline/Scalar Plot"

  res@stLevelPalette   = "gui_default"             ; set color map

  res@tiMainString     = "Streamlines colored by a scalar field"

  plot = gsn_streamline_scalar(wks,u,v,speed,res)

end
