;*************************************************
; NCL Graphics: leg_1.ncl
;
; Concepts illustrated:
;   - Drawing a legend inside an XY plot
;   - Changing the width and height of a legend
;   - Turning off the perimeter around a legend
;   - Changing the font size of legend labels
;   - Customizing the labels in a legend
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
  a = addfile("$NCARG_ROOT/lib/ncarg/data/cdf/uv300.nc","r")
;************************************************
; read in zonal winds
;************************************************
  lat=a->lat
  nlat=dimsizes(lat)

  u = a->U(0,:,:)
  uz = dim_avg(u)
  v = a->V(0,:,:)
  vz= dim_avg(v)
  uz!0="lat"
  uz&lat=lat
  vz!0="lat"
  vz&lat=lat

  data=new( (/2,nlat/),float)
  data(0,:)=uz
  data(1,:)=vz
;************************************************
; create plot
;************************************************
  wks = gsn_open_wks("png","leg")                  ; send graphics to PNG file

  res                        = True                ; plot mods desired

  res@pmLegendDisplayMode    = "Always"            ; turn on legend
  res@pmLegendSide           = "Top"               ; Change location of 
  res@pmLegendParallelPosF   = .1                  ; move units right
  res@pmLegendOrthogonalPosF = -0.3                ; move units down
  res@pmLegendWidthF         = 0.15                ; Change width and
  res@pmLegendHeightF        = 0.18                ; height of legend.
  res@lgPerimOn              = False               ; turn off box around
  res@lgLabelFontHeightF     = .03                 ; label font height
  res@xyExplicitLegendLabels = (/"U","V"/)         ; create explicit labels

  plot=gsn_csm_xy(wks,lat,data,res)

end
