;----------------------------------------------------------------------
; scatter_13.ncl
;
; Concepts illustrated:
;   - Drawing a 4-panel scatter plot
;   - Filling the plot area in light gray
;   - Turning off the top and right tickmarks
;   - Adjusting the X positions of plots in a panel
;   - Adding a rotated title at the left side of a panel
;   - Using "getvalues" to retrieve the min/max of axes
;----------------------------------------------------------------------

;----------------------------------------------------------------------
; This procedure takes an existing XY plot, retrieves the viewport 
; coordinates, and fills that area in the desired color.
;----------------------------------------------------------------------
procedure fill_xy_plot_area(wks,plot)
begin
  getvalues plot
    "trXMinF"   : xmin
    "trYMinF"   : ymin
    "trXMaxF"   : xmax
    "trYMaxF"   : ymax
  end getvalues

  xbox = (/xmin,xmax,xmax,xmin,xmin/)
  ybox = (/ymin,ymin,ymax,ymax,ymin/)

  gnres = True
  gnres@gsFillColor     = "LightGray"
  gnres@tfPolyDrawOrder = "PreDraw"
  plot@$unique_string("box")$ = gsn_add_polygon(wks,plot,xbox,ybox,gnres)
end

;----------------------------------------------------------------------
; Main driver code
;----------------------------------------------------------------------
begin
;---Create some dummy data for four dots per plot
  times = (/3, 4, 5, 6/)     ; hours
  sflow = (/(/0.0, 0.16, 0.20, 0.19/), \
            (/0.0, 0.15, 0.71, 0.61/), \
            (/0.0, 0.0,  0.25, 0.14/), \
            (/0.0, 0.0,  0.14, 0.19/)/)
  ntime = dimsizes(times)
  titles = "Station " + ispan(1,ntime,1)

  plots = new(ntime,graphic)

  wks  = gsn_open_wks("png","scatter")   


;---Set plot options for XY plots
  res = True

;---Turn these off because we plan to panel later.
  res@gsnDraw        = False
  res@gsnFrame       = False

;---Change aspect ratio of plot
  res@vpWidthF       = 0.7 
  res@vpHeightF      = 0.5

;---Customize the markers
  res@xyMarkLineMode = "Markers"      ; default is line
  res@xyMarker       = 16             ; filled dot
  res@xyMarkerSizeF  = 20.0           ; default is a little small
  res@xyMarkerColor  = "DarkOrange4"

;---Set the X and Y axis limits
  res@trYMinF        = min(sflow) - 0.04
  res@trYMaxF        = max(sflow) + 0.03
  res@trXMinF        = min(times) - 0.1
  res@trXMaxF        = max(times) + 0.1

  res@tmGridDrawOrder = "predraw"    ; new resource added in NCL V6.5.0

;---Customize the X tickmarks and add some grid lines
  res@tmXBMode        = "Explicit"      ; Change labels on X axis.
  res@tmXBValues      = times
  res@tmXBMinorValues = ispan(min(times)*10,max(times)*10,5)*0.1
  res@tmXBLabels      = sprinti("%0.2i",times) + ":00"

  res@tmXTOn                  = False       ; Turn off top tickmarks
  res@tmXMajorGrid            = True        ; Add vertical grid lines
  res@tmXMinorGrid            = True
  res@tmXMajorGridLineColor   = "White"
  res@tmXMinorGridLineColor   = "White"
  res@tmXBMinorPerMajor       = 1

  res@tmXBMajorLengthF        = 0.0    ; Turn off the bottom X tickmarks
  res@tmXBMajorOutwardLengthF = 0.0
  res@tmXBMinorOutwardLengthF = 0.0
  res@tmXBMinorLengthF        = 0.0

;---Customize the Y tickmarks and add some grid lines
  res@tmYROn                  = False       ; Turn off right tickmraks
  res@tmYMajorGrid            = True        ; Add horizontal grid lines
  res@tmYMinorGrid            = True
  res@tmYMajorGridLineColor   = "White"
  res@tmYMinorGridLineColor   = "White"
  res@tmYLTickSpacingF        = 0.2
  res@tmYLMinorPerMajor       = 1
  res@tmYLFormat              = "0@;*.1f"   ; only one value after decimal pont

  res@tmYLMinorOutwardLengthF = 0.0    ; Turn off the left Y tickmarks
  res@tmYLMinorLengthF        = 0.0

  res@tiYAxisString           = ""
  res@tiMainFontHeightF       = 0.025

;----------------------------------------------------------------------
; Loop across each station and create an XY plot for paneling later.
;----------------------------------------------------------------------
  do nt=0,ntime-1
;----------------------------------------------------------------------
; Set additional resources to turn off various tickmarks and labels
; depending on which plots we're drawing
;----------------------------------------------------------------------
    if(nt.eq.1.or.nt.eq.3) then      ; The rightmost plots; turn off left labels
      res@tmYLLabelsOn = False
      res@tmYLMajorOutwardLengthF = 0.0
      res@tmYLMajorLengthF        = 0.0
      res@tmYLMinorOutwardLengthF = 0.0
      res@tmYLMinorLengthF        = 0.0
    else
      res@tmYLLabelsOn = True
      delete_attr(res,"tmYLMinorOutwardLengthF")
      delete_attr(res,"tmYLMinorLengthF")
      delete_attr(res,"tmYLMajorOutwardLengthF")
      delete_attr(res,"tmYLMajorLengthF")
    end if
    if(nt.eq.0.or.nt.eq.1) then      ; The topmost plots; turn off bottom labels
      res@tmXBLabelsOn = False
    else
      res@tmXBLabelsOn = True
    end if

;----------------------------------------------------------------------
; Create the XY plot for this time step
;----------------------------------------------------------------------
    res@tiMainString = titles(nt)
    plots(nt) = gsn_csm_xy(wks,times,sflow(nt,:),res)
    fill_xy_plot_area(wks,plots(nt))
  end do

;----------------------------------------------------------------------
; Panel the four plots.
;----------------------------------------------------------------------
  pres             = True
  pres@gsnMaximize = True
  pres@gsnPanelXF  = (/0.08,0.54,0.08,0.54/)  ; slightly adjust X location of each plot
  pres@gsnFrame    = False
  gsn_panel(wks,plots,(/2,2/),pres)

;----------------------------------------------------------------------
; Add a sideways text string on left side.
;----------------------------------------------------------------------
  txres               = True
  txres@txFontHeightF = 0.02
  txres@txAngleF      = 90    ; rotate 90 degrees
  gsn_text_ndc(wks,"streamflow",0.015,0.5,txres)

;----------------------------------------------------------------------
; Advance frame once we are done drawing to this page.
;----------------------------------------------------------------------
  frame(wks)
end
