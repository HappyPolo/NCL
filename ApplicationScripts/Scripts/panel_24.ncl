;*************************************************
; panel_24.ncl
;
; Concepts illustrated:
;   - Paneling six plots on a page
;   - Selecting a plot on which to base the scale factor for paneled plots
;   - Changing the width and height of a plot
;   - Changing the color of tickmark labels
;
;*************************************************
;
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"

begin
  npts   = 50
  nplots = 6

  y    = new((/nplots,npts/),float)
  plot = new(nplots,graphic)

  ybeg = (/0.00001,-5, 100000, 0, 10, 100/)
  yend = (/1.00000, 5, 500000,20, 50, 200/)

  wks = gsn_open_wks("png","panel")  ; send graphics to PNG file

  res = True

  res@gsnDraw   = False
  res@gsnFrame  = False

  res@vpWidthF  = 0.8		; set width of plot 
  res@vpHeightF = 0.3		; set height of plot

  do i=0,nplots-1
    if(i.eq.2)
       res@xyLineColor = "Blue"
       res@tmYLLabelFontColor = "Blue"
    else
       res@xyLineColor = "Black"
       res@tmYLLabelFontColor = "Black"
    end if
    y(i,:)  = random_uniform(ybeg(i),yend(i),npts)
    plot(i) = gsn_csm_y(wks,y(i,:),res)
  end do
 
  pres                        = True
  pres@gsnMaximize            = True

  pres@gsnPanelMainString     = "Scale factor based on first plot in list"
  gsn_panel(wks,plot,(/3,2/),pres)	

  pres@gsnPanelMainString     = "Scale factor based on third (largest) plot in list"
  pres@gsnPanelScalePlotIndex = 2   ; 3rd plot in list, which is the biggest
  gsn_panel(wks,plot,(/3,2/),pres)	

end
