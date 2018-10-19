; ===============================================
; eqn_1.ncl
;
; Concepts illustrated:
;   - Drawing the Greek character fonts
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
  wks   = gsn_open_wks ("png", "eqn" )            ; open a workstation and send graphics to PNG file    
  txres               = True                      ; text mods desired
  txres@txFontHeightF = 0.030                     ; text font height
  txres@txJust        = "CenterLeft"              ; Default is "CenterCenter".

; note that a colon is the default function code, but since I have personally
; set the default code to be a tilde (~) in my .hluresfile, I manually 
; reset it here, since the colon makes for a cleaner example.
  txres@txFuncCode    = ":"                 
;****************************
; drawing Greek characters
;****************************
; to get Greek characters, you much change your default font set. we do
; this by first writing the function code ":", then the font set we wish
; to access. In this case it is set 8, and then another function code and
; the letter whe wish to write. so, for an alpha, we get ":F8:a"


  gsn_text_ndc(wks,"The Greek Character Set",.23,.95,txres)
; first column
  gsn_text_ndc(wks,":F8:a",.2,.9,txres)
  gsn_text_ndc(wks,":F8:b",.2,.8,txres)
  gsn_text_ndc(wks,":F8:c",.2,.7,txres)
  gsn_text_ndc(wks,":F8:d",.2,.6,txres)
  gsn_text_ndc(wks,":F8:e",.2,.5,txres)
  gsn_text_ndc(wks,":F8:f",.2,.4,txres)
  gsn_text_ndc(wks,":F8:g",.2,.3,txres)
  gsn_text_ndc(wks,":F8:h",.2,.2,txres)
  gsn_text_ndc(wks,":F8:i",.2,.1,txres)
; second column
  gsn_text_ndc(wks,":F8:j",.4,.9,txres)
  gsn_text_ndc(wks,":F8:k",.4,.8,txres)
  gsn_text_ndc(wks,":F8:l",.4,.7,txres)
  gsn_text_ndc(wks,":F8:m",.4,.6,txres)
  gsn_text_ndc(wks,":F8:n",.4,.5,txres)
  gsn_text_ndc(wks,":F8:o",.4,.4,txres)
  gsn_text_ndc(wks,":F8:p",.4,.3,txres)
  gsn_text_ndc(wks,":F8:q",.4,.2,txres)
  gsn_text_ndc(wks,":F8:r",.4,.1,txres)
; third column
  gsn_text_ndc(wks,":F8:s",.6,.9,txres)
  gsn_text_ndc(wks,":F8:t",.6,.8,txres)
  gsn_text_ndc(wks,":F8:u",.6,.7,txres)
  gsn_text_ndc(wks,":F8:v",.6,.6,txres)
  gsn_text_ndc(wks,":F8:w",.6,.5,txres)
  gsn_text_ndc(wks,":F8:x",.6,.4,txres)
  gsn_text_ndc(wks,":F8:y",.6,.3,txres)
  gsn_text_ndc(wks,":F8:z",.6,.2,txres)

  draw(wks)
  frame(wks)     
end 
                      
