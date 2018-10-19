;***********************************************
; color_10.ncl
;
; Concepts illustrated:
;   - Creating a color map using RGB triplets read off a file
;   - Drawing the current color map
;
;************************************************
;
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"   
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl" 
;************************************************
begin
 wks = gsn_open_wks("png","color")                 ; send graphics to PNG file

 cmap = RGBtoCmap("test_rgb.txt")                  ; RCGtoCmap in contributed

 gsn_define_colormap(wks,cmap)                     ; create the color map 
     
 gsn_draw_colormap(wks)     			   ; draw the colormap        
end
