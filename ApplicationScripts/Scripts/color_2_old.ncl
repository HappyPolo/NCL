;*************************************************
; color_2_old.ncl
;
; Concepts illustrated:
;   - Drawing color filled contours using a selected color map
;   - Selecting a different color map
;   - Spanning the full color map for contour fill
;   - Spanning part of a color map for contour fill
;   - Adding a color to an existing color map
;   - Using "mask" to set land or ocean values in your data to missing
;   - Setting contour levels using a min/max contour level and a spacing
;************************************************
; Note: This script is the old way of doing 
; color in NCL (NCL versions 6.0.0 and older).
;
; See color_2.ncl for a more modern way.
;************************************************
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl" 
;************************************************
begin
;************************************************
; read in netCDF file
;************************************************
  in  = addfile("atmos.nc","r")
  u   = in->U(0,0,:,:)                            ; read in data
  oro = in->ORO(0,:,:)
;************************************************
; create plot 1
;************************************************
  wks = gsn_open_wks("ps","color")                 ; open a ps file
  gsn_define_colormap(wks,"BlWhRe")                ; choose colormap

  res                      = True                  ; plot mods desired
  res@tiMainString         = "BlWhRe Colormap"     ; title
  res@cnFillOn             = True                  ; turn on color fill

;---This resource not needed in NCL V6.1.0
  res@gsnSpreadColors      = True                  ; use full range of colors

  res@cnLinesOn            = False

; when using a blue/red color map, it is best to set the contour min/max
; to equal but opposite values so that the lightest colors are centered 
; on zero
  res@cnLevelSelectionMode = "ManualLevels"        ; set manual contour levels
  res@cnMinLevelValF       =  -80.                 ; set min contour level
  res@cnMaxLevelValF       =   80                  ; set max contour level
  res@cnLevelSpacingF      =   10                  ; set contour spacing

  plot = gsn_csm_contour_map(wks,u, res)        ; create plot
;************************************************
; use mask function to mask out land and then ocean data
; ocean=0,land=1,sea_ice=2
;************************************************
  ocean_only = u
  ocean_only = mask(u,oro,0)
;************************************************
; create plot 2
;************************************************
;
; This will not be necessary in V6.1.0 and later. Named colors can
; be used without having to first add them to the color map.
;
  i = NhlNewColor(wks,0.8,0.8,0.8)                ; add gray to color map 

  res@gsnSpreadColorEnd              = -3         ; don't use added gray
  res@tiMainString                   = "Blue/Red Ocean Example"

  plot = gsn_csm_contour_map(wks,ocean_only,res)
  end
