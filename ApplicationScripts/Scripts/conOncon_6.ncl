;*******************************************************
; conOncon_6.ncl
;
; Concepts illustrated:
;   - Overlaying dashed contours on solid line contours
;   - Changing the dash pattern of a contour line
;   - Drawing a legend on a contour plot
;   - Changing the colors of lines inside a legend
;   - Changing the dash patterns of lines inside a legend
;   - Changing the width and height of a legend
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
 T1    = f->T(0,0,:,:)                           ; get 1st time and level
 T5    = f->T(4,0,:,:)                           ; get 5th time and level
;***********************************************
; plot resources
;***********************************************
 wks   = gsn_open_wks ("png", "conOncon" )       ; send graphics to PNG file

 res                   = True
 res@vpYF              = 0.85                    ; set height of plot

 res@gsnDraw           = False                   ; don't draw
 res@gsnFrame          = False			 ; don't advance frame

 res@cnInfoLabelOn     = False                   ; turn off info label
 res@cnLineThicknessF  = 2.                      ; line thickness
 res@tiMainString      = "Contour on Contour w/ Legend"
;***********************************************
; create first contour plot
;***********************************************
 plotA  = gsn_csm_contour(wks, T1, res )         ; create first plot

;***********************************************
; create second contour plot
;***********************************************
 res@cnLineColor       = "Blue"                  ; blue contour lines 
 res@cnLineDashPattern = 12                      ; dashed lines
 plotB  = gsn_csm_contour(wks, T5, res )         ; second plot 

 overlay(plotA,plotB)                            ; Overlay plots; plot1 now
 draw(plotA)                                     ; Draw base plot.
;***********************************************
; legend resources
;***********************************************
 lgres                    = True
 lgres@lgLineColors       = (/"black","blue"/)    ; colors for legend lines
 lgres@vpWidthF           = 0.2                   ; width of legend (NDC)
 lgres@vpHeightF          = 0.1                   ; height of legend (NDC)
 lgres@lgPerimOn          = False                 ; turn off perimeter
 lgres@lgDashIndexes      = (/0,12/)              ; dash indexes
 lgres@lgLineLabelStrings = (/"",""/)             ; no labels in lines

;**************************************************************
; Draw the legend, indicating the number of items, a label for each
; item, and the X, Y position of the legend in NDC coordinates.
;**************************************************************
 gsn_legend_ndc(wks,2,(/"time=0","time=4"/),0.4,0.15,lgres)

 frame(wks)                                        ; finally advance frame

end

