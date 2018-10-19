; ===============================================
; fcodes_2.ncl
;
; Concepts illustrated:
;   - Drawing text on the frame
;   - Drawing superscripts/subscripts in a text string using function codes
;   - Changing the font size of text
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
  res@txFontHeightF = 0.03                      ; text font height

  res@txJust         =           "CenterLeft"

;---An "N" returns you back to "normal" level.
  str1 = "x~S~2~N~ + y~S~2~N~"
  str2 = "CH~B~4~N~ + N~B~2~N~O"

;---A number after the B or S indicates the level of the sub/superscript
  str3 = "X~B1~2~S1~3"

  str4 = "X~B1~2~S~3~N~Y~S~2"

;---If you only use one "N" here, you will still be in a subscript level.
  str5 = "X~S~A~B~1~NN~ABC"

;---You can do superscripts of superscripts
  str6 = "10~S~10~S~100"

;
; First draw the strings that show the actual code
; needed to create the super and subscripts.
;
  res@txFuncCode    = ":"     ; Change function code to ":" (default)

  dq = str_get_dq()           ; Get the double quote character.

  gsn_text_ndc(wks,":F22:String with function codes",0.04,0.95,res)
  gsn_text_ndc(wks,dq+str1+dq,0.04,0.85,res)
  gsn_text_ndc(wks,dq+str2+dq,0.04,0.70,res)
  gsn_text_ndc(wks,dq+str3+dq,0.04,0.55,res)
  gsn_text_ndc(wks,dq+str4+dq,0.04,0.40,res)
  gsn_text_ndc(wks,dq+str5+dq,0.04,0.25,res)
  gsn_text_ndc(wks,dq+str6+dq,0.04,0.10,res)

;
; Now draw the resultant strings.
;
  res@txFuncCode    = "~"     ; Change function code to "~"

  gsn_text_ndc(wks,"~F22~Resultant string",0.65,0.95,res)
  gsn_text_ndc(wks,str1,0.65,0.85,res)
  gsn_text_ndc(wks,str2,0.65,0.70,res)
  gsn_text_ndc(wks,str3,0.65,0.55,res)
  gsn_text_ndc(wks,str4,0.65,0.40,res)
  gsn_text_ndc(wks,str5,0.65,0.25,res)
  gsn_text_ndc(wks,str6,0.65,0.10,res)

  draw(wks)
  frame(wks)     

end 
                      
