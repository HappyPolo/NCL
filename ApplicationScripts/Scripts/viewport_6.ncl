;*************************************************
; viewport_6.ncl
;
; Concepts illustrated:
;   - Drawing a cylindrical equidistant map
;   - Changing the aspect ratio of a map
;   - Paneling two plots vertically on a page
;   - Forcing two maps to be the same size
;   - Changing the width and height of a map
;   - Using "getvalues" to retrieve the size of a plot
;   - Adding a common title to paneled plots
;   - Increasing the size of a panel title
;
;************************************************
;
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"

begin

;---Open a PS workstation.
  wks = gsn_open_wks("png","viewport") ; send graphics to PNG file

  res              = True

  res@gsnDraw      = False
  res@gsnFrame     = False

  res@mpCenterLonF = 180
  res@mpMinLonF    =  30
  res@mpMaxLonF    = 150
  res@mpMinLatF    = -30
  res@mpMaxLatF    =  30

  map1 = gsn_csm_map(wks,res)

;---Change the map zoom area, causing the 2nd map to be a different size.
  res@mpMinLonF    =  30
  res@mpMaxLonF    = 270
  res@mpMinLatF    = -30
  res@mpMaxLatF    =  30

  map2 = gsn_csm_map(wks,res)

;---Panel these plots and see how different they are in size.
  pres               = True
  pres@gsnMaximize   = True
  pres@txString      = "Panelling two different-sized maps"
  pres@txFontHeightF = 0.03

  gsn_panel(wks,(/map1,map2/),(/2,1/),pres)

;
; To force the second map to be same size as first map,
; first retrieve its width and height.
;
  getvalues map1
    "vpWidthF"  : vpw
    "vpHeightF" : vph
  end getvalues

;
; By default, you can't skew the width/height of a map plot.
; You must also set mpShapeMode to "FreeAspect" to indicate
; that you really want to skew the map.
;
  res@mpShapeMode = "FreeAspect"
  res@vpWidthF    = vpw
  res@vpHeightF   = vph

;---Recreate second map with new width and height.
  map2 = gsn_csm_map(wks,res)
    
;---Panel these plots and add a title.
  pres@txString    =  "Forcing two maps to be the same size"
  pres@txFontHeightF = 0.03

  gsn_panel(wks,(/map1,map2/),(/2,1/),pres)
end
