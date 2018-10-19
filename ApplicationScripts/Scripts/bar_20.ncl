;----------------------------------------------------------------------
; bar_20.ncl
;
; Concepts illustrated:
;   - Drawing bars instead of curves in an XY plot
;   - Adding text to individual bars
;   - Applying transparency to filled bars
;----------------------------------------------------------------------
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"   
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"    
;----------------------------------------------------------------------

begin
  wks  = gsn_open_wks("png","bar")

;---Create some dummy data.
  y = (/17.,16.,20.,21.,4./) 
  x = (/0,1,2,3,4/) 
  
;---Create five RGB colors
  colors_rgb  = (/ (/0.972549,0,0/),(/0.533333,0.25098,0.12549/),(/0,0,0.972549/),\ 
                   (/0.972549,0.470588,0/),(/0.972549,0,0.972549/) /) 

;---Copy RGB values to RGBA array with varying transparency
  colors_rgba = new((/dimsizes(colors_rgb(:,0)),4/),typeof(colors_rgb))
  colors_rgba(:,0:2) = colors_rgb
  colors_rgba(:,3)   = (/0.,.3,.4,.5,.6/)   ; 0 is completely transparent, 1.0 is completely opaque

  res                     = True 
  res@gsnDraw             = False    ; Will panel both plots later
  res@gsnFrame            = False

  res@gsnXYBarChart       = True 

  res@trYMinF             = 0. 
  res@trYMaxF             = ceil(max(y))+1
  
  res@gsnXYBarChartColors = colors_rgb
  res@tiMainString        = "RGB colors, no transparency"
  plot_rgb = gsn_csm_xy(wks,x, y, res)

  res@tiMainString        = "RGB/A colors w/varying transparency"
  res@gsnXYBarChartColors := colors_rgba
  plot_rgba = gsn_csm_xy(wks,x, y, res)

;---Add some text strings to indicate the alpha values.
  txres = True
  txres@txFontHeightF = 0.01
  txres@txPerimOn     = True
  txres@txBackgroundFillColor = "white"
  id = gsn_add_text(wks,plot_rgba,"alpha~C~  "+sprintf("%3.1f",colors_rgba(:,3)),x,(/3,3,3,3,3/),txres)
    
;---Panel both plots.
  pres                    = True
  pres@gsnMaximize        = True
  pres@gsnPanelMainFont   = "Helvetica-bold"
  pres@gsnPanelMainString = "Coloring vertical bars with RGB & RGB/A values"
  gsn_panel(wks,(/plot_rgb,plot_rgba/),(/1,2/),pres)
end
