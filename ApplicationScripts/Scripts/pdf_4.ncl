;*************************************************
; panel_4.ncl
;
; Concepts illustrated:
;   - Showing the effect of different bin numbers 
;
;************************************************
;
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"   
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"   
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"   

;************************************************
begin
  x       = random_normal ( 0,50, (/96,144/))
  y       = random_normal (10,25, dimsizes(x))

  pdf2a   = pdfxy(x,y, 0, 0, False)         ; 25 is the default       
  pdf2b   = pdfxy(x,y,20,40, False)                 
  pdf2c   = pdfxy(x,y,40,40, False)        

  wks  = gsn_open_wks("png","pdf")          ; send graphics to PNG file
  res  = True
  res@gsnDraw  = False
  res@gsnFrame = False

;;res@cnInfoLabelOn               = False   ; do not plot info label
  res@cnInfoLabelOrthogonalPosF   = -0.130  ; shift upward into plot

  plot = new ( 3, "graphic")
  
  res@gsnCenterString = "Default: 25 bins"
  plot(0) = gsn_csm_contour (wks,pdf2a, res)

  res@gsnCenterString = "User specified: 20(x) and 40(y) bins"
  plot(1) = gsn_csm_contour (wks,pdf2b, res)

  res@gsnCenterString = "User specified: 40 bins"
  plot(2) = gsn_csm_contour (wks,pdf2c, res)

;************************************************
; create panel
;************************************************
  resP            = True                         ; modify the panel plot
  resP@txString = "Bivariate PDF (%): Different Bin Numbers"
  resP@gsnPanelRowSpec = True                   ; tell panel what order to plt
  gsn_panel(wks,plot,(/1,2/),resP)
end
