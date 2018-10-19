;*************************************************
; table_3.ncl
;
; Concepts illustrated:
;   - Drawing several tables using gsn_table
;   - Specifying the NDC position of individual tables
;   - Filling table cells with a given color
;   - Filling table cells with a given pattern
;   - Rotating text in a table cell
;   - Justifying text in a table cell
;
;*************************************************
;
; This file is loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"

begin
  wks = gsn_open_wks("png","table")  ; send graphics to PNG file

  res        = True             ; Set up resource list

  res@gsLineThicknessF = 2.     ; Increase thickness of grid lines.

;
; Array for text strings.  Must be dimensioned nrows x ncols.
;
  ncr  = (/3,3/)     ; 3 rows, 3 columns
  text = (/ (/"Index 1",       "Index 2",       "Index 3"/),       \
            (/"Row 2~C~Col 1", "Row 2~C~Col 2", "Row 2~C~Col 3"/), \
            (/"~F34~[",        "~F34~u",        "~F37~l"/)/)
;
; Position of text in cell.  Default is "CenterCenter"
; for all grid cells.
;
  res@txJust = (/ (/"CenterCenter","CenterCenter","CenterCenter"/),\
                  (/"CenterRight", "CenterRight", "CenterRight" /),\
                  (/"CenterCenter","CenterCenter","CenterCenter"/)/)
;
; Text color
;
  res@txFontColor = (/ (/"gray",   "Cyan",     "black"   /), \
                       (/"orange", "NavyBlue", "HotPink" /), \
                       (/"green",  "purple",   "brown"   /)/)
;
; Text height.
;
  res@txFontHeightF = (/ (/.03,.03,.03/),(/.03,.03,.03/),(/.05,.05,.05/)/)

  x = (/0.50,0.95/)       ; Start and end X
  y = (/0.40,0.70/)       ; Start and end Y

  gsn_table(wks,ncr,x,y,text,res)    ; Draw table

;
; Second table.
;
  ncr   = (/2,1/)            ; Two rows, one column
  text2 = (/"Small","Table"/)
  
  x = (/0.60,0.80/)       ; Start and end X
  y = (/0.15,0.30/)       ; Start and end Y

  res2 = True             ; New set of resources

  res2@gsFillIndex           = 17                    ; 17 = filled dots
  res2@gsFillBackgroundColor = (/"Cyan","Green"/)
  res2@txFontColor           = "White"    
  res2@txFontHeightF         = 0.04

  res2@txJust = (/"TopCenter","BottomCenter"/)

  gsn_table(wks,ncr,x,y,text2,res2)    ; Draw table

;
; Third table.
;
  ncr   = (/1,3/)            ; One row, three columns
  text3 = (/"Another","Small","Table"/)
  
  x = (/0.05,0.35/)       ; Start and end X
  y = (/0.10,0.35/)       ; Start and end Y

  res3 = True             ; New set of resources

  res3@txAngleF      = 90     ; Rotate counter clockwise 90 degrees
  res3@txFontColor   = 2
  res3@txFontHeightF = 0.03

  gsn_table(wks,ncr,x,y,text3,res3)    ; Draw table

;
; Fourth table, which serves as a header for the third table.
;
  ncr   = (/1,1/)            ; One row, one column
  text4 = "Header"

  res4  = True
  res4@gsFillColor = "gray75"
  
  x = (/0.05,0.35/)       ; Start and end X
  y = (/0.35,0.45/)       ; Start and end Y

  gsn_table(wks,ncr,x,y,text4,res4)    ; Draw table

;
; Fifth table.
;
;
; Note the spaces in front of text to force a small margin.
;
  ncr   = (/4,2/)     ; 4 rows, 2 columns
  text5 = (/ (/" ONE"," TWO"/), (/" THREE"," FOUR"/),(/""," SIX"/), \
             (/" SEVEN",""/)/)
  
  x = (/0.05,0.45/)       ; Start and end X
  y = (/0.50,0.95/)       ; Start and end Y

  res5 = True                  ; New resource list
  res5@gsFillColor = (/ (/"cyan","orange"/),(/"purple","green"/), \
                        (/"gray","gray"/),(/"palegreen","hotpink"/)/)
  res5@txJust = "CenterLeft"   ; Left-justified
  res5@txFontHeightF = 0.02    ; Font Height

  gsn_table(wks,ncr,x,y,text5,res5)    ; Draw table

  frame(wks)      ; Advance the frame.

end
