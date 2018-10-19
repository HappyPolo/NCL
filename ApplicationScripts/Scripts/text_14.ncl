;*************************************************
; text_14.ncl
;
; Concepts illustrated:
;   - Using text function codes to generate accented characters
;   - Adding a carriage return to a text string using a function code
;   - Moving horizontally/vertically in a text string using function codes
;   - Drawing text on the frame using NDC coordinates
;
;*************************************************
; This script shows how to use text function codes to
; generated accented characters. It was contributed
; by Mateus da Silva Teixeira of IPMet.
;************************************************
;
; This file is loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
;************************************************

begin
; tabela de acentos
  Agrave  = "A~H-15V6F35~A~FV-6H3~"
  agrave  = "a~H-13V2F35~A~FV-2H3~"
  Aacute  = "A~H-15V6F35~B~FV-6H3~"
  aacute  = "a~H-13V2F35~B~FV-2H3~"
  Acirc   = "A~H-15V6F35~C~FV-6H3~"
  acirc   = "a~H-13V2F35~C~FV-2H3~"
  Atilde  = "A~H-15V6F35~D~FV-6H3~"
  atilde  = "a~H-13V2F35~D~FV-2H3~"
  Auml    = "A~H-15V6F35~H~FV-6H3~"
  auml    = "a~H-13V2F35~H~FV-2H3~"

  Egrave  = "E~H-15V6F35~A~FV-6H3~"
  egrave  = "e~H-13V2F35~A~FV-2H3~"
  Eacute  = "E~H-15V6F35~B~FV-6H3~"
  eacute  = "e~H-13V2F35~B~FV-2H3~"
  Ecirc   = "E~H-15V6F35~C~FV-6H3~"
  ecirc   = "e~H-13V2F35~C~FV-2H3~"
  Euml    = "E~H-15V6F35~H~FV-6H3~"
  euml    = "e~H-13V2F35~H~FV-2H3~"

  Igrave  = "I~H-10V6F35~A~FV-6H3~"
  igrave  = "i~H-10V2F35~A~FV-2H3~"
  Iacute  = "I~H-08V6F35~B~FV-6H3~"
  iacute  = "i~H-08V2F35~B~FV-2~"
  Icirc   = "I~H-09V6F35~C~FV-6H3~"
  icirc   = "i~H-09V2F35~C~FV-2H3~"
  Iuml    = "I~H-09V6F35~H~FV-6H3~"
  iuml    = "i~H-09V2F35~H~FV-2H3~"

  Ograve  = "O~H-15V6F35~A~FV-6H3~"
  ograve  = "o~H-13V2F35~A~FV-2H3~"
  Oacute  = "O~H-15V6F35~B~FV-6H3~"
  oacute  = "o~H-13V2F35~B~FV-2H3~"
  Ocirc   = "O~H-16V6F35~C~FV-6H3~"
  ocirc   = "o~H-14V2F35~C~FV-2H3~"
  Otilde  = "O~H-15V6F35~D~FV-6H3~"
  otilde  = "o~H-13V2F35~D~FV-2H3~"
  Ouml    = "O~H-16V6F35~H~FV-6H3~"
  ouml    = "o~H-14V2F35~H~FV-2H3~"

  Ugrave  = "U~H-15V6F35~A~FV-6H3~"
  ugrave  = "u~H-13V2F35~A~FV-2H3~"
  Uacute  = "U~H-13V6F35~B~FV-6H3~"
  uacute  = "u~H-13V2F35~B~FV-2H3~"
  Ucirc   = "U~H-15V6F35~C~FV-6H3~"
  ucirc   = "u~H-13V2F35~C~FV-2H3~"
  Uuml    = "U~H-15V6F35~H~FV-6H3~"
  uuml    = "u~H-13V2F35~H~FV-2H3~"

  Cedil   = "C~H-15F35~K~FH2~"
  cedil   = "c~H-13F35~K~FH2~"

  Ntilde  = "N~H-15V6F35~D~FV-6H3~"
  ntilde  = "n~H-13V2F35~D~FV-2H3~"


