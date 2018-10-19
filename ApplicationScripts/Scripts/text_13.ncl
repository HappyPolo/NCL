
;*************************************************
; text_13.ncl
;
; Concepts illustrated:
;   - Aligning text in various ways using the txJust resource
;   - Drawing the bounding box of a text string
;   - Drawing polylines, polymarkers, and text in NDC space
;   - Using drawNDCGrid to draw a nicely labeled NDC grid
;
;************************************************
;
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
;
; This file still has to be loaded manually
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl"
;************************************************

; 
; This example shows how to use the txJust resource to align
; text. To place text using a gsn_text* routine, you specify
; an X and Y position. By default, the string is centered
; about that X,Y position, unless you set txJust to one of
; eight other values.
;
; Here are all nine justification values:
;
;   "BottomRight"   "CenterRight"   "TopRight"
;   "BottomCenter"  "CenterCenter"  "TopCenter"
;   "BottomLeft"    "CenterLeft"    "TopLeft"
;
; These indicate possible locations (on an invisible box that encloses
; the whole string) that can be used to orient the text.

;
; This procedure draws the bounding box that encompasses the string.
;
undef("draw_bb")
procedure draw_bb(tid)
local wks, bb, top, bot, lft, rgt, gsres
begin
  wks = NhlGetParentWorkstation(tid)

  bb = NhlGetBB(tid)
  top = bb(0)
  bot = bb(1)
  lft = bb(2)
  rgt = bb(3)
  
; Line resources
  gsres = True
;  gsres@gsLineThicknessF = 5.0
  gsres@gsLineColor      = "red"

  gsn_polyline_ndc(wks,(/lft,rgt,rgt,lft,lft/), \
                       (/bot,bot,top,top,bot/),gsres)
end

;
; This procedure draws a polymarker and label at the location
; where the text box is being positioned.
;
undef("draw_label")
procedure draw_label(tid:graphic)
local wks, x, y, just, tres, mkres
begin
  wks = NhlGetParentWorkstation(tid)

  getvalues tid
    "txPosXF"  : x
    "txPosYF"  : y
    "txJust"   : ijust
  end getvalues

  mkres               = True        ; Marker resources
  mkres@gsMarkerIndex = 16          ; Filled dot
  mkres@gsMarkerColor = "blue"      ; Blue dot
  mkres@gsMarkerSizeF = 0.014       ; Make it larger

  gsn_polymarker_ndc(wks,x,y,mkres)

  tres               = True         ; Text resources
  tres@txFontHeightF = 0.015
;
; txJust:
;
; 0 = TopLeft    1 = CenterLeft    2 = BottomLeft
; 3 = TopCenter  4 = CenterCenter  5 = BottomCenter
; 6 = TopRight   7 = CenterRight   8 = BottomRight
;
; Based on the txJust for the original string, use these justifications
; for the little label.
  tjust = (/"BottomRight", "CenterRight", "TopRight", "BottomCenter", \
            "TopCenter", "TopCenter", "BottomLeft", "CenterLeft", "TopLeft"/)

  xadj  = (/-0.01,-0.01,-0.01,0.0, 0.0,  0.0, 0.01,0.01, 0.01/)
  yadj  = (/ 0.01, 0.0 ,-0.01,0.01,0.05,-0.01,0.01,0.0, -0.01/)
  tres@txJust = tjust(ijust)

  str = "(" + x + "," + y + ")"
  x = x + xadj(ijust)
  y = y + yadj(ijust)
  gsn_text_ndc(wks,str,x,y,tres)
end


; Main code.

begin
  wks = gsn_open_wks("png","text")            ; send graphics to PNG file

  drawNDCGrid(wks)                            ; Draw an NDC grid

; Draw some titles at the top.

  txres               = True   ; Set up resource list for text strings
  txres@txFontHeightF = 0.025
  gsn_text_ndc(wks,"Nine possible values for resource 'txJust'",0.5,0.97,txres)

  txres@txFontHeightF = 0.02
  gsn_text_ndc(wks,"Red box denotes bounding box, used to determine location of justification point.",0.5,0.93,txres)
  gsn_text_ndc(wks,"Blue dot w/label shows location and value of txPosXF/txPosYF.",0.5,0.89,txres)

; Get ready to draw 9 text strings, each with a different justification
; point.
  xpos = (/0.25, 0.50, 0.75/)   ; The X positions for the text boxes.
;  ypos = ispan(1,9,1) * .1 - 0.05
   ypos = (/0.10, 0.19, 0.28, 0.37, 0.46, 0.55, 0.64, 0.73, 0.82/)

  just_strs = (/"BottomRight","CenterRight","TopRight","BottomCenter", \
                "CenterCenter","TopCenter","BottomLeft","CenterLeft",  \
                "TopLeft"/)

  txres@txFontHeightF = 0.03
  txres@txFontColor   = "Black"
  txres@gsnDraw       = True

  txid = new(9,graphic)      ; Id to hold text strings.

  ic = 0
  do iy = 0,2
    do ix = 0,2
      xp = xpos(ix)
      yp = ypos(ic)
      txres@txJust = just_strs(ic)

; Create and draw string.
      txid(ic) = gsn_create_text_ndc(wks,just_strs(ic),xp,yp,txres)

; Draw bounding box around string.
      draw_bb(txid(ic))

; Draw marker and label.
      draw_label(txid(ic))
      ic = ic + 1
    end do
  end do

  frame(wks)
end
