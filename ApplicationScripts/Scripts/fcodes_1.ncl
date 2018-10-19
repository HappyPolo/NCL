; ===============================================
; fcodes_1.ncl
;
; Concepts illustrated:
;   - Drawing text on the frame
;   - Changing the font of a text string using a function code 
;   - Changing the color of text strings
;   - Drawing special symbols
;
; ===============================================
;
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
;================================================
begin 
  wks   = gsn_open_wks ("png", "fcodes" )       ; send graphics to PNG file    

  res               = True                      ; text mods desired
  res@txFontHeightF = 0.030                     ; text font height
  res@txFontColor   = "Green"

; Font table 35, letter 'p' is a shamrock.
  str = "Happy St. Patrick's ~F35~p~F~ Day"

  gsn_text_ndc(wks,str,0.5,0.55,res)

  res@txFuncCode    = "~"
  res@txFontColor   = "Red"

; Font table 35, letter 'r' is a heart.
  str = "Happy Valentine's ~F35~r~F~ Day"
  gsn_text_ndc(wks,str,0.5,0.45,res)

; Font table 121 and 135 are outlined fonts
  str = "~F121~Happy Valentine's ~F135~r~F121~ Day"
  gsn_text_ndc(wks,str,0.5,0.40,res)

  res@txFontColor   = "Black"

; Font table 22 and 26 are bold fonts.
  str = "This is ~F22~helvetica bold~F~ and ~F26~times bold"
  gsn_text_ndc(wks,str,0.5,0.65,res)

  draw(wks)
  frame(wks)     

end 
                      
