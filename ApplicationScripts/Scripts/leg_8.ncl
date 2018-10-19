;*******************************************************
; leg_8.ncl
;
; Concepts illustrated:
;   - Drawing a custom legend outside a contour plot
;   - Attaching a legend to a plot
;   - Increasing the thickness of the legend perimeter
;   - Overlaying dashed contours on solid line contours
;
;*******************************************************
;
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
;*******************************************************
begin

;***********************************************
; open file and read in data
;***********************************************
 f     = addfile ("$NCARG_ROOT/lib/ncarg/data/cdf/contour.cdf", "r")
 T3    = f->T(2,0,:,:)                           ; get 3rd time and level
 T5    = f->T(4,0,:,:)                           ; get 5th time and level
;***********************************************
; plot resources
;***********************************************
 wks   = gsn_open_wks ("png", "leg" )            ; send graphics to PNG file

 res                   = True
 res@vpYF              = 0.85                    ; set height of plot

 res@gsnDraw           = False                   ; don't draw
 res@gsnFrame          = False			 ; don't advance frame

 res@cnInfoLabelOn     = False                   ; turn off info label
 res@cnLineThicknessF  = 2.                      ; line thickness
 res@tiMainString      = "Legend for Contour Plots"
;***********************************************
; create first contour plot
;***********************************************
 plotA  = gsn_csm_contour(wks, T3, res )         ; create first plot

;***********************************************
; create second contour plot
;***********************************************
 res@cnLineColor       = "Blue"                  ; blue contour lines 
 res@cnLineDashPattern = 12                      ; dashed lines
 plotB  = gsn_csm_contour(wks, T5, res )         ; second plot 

 overlay(plotA,plotB)                            ; Overlay plots; plot1 now
;***********************************************
; legend resources
;***********************************************
  lgres                    = True
  lgres@lgLineColors     = (/"foreground","blue"/)
  lgres@lgLineThicknessF   = res@cnLineThicknessF  ; legend line thickness = contour line thickness
  lgres@lgItemType         = "Lines"        ; show lines only (default)
  lgres@lgLabelFontHeightF = .08            ; set the legend label font thickness
  lgres@vpWidthF           = 0.15           ; width of legend (NDC)
  lgres@vpHeightF          = 0.1            ; height of legend (NDC)
  lgres@lgPerimColor       = "orange"       ; draw the box perimeter in orange
  lgres@lgPerimThicknessF  = 5.0            ; thicken the box perimeter
  lbid = gsn_create_legend(wks,2,(/" T3"," T5"/),lgres)         ; create legend

  amres = True
  amres@amParallelPosF   = 0.35		    ; move legend to the right
  amres@amOrthogonalPosF = 0.62             ; move the legend down
  annoid1 = gsn_add_annotation(plotA,lbid,amres)   ; add legend to plot

 draw(plotA)   ; Draw base plot.
 frame(wks)    ; advance frame
end
