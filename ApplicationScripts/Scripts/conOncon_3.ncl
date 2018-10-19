;*************************************************
; conOncon_3.ncl
;
; Concepts illustrated:
;   - Overlaying two sets of contours on a polar stereographic map
;   - Overlaying line contours on filled contours
;   - Turning off map tickmarks
;   - Increasing the thickness of contour lines
;   - Using a blue-white-red color map
;*************************************************
;
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
begin

  a = addfile("$NCARG_ROOT/lib/ncarg/data/cdf/uv300.nc","r")

  u = a->U(0,:,:) ; this includes the cyclic point
  v = a->V(0,:,:) ; this includes the cyclic point

  wks = gsn_open_wks("png" ,"conOncon")  ; send graphics to PNG file

;*****************************
; create first plot
;*****************************
  resn            = True 	; create vector resource array
  resn@gsnPolarNH = True	; choose northern hemisphere
  resn@cnFillOn   = True	; color fill
  resn@cnFillPalette = "blwhre" ; set color map
  resn@cnLinesOn  = False	; no contour lines

  resn@gsnDraw    = False	; don't draw
  resn@gsnFrame   = False	; don't advance frame

  plot1 = gsn_csm_contour_map_polar(wks,u,resn)
;*****************************
; create second plot
;*****************************
  res = True
  res@gsnTickMarksOn   = False	; no tickmarks
  res@gsnDraw          = False	; don't draw
  res@gsnFrame         = False	; don't advance frame
  res@gsnLeftString    = ""	; no titles
  res@gsnRightString   = ""
  res@tiXAxisString    = ""
  res@tiYAxisString    = ""
  res@cnLineThicknessF = 1.5	; thicker contours
  res@cnLineLabelsOn   = False	; no line labels

  plot2 = gsn_csm_contour(wks,v,res)
;******************************
; overlay the plots
;******************************
  overlay(plot1,plot2)
  draw(plot1)
  frame(wks)
end
