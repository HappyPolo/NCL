;----------------------------------------------------------------------
; xy_32.ncl
;
; Concepts illustrated:
;   - Drawing a time series plot
;   - Drawing multiple legends outside an XY plot
;   - Overlaying XY plots on each other
;   - Changing the labels in a legend
;   - Labeling the X axis with nicely-formatted time labels
;----------------------------------------------------------------------
; In order to have the legends side-by-side, instead of one legend
; with 8 lines it in, it is necessary to create 4 XY plots, each with
; its own legend. Each legend is moved to the right or left 
; slightly so they don't overlap.  The plots are all "connected" into
; one plot using "overlay".
;----------------------------------------------------------------------
;
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
;
; This file still has to be loaded manually
load "$NCARG_ROOT/lib/ncarg/nclscripts/contrib/time_axis_labels.ncl"

begin
  dir = "$NCARG_ROOT/lib/ncarg/data/cdf/"
  a   = addfile(dir + "chi200_ud_smooth.nc","r")
  chi = transpose(a->CHI)
  chi = chi/1.e6                              ; scale for convenience

;---Start the graphics
  wks = gsn_open_wks("png","xy")              ; send graphics to PNG file

;---Plotting options for time series plot
  res             = True

  res@gsnMaximize = True

  res@gsnDraw     = False      ; Will draw later, after overlaying
  res@gsnFrame    = False      ; all plots

  res@vpWidthF    = 0.8        ; Make plots wider
  res@vpHeightF   = 0.4

  res@trXMinF     = min(chi&time)
  res@trXMaxF     = max(chi&time)
  res@trYMinF     = min(chi)
  res@trYMaxF     = max(chi)

;---Resources for legend
  res@pmLegendDisplayMode    = "Always"              ; turn on legend
  res@pmLegendWidthF         = 0.12                  ; Change width and
  res@pmLegendHeightF        = 0.15                  ; height of legend.
  res@pmLegendOrthogonalPosF = -0.08                 ; move up slightly 
  res@lgLabelFontHeightF     = .011                  ; change font height
  res@lgPerimOn              = False                 ; no box around
  res@lgItemOrder            = (/1,0/)               ; reverse legend

;---Titles
  res@tiMainString           = chi@long_name
  res@tiYAxisString          = ""

;---Turn off some tickmarks
  res@tmXTOn                 = False    ; bottom off
  res@tmYROn                 = False    ; right off

  res@xyLineThicknessF       = 2.0      ; default is 1
  res@xyMonoDashPattern      = True     ; force all solid lines

;--------------------------------------------------
; The time_axis_label function adds additional
; resources to "res" to produce nicely-formatted
; time labels on X axis. This function only works
; if you have a time "units" recognized by the
; cd_calendar function.
;---------------------------------------------------
  restick                = True
  restick@ttmFormat      = "%N/%D/%y"
  time_axis_labels(chi&time,res,restick)

;---Subset of longitudes to plot for the four plots
  lon1_start_idx = 0
  lon1_end_idx   = 1
  lon2_start_idx = 2
  lon2_end_idx   = 3
  lon3_start_idx = 4
  lon3_end_idx   = 5
  lon4_start_idx = 6
  lon4_end_idx   = 7

;---Set resources for colors and labels
  colors1 = (/"blue","red"/)
  colors2 = (/"darkgreen","darkorange"/)
  colors3 = (/"brown","purple"/)
  colors4 = (/"navyblue","black"/)
  labels1 = "lon = " + chi&lon(lon1_start_idx:lon1_end_idx)
  labels2 = "lon = " + chi&lon(lon2_start_idx:lon2_end_idx)
  labels3 = "lon = " + chi&lon(lon3_start_idx:lon3_end_idx)
  labels4 = "lon = " + chi&lon(lon4_start_idx:lon4_end_idx)

;---Create the four XY plots
  res@xyLineColors           = colors1
  res@xyExplicitLegendLabels = labels1
  res@pmLegendParallelPosF   = 0.15

  plot1 = gsn_csm_xy(wks,chi&time,chi(lon1_start_idx:lon1_end_idx,:),res)

  res@xyLineColors           = colors2
  res@xyExplicitLegendLabels = labels2
  res@pmLegendParallelPosF   = 0.37
  plot2 = gsn_csm_xy(wks,chi&time,chi(lon2_start_idx:lon2_end_idx,:),res)

  res@xyLineColors           = colors3
  res@xyExplicitLegendLabels = labels3
  res@pmLegendParallelPosF   = 0.59
  plot3 = gsn_csm_xy(wks,chi&time,chi(lon3_start_idx:lon3_end_idx,:),res)

  res@xyLineColors           = colors4
  res@xyExplicitLegendLabels = labels4
  res@pmLegendParallelPosF   = 0.81
  plot4 = gsn_csm_xy(wks,chi&time,chi(lon4_start_idx:lon4_end_idx,:),res)

;---Overlay one plot on the other, so they become one plot.
  overlay(plot1,plot2)
  overlay(plot1,plot3)
  overlay(plot1,plot4)

  draw(plot1)            ; This will draw all four plots
  frame(wks)
end
