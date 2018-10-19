;***********************************************************
; pdf_1.ncl
;
; Concepts illustrated:
;   - Generating univariate probability distributions
;   - Generating PDFs of each sample distribution
;   - Paneling two plots horizontally on a page
;***********************************************************
;
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"   
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"   
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"   

begin
  a   = random_normal (0,50, (/64,128/))
  b   = random_chi    (2   , (/1000/))
  c   = random_gamma  (75,2, (/50,100/))

  ap  = pdfx(a, 0, False)    ; default number of bins
  bp  = pdfx(b, 0, False)   
  cp  = pdfx(c, 0, False)   

;------------------------------------------------
; Plot each PDF
;------------------------------------------------
  nVar    = 3
  plot    = new ( nVar, "graphic")
  
  wks  = gsn_open_wks ("png","pdf")             ; send graphics to PNG file

  res  = True
  res@gsnDraw                = False
  res@gsnFrame               = False
  res@xyLineThicknessF       = 2
  res@tiYAxisString          = "PDF (%)"

  res@gsnCenterString        = "Univariate PDF: Normal"
  plot(0) = gsn_csm_xy (wks, ap@bin_center, ap, res)
  res@gsnCenterString        = "Univariate PDF: Chi (df=2)"
  plot(1) = gsn_csm_xy (wks, bp@bin_center, bp, res)
  res@gsnCenterString        = "Univariate PDF: Gamma (75,2)"
  plot(2) = gsn_csm_xy (wks, cp@bin_center, cp, res)

  resP    = True
  resP@txString        = "Univariate PDFs of Three Variables"
  resP@gsnPanelRowSpec = True                   ; tell panel what order to plt
  gsn_panel(wks,plot,(/1,2/),resP)
end
