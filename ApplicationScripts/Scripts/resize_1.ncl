;*************************************************
; resize_1.ncl
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
  wks = gsn_open_wks("png","resize")          ; send graphics to PNG file
  plot = new(3,graphic)                       ; create a plot array
  
  res                     = True
  res@gsnDraw             = False           ; don't draw
  res@gsnFrame            = False           ; don't advance frame
  res@cnInfoLabelOn       = False           ; turn off cn info label
  res@cnFillOn            = True            ; turn on color
  cmap    = read_colormap_file("gui_default")
  ncolors = dimsizes(cmap(:,0))               ; get the number of colors
  res@cnFillPalette       = cmap(0:ncolors-3,:)   ; drop the last two colors
  res@lbLabelBarOn        = False           ; turn off individual cb's

; to have a common label bar, both plots should be set to the same interval
; b/c the label bar is drawn by default from the interval of the first plot.
  res@cnLevelSelectionMode =  "ManualLevels"   
  res@cnMinLevelValF       = -10.
  res@cnMaxLevelValF       =  45.
  res@cnLevelSpacingF      =   5. 

  plot(0) = gsn_csm_contour_map_ce(wks,u,res) 
  plot(1) = gsn_csm_contour_map_ce(wks,v,res) 
  plot(2) = gsn_csm_contour_map_ce(wks,u,res) 
;************************************************
; create panel
;************************************************
  resP                  = True                   ; modify the panel plot
  resP@gsnPanelLabelBar = True                   ; add common colorbar
  resP@txString         = "Using gsnMaximize"    ; add common title
  resP@gsnMaximize      = True                   ; use full page
  gsn_panel(wks,plot,(/3,1/),resP)               ; now draw as one plot

end
