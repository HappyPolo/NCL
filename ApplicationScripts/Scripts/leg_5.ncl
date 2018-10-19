;*************************************************
; NCL Graphics: leg_5.ncl
;
; Concepts illustrated:
;   - Drawing a custom legend outside an XY plot
;   - Manually creating a legend
;   - Changing the line colors of lines inside a legend
;   - Changing the dash patterns of lines inside a legend
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

  data_1 = new( (/2,nlat/),float)
  data_1(0,:)=uz1
  data_1(1,:)=vz1

  data_2 = new( (/2,nlat/),float)
  data_2(0,:)=uz2
  data_2(1,:)=vz2
;************************************************
; create plot
;************************************************
  wks = gsn_open_wks("png","leg")                  ; send graphics to PNG file
  plot = new(2,graphic) 

  res                        = True
  res@xyMarkLineModes        = (/"Lines"/)         ; line style
  res@xyLineThicknesses      = (/2.,2.,2.,2./)     ; line thickness

  res@gsnDraw                = False
  res@gsnFrame               = False

  res@xyLineColors           = (/"foreground","green"/) ; choose line colors
  plot(0) = gsn_csm_xy(wks,lat,data_1,res)

  res@xyLineColors           = (/"blue","red"/)         ; change line colors
  plot(1) = gsn_csm_xy(wks,lat,data_2,res)
;************************************************
; panel resources and plot
;************************************************
  pnlres                = True
  pnlres@gsnFrame       = False
  pnlres@gsnPanelBottom = 0.18  ; Leave room for legend at the bottom.
  pnlres@txString       = "Example of a Common Legend"
  gsn_panel(wks,plot,(/2,1/),pnlres)
;************************************************
; create common legend

; note a legend has two labels. one is in the center of the
; line (LineLabel), and the other is at the end (LegendLabel). 
; this example uses the former, which is why several of the
; resources are different from the other legend examples.
;************************************************
  legend = create "Legend" legendClass wks 
    "vpXF"                     : 0.26                    ; orientation on page
    "vpYF"                     : 0.17
    "vpWidthF"                 : 0.5                     ; width
    "vpHeightF"                : 0.1                     ; height
    "lgPerimOn"                : False                   ; no perimeter
    "lgItemCount"              : 4                       ; how many
    "lgLineLabelStrings"       : (/"u1","v1","u2","v2"/) ; labels
    "lgLabelsOn"               : False                   ; no default lables
    "lgLineLabelFontHeightF"   : 0.015                   ; font height
    "lgDashIndexes"            : (/0,1,0,1/)             ; line paters
    "lgLineColors"             : (/"foreground","green","blue","red"/)
    "lgMonoLineLabelFontColor" : True                    ; one label color
  end create

  draw(legend)
  frame(wks)
end
