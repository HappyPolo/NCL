;************************************
; unique_10.ncl
;
; Concepts illustrated:
;   - Drawing stacked XY plots
;   - Attaching multiple XY plots along the X axes
;   - Adding filled boxes to an XY plot
;   - Changing the line color for multiple curves in an XY plot
;   - Changing the color of tickmark labels
;   - Removing the border, tickmarks, and labels from an XY plot
;   - Changing the labels and tickmarks on the X axis in an XY plot
;   - Changing the size of a PNG image
;
;*************************************************
; See unique_10_thicker.ncl for a similar script
; that produces a slightly nicer image for large
; PNG images.
;*************************************************
; This NCL script plots a few reconstructions
; based at measurements from ice core data (Fuji Dome) and
; insolation from the calculation of Andre Berger.
;
; It is the typical plot that people mostly see in 
; Papers of paloclimate studies
; Please enjoy---------by Yi Wang PNNL (ywang699@gmail.com)
;************************************************
;
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
;
; This file still has to be loaded manually
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl"  

begin

;;; Dome Fuji data from Kawanura et al. (2007) Nature 448: 912-916, paper
;;; Insolation Berger and Loutre, 1991 Quaternary Science Reviews, 10, 297-317, paper.
;;;; We will plot delta O_18, CO2 concentration, and temperature anomaly

  ncol1 = 3 ;;; temp
  ncol2 = 4 ;;; O_18
  ncol3 = 5 ;;; CO2
  ncol4 = 8 ;;; insolation

;;;;; CO2 data

  data3 = readAsciiTable("dco2.txt",ncol3,"float",0)

;;;; delta O_18 data

  data2 = readAsciiTable("d18.txt",ncol2,"float",0)

;;;; temp data

  data1 = readAsciiTable("dtem.txt",ncol1,"float",0)

;;;; insolation data (June, 60N)

  datas = readAsciiTable("insol41.txt",ncol4,"float",0)

  data4 = new((/401,8/),float)   ;; datas ;;; copy 

  data4(:,0)  = datas(0:400,0)*(0-1000.0) 
  data4(:,1:) = datas(0:400,1:)

  xindexc = (/0,50000,100000,150000,200000,250000,300000,350000,400000/)
  xlabelc = (/"0","50","100","150","200","250","300","350","400"/)

;************************************************
; create plots  
;************************************************
  plot = new(4,graphic)
  poly = new(16,graphic)   ; For attaching grey-filled rectangles

  wtype          = "png"
  wtype@wkWidth  = 2500
  wtype@wkHeight = 2500
  wks = gsn_open_wks(wtype ,"unique")                   ; ps,pdf,x11,png

  trxmin = 0.0         ; min/max values for X axis 
  trxmax = 400000.0

  res                       = True          ; plot mods desired
  res@gsnDraw               = False
  res@gsnFrame              = False

  res@vpWidthF              = 0.70       ; change aspect ratio of plot
  res@vpHeightF             = 0.25

  res@trXMinF               = trxmin
  res@trXMaxF               = trxmax
  res@trXReverse            = True     ; Reverse X axis values

  res@xyLineColor           = "red"
  res@xyLineThicknessF      = 2.0

  res@tiYAxisString         = "delta T ~S~o~N~C"
  res@tiYAxisFontColor      = res@xyLineColor
  res@tiYAxisFontHeightF    = 0.05

  res@tfPolyDrawOrder       = "PreDraw"    ; Draw any attached primitives
                                           ; before rest of plot.

  res@tmXBOn                = False
  res@tmYLLabelFontHeightF  = 0.01      ; resize tick labels
  res@tmYLLabelFontColor    = res@xyLineColor

  res1                      = True

  res1@gsnDraw              = False
  res1@gsnFrame             = False

  res1@vpWidthF             = 0.70          ; change aspect ratio of plot
  res1@vpHeightF            = 0.25

  res1@trXMinF              = trxmin
  res1@trXMaxF              = trxmax
  res1@trXReverse           = True

  res1@xyDashPatterns       = 0                   ; dashed line for 2nd
  res1@xyLineColor          = "blue"  ; 3 different colors
  res1@xyLineThicknessF     = 2.0

  res1@tiYAxisFontHeightF   = 0.05
  res1@tiYAxisSide          = "Right"	
  res1@tiYAxisString        = "delta O18, per mil"
  res1@tiYAxisFontColor     = res1@xyLineColor

  res1@tfPolyDrawOrder       = "PreDraw"    ; Draw any attached primitives
                                            ; before rest of plot.

  res1@tmXBOn               = False
  res1@tmXTOn               = False
  res1@tmYLLabelFontColor   = res1@xyLineColor
  res1@tmYLLabelsOn         = False
  res1@tmYRLabelFontHeightF = 0.01      ; resize tick labels
  res1@tmYRLabelsOn         = True

