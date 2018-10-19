;*************************************************
; color_9_new.ncl
;
; Concepts illustrated:
;   - Changing the contour level spacing
;   - Using cnFillPalette to assign a color palette to contours
;   - Paneling two plots vertically
;************************************************
; Note: in version 6.1.0-beta and later, is no
; longer necessary to merge color maps in order
; to use two different ones in a plot.
;
; Instead, you can use the new "cnFillPalette",
; "vcLevelPalette", and "stLevelPalette" resources
; to associate a color table with a plot, rather
; than with a workstation.
;
; See color_9.ncl for an example of using
; these new resources.
;************************************************
;
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"   
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"    
;************************************************
begin
  wks = gsn_open_wks("png","color")               ; send graphics to PNG file
  
  draw_color_palette(wks,(/"wgne15","gui_default"/),False)
  
  a = addfile("$NCARG_ROOT/lib/ncarg/data/cdf/uv300.nc","r")
  u = a->U(1,:,:)                    ; read in data

  plot = new(2,graphic)              ; create graphic array for panel plot

  res           = True               ; plot mods desired
  res@cnFillOn  = True               ; turn on color fill
  res@gsnDraw   = False              ; don't draw yet
  res@gsnFrame  = False              ; don't advance frame yet

  res@cnLevelSpacingF = 6.           ; change contour spacing
  res@cnFillPalette   = "wgne15"     ; specify color palette
  plot(0) = gsn_csm_contour_map(wks,u, res)    

  res@cnLevelSpacingF = 5.                ; change contour spacing
  res@cnFillPalette   = "gui_default"     ; specify color palette
  plot(1) = gsn_csm_contour_map(wks,u, res)    

  gsn_panel(wks,plot,(/2,1/),False)
end
