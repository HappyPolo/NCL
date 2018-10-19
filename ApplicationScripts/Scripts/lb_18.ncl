;----------------------------------------------------------------------
;  lb_18.ncl
;----------------------------------------------------------------------
; Concepts illustrated:
;   - Turning off the interior box lines in a labelbar
;----------------------------------------------------------------------
; This script requires that you have NCL V6.2.0 or later, which as
; of June 2013 hadn't been released yet. 
;----------------------------------------------------------------------
;
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
;
; This file still has to be loaded manually
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl"


;----------------------------------------------------------------------
; Main code
;----------------------------------------------------------------------
begin
;---Generate some dummy data.
  data = generate_2d_array(10, 12, -20., 17., 0, (/129,129/))

  wks = gsn_open_wks("png","lb")  ; send graphics to PNG file

  res                     = True

  res@vpYF                  = 0.9
  res@cnFillOn              = True        ; Turn on contour fill
  res@cnFillPalette         = "wgne15"    ; set color map
  res@cnLinesOn             = False       ; Turn off contour lines
  res@lbBoxSeparatorLinesOn = False       ; Turn off interior lines, 6.2.0 only
  res@lbBoxLineThicknessF   = 3.0

  res@tiMainString        = "Labelbar with a box around it"

  plot = gsn_csm_contour(wks,data,res)  ; Create filled contours
end
