;***********************************************************
; pdf_5.ncl
;
; Concepts illustrated:
;   - Generating different univariate probability distributions
;   - Generating PDFs of each sample distribution
;   - Creating bivariate PDFs of variables with different distributions
;***********************************************************
;
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"   
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"   
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"   

;************************************************
begin
  N    = 96
  M    = 144

  norm = random_normal (0,50, (/64,128/) )
  chi  = random_chi    (2   , dimsizes(norm))
  gam  = random_gamma  (75,2, dimsizes(norm))

                                      ; univariate PDFs
  pdf_norm = pdfx(norm, 0, False)     ; default number of bins
  pdf_chi  = pdfx(chi , 0, False)   
  pdf_gam  = pdfx(gam , 0, False)   
                                      ; bivariate PDFs
  pdf2_nc  = pdfxy(norm,chi,0,0,False)
  pdf2_ng  = pdfxy(norm,gam,0,0,False)
  pdf2_gc  = pdfxy(gam ,chi,0,0,False)
  
  plot     = new (3, "graphic")

  wks      = gsn_open_wks("png","pdf")           ; send graphics to PNG file

  res      = True
  res@gsnDraw       = False
  res@gsnFrame      = False
  res@cnInfoLabelOn = False

  res@gsnCenterString = "Normal [0, 50]; Chi (2)"
  plot(0) = gsn_csm_contour (wks,pdf2_nc, res)

  res@gsnCenterString = "Normal [0, 50]; Gamma (75,2)"
  plot(1) = gsn_csm_contour (wks,pdf2_ng, res)

  res@gsnCenterString = "Gamma (75,2); Chi (2)"
  plot(2) = gsn_csm_contour (wks,pdf2_gc, res)

;************************************************
; create panel
;************************************************
  resP            = True                         ; modify the panel plot
  resP@txString = "Bivariate PDF: Different Distributions"
  resP@gsnPanelRowSpec = True                   ; tell panel what order to plt
  gsn_panel(wks,plot,(/1,2/),resP)

;************************************************
; Using coordinate subscripting, select subsets
;************************************************
  res@cnFillOn          = True    ; Turn on color
  res@cnFillPalette     = "amwg"  ; set color map
  res@cnLinesOn         = False
  res@cnLineLabelsOn    = False

  res@gsnCenterString = "Normal [0, 50]; Chi (2)"
  plot(0) = gsn_csm_contour (wks,pdf2_nc({0:7},{-120:120}), res)

  res@gsnCenterString = "Normal [0, 50]; Gamma (75,2)"
  plot(1) = gsn_csm_contour (wks,pdf2_ng({0:7},{-110:110}), res)

  res@gsnCenterString = "Gamma (75,2); Chi (2)"
  plot(2) = gsn_csm_contour (wks,pdf2_gc({0:7},{0:0.08}), res)

  resP@txString = "Bivariate PDF: Different Distributions"
  gsn_panel(wks,plot,(/1,2/),resP)
end
