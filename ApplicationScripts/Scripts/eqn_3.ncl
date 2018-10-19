; ===============================================
; eqn_3.ncl
;
; Concepts illustrated:
;   - Drawing the math symbol fonts
;   - Drawing text on the frame
;   - Increasing the font size of text
;   - Left-justifying text
;   - Changing the font of a text string using a function code
; ===============================================
;
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
;================================================
begin 
  wks   = gsn_open_wks ("png", "eqn" )            ; open a workstation and send data to PNG file  
  txres               = True                      ; text mods desired
  txres@txFontHeightF = 0.030                     ; text font height
  txres@txJust        = "CenterLeft"              ; Default is "CenterCenter".

; note that a colon is the default function code, but since I have personally
; set the default code to be a tilde (~) in my .hluresfile, I manually 
; reset it here, since the colon makes for a cleaner example.
  txres@txFuncCode    = ":"                 
;****************************
  gsn_text_ndc(wks,"The Math-Symbols",.23,.95,txres)
; first column
  gsn_text_ndc(wks,":F34:a",.2,.9,txres)
  gsn_text_ndc(wks,":F34:A",.2,.8,txres)
  gsn_text_ndc(wks,":F34:e",.2,.7,txres)
  gsn_text_ndc(wks,":F34:E",.2,.6,txres)
  gsn_text_ndc(wks,":F34:B",.2,.5,txres)
  gsn_text_ndc(wks,":F34:C",.2,.4,txres)
  gsn_text_ndc(wks,":F34:F",.2,.3,txres)
  gsn_text_ndc(wks,":F34:G",.2,.2,txres)
  gsn_text_ndc(wks,":F34:H",.2,.1,txres)
; second column
  gsn_text_ndc(wks,":F34:J",.4,.9,txres)
  gsn_text_ndc(wks,":F34:K",.4,.8,txres)
  gsn_text_ndc(wks,":F34:L",.4,.7,txres)
  gsn_text_ndc(wks,":F34:M",.4,.6,txres)
  gsn_text_ndc(wks,":F34:N",.4,.5,txres)
  gsn_text_ndc(wks,":F34:O",.4,.4,txres)
  gsn_text_ndc(wks,":F34:P",.4,.3,txres)
  gsn_text_ndc(wks,":F34:q",.4,.2,txres)
  gsn_text_ndc(wks,":F34:r",.4,.1,txres)
; third column
  gsn_text_ndc(wks,":F34:s",.6,.9,txres)
  gsn_text_ndc(wks,":F34:t",.6,.8,txres)
  gsn_text_ndc(wks,":F34:u",.6,.7,txres)
  gsn_text_ndc(wks,":F34:Q",.6,.6,txres)
  gsn_text_ndc(wks,":F34:V",.6,.5,txres)
  gsn_text_ndc(wks,":F34:W",.6,.4,txres)
  gsn_text_ndc(wks,":F34:Y",.6,.3,txres)
  gsn_text_ndc(wks,":F34:Z",.6,.2,txres)

  draw(wks)
  frame(wks)     
end 
                      
