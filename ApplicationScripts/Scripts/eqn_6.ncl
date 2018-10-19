; ===============================================
; eqn_6.ncl
;
; Concepts illustrated:
;   - Drawing equations using function codes (complicated)
;   - Changing the font of a text string  using a function code 
;   - Drawing text on the frame
;   - Increasing the font size of text
;   - Left-justifying text
;
; ===============================================
;
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
;================================================

begin
  wks   = gsn_open_wks ("png", "eqn")               ; open a workstation and send data to PNG file

; note that a colon is the default function code, but since I have personally
; set the default code to be a tilde (~) in my .hluresfile, I manually 
; reset it here, since the colon makes for a cleaner example.
;****************************
; Equation 
;***************************
  txres               = True                      ; text mods desired
  txres@txFontHeightF = 0.030                     ; text font height
  txres@txFontThicknessF = 3.0                    ; thicken font for better PNG display
  txres@txJust        = "CenterLeft"              ; Default is "CenterCenter".
  txres@txFuncCode    = ":"                       ; see above

  W_p                 = ":F10:W:B:p:E:"               
  equal               = ":F10: =:E:"
  integral            = ":F18:v:E:"
  rho_air             = ":F8:r:B::F10:air:E:" 
  r_l                 = ":F10:r:B:L:E:"
  dz                  = ":F10:dz:E:"
                                                 ; example
  gsn_text_ndc(wks, W_p     ,.2,.8,txres)        ; plot each term
  gsn_text_ndc(wks, equal   ,.3,.7,txres)
  gsn_text_ndc(wks, integral,.4,.6,txres)
  gsn_text_ndc(wks, rho_air ,.5,.5,txres)
  gsn_text_ndc(wks, r_l     ,.6,.4,txres)
  gsn_text_ndc(wks, dz      ,.7,.3,txres)
  draw(wks)
  frame(wks)     
                                                 ; combine: add spaces 
                                                 ; where necessary
  eqn =  W_p + equal + integral + rho_air +"  "+ r_l +" " + dz 
  gsn_text_ndc(wks, eqn,.2,.5,txres)
  draw(wks)
  frame(wks)     

end
