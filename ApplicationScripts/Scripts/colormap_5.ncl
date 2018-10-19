;*************************************************
; colormap_5.ncl
;
; Concepts illustrated:
;   - Selecting a different color map
;   - Drawing the current color map
;   - Adding named colors to an existing color map
;
;************************************************
;
; This file is loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
;************************************************
begin
  wks = gsn_open_wks("png","colormap")             ; send graphics to PNG file
  gsn_define_colormap(wks,"BlueGreen14")           ; change colormap

; Add named colors "DimGray", "SaddleBrown", and "HotPink"
;
; In the $NCARG_ROOT/lib/ncarg/database/rgb.txt file, these 3 colors
; are defined as follows:
;
;   105 105 105		DimGray
;   139  69  19		saddle brown
;   255 105 180		hot pink
;
; This is equivalent to:
; 
;  0.41   0.41   0.41           dim gray
;  0.55   0.27   0.07           saddle brown
;  1.00   0.41   0.71           hot pink
;
  colors = (/ (/0.41, 0.41, 0.41/), \   ; dim gray
              (/0.55, 0.27, 0.07/), \   ; saddle brown
              (/1.00, 0.41, 0.71/)/)    ; hot pink

;                         Red       Green        Blue
  nc = NhlNewColor(wks,colors(:,0),colors(:,1),colors(:,2))
  gsn_draw_colormap(wks)                           ; draw colormap

end
