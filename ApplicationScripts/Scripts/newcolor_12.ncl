;----------------------------------------------------------------------
; newcolor_12.ncl
;
; Concepts illustrated:
;   - Showing features of the new color display model
;   - Drawing partially transparent polygons
;   - Turning off all tickmarks
;   - Creating a blank plot
;----------------------------------------------------------------------
; This script shows how to draw several filled polygons
; on top of each other. The first frame uses no 
; transparency, while the second one does.
;----------------------------------------------------------------------
; NOTE: This example will only work with NCL V6.1.0 and later.
;----------------------------------------------------------------------
;
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"

;----------------------------------------------------------------------
; Procedure to attach a box to the given plot, given the lower left
; corner, width, color, and opacity.
;----------------------------------------------------------------------
procedure add_box(wks,plot,ll[2],width,cname,oval)
local xbox, ybox, gsres, dumstr
begin
  xbox = (/ll(0),ll(0)+width,ll(0)+width,ll(0),ll(0)/)
  ybox = (/ll(1),ll(1),ll(1)+width,ll(1)+width,ll(1)/)

  gsres                = True
  gsres@gsFillColor    = cname
  gsres@gsFillOpacityF = oval
  dumstr               = unique_string("gon")
;
; Adding it as an attribute is a sneaky way to
; make sure it "lives" outside this procedure.
;
  plot@$dumstr$ = gsn_add_polygon(wks,plot,xbox,ybox,gsres)
end

;----------------------------------------------------------------------
; Main code
;----------------------------------------------------------------------
begin
  wks = gsn_open_wks("png","newcolor") ; send graphics to PNG file

  res = True

  res@gsnMaximize       = True
  res@gsnDraw           = False      ; Don't draw until after we add boxes.

;---Turn off tickmarks
  res@tmXBOn            = False
  res@tmYLOn            = False
  res@tmXTOn            = False
  res@tmYROn            = False
  res@tmXBBorderOn      = False
  res@tmXTBorderOn      = False
  res@tmYLBorderOn      = False
  res@tmYRBorderOn      = False

;---Three titles at top
  res@gsnLeftString        = "drawn bottom-top,~C~     1.0 opacity"
  res@gsnCenterString      = "drawn bottom-top,~C~     0.5 opacity"
  res@gsnRightString       = "drawn top-bottom,~C~     0.5 opacity"
  res@gsnStringFontHeightF = 0.013

;---Create a blank plot
  plot = gsn_csm_blank_plot(wks,res)

;--------------------------------------------------
; Section to attach filled boxes to blank plot.
;--------------------------------------------------

;---Fully opaque, bottom-to-top
  add_box(wks,plot,(/0.02,0.03/),0.2,"red",    1.0)
  add_box(wks,plot,(/0.12,0.18/),0.2,"green",  1.0)
  add_box(wks,plot,(/0.02,0.33/),0.2,"blue",   1.0)
  add_box(wks,plot,(/0.12,0.48/),0.2,"cyan",   1.0)
  add_box(wks,plot,(/0.02,0.63/),0.2,"magenta",1.0)
  add_box(wks,plot,(/0.12,0.78/),0.2,"yellow", 1.0)

;---0.5 opacity, bottom-to-top
  add_box(wks,plot,(/0.35,0.03/),0.2,"red",    0.5)
  add_box(wks,plot,(/0.45,0.18/),0.2,"green",  0.5)
  add_box(wks,plot,(/0.35,0.33/),0.2,"blue",   0.5)
  add_box(wks,plot,(/0.45,0.48/),0.2,"cyan",   0.5)
  add_box(wks,plot,(/0.35,0.63/),0.2,"magenta",0.5)
  add_box(wks,plot,(/0.45,0.78/),0.2,"yellow", 0.5)

;---0.5 opacity, top-to-bottom
  add_box(wks,plot,(/0.78,0.78/),0.2,"yellow", 0.5)
  add_box(wks,plot,(/0.68,0.63/),0.2,"magenta",0.5)
  add_box(wks,plot,(/0.78,0.48/),0.2,"cyan",   0.5)
  add_box(wks,plot,(/0.68,0.33/),0.2,"blue",   0.5)
  add_box(wks,plot,(/0.78,0.18/),0.2,"green",  0.5)
  add_box(wks,plot,(/0.68,0.03/),0.2,"red",    0.5)

  draw(plot)      ; This will draw all the attached boxes
  frame(wks)
end
