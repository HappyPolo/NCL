;*************************************************
; conLab_6.ncl
;
; Concepts illustrated:
;   - Drawing black-and-white contours over a polar stereographic map
;   - Drawing the southern hemisphere of a polar stereographic map
;   - Increasing the density of the number of labels on a contour line
;   - Turning off the contour informational label
;   - Increasing the thickness of contour lines
;   - Zooming in on a particular area on a polar stereographic map
;
;************************************************
;
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
;************************************************
begin

  f   = addfile ("AmpHar2.nc", "r")
  amp = f->AMP2 
  delete (amp@long_name)
  delete (amp@units)
;***********************************
; Graphics
;***********************************

  wks = gsn_open_wks("png" ,"conLab") ; open a file for graphic output
  plt = new (3,graphic)

  res                   = True
  res@gsnPolar          = "SH"                 ; specify the hemisphere
  res@gsnDraw           = False                ; do(default)/do not draw
  res@gsnFrame          = False                ; do(default)/do not advance frame

  res@mpMaxLatF         = -20                  ; 20S-S.Pole only
  res@mpGridLatSpacingF = 45.
  res@mpGridLonSpacingF = 90.

  res@cnInfoLabelOn     = False                ; turn off info label
 ;res@cnLineThicknessF  = 2.0                  ; specify contour thickness (default=1.0) 
  res@cnLevelSpacingF   = 0.25                 ; set contour spacing

  res@gsnCenterString   = "Default Line Label Settings"
  plt(0) = gsn_csm_contour_map_polar  (wks, amp,  res )

  res@cnLineLabelDensityF   = 1.5               ; increase the number of line labels/line
  res@cnLineLabelInterval   = 1                 ; labels for every line (default=2)
  res@gsnCenterString       = "Increase Label Density + Every cn Line"
  plt(1) = gsn_csm_contour_map_polar  (wks, amp,  res )
 
  res@cnLabelMasking        = True              ; do not draw labels over contour 
  res@gsnCenterString       = "Label Masking"
  plt(2) = gsn_csm_contour_map_polar  (wks, amp,  res )

; ************************************************************
; create panel plot
; ************************************************************

  rp=True                                       ; panel mods desired
  rp@gsnMaximize    = True
  gsn_panel(wks,plt,(/3,1/),rp)                 ; create panel plot
end
