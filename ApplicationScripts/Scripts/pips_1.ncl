;================================================;
;  pips_1.ncl
;================================================;
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"   
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"   
; ================================================;
begin
  f             = addfile("./iceh_davg.0014-01-01.nc","r")

  hi            = f->hi(0,:,1:)
  hi!0          = "lat"
  hi!1          = "lon"

  lat2d         = f->tlat
  lon2d         = f->tlon
  hi@lon2d      = lon2d(:,1:)
  hi@lat2d      = lat2d(:,1:)
  hi@_FillValue = hi@missing_value
  hi = mask(hi, hi.eq.0.0,False)       ; change all 0.0 to _FillValue

;=================================================;
; Create plot
;=================================================;
  wks  = gsn_open_wks("ps","pips")                ; open a ps file
  gsn_define_colormap(wks,"gui_default")          ; choose colormap

; plot resources  
  res                  = True                     ; plot mods desired
  res@gsnAddCyclic     = False                    ; no cyclic point
  res@gsnPolar         = "NH"                     ; which hemisphere to plot
  res@mpMinLatF        = 60.                      ; minimum latitude
  res@cnFillOn         = True                     ; turn on color
  res@cnLinesOn        = False                    ; turn off contour lines
  res@gsnSpreadColors  = True                     ; use full range of colormap

  plot = gsn_csm_contour_map_polar(wks,hi,res)    ; create plot
  end
