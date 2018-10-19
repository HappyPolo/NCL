;*************************************************
; resize_6.ncl
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
  a4_height   = 29.7
  a4_width    = 23.0
  cm_per_inch = 2.54

;---Change the width/height of the paper being drawn to.
  wtype           = "ps"
  wtype@wkWidthF  = a4_width/cm_per_inch
  wtype@wkHeightF = a4_height/cm_per_inch
  wks = gsn_open_wks(wtype,"resize")                 ; open a ps file
  
  res                     = True
  res@cnFillOn            = True             ; turn on color
  res@cnFillPalette       = "BlAqGrYeOrReVi200"  ; set color map
  res@cnLinesOn           = False            ; turn off contour lines
  
  res@cnLevelSelectionMode =  "ManualLevels" ; manually set contour levels  
  res@cnMinLevelValF       = -10.
  res@cnMaxLevelValF       =  45.
  res@cnLevelSpacingF      =   5.
  
  res@gsnMaximize         = True        ; must include w/ Paper Orientation

  plot  = gsn_csm_contour_map_ce(wks,u,res) 
  
end


