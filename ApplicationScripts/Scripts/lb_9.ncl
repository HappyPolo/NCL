;================================================
;  lb_9.ncl
;================================================
; Concepts illustrated:
;   - Keeping labelbar labels from overlapping
;   - Changing the contour level spacing
;   - Drawing a custom labelbar
;   - Turning off the perimeter around a labelbar
;   - Setting the fill colors for a labelbar
;   - Setting the fill patterns for a labelbar
;   - Increasing the thickness of fill patterns in a labelbar
;   - Increasing the density of fill patterns in a labelbar
;================================================
;
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"   
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"    
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"    
;************************************************
; This example shows how to create your own labelbar
; and force it to use a nice span of colors in your
; color map. The gsnSpreadColors resource can't be 
; used here; it is only recognized by contour and
; vector routines.
;
begin
  wks  = gsn_open_wks("png","lb")       ; send graphics to PNG file
  gsn_define_colormap(wks,"testcmap")

  nboxes = 7                            ; # of labelbar boxes
  clen   = 201                          ; # of colors in color map
  stride = ((clen-1) - 2) / nboxes      ; Start at color index 2 and end
                                        ; near color index clen-1.
  fill_colors = ispan(2,clen-1,stride)
  lblabels    = "" + fspan(0,200,dimsizes(fill_colors))
  
  lbres                           = True
  lbres@lbAutoManage              = False         ; we control label bar
  lbres@lbFillColors              = fill_colors   ; use nice strided colors  
  lbres@lbPerimOn                 = False         ; Turn off labelbar perimeter.
  lbres@lbMonoFillPattern         = True          ; one pattern, all solid

  gsn_labelbar_ndc(wks,nboxes,lblabels,0.2,0.8,lbres)
  frame(wks)
  
  lbres@lbMonoFillPattern    = False  ; allow multiple patterns
  lbres@lbFillColors         = (/30,50,70,90,110,150,170,200/)
  lbres@lbFillPatterns       = (/ 1,13,10,12,16,17, 8, 16/)

  lbres@lbFillLineThicknessF = 2.0  ; Increase thickness of pattern lines

  gsn_labelbar_ndc(wks,nboxes,lblabels,0.2,0.8,lbres)
  frame(wks)

  delete(lbres@lbFillLineThicknessF)
  lbres@lbFillScaleF         = 0.5  ; Increase density of patterns

  gsn_labelbar_ndc(wks,nboxes,lblabels,0.2,0.8,lbres)
  frame(wks)
end
