;================================================;
;  gsn_contour_1.ncl
;================================================;
;
; Concepts illustrated:
;   - Drawing a basic contour plot using gsn_contour
;================================================;
;
; This file is loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
; ================================================;
begin
;=================================================;
; open file and read in data
;=================================================;
  f    = addfile("cone.nc","r")
  u  = f->u(4,:,:)                
;=================================================;
; PLOT 2
;=================================================;
  wks  = gsn_open_wks("png","gsn_contour")     ; send graphics to PNG file
  plot = gsn_contour(wks,u,False)              ; contour the variable

  end
