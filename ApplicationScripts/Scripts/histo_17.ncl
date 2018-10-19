;*************************************************
; histo_17.ncl
;
; Concepts illustrated:
;   - Generating dummy data using "random_uniform"
;   - Stacking histograms
;*************************************************
;
; This file is loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"   

begin
;
; Generate some random data. Make sure that each
; new array is larger and has more points in
; each bin than the previous. 
;
  npts = 100 
  x1   = random_uniform(70,100,npts)
  x2   = random_uniform(70,100,npts*2)
  x3   = random_uniform(70,100,npts*3)
  x4   = random_uniform(70,100,npts*4)

  wks = gsn_open_wks("png","histo")              ; send graphics to PNG file
  gsn_define_colormap(wks,"temp_19lev")          ; choose colormap

;---Define colors for each histogram.
  colors = (/(/ 2, 3, 4/), (/ 7, 8, 9/), \
             (/12,13,14/), (/17,18,19/)/)

;---Resource list for histogram.
  res = True

  res@vpXF          = 0.12    ; Move to left a bit.
  res@vpYF          = 0.85
  res@vpWidthF      = 0.68
  res@vpHeightF     = 0.68

  res@tiXAxisString = ""
  res@tiYAxisString = ""
  res@tiMainString  = "Stacked histogram"

;---Just create plots for now, so we can get info from each one.
  res@gsnDraw  = False
  res@gsnFrame = False

;---Fix the bin intervals for each histogram.
  res@gsnHistogramClassIntervals = (/70,80,90,100/)

;---Generate the plots so we can get the maximum number in the bins.
  plot1 = gsn_histogram(wks,x1,res)
  plot2 = gsn_histogram(wks,x2,res)
  plot3 = gsn_histogram(wks,x3,res)
  plot4 = gsn_histogram(wks,x4,res)

;---Get the largest bin count.
  ymax = max((/max(plot1@NumInBins), max(plot2@NumInBins), \
               max(plot3@NumInBins), max(plot4@NumInBins)/))

;
; Draw the plots one on top of the other, fixing the max Y axis to the
; same value for each. Make sure you draw the plots in reverse order
; so you can see the stacking.
;
  res@trYMaxF  = ymax + 5
  res@gsnDraw  = True

  res@gsFillColor = colors(3,:)
  plot4 = gsn_histogram(wks,x4,res)

  res@gsFillColor = colors(2,:)
  plot3 = gsn_histogram(wks,x3,res)

  res@gsFillColor = colors(1,:)
  plot2 = gsn_histogram(wks,x2,res)

  res@gsFillColor = colors(0,:)
  plot1 = gsn_histogram(wks,x1,res)

  txres               = True
  txres@txFontHeightF = 0.018
  txres@txJust        = "CenterLeft"

  dims = dimsizes(colors)
  k    = 0
  do i=0,dims(0)-1
    do j=0,dims(1)-1
      txres@txFontColor = colors(i,j)
      gsn_text_ndc(wks,"~F35~y",0.85,0.82-k*0.05,txres)
      txres@txFontColor = 1    ; Black
      gsn_text_ndc(wks,"     Bar "+(j+1)+" x"+(i+1),0.85,0.82-k*0.05,txres)
      k = k + 1
    end do
  end do  
  frame(wks)
end
