;----------------------------------------------------------------------
; newcolor_2.ncl 
;
; Concepts illustrated:
;   - Showing features of the new color display model
;   - Drawing a partially transparent text string
;----------------------------------------------------------------------
; Adapted from example "text_1.ncl".  A very simple example 
; of using font-opacity to annotate a plot.
;
; NOTE: This example will only work with NCL V6.1.0 and later.
;----------------------------------------------------------------------
;
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"

begin
;---Read in netCDF file
  a = addfile("$NCARG_ROOT/lib/ncarg/data/cdf/uv300.nc","r")
  u = a->U(0,:,8)

;---Create plot
  wks = gsn_open_wks("png","newcolor")           ; send graphics to PNG file

  res                 = True                     ; plot mods desired
  res@gsnMaximize     = True                     ; maximize size of plot
  res@gsnDraw         = False                    ; don't draw plot yet
  res@gsnFrame        = False                    ; don't advance frame yet

  plot = gsn_csm_xy(wks,u&lat,u,res)             ; Draw xy plot.

;---Attach text to plot using plot coordinates.
  txres                = True                    ; text mods desired
  txres@txFont         = 30
  txres@txFontHeightF  = 0.04                    ; font smaller. default big
  txres@txFontOpacityF = 0.10                    ; highly transparent
  txres@txAngleF       = 45.

  txid = gsn_add_text(wks,plot,"Preliminary Data",10,15,txres) 

  draw(plot)        ; Drawing plot will draw attached text
  frame(wks)        ; Advance frame

end
