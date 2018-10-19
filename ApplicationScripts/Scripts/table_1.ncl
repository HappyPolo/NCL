;*************************************************
; table_1.ncl
;
; Concepts illustrated:
;   - Drawing a table using gsn_table
;   - Justifying text in a table cell
;
;*************************************************
;
; This file is loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"

begin
  wks = gsn_open_wks("png","table") ; send graphics to PNG file

  res = False      ; No resources desired.
;
; Array for text strings.  Must be dimensioned 4 x 3.
;
  ncr = (/4,3/)     ; 4 rows, 3 columns

  text = (/ (/"R1,C1", "R1,C2", "R1,C3"/), \
            (/"R2,C1", "R2,C2", "R2,C3"/), \
            (/"R3,C1", "R3,C2", "R3,C3"/), \
            (/"R4,C1", "R4,C2", "R4,C3"/) /)

  x = (/0.15,0.85/)         ; Start and end X
  y = (/0.20,0.80/)       ; Start and end Y

  gsn_table(wks,ncr,x,y,text,res)
  frame(wks)      ; Advance the frame.

;
; Position of text in cell.  Default is "CenterCenter"
; for all grid cells.
;
  res = True
  res@txJust = (/ \
     (/"CenterCenter","CenterCenter","CenterCenter"/),\
     (/"CenterLeft",  "CenterLeft",  "CenterLeft"  /),\
     (/"CenterRight", "CenterRight", "CenterRight" /),\
     (/"BottomCenter","BottomCenter","BottomCenter"/)/)

  gsn_table(wks,ncr,x,y,text,res)

  frame(wks)      ; Advance the frame.


end
