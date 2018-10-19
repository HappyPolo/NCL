;*************************************************************
; panel_14.ncl
;
; Concepts illustrated:
;   - Combining two sets of paneled plots on one page
;   - Adding a common labelbar to paneled plots
;   - Reversing the Y axis
;
; Created and contributed by Keith Lindsay
;*************************************************************
;
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
;*************************************************************
begin
  in = addfile("h_avg_Y0191_D000.00.nc","r")
  T=in->T
;*************************************************************
; plot parameters
;************************************************************* 
  wks = gsn_open_wks("png","panel")              ; send graphics to PNG file

  plot = new(4,graphic)                          ; create graphical array
;*************************************************************
; create xy plots
;*************************************************************  
  xy_res               = True       ; plot mods desired
  xy_res@gsnFrame      = False      ; don't advance frame yet
  xy_res@vpWidthF      = 0.359488   ; plot size (width)
  xy_res@vpHeightF     = 0.359488   ; plot size (length)
  
  xy_res@trYReverse    = True       ; reverse y axis
  xy_res@tmXTLabelsOn  = True       ; have tick mark labels
  xy_res@tmXTOn        = True       ; have tick marks
  xy_res@tmXBLabelsOn  = False      ; turn off bottom labels
  xy_res@tiXAxisSide   = "top"      ; move axis title to top
  
  xy_res@vpYF          = 0.90       ; location of plot(0)
  xy_res@vpXF          = 0.121578   ; location of plot(0)

  plot(0) = gsn_csm_xy(wks,T(0,:,{30},{180}),T&z_t,xy_res)
  
  xy_res@vpXF          = 0.55       ; location of plot(1)
  xy_res@tiYAxisOn     = False      ; no y-axis title
  xy_res@tmYLLabelsOn  = False      ; no left tm lables
  plot(1) = gsn_csm_xy(wks,T(0,:,{-30},{180}),T&z_t,xy_res)
;*************************************************************
; create contour plots
;*************************************************************  
  con_res                 = True    ; contour mods desired
  con_res@gsnFrame        = False   ; don't draw yet
  con_res@gsnDraw         = False   ; don't advance frame yet
  
  con_res@tiMainOn        = False   ; no title
  con_res@cnFillOn        = True    ; turn on color
  con_res@cnLinesOn       = False   ; turn off contour lines
  con_res@cnLineLabelsOn  = False   ; turn off contour line labels
  con_res@cnFillPalette   = "gui_default"
  
  con_res@gsnLeftString  = ""       ; turn off special strings
  con_res@gsnRightString = ""
  
  con_res@lbLabelBarOn   = False    ; no individual label bar
  con_res@cnInfoLabelOn  = False    ; no contour labels
  con_res@trYReverse     = True     ; reverse y axis
  con_res@vpWidthF       = 0.6      ; width of contour plots
  
  con_res@tiYAxisString  = "Depth (T grid)" ; y-axis title
  plot(2) = gsn_csm_contour(wks,T(0,:,:,{270}),con_res)
  
  con_res@tmYLLabelsOn   = False    ; no y left tm labels
  con_res@tiYAxisOn      = False    ; no y-axis title
  con_res@tiYAxisString  = " "
  plot(3) = gsn_csm_contour(wks,T(0,:,:,{200}),con_res)
;***********************************************************
; panel resources
;***********************************************************
  panel_res                    = True   ; panel mods desired
  panel_res@gsnPanelBottom     = 0.0    ; space for label bar
  panel_res@gsnPanelTop        = 0.5    ; only panel on lower half of page
  panel_res@gsnPanelLabelBar   = True   ; common label bar
  panel_res@pmLabelBarWidthF   = 0.8    ; label bar width
  panel_res@gsnPanelXF         = (/0.121578,0.55/)
  
  gsn_panel(wks, plot(2:3), (/ 1, 2 /), panel_res)
end
 
          


