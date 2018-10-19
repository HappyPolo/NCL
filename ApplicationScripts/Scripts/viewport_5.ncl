;*************************************************
; viewport_5.ncl
;
; Concepts illustrated:
;   - Drawing a custom labelbar
;   - Drawing text on the frame
;   - Drawing the bounding box
;   - Drawing polylines, polymarkers, and text in NDC space
;   - Using drawNDCGrid to draw a nicely labeled NDC grid
;   - Changing the font of a text string
;   - Using "getvalues" to retrieve resource values
;   - Adding a carriage return to a text string using a function code 
;   - Changing the font of a text string using a function code
;   - Including a double quote in a text string
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

;********************************************************************
; Draw illustrations for the viewport values.
;********************************************************************
procedure draw_vp_illus(wks,plot)
local vpx, vpy, vpw, vph, xbox, ybox, lnres, mkres, txres
begin

; Retrieve the viewport values of the drawable object.
  getvalues plot
    "vpXF"      : vpx
    "vpYF"      : vpy
    "vpWidthF"  : vpw
    "vpHeightF" : vph
  end getvalues

; Set up some marker resources.
  mkres                  = True
  mkres@gsMarkerIndex    = 16     ; filled dot
  mkres@gsMarkerSizeF    = 0.02   ; larger than default
  mkres@gsMarkerColor    = "Red"

; Draw a single marker at the vpXF/vpYF location.
  gsn_polymarker_ndc(wks,vpx,vpy,mkres)

; Set up some text resources.
  txres                       = True  
  txres@txJust                = "BottomLeft"
  txres@txFontHeightF         = 0.018
  txres@txFontColor           = "Blue"
  txres@txBackgroundFillColor = "white"

  gsn_text_ndc(wks,"(vpXF="+vpx+", vpYF="+vpy+")",vpx,vpy+0.02,txres)

; Set up some line resources.
  lnres                  = True
  lnres@gsLineColor      = "Red"       ; line color
  lnres@gsLineThicknessF = 2.0         ; 3.5 times as thick

; Draw lines indicating the width and height
  xline = (/vpx,     vpx+vpw/)
  yline = (/vpy-0.05,vpy-0.05/)
  gsn_polyline_ndc(wks,xline,yline,lnres)

  xline = (/vpx+0.05,vpx+0.05/)
  yline = (/vpy,vpy-vph/)
  gsn_polyline_ndc(wks,xline,yline,lnres)

  txres@txJust                = "CenterCenter"
  gsn_text_ndc(wks,"vpWidthF = " + vpw,vpx+vpw/2.,vpy-0.05,txres)

  txres@txAngleF              = 90.
  gsn_text_ndc(wks,"vpHeightF = " + vph,vpx+0.05,vpy-vph/2.,txres)
end

;********************************************************************
; Draw a box around the bounding box of the given object..
;********************************************************************
procedure draw_bb_box(wks,plot,bbres)
local bb, top, bot, lft, rgt, xbox, ybox, lnres
begin
; Retrieve the bounding box of the given object.
  bb  = NhlGetBB(plot)
  top = bb(0)
  bot = bb(1)
  lft = bb(2)
  rgt = bb(3)

; Make a box with the bounding box values.
  xbox = (/rgt,lft,lft,rgt,rgt/)
  ybox = (/top,top,bot,bot,top/)

; Set up some line resources.
  lnres                   = True
  lnres@gsLineColor       = "Brown"
  lnres@gsLineThicknessF  = 2.5

; Set up some text resources.
  txres                       = True
  txres@txFontHeightF         = 0.015
  txres@txBackgroundFillColor = "white"
  txres@txJust                = "CenterLeft"

; Draw a box showing the bounding box.
  gsn_polyline_ndc(wks,xbox,ybox,lnres)