;;;;; TEMP

  plot(0) = gsn_csm_xy(wks,data1(::-1,0),data1(::-1,2),res)

;;;;; o_18

  plot(1) = gsn_csm_xy(wks,data2(::-1,1),data2(::-1,3),res1)

;;;;; CO2

  res@tmXTOn                = False
  res@tiYAxisString         = "CO2, ppmv"
  res@xyLineColor           = "forestgreen"
  res@tiYAxisFontColor      = res@xyLineColor
  res@tmYLLabelFontColor    = res@xyLineColor

  plot(2) = gsn_csm_xy(wks,data3(::-1,1),data3(::-1,4),res)

;;;;; Insolation

  res1@tmXBOn               = True
  res1@tmXBMode             = "Explicit"
  res1@tmXBValues           = xindexc  
  res1@tmXBLabels           = xlabelc  
  res1@tmXBLabelFontHeightF = 0.02
  res1@xyLineColor          = "darkorange3"
  res1@tiYAxisString        = "July Insolation (65~S~o~N~N,W/m2)"
  res1@tiXAxisString        = "ka BP"
  res1@tiYAxisFontColor     = res1@xyLineColor
  res1@tmYLLabelFontColor   = res1@xyLineColor

  plot(3) = gsn_csm_xy(wks,data4(::-1,0),data4(::-1,2),res1)

;;;;;; add gray bars before attaching plots to each other

;;;;;; First get min/max values of each Y axis
  ymin = new(4,float)
  ymax = new(4,float)
  do i=0,3
    getvalues plot(i)
      "trYMinF": ymin(i)
      "trYMaxF": ymax(i)
    end getvalues
  end do

;;;;;; Set up arrays to hold bar coordinates

  xwdt = 16000    ; bar width
  xmin = (/10000.0,120000.0,215000.0,325000.0/)
  xmax = xmin + 15000.0

  xbars = (/ (/xmin(0), xmax(0), xmax(0), xmin(0), xmin(0)/), \
             (/xmin(1), xmax(1), xmax(1), xmin(1), xmin(1)/), \
             (/xmin(2), xmax(2), xmax(2), xmin(2), xmin(2)/), \
             (/xmin(3), xmax(3), xmax(3), xmin(3), xmin(3)/)/)

  ybars = (/ (/ymin(0),ymin(0),ymax(0),ymax(0),ymin(0)/), \
             (/ymin(1),ymin(1),ymax(1),ymax(1),ymin(1)/), \
             (/ymin(2),ymin(2),ymax(2),ymax(2),ymin(2)/), \
             (/ymin(3),ymin(3),ymax(3),ymax(3),ymin(3)/)/)

;;;;;; Create the bars and attach to appropriate plot
  gres             = True
  gres@gsFillColor = "lightgray"

  do i=0,3
    do j=0,3
      poly((i*4)+j) = gsn_add_polygon(wks,plot(j),xbars(i,:),ybars(j,:),gres)
    end do
  end do

;;;;;; Attach plots along the X axes
  attachres1                     = True
  attachres1@gsnAttachPlotsXAxis = True  ;; attaches along x-axis
  attachres1@gsnAttachBorderOn   = False ;; No border please
  attachres2                     = True
  attachres2@gsnAttachPlotsXAxis = True  ;; attaches along x-axis
  attachres2@gsnAttachBorderOn   = False ;; No border please

  attachid1  = gsn_attach_plots(plot(0),plot(1:3),attachres1,attachres2)

;;;;;; Maximize output on the page and draw everything
  pres = False               ; No resources needed
  maximize_output(wks,pres)  ; Maximize plot on page
end

