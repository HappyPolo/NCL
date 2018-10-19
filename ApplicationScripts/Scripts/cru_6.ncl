;----------------------------------------------------------------------
; cru_6.ncl
;
; Concepts illustrated:
;   - Plotting CRU (Climate Research Unit) data
;   - Drawing filled bars above and below a given reference line
;   - Paneling three plots vertically on a page
;   - Adding lines and text to a plot
;   - Changing the width and height of a plot
;   - Attaching multiple XY plots along the X axes
;----------------------------------------------------------------------
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"  
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"  
;----------------------------------------------------------------------
begin
;---Read data
  f    = addfile("Tave_18562003.nc","r")

  year = f->year
  time = f->time
  ntime  = dimsizes(time)
  nyears = dimsizes(year)

  tnhan = f->TAveNhAn
  tshan = f->TAveShAn
  tglan = f->TAveGlAn

;***************************************
; Some weights for 'decadal' filter (smoother)
; Other weights could be used
;***************************************  
  wgts = (/ 1,6,19,42,71,96,106,96,71,42,19,6,1 /)*1.0
  wgts = wgts/sum(wgts)

  TNH  = wgt_runave_n_Wrap(tnhan, wgts, 1, 0)      ; reflective end pts 
  TSH  = wgt_runave_n_Wrap(tshan, wgts, 1, 0)  
  TGL  = wgt_runave_n_Wrap(tglan, wgts, 1, 0)  

;---Create plot
  wks = gsn_open_wks("png","cru")                 ; send graphics to PNG file
  plot= new (3,graphic)                           ; create graphical array

  res                       = True                ; plot mods desired
  res@gsnDraw               = False               ; don't draw yet      
  res@gsnFrame              = False               ; don't advance frame yet

  res@vpHeightF             = 0.43                ; Changes the aspect ratio
  res@vpWidthF              = 0.90                ; of plots

  res@trYMinF               = -0.75               ; min value on y-axis
  res@trYMaxF               =  0.75               ; max value on y-axis

  res@gsnYRefLine           = 0.                  ; reference line   
  res@gsnAboveYRefLineColor = "red"               ; above ref line fill red
  res@gsnBelowYRefLineColor = "blue"              ; below ref line fill blue

  res@gsnXYBarChart         = True                ; create bar chart 
  res@xyLineColors          = (/"red","blue"/)    ; line around bar color

; create plots
  res@tiYAxisString = ""
  plot(0) = gsn_csm_xy (wks,year,tnhan,res)

  res@tiYAxisString = "HadCRUT3: Anomalies (C)"
  plot(1) = gsn_csm_xy (wks,year,tshan,res)

  res@tiYAxisString = ""
  plot(2) = gsn_csm_xy (wks,year,tglan,res)

;---Add some text strings inside the plots
  txres               = True
  txres@txFontHeightF = 0.025
  txres@txJust        = "CenterLeft"

  tx_tnh = gsn_add_text(wks,plot(0),"Northern Hemisphere",1870,0.6,txres)
  tx_tsh = gsn_add_text(wks,plot(1),"Southern Hemisphere",1870,0.6,txres)
  tx_tgl = gsn_add_text(wks,plot(2),"Globe",1870,0.6,txres)

;---Add black curve to each plot
  plres               =  True
  plres@gsLineColor   = "black"                   ; color of lines
  plres@gsLineThicknessF = 3.0                    ; thickness of lines

  ln_tnh = gsn_add_polyline(wks, plot(0), year, TNH, plres)
  ln_tsh = gsn_add_polyline(wks, plot(1), year, TSH, plres)
  ln_tgl = gsn_add_polyline(wks, plot(2), year, TGL, plres)

;---Create panel plot
  resP             = True
  resP@gsnMaximize = True
  gsn_panel(wks,plot,(/3,1/),resP)

;---Attach plots along the X axes and redraw
 res1 = True
 res1@gsnAttachPlotsXAxis = True
 newplot = gsn_attach_plots(plot(0),(/plot(1),plot(2)/),res1,False)
 draw(plot(0))
 frame(wks)
 
end
