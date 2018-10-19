;*************************************************
; overlay_3.ncl
;
; Concepts illustrated:
;   - Overlaying line contours on filled contours
;   - Explicitly setting contour levels
;   - Overlaying plots manually by not advancing the frame
;   - Moving the contour informational label away from the plot
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
  res@gsnFrame     =  False                   ; do not advance the frame
  
  res@cnLevelSelectionMode = "ExplicitLevels" ; use explicit levels
  res@cnLevels = ispan(215,265,5)             ; set the contour levels
  res@cnLineLabelsOn = False                  ; do not use line labels
  res@cnFillOn        = True                  ; color fill
  res@cnLinesOn       = False                 ; do not draw contour lines
  res@cnFillPalette   = "BlueDarkRed18"
  res@tiMainString = "T/U @500hPa"            ; set the main title
  res@gsnLeftString = ""                      ; do not draw the left sub-title (otherwise automatically set to temp@long_name)
  res@gsnRightString = ""                     ; do not draw the right sub-title (otherwise automatically set to temp@units)

  sres = res
  sres@cnFillOn = False                       ; do not color fill
  sres@cnLinesOn = True                       ; turn the contour lines on
  sres@cnLineLabelsOn = True                  ; turn the line labels on
  sres@tiMainString = ""                      ; do not draw a main title
  delete(sres@cnLevels)                       ; needed as the size of the cnLevels attribute is about to change (next line)
  sres@cnLevels = ispan(-5,35,5)              ; set a different set of contour levels
  sres@cnInfoLabelOrthogonalPosF = 0.4        ; push the InfoLabel down below the label bar

  plot = gsn_csm_contour_map(wks,temp,res)    ; create and draw the temperature plot
  plot2 = gsn_csm_contour_map(wks,uwnd,sres)  ; create and draw the U-wind plot on top of the temperature plot
  frame(wks)                                  ; advance the frame
end
   
  