; Open workstation.
  wks = gsn_open_wks("png","text")   ; send graphics to PNG file

; Set up resources for text strings.
  txres                   = True   
  txres@txFontHeightF     = 0.03

; Plot accented characters.
  txres@txJust            = "CenterCenter"
  titulo1                 = "Acentua" + cedil + atilde + "o com o NCL"
  gsn_text_ndc(wks,titulo1,.5,.95,txres) 

  txres@txJust            = "CenterLeft"
  titulo2                 = "Caracteres acentuados:"
  gsn_text_ndc(wks,titulo2,0.,.85,txres) 

  texto                   = Agrave + "  " + agrave + "  " + Aacute + "  " + \
                            aacute + "  " + Acirc + "  " + acirc + "  " + \
                            Atilde + "  " + atilde + "  " +  \
                            Auml + "  " + auml
  gsn_text_ndc(wks,texto,.2,.8,txres) 

  texto                   = Egrave + "  " + egrave + "  " + Eacute + "  " + \
                            eacute + "  " + Ecirc + "  " + ecirc + "  " + \
                            Euml + "  " + euml
  gsn_text_ndc(wks,texto,.2,.75,txres) 

  texto                   = Igrave + "  " + igrave + "  " + Iacute + "  " + \
                            iacute + "  " + Icirc + "  " + icirc + "  " + \
                            Iuml + " " + iuml
  gsn_text_ndc(wks,texto,.2,.7,txres) 

  texto                   = Ograve + "  " + ograve + "  " + Oacute + "  " + \
                            oacute + "  " + Ocirc + "  " + ocirc + "  " + \
                            Otilde + "  " + otilde + "  " + \
                            Ouml + "  " + ouml
  gsn_text_ndc(wks,texto,.2,.65,txres) 

  texto                   = Ugrave + "  " + ugrave + "  " + Uacute + "  " + \
                            uacute + "  " + Ucirc + "  " + ucirc + " " + \
                            Uuml + " " + uuml
  gsn_text_ndc(wks,texto,.2,.6,txres) 

  texto                   = Cedil + "  " + cedil + "  " + Ntilde + "  " + \
                            ntilde
  gsn_text_ndc(wks,texto,.2,.55,txres) 

; algumas palavras accents
  titulo3                 = "Algumas palavras:"
  gsn_text_ndc(wks,titulo3,0.,.45,txres)

  txres@txFontHeightF     = 0.025
  texto                   = "ver"  +  atilde  +  "o - inst" + aacute  +   \
                            "vel - hist" + oacute + "rico - mat" + eacute + \
                            "ria"
  gsn_text_ndc(wks,texto,.1,.4,txres) 
  
  texto                   = "precipita"  +  cedil  +  atilde  +  \
                            "o - INFORMA" + Cedil + Otilde + "ES - tr" + \
                            ecirc + "s"
  gsn_text_ndc(wks,texto,.1,.35,txres) 

  texto                   = "dire"  +  cedil  +  otilde  +  "es - El-Ni"  +   \
                             ntilde  +  "o - LA-NI"  +  Ntilde  +  "A"
  gsn_text_ndc(wks,texto,.1,.3,txres) 

  texto                   = "got" + iacute + "culas - pol" + ecirc + \
                            "mica - Amaz" + ocirc + "nia"
  gsn_text_ndc(wks,texto,.1,.25,txres) 

  texto                   = "mec" + acirc + "nica - portugu" + ecirc + \
                            "s - ci" + ecirc + "ncia atmosf" + eacute + "rica"
  gsn_text_ndc(wks,texto,.1,.2,txres) 

  texto                   = Aacute + "reas - din" + acirc + "mica - Sa" + \
                            uacute + "de"
  gsn_text_ndc(wks,texto,.1,.15,txres) 

  frame(wks)

end

