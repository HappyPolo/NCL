;================================================;
;  gsn_contour_2.ncl
;================================================;
; Concepts illustrated:
;   - Drawing a basic contour plot using gsn_contour
;   - Spanning the full color map for contour fill
;   - Turning on color fill for a contour plot
;   - Turning off contour line labels
;   - Turning off the contour informational label
;   - Changing the size/shape of a contour plot using viewport resources
;   - Increasing the size of tickmark labels
;
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
  wks  = gsn_open_wks("png","gsn_contour")    ; send graphics to PNG file

  res                     = True
  res@cnFillOn            = True         ; turn on color
  res@cnFillPalette       = "gui_default";set color map

  res@cnLineLabelsOn      = False        ; no contour line labels
  res@cnInfoLabelOn       = False        ; no info label
 
  res@vpWidthF  = 0.8                    ; change the aspect ratio
  res@vpHeightF = 0.4
  res@vpXF      = .1                     ; location of where plot starts
  res@vpYF      = .7

  res@tmXBLabelFontHeightF = 0.025       ; label font height
  res@tmYLLabelFontHeightF = 0.025

  plot = gsn_contour(wks,u,res)          ; contour the variable


  end
