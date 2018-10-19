;*************************************************
; pub_2.ncl
;
; Concepts Illustrated:
;   - Subsetting color maps using the old model
;   - Paneling plots
;   - Using a common labelbar for paneled plots
;
;************************************************
;
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl" 
;************************************************
begin
;************************************************
; read in netCDF file
;************************************************
  a = addfile("$NCARG_ROOT/lib/ncarg/data/cdf/uv300.nc","r")
  u = a->U(1,:,:)                                ; read July zonal winds
  v = a->V(1,:,:)
;************************************************
; create plots
;************************************************
  wks = gsn_open_wks("png","pub")                ; send graphics to PNG file
  gsn_define_colormap(wks,"gui_default")
  plot = new(2,graphic)                          ; create a plot array
  
  res                     = True
  res@gsnDraw             = False           ; don't draw
  res@gsnFrame            = False           ; don't advance frame
  res@cnInfoLabelOn       = False           ; turn off cn info label
  res@cnFillOn            = True            ; turn on color
  res@gsnSpreadColors     = True            ; spread out color table
  res@gsnSpreadColorStart = 2               ; color to start
  res@gsnSpreadColorEnd   = 20              ; color to end
  res@lbLabelBarOn        = False           ; turn off individual cb's

; to have a common label bar, both plots should be set to the same interval
; b/c the label bar is drawn by default from the interval of the first plot.
  res@cnLevelSelectionMode =  "ManualLevels"   
  res@cnMinLevelValF       = -10.
  res@cnMaxLevelValF       =  45.
  res@cnLevelSpacingF      =   5. 

  plot(0) = gsn_csm_contour_map_ce(wks,u,res) 
  plot(1) = gsn_csm_contour_map_ce(wks,v,res) 
;************************************************
; create panel
;************************************************
  resP                  = True                    ; modify the panel plot
  resP@txString         = "A plot with a common label bar"
  resP@gsnPanelLabelBar = True                    ; add common colorbar
  resP@gsnPanelFigureStrings = (/"a)","b)"/)      ; add strings to panel
  gsn_panel(wks,plot,(/3,1/),resP)                ; now draw as one plot

 

end
