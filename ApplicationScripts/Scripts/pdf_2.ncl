;***********************************************************
; pdf_2.ncl
;
; Concepts illustrated:
;   - Generating univariate distributions of different sizes
;   - Using the returned 'bin_center' attribute to assign the appropriate x-axis coordinates
;   - Using bar chart resources to give the plot a different look
;***********************************************************
;
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"   
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"   
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"   

begin
  a   = random_normal (  0,75, (/ 1000/))
  b   = random_normal ( 25,20, (/10,40/))
  c   = random_normal (  5,50, (/  500/))

  ap  = pdfx(a, 40, False)    ; specify 40 bins
  bp  = pdfx(b, 40, False)    ; rather than the default 25
  cp  = pdfx(c, 40, False)   

;------------------------------------------------
; 
;------------------------------------------------
  nVar    = 3
  nBin    = ap@nbins          ; retrieve the number of bins

  xx      = new ( (/nVar, nBin/), typeof(ap))

  xx(0,:) = ap@bin_center     ; assign appropriate "x" axis values
  xx(1,:) = bp@bin_center
  xx(2,:) = cp@bin_center

  yy      = new ( (/nVar, nBin/), typeof(ap))
  yy(0,:) = (/ ap /)
  yy(1,:) = (/ bp /)
  yy(2,:) = (/ cp /)

  wks  = gsn_open_wks ("png","pdf")                ; send graphics to PNG file
  res  = True
  res@xyLineThicknesses        = (/2.0,2.0,2.0/)        
  res@xyLineColors             = (/"blue","red","green"/)  
  res@xyMonoDashPattern        = True              ; all solid 
  res@tiYAxisString            = "PDF (%)"

  res@gsnXYBarChart            = True              ; Create bar plot
  res@gsnXYBarChartOutlineOnly = True

  res@pmLegendDisplayMode    = "Always"            ; turn on legend
  res@pmLegendSide           = "Top"               ; Change location of 
  res@pmLegendParallelPosF   = .25                 ; move units right
  res@pmLegendOrthogonalPosF = -0.4                ; move units down
  res@pmLegendWidthF         = 0.125               ; Change width and
  res@pmLegendHeightF        = 0.15                ; height of legend.
  res@lgPerimOn              = True                ; turn off/on box around
  res@lgLabelFontHeightF     = .015                ; label font height
  res@xyExplicitLegendLabels = (/"AP","BP","CP"/)  ; create explicit labels

  res@tiMainString           = "PDF: Three Distributions: 40 Bins"
  plot = gsn_csm_xy (wks, xx, yy, res)
end
