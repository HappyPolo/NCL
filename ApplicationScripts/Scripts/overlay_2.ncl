;*************************************************
; overlay_2.ncl
;
; Concepts illustrated:
;   - Overlaying line contours on filled contours
;   - Explicitly setting contour levels
;
;*************************************************
;
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"

begin
  a = addfile("80.nc","r")
  temp = a->T(0,{500},:,:)
  uwnd = a->U(0,{500},:,:)

  wks = gsn_open_wks("png","overlay")         ; send graphics to PNG file
  
  res = True
  res@mpFillOn = False
  res@mpMaxLatF = 60.                         ; specify the plot domain
  res@mpMinLatF = 20.                         ;                         
  res@mpMinLonF = 230.                        ;
  res@mpMaxLonF = 300.                        ;
  res@mpOutlineOn = True	                    ; turn the map outline on
  
  res@cnLevelSelectionMode = "ExplicitLevels" ; use explicit levels
  res@cnLevels = ispan(215,265,5)             ; set the contour levels
  res@cnLineLabelsOn = False                  ; do not use line labels
  res@cnFillOn        = True                  ; color fill
  res@cnLinesOn       = False                 ; do not draw contour lines
  res@cnFillPalette   = "BlueDarkRed18"
  res@tiMainString = "T/U @500hPa"            ; set the main title
  
  sres = True
  sres@cnLevelSelectionMode = "ExplicitLevels" ; use explicit levels
  sres@cnLevels = ispan(-5,35,5)              ; set the contour levels

  plot = gsn_csm_contour_map_overlay(wks,temp,uwnd,res,sres)  ; create the overlay plot
end
   
  
