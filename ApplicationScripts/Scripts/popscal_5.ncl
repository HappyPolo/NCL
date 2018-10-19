; =================================================;
; popscal_5.ncl
; =================================================;
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"   
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"   
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"   
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl"   
; =================================================;
begin
  f = addfile("b20.007.pop.h.1000-01.nc","r")

  ssh           = f->SSH
  shf           = f->SHF
  lat2d         = f->TLAT
  lon2d         = f->TLONG

  ssh@lon2d     = lon2d
  ssh@lat2d     = lat2d
;=================================================;
; Create plot
;=================================================;
  wks  = gsn_open_wks("ps","popscal")            ; open a ps file
  gsn_define_colormap(wks,"BlAqGrYeOrRe")         ; choose colormap

  res                      = True                 ; plot mods desired
  res@cnFillOn             = True                 ; turn on color fill
  res@cnLinesOn            = False                ; turn off contour lines
  res@gsnSpreadColors      = True                 ; use full colormap
  res@gsnDraw              = False                ; don't draw yet
  res@gsnFrame             = False                ; don't advance frame yet
  res@gsnAddCyclic         = True                 ; add cyclic point

  pltBase = gsn_csm_contour_map_ce(wks,ssh(0,:,:),res)
;=================================================;
; Create second plot
;=================================================; 
  cnres          = True
  cnres@gsnDraw  = False                          ; don't draw yet
  cnres@gsnFrame = False                          ; don't advance frame yet
  cnres@sfXArray = lon2d                          ; set x coordinates
  cnres@sfYArray = lat2d                          ; set y coordinates
  cnres@cnInfoLabelOn = False                     ; turn off info label

  plot = gsn_csm_contour(wks,shf(0,:,:),cnres)
; =================================================;
; now overlay vector plot on top of scalar plot
; =================================================;
  overlay(pltBase,plot)
  draw(pltBase)
  frame(wks)
  end

