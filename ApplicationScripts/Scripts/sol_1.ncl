;
; sol_1.ncl
;
; this code was contributed by joel norris from gfdl
;
; he found a bug in the GSN_CSM plotting interfaces that causes 
; the font sizes of the
; cylindrical equidistant plot to be too small when a global 
; plot of the tropics is drawn. 

; 8/29/00
; we have modified joel's original script with some new resources
; that make the code these bulky.
;----------------------------------------------------------------------------
; Begin plotting code
;----------------------------------------------------------------------------
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
;************************************************
; read in zonal winds
;************************************************
  u = a->U(1,:,:)                                ; read July zonal winds
;************************************************
; create plot
;************************************************
wks = gsn_open_wks("png","sol")	        ; send graphics to PNG file

res              = True                 ; plot mods desired
res@gsnDraw      = False                ; don't draw
res@gsnFrame     = False                ; don't advance frame
res@tiMainString = "Equatorial Plot"	; title
res@cnInfoLabelOrthogonalPosF = 0.42	; must change positioning
res@mpMinLatF    = -30.0		; only plot 30S to 30N
res@mpMaxLatF    = 30.0

; note: the plot manager chooses the font sizes and tickmark sizes of the 
; plot based on the aspect ratio chosen.  For this subregion, the default
; sizes are far too small, so they must be enlarged.  If a smaller longitude
; extent were chosen, this would probably not be an issue.

res@tmXBMajorLengthF = 0.014	        ; resize tickmark lengths
res@tmXBMinorLengthF = 0.007
res@tmYLMajorLengthF = 0.014
res@tmYLMinorLengthF = 0.007

res@tmXBLabelFontHeightF = 0.014	; resize tick labels
res@tmYLLabelFontHeightF = 0.014
res@tiMainFontHeightF    = 0.022        ; resize title

; as a personal preference, limit the labeling of the y-axis

res@gsnMajorLatSpacing = 30
res@gsnMinorLatSpacing = 10

res@txFontHeightF    = 0.017            ; resize the text
res@amOrthogonalPosF = 0.15             ; move text up
;*****************************************
; create the plot
;*****************************************
plot = gsn_csm_contour_map(wks,u,res)	; create plot
plot = ZeroNegDashLineContour(plot) 	; previously specified

draw(plot)
frame(wks)

end
