;================================================;
;  gsn_vec_scal_2.ncl
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
; PLOT 2
;=================================================;
  wks  = gsn_open_wks("png","gsn_vec_scal")         ; send graphics to PNG file

  resC                  = True                      ; plot mods desired
  resC@tiMainString     = "Basic Vector/Scalar Plot"
  resC@cnFillOn         = True                      ; turn on color
  resC@cnFillPalette    = "gui_default"             ; set contour color map

  resC@cnLineLabelsOn   = False                     ; no contour line labels
  resC@cnInfoLabelOn    = False                     ; no info label
  resC@gsnDraw          = False                     ; don't draw yet
  resC@gsnFrame         = False                     ; don't advance yet

  plot = gsn_contour(wks,speed(10:30,20:40),resC)   ; contour the variable

  resV                  = True                      ; vector only resources
  resV@gsnDraw          = False                     ; don'd draw yet
  resV@gsnFrame         = False                     ; don't advance yet
  resV@vcRefMagnitudeF  = 5.0                       ; add a reference vector
  resV@vcRefLengthF     = 0.045                     ; what the ref length is
  resV@vcGlyphStyle     = "CurlyVector"             ; turn on curly vectors
  resV@vcLevelPalette   = "gui_default"             ; set vector color map
  plotV = gsn_vector(wks,u(10:30,20:40),v(10:30,20:40),resV)

  overlay(plot,plotV)
  draw(plot)
  frame(wks)
  end
