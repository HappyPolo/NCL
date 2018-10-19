;================================================;
;  Popgrid_1.ncl
;================================================;
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"   
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"   
; ================================================;
begin
  f         = addfile("TEMP.nc","r")

  t         = f->TEMP

  lat2d     = f->TLAT
  lon2d     = f->TLONG
;=================================================;
; Create plot
;=================================================;
  wks  = gsn_open_wks("ps","popgrid")             ; open a ps file
  gsn_define_colormap(wks,"BlAqGrYeOrRe")         ; choose colormap
  res                      = True                 ; plot mods desired
  res@gsnDraw              = False                ; don't draw yet
  res@gsnFrame             = False                ; don't advance frame yet
  res@cnFillOn             = True                 ; turn on color fill
  res@cnLinesOn            = False                ; turn off contour lines
  res@gsnSpreadColors      = True                 ; use full colormap
  res@gsnSpreadColorStart  = 10                   ; start at color 10
  res@gsnSpreadColorEnd    = 96                   ; end at color 96    
  res@lbLabelAutoStride    = True                 ; nice label bar labels
             
  plot = gsn_csm_contour(wks,t(0,0,:,:),res)  
;************************************
; create overlays of both lat/lon contours
; and add to the map plot
;************************************
  ores               = True                       ; plots mods desired
  ores@gsnDraw       = False                      ; don't draw yet
  ores@gsnFrame      = False                      ; don't advance frame yet
  ores@cnInfoLabelOn = False                      ; turn off info label
  ores@tiMainString  = "The POP Grid"             ; add title

  latplot = gsn_contour(wks,lat2d,ores)           ; create lat contours
  overlay(plot,latplot)                           ; overlay onto map

  lonplot = gsn_contour(wks,lon2d,ores)           ; create lon contours
  overlay(plot,lonplot)                           ; overlay on map

; now we draw the whole thing and advance the frame.
  draw(plot)
  frame(wks)
  end

