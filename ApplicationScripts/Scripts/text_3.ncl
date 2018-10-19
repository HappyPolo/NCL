;*************************************************
; text_3.ncl
;
; Concepts illustrated:
;   - Using drawNDCGrid to draw a nicely labeled NDC grid
;   - Drawing text on the frame using NDC coordinates
;   - Decreasing the font size of text
;************************************************
;
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
;
; This file still has to be loaded manually
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl"
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
  res@gsnFrame        = False                    ; don't advance frame yet

  plot=gsn_csm_xy(wks,u&lat,u,res)               ; create xy plot

;************************************************
; Draw NDC grid on plot
;
; Page coordinates are normalized; i.e. they go
; from 0 to 1.
;
  drawNDCGrid(wks)

;************************************************
; Draw text on plot using NDC coordinates
;************************************************
  txres               = True                     ; text mods desired
  txres@txFontHeightF = 0.03                     ; font smaller. default big

  gsn_text_ndc(wks,"Text in Page(NDC) Coordinates",0.3,0.1,txres) 

  frame(wks)                                     ; now advance frame

end
