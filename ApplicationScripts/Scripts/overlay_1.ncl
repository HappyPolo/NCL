;*************************************************
; overlay_1.ncl
;
; Concepts illustrated:
;   - Overlaying line contours on filled contours
;   - Explicitly setting contour levels
;   - Selecting a different color map for each contour plot
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
  res@mpFillOn     = False
  res@mpMaxLatF    = 60.                      ; specify the plot domain
  res@mpMinLatF    = 20.                      ;                         
  res@mpMinLonF    = 230.                     ;
  res@mpMaxLonF    = 300.                     ;
  res@mpOutlineOn  = True	              ; turn the map outline on
  res@gsnDraw      =  False                   ; do not draw the plot
  res@gsnFrame     =  False                   ; do not advance the frame
  
  res@cnLevelSelectionMode = "ExplicitLevels" ; use explicit levels
  res@cnLevels             = ispan(215,265,5) ; set the contour levels
  res@cnLineLabelsOn       = False            ; do not use line labels
  res@cnFillOn             = True             ; color fill
  res@cnLinesOn            = False            ; do not draw contour lines
  res@cnFillPalette        = "BlueDarkRed18"

  res@tiMainString = "T/U @500hPa"            ; set the main title
  
  sres                      = True              ; set up a second resource list
  sres@gsnDraw              = False             ; do not draw the plot
  sres@gsnFrame             = False             ; do not advance the frame
  sres@cnLevelSelectionMode = "ExplicitLevels"  ; use explicit levels
  sres@cnLevels             = ispan(-5,35,5 )   ; set the contour levels

  plot    = gsn_csm_contour_map(wks,temp,res)   ; create the temperature plot
  plot_ov = gsn_csm_contour(wks,uwnd,sres)      ; create the U-wind plot

  overlay(plot,plot_ov)                       ; overlay the U-wind plot on the temperature plot
  draw(plot)                                  ; draw the temperature plot (with the U-wind plot overlaid)
  frame(wks)                                  ; advance the frame
end
   
  
