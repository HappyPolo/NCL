;*******************************************
; weather_sym_2.ncl
;
; Concepts illustrated:
;   - Creating dummy data
;   - Setting parameters for weather routines
;*******************************************
;
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"

begin
;
;  Send graphics to PNG file
;
  wks = gsn_open_wks("png","weather_sym")

;
;  Draw wind barbs.
;
  x = (/0.25, 0.75, 0.75, 0.25/)
  y = (/0.25, 0.25, 0.75, 0.75/)
  u = (/50., -50., -50.,  50./)
  v = (/50.,  50., -50., -50./)
  wmsetp("wbs",0.2)
  wmbarb(wks, x, y, u, v)
  frame(wks)
end
