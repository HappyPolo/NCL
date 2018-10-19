;*************************************************
; panel_4.ncl
;
; Concepts illustrated:
;   - Paneling three plots vertically on a page
;   - Adding a common title to paneled plots
;   - Adding a common labelbar to paneled plots
;   - Adding additional text at the bottom of a series of paneled plots
;   - Subsetting a color map
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
  wks = gsn_open_wks("png","panel")           ; send graphics to PNG file

  plot = new(3,graphic)                       ; create a plot array
  
  cmap  = read_colormap_file("gui_default")
  ncmap = dimsizes(cmap(:,0))

  res                     = True
  res@gsnDraw             = False            ; don't draw
  res@gsnFrame            = False            ; don't advance frame
  res@cnInfoLabelOn       = False            ; turn off cn info label
  res@cnFillOn            = True             ; turn on color
  res@cnFillPalette       = cmap(:ncmap-3,:) ; skip last two colors
  res@lbLabelBarOn        = False            ; turn off individual cb's
;
; Force both plots to have the same contour levels. This is necessary
; because the gsn_panel routine will based the labelbar on the first
; plot in the list.
;
  res@cnLevelSelectionMode =  "ManualLevels"   
  res@cnMinLevelValF       = -10.
  res@cnMaxLevelValF       =  45.
  res@cnLevelSpacingF      =   5. 

  plot(0) = gsn_csm_contour_map(wks,u,res) 
  plot(1) = gsn_csm_contour_map(wks,v,res) 
  plot(2) = gsn_csm_contour_map(wks,u,res) 
;************************************************
; create panel
;************************************************
  resP                    = True                 ; modify the panel plot
  resP@gsnFrame           = False                ; don't advance panel plot
  resP@gsnPanelLabelBar   = True                 ; add common colorbar
  resP@gsnPanelBottom     = 0.05
  resP@gsnPanelMainString = "A common title"     ; new way of setting main title (as of NCL V6.4.0)
; resP@txString           = "A common title"     ; old way of setting main title
  gsn_panel(wks,plot,(/3,1/),resP)               ; now draw as one plot


; Draw a text string at the bottom
  txres               = True
  txres@txFontHeightF = 0.015
  gsn_text_ndc(wks,"Figure 1: A nifty panel plot",0.5,0.02,txres)
  frame(wks)

end
