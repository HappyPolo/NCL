;*************************************************
; text_6.ncl
;
; Concepts illustrated:
;   - Including a double quote in a text string
;   - Drawing text on a plot using plot data coordinates
;************************************************
;
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
;************************************************
begin
;************************************************
; read in netCDF file
;************************************************
  a = addfile("$NCARG_ROOT/lib/ncarg/data/cdf/uv300.nc","r")
  u = a->U(0,:,8)
;************************************************
; create plot
;************************************************
  wks = gsn_open_wks("png","text")               ; send graphics to PNG file

  res                 = True                     ; plot mods desired

  res@gsnDraw         = False                    ; don't draw yet
  res@gsnFrame        = False                    ; don't advance frame yet
  plot=gsn_csm_xy(wks,u&lat,u,res)               ; create xy plot
;************************************************
; add text to plot
;************************************************
  txres               = True                     ; text mods desired
  txres@txFontHeightF = 0.03                     ; font smaller. default big
  dblquote = str_get_dq()

  title = dblquote + "This is a title with double quotes" + dblquote

  dum = gsn_add_text(wks,plot,title,10,9,txres) 
  draw(plot)                                     ; now draw plot
  frame(wks)                                     ; now advance frame

end
