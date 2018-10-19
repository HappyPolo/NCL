;*************************************************
; NCL Graphics: leg_3.ncl
;
; Concepts illustrated:
;   - Drawing a legend inside an XY plot
;   - Changing the width and height of a legend
;   - Changing the orientation of a legend
;   - Changing the default markers in an XY plot
;   - Adding labels to a curve in an XY plot
;   - Drawing XY plot curves with both lines and markers
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

  res                        = True
  res@pmLegendDisplayMode    = "Always"            ; turn on legend

  res@pmLegendSide           = "Top"               ; Change location of 
  res@pmLegendParallelPosF   = .45                 ; move units right
  res@pmLegendOrthogonalPosF = -0.4                ; move units down

  res@pmLegendWidthF         = 0.15                ; Change width and
  res@pmLegendHeightF        = 0.18                ; height of legend.
  res@lgLabelFontHeightF     = .03                 ; change font height
  res@lgOrientation          = "horizontal"
  res@lgPerimOn              = False               ; turn off box

  res@xyMarkLineModes        = (/"MarkLines","Lines"/) ; line style
  res@xyMarkers              = (/14,0/)                ; marker style
  res@xyMarkerColor          ="red"                    ; marker color

  res@xyExplicitLegendLabels = (/"U","V"/)
  plot=gsn_csm_xy(wks,lat,data,res)

end
