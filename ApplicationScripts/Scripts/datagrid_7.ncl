;--------------------------------------------------
;  datagrid_7.ncl
;
; Concepts illustrated: 
;   - Drawing locations of contour data points using gsn_coordinates
;--------------------------------------------------
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"   
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"   
;--------------------------------------------------
begin
  f    = addfile("cone.nc","r")
  u  = f->u(5,:,:)                

  wks  = gsn_open_wks("png","datagrid")    ; send graphics to PNG file

  res                = True
  res@gsnMaximize    = True          ; maximize plot size
  res@gsnDraw        = False         ; will draw and advance
  res@gsnFrame       = False         ; frame later

  res@cnFillOn       = True          ; turn on color
  res@cnFillOpacityF = 0.5           ; draw contours partially transparent
  res@cnLinesOn      = False
  res@lbOrientation  = "vertical"

  plot = gsn_csm_contour(wks,u,res)
  gsn_coordinates(wks,plot,u,True)
end
