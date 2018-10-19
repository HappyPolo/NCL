;*************************************************
; color_11.ncl
;
; Concepts illustrated:
;   - Using the CMYK color model
;   - Selecting a different color map
;   - Spanning part of a color map for contour fill
;   - Changing the contour level spacing
;   - Setting contour levels using a min/max contour level and a spacing
;
;************************************************
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl" 
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl" 
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl" 
;************************************************
begin
;************************************************
; read in netCDF file
;************************************************
  a = addfile("$NCARG_ROOT/lib/ncarg/data/cdf/uv300.nc","r")
;************************************************
; read in zonal winds
;************************************************
  u = a->U(1,:,:)                                ; read July zonal winds
;************************************************
; create plot
;************************************************
  type              = "oldps"                ; You must use "oldps" here. The "new"
  type@wkColorModel = "cmyk"                 ;  ps doesn't recognize cmyk.


  wks = gsn_open_wks(type,"color")                 ; open a ps file
  gsn_define_colormap(wks,"BlAqGrYeOrRe")          ; choose colormap

  res = True                                       ; plot mods desired
  res@gsnCenterString      = "300 mb"              ; plot center string
  res@cnFillOn             = True                  ; turn on color fill
  res@mpFillOn             = False                 ; turn off continent gray


  res@gsnSpreadColors      = True                  ; use full colormap
  res@gsnSpreadColorStart  = 10                    ; start at color 10
  res@gsnSpreadColorEnd    = 96                    ; end at color 96

  res@cnLevelSelectionMode = "ManualLevels"        ; set manual contour levels
  res@cnMinLevelValF       = -10.                  ; set min contour level
  res@cnMaxLevelValF       =  35.                  ; set max contour level
  res@cnLevelSpacingF      =   5.                  ; set contour spacing

  plot = gsn_csm_contour_map_ce(wks,u, res)        ; create plot
  end
