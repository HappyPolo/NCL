; ********************************************************
; weather_sym_1.ncl
; ********************************************************
; Concepts illustrated:
;   - Drawing weather symbols
;   - Setting parameters for weather-symbol routines
; ********************************************************
;
; This file is loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"

;
;  Draw station model data.
;
begin

;
;  Define a color map and open a workstation.
;
  cmap = (/                      \
            (/ 1., 1., 1. /),    \  ; color index 0 - white
            (/ 0., 0., 0. /)     \  ; color index 1 - black
         /)

  wks = gsn_open_wks("png","weather_sym")  ; send graphics to PNG file
  gsn_define_colormap(wks,cmap)

  imdat="11212833201001120000300004014752028601117706086792"
  wmsetp("wbs",0.20)
  wmstnm(wks,0.5,0.5,imdat)

  frame(wks)
end
