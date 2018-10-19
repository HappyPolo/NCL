; ===============================================
; eqn_2.ncl
;
; Concepts illustrated:
;   - Drawing the math character fonts
;   - Drawing text on the frame
;   - Increasing the font size of text
;   - Left-justifying text
;   - Changing the font of a text string using a function code
;
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
  gsn_text_ndc(wks,"The Math Character Set",.23,.95,txres)
; first column
  gsn_text_ndc(wks,":F18:a",.2,.9,txres)
  gsn_text_ndc(wks,":F18:b",.2,.8,txres)
  gsn_text_ndc(wks,":F18:c",.2,.7,txres)
  gsn_text_ndc(wks,":F18:d",.2,.6,txres)
  gsn_text_ndc(wks,":F18:e",.2,.5,txres)
  gsn_text_ndc(wks,":F18:f",.2,.4,txres)
  gsn_text_ndc(wks,":F18:g",.2,.3,txres)
  gsn_text_ndc(wks,":F18:h",.2,.2,txres)
  gsn_text_ndc(wks,":F18:i",.2,.1,txres)
; second column
  gsn_text_ndc(wks,":F18:j",.4,.9,txres)
  gsn_text_ndc(wks,":F18:k",.4,.8,txres)
  gsn_text_ndc(wks,":F18:l",.4,.7,txres)
  gsn_text_ndc(wks,":F18:m",.4,.6,txres)
  gsn_text_ndc(wks,":F18:n",.4,.5,txres)
  gsn_text_ndc(wks,":F18:o",.4,.4,txres)
  gsn_text_ndc(wks,":F18:p",.4,.3,txres)
  gsn_text_ndc(wks,":F18:q",.4,.2,txres)
  gsn_text_ndc(wks,":F18:r",.4,.1,txres)
; third column
  gsn_text_ndc(wks,":F18:s",.6,.9,txres)
  gsn_text_ndc(wks,":F18:t",.6,.8,txres)
  gsn_text_ndc(wks,":F18:u",.6,.7,txres)
  gsn_text_ndc(wks,":F18:v",.6,.6,txres)
  gsn_text_ndc(wks,":F18:w",.6,.5,txres)
  gsn_text_ndc(wks,":F18:x",.6,.4,txres)
  gsn_text_ndc(wks,":F18:y",.6,.3,txres)
  gsn_text_ndc(wks,":F18:z",.6,.2,txres)

  draw(wks)
  frame(wks)     
end 
                      
