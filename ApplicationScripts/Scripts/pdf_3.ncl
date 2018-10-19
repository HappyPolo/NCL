;************************************************
; pdf_3.ncl
;
; Concepts illustrated:
;   - Generating a bivariate PDF
;
;************************************************
;
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"   
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"   
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"   
;
;************************************************
begin
  x       = random_normal ( 0,50, (/96,144/))
  y       = random_normal (40,25, dimsizes(x))

  pdf2    = pdfxy(x,y, 0, 0, False)         ; 25 is the default       

  wks  = gsn_open_wks("png","pdf")          ; send graphics to PNG file

  res  = True
  res@tiXAxisString   = "Variable X: [0, 50]"
  res@tiYAxisString   = "Variable Y: [40,25]"

;;res@cnInfoLabelOn               = False   ; do not plot info label
  res@cnInfoLabelOrthogonalPosF   = -0.130  ; shift upward into plot

  res@gsnCenterString = "Sample Bivariate Joint PDF: default"
  plot = gsn_csm_contour (wks,pdf2, res)
end
