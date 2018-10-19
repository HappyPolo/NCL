;----------------------------------------------------------------------
; draworder_7.ncl
;
; Concepts illustrated:
;   - Drawing vertical and horizontal grid lines on an XY plot
;   - Using tickmark resources to customize grid lines
;   - Adding polygons to an XY plot
;   - Using draw order resource to control order of curves, grid lines, and filled boxes
;----------------------------------------------------------------------
; This script uses a resource (tmGridDrawOrder) added 
; in NCL 6.5.0. At the time this script was created 
; (Mar 20, 2017) NCL V6.5.0 had not been released yet.
;----------------------------------------------------------------------

begin
;---Create dummy data
  npts = 500
  x    = ispan(0,npts-1,1)
  y    = npts+.9*ispan(0,npts-1,1)*sin(0.031415926535898*x)

  wks = gsn_open_wks("png","draworder")

  res                             = True
  res@gsnMaximize                 = True
  res@gsnDraw                     = False
  res@gsnFrame                    = False
  res@xyLineThicknessF            = 4.0          ; thicker curves
  res@xyLineColor                 = "NavyBlue"
 
  res@tmXMajorGrid                = True         ; turn on X grid lines
  res@tmYMajorGrid                = True         ; turn on Y grid lines
  res@tmXMajorGridLineColor       = "Gray25"
  res@tmYMajorGridLineColor       = "Gray25"
  res@tmYMajorGrid                = True         ; turn on Y grid lines
  res@tmXMajorGridLineDashPattern = 2            ; dashed lines
  res@tmYMajorGridLineDashPattern = 1            ; different dashed lines
  res@tmXMajorGridThicknessF      = 2.0          ; thicker lines
  res@tmYMajorGridThicknessF      = 2.0          ; thicker lines

;---Create three plots with different draw order resources set.
  res@tiMainString  = "Filled box under grid lines and over curves"
  plot_ugoc = gsn_csm_xy(wks,x,y,res)

  res@tmGridDrawOrder = "PreDraw"                 ; NEW in NCL V6.5.0, default is "PostDraw"
  res@tiMainString = "Filled box over grid lines and curves"
  plot_ogoc = gsn_csm_xy(wks,x,y,res)

  res@xyCurveDrawOrder = "PostDraw"
  res@tiMainString = "Filled box over grid lines and under curves"
  plot_oguc = gsn_csm_xy(wks,x,y,res)

;---Set values and resources to add a filled rectangle to the plots
  pgx = (/  50., 450., 450.,  50.,  50. /)
  pgy = (/ 250., 250., 650., 650., 250. /)

  gsres = True
  gsres@gsFillColor = "salmon"

;---Add the same filled box to all XY plots.
  id_ugoc = gsn_add_polygon(wks,plot_ugoc,pgx,pgy,gsres)
  id_ogoc = gsn_add_polygon(wks,plot_ogoc,pgx,pgy,gsres)
  id_oguc = gsn_add_polygon(wks,plot_oguc,pgx,pgy,gsres)

;---Panel all three plots
  pres                 = True
  pres@gsnMaximize     = True
  pres@gsnPanelRowSpec = True    ; 1 plot on first row, 2 plots on second row
  gsn_panel(wks,(/plot_ugoc,plot_ogoc,plot_oguc/),(/1,2/),pres)
end