; Draw text strings labeling the bounding box.

  if(isatt(bbres,"DrawBBText").and.bbres@DrawBBText) then
    gsn_text_ndc(wks,"bounding box",lft+0.05,bot,txres)
    txres@txJust                = "CenterRight"
    gsn_text_ndc(wks,"bounding box",rgt-0.05,top,txres)

    txres@txAngleF              = 90.
    txres@txJust                = "CenterRight"
    gsn_text_ndc(wks,"bounding box",lft,top-0.05,txres)

    txres@txJust                = "CenterLeft"
    gsn_text_ndc(wks,"bounding box",rgt,bot+0.05,txres)
  end if
end

;********************************************************************
; Main code
;********************************************************************
begin
;
; This code draws a labelbar on one frame, and
; two text boxes on another.
;

  wks = gsn_open_wks("png","viewport")  ; send graphics to PNG file
  gsn_define_colormap(wks, "default")


; Set up values and resources for a labelbar
  fill_colors = ispan(2,23,1)
  lblabels    = "" + fill_colors
  nboxes      = dimsizes(fill_colors)
  
  lbres                    = True

  lbres@vpHeightF          = 0.7         ; Set height and width
  lbres@vpWidthF           = 0.4

  lbres@lbAutoManage       = False       ; Allow us to control labelbar

  lbres@lbTitleString      = "Labelbar title"
  lbres@lbTitleFontHeightF = 0.018

  lbres@lbFillColors       = fill_colors   ; Use nice strided colors  
  lbres@lbPerimOn          = False         ; Turn off labelbar perimeter.
  lbres@lbMonoFillPattern  = True          ; One pattern; default is solid

  lbres@lbBottomMarginF    = 0.0           ; No white space at bottom

; Create the labelbar.
  labelbar = gsn_create_labelbar_ndc(wks,nboxes,lblabels,0.3,0.8,lbres)

  drawNDCGrid(wks)                 ; Draw helpful grid lines showing
                                   ; NDC square.
  draw(labelbar)                   ; Draw the labelbar.
  draw_bb_box(wks,labelbar,False)  ; Draw the bounding box.
  draw_vp_illus(wks,labelbar)      ; Draw the viewport illustrations.

  frame(wks)              ; Advance the frame.

; Set up some text resources.
  txres                       = True  
  txres@txJust                = "CenterLeft"
  txres@txFontHeightF         = 0.04
  txres@txBackgroundFillColor = "yellow"

  txres@txPosXF               = 0.2   ; Rough approximation
  txres@txPosYF               = 0.7

  quote = str_get_dq()    ; Double quote

  emq = quote + "A computer once beat me~C~"  + \
                " at chess, but it was no~C~" + \
                " match for me at kick~C~"    + \
                " boxing." + quote + "~C~" + \
                "                   --Emo Philips"

; Create the first text string.
  text = gsn_create_text(wks,emq,txres)

  bbres = True
  bbres@DrawBBText = False

  drawNDCGrid(wks)                 ; Draw helpful grid lines showing
                                   ; NDC square.
  draw(text)                       ; Draw text box.
  draw_bb_box(wks,text,bbres)      ; Draw the bounding box
  draw_vp_illus(wks,text)          ; Draw the viewport illustrations.

  txres@txPerimSpaceF         = 0.   ; Remove any margins
  txres@txPosYF               = 0.3  ; Rough estimate of text
  txres@txPosXF               = 0.1; ; position.

  ltq = quote + "~F25~I always wanted to be somebody,~C~"   + \
                " but now I realize I should have~C~"  + \
                " been more specific." + quote + "~C~" + \
                "~F26~                                   --Lily Tomlin"

; Create the second text string.
  text = gsn_create_text(wks,ltq,txres)

  draw(text)                       ; Draw text box.
  draw_bb_box(wks,text,bbres)      ; Draw the bounding box
  draw_vp_illus(wks,text)          ; Draw the viewport illustrations.

  frame(wks)                       ; Advance the frame.

end
