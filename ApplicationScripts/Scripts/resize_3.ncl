;***********************************************
; resize_3.ncl
;***********************************************
;
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"  
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"   
;************************************************
begin
;************************************************
; read in netCDF file
;************************************************
  a = addfile("$NCARG_ROOT/lib/ncarg/data/cdf/uv300.nc","r")
;************************************************
; read in zonal winds
;************************************************
  u = a->U(1,:,:)                                ; read July zonal winds
;************************************************
; create plot
;************************************************
wks = gsn_open_wks("png","resize")      ; send graphics to PNG file

res              = True                 ; plot mods desired
res@tiMainString = "User Determined Aspect Ratio"
res@mpMinLatF    = -30.0		; only plot 30S to 30N
res@mpMaxLatF    =  30.0
cmap    = read_colormap_file("gui_default")
ncolors = dimsizes(cmap(:,0))               ; get the number of colors
res@cnFillPalette       = cmap(0:ncolors-3,:)   ; drop the last two colors

; change aspect ratio of strip plot. Note that w/o the mpShapeMode resource,
; NCL will take whatever values you input for Height and Width, and change 
; them behind the scenes so that the aspect ratio is maintained. Note also
; that this only happens with maps. You will be able to change a plain 
; contour plot, without "FreeAspect".
 
res@mpShapeMode  = "FreeAspect"
res@vpWidthF      = 0.8
res@vpHeightF     = 0.4

; Note that with this stretched plot, all the labeling returns to "normal",
; and we were able to remove many of the resources used in the first
; three examples.

res@cnFillOn               = True
;*****************************************
; create the plot
;*****************************************
plot = gsn_csm_contour_map(wks,u,res)	; create plot

end
