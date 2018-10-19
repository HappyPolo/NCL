; ===============================================
; eqn_4.ncl
;
; Concepts illustrated:
;   - Drawing equations using function codes (complicated)
;   - Moving vertically in a text string using a function code
;   - Moving horizontally in a text string using a function code
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
  txres@txJust        = "CenterLeft"              ; Default is "CenterCenter"

; note that a colon is the default function code, but since I have personally
; set the default code to be a tilde (~) in my .hluresfile, I manually 
; reset it here, since the colon makes for a cleaner example.
  txres@txFuncCode    = ":"                 
;****************************
; method 1: place each component manually on the page. I found this
; method to be a bit faster to create and easier to read
;****************************
  txres@txFontHeightF = 0.035
  gsn_text_ndc(wks,"Created and placed by parts",.2,.95,txres)
; du/dt
  txres@txFontHeightF = 0.030 
  gsn_text_ndc(wks,"d:F10:u",.2,.9,txres)
  gsn_text_ndc(wks,"__",.2,.88,txres)
  gsn_text_ndc(wks,"d:F10:t",.2,.84,txres)
; -fv = alpha  
  gsn_text_ndc(wks,"-:F10:fv = :F21:-:F8:a",.27,.87,txres)
; partial p over partial x
  txres@txFontHeightF = 0.035                   
  gsn_text_ndc(wks,":F18:s",.48,.90,txres)

  txres@txFontHeightF = 0.030    
  gsn_text_ndc(wks,":F10:p",.51,.89,txres)
  gsn_text_ndc(wks,"___",.48,.88,txres)

  txres@txFontHeightF = 0.035   
  gsn_text_ndc(wks,":F18:s",.48,.84,txres)
  txres@txFontHeightF = 0.030    
  gsn_text_ndc(wks,":F10:x",.51,.834,txres)
;****************************
; method 2: Create the string as one entity using function codes.
; V indicates vertical position, H is horizontal position, F is a 
; font change.  The tricky part comes in while making sure that each
; segment begins and ENDS with a function code. That is where the ::
; comes from in the example below.  The vertical and horizontal positions
; are relative to the starting point.
;***************************
  txres@txFontHeightF = 0.035 
  gsn_text_ndc(wks,"Created using function codes",.2,.67,txres)

  eqn = ":V1:d:F10:u:H-45::V-1::F21:___:H-40::V-30::F21:d:F10:t:H23::V18::F21:-:F10:fv = :F21:-:F8:a:H6::V10::F18:s:F10:p:H-40::V-1::F21:__:H-35::V-30::F18:s:F10:x"
  gsn_text_ndc(wks,eqn,.2,.6,txres)

  draw(wks)
  frame(wks)     
end 
                      
