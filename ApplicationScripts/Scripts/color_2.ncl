;*************************************************
; color_2.ncl
;
; Concepts illustrated:
;   - Drawing color filled contours using a selected color map
;   - Using "mask" to set land or ocean values in your data to missing
;   - Setting contour levels using a min/max contour level and a spacing
;
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
  in  = addfile("atmos.nc","r")
  u   = in->U(0,0,:,:)                            ; read in data
  oro = in->ORO(0,:,:)
;************************************************
; create plot 1
;************************************************
  wks = gsn_open_wks("png","color")                ; send graphics to PNG file

  res                      = True                  ; plot mods desired
  res@tiMainString         = "BlWhRe Colormap"     ; title

  res@cnFillOn             = True                  ; turn on color fill
  res@cnFillPalette        = "BlWhRe"              ; choose colormap
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
; use mask function to mask out ocean data
; ocean=0,land=1,sea_ice=2
;************************************************
  ocean_only = u
  ocean_only = mask(u,oro,0)
;************************************************
; create plot 2
;************************************************
  res@tiMainString                   = "Blue/Red Ocean Example"

  plot = gsn_csm_contour_map(wks,ocean_only,res)
  end
