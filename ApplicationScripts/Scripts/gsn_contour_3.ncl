;================================================;
;  gsn_contour_3.ncl
;================================================;
; Concepts illustrated:
;   - Drawing a basic contour plot using gsn_contour
;   - Turning on a labelbar for a contour plot
;   - Customizing a labelbar for a contour plot
;   - Changing the font size of the labelbar's labels
;   - Changing the width and height of a labelbar
;   - Making the labelbar be horizontal
;   - Turning off the perimeter around a labelbar
;   - Moving the labelbar away from the plot
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
  wks  = gsn_open_wks("png","gsn_contour")   ; send graphics to PNG file

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


  res@pmLabelBarDisplayMode   = "Always" ; turn on color bar
  res@pmLabelBarSide          = "Bottom" ; put it on the bottom of plot
  res@pmLabelBarWidthF        = 0.4      ; control size of colorbar
  res@pmLabelBarHeightF       = 0.1      ;
  res@pmLabelBarOrthogonalPosF = -0.02   ; position wrt plot
  res@lbLabelFontHeightF      = 0.02     ; label bar font
  res@lbOrientation           = "Horizontal" ; label bar orientation
  res@lbPerimOn               = False    ; no box around label bar
  res@lbAutoManage            = False	 ; we control how drawn not plot 



  plot = gsn_contour(wks,u,res)          ; contour the variable


  end
