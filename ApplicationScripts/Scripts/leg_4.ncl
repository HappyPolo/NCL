;*************************************************
; NCL Graphics: leg_4.ncl
;
; Concepts illustrated:
;   - Drawing a legend inside an XY plot
;   - Changing the width and height of a legend
;   - Adding labels to a curve in an XY plot
;   - Changing the font size of legend labels
;   - Changing the angle of the legend labels
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

  u   = a->U(0,:,:)
  uz1 = dim_avg(u)
  u   = a->U(1,:,:)
  uz2 = dim_avg(u)
  uz1!0   = "lat"
  uz1&lat =  lat
  uz2!0   = "lat"
  uz2&lat =  lat

  v   = a->V(0,:,:)
  vz1 = dim_avg(v)
  v   = a->V(1,:,:)
  vz2 = dim_avg(v)
  vz1!0   = "lat"
  vz1&lat =  lat
  vz2!0   = "lat"
  vz2&lat =  lat

  data=new( (/4,nlat/),float)
  data(0,:)=uz1
  data(1,:)=vz1
  data(2,:)=uz2
  data(3,:)=vz2
;************************************************
; create plot
;************************************************
  wks = gsn_open_wks("png","leg")                  ; send graphics to PNG file

  res                        = True
  res@pmLegendDisplayMode    = "Always"

  res@pmLegendSide           = "Top"               ; Change location of 
  res@pmLegendParallelPosF   = .50                 ; move units right
  res@pmLegendOrthogonalPosF = -0.2                ; move units down

  res@pmLegendWidthF         = 0.12                ; Change width and
  res@pmLegendHeightF        = 0.05                ; height of legend.
  res@lgLabelFontHeightF     = .02                 ; change font height
  res@lgOrientation          = "horizontal"
  res@lgPerimOn              = False               ; no box around

  res@xyMarkLineModes        = (/"Lines"/)         ; line style
  res@xyLineThicknesses      = (/2.,2.,2.,2./)     ; line thickness
  res@xyLineColors           = (/"foreground","green","blue","red"/)
  res@lgLabelAngleF          = 280.                ; angle of legend label
  res@xyExplicitLegendLabels = (/"u1","v1","u2","v2"/)

  plot=gsn_csm_xy(wks,lat,data,res)

end
