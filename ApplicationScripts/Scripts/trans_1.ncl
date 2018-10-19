;************************************
; trans_1.ncl
;************************************
;
; Concepts illustrated:
;   - Calculating and plotting a transect
;   - Using gc_latlon to calculate a great circle path
;   - Using linint2_points to interpolate rectilinear grid values to set of lat/lon points
;   - Attaching polylines to a map plot
;   - Explicitly setting tickmarks and labels on the bottom X axis
;************************************
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
;************************************
begin
  in = addfile("h_avg_Y0191_D000.00.nc","r")
  t  = in->T(0,:,:,:)
;************************************
; calculate great circle along transect
;************************************
  leftlat  =  -60.0
  rightlat =  -30.0

  leftlon  =  -60.0
  rightlon =   20.0

  npts     =   100                    ; number of points in resulting transect

  dist     = gc_latlon(leftlat,leftlon,rightlat,rightlon,npts,2)
  points   = ispan(0,npts-1,1)*1.0 
;********************************
; interpolate data to great circle
;********************************
  trans   = linint2_points(t&lon_t,t&lat_t,t,True,dist@gclon,dist@gclat,2)
  copy_VarAtts(t,trans)          ; copy attributes

  trans!0      = "z_t"           ; create named dimension and assign
  trans&z_t    = t&z_t           ; coordinate variable for 0th dimension only
;********************************
; create plot
;********************************
  wks = gsn_open_wks("png","trans")       ; send graphics to PNG file

  res                     = True          ; plot mods desired
  res@tmXBMode            = "Explicit"    ; explicitly label x-axis
  res@tmXBValues          = (/points(0),points(npts-1)/) ; points to label
; label values
  res@tmXBLabels          = (/leftlat +", "+leftlon,rightlat+", "+rightlon/)

  res@cnFillOn            = True         ; turn on color
  res@cnFillPalette       = "BlAqGrYeOrReVi200"  ; set color map
  res@cnLinesOn           = False        ; turn off countour lines
  res@lbOrientation       = "vertical"   ; vertical label bar
  res@pmLabelBarOrthogonalPosF = -0.05        ; move label bar closer to plot
 
  res@tiMainString        = "Transect"   ; add title
  res@tiXAxisString       = "lat/lon along transect"
  res@trYReverse          = True         ; reverse y axis
;  res@trXReverse          = True         ; reverse x axis (neg longitudes)
  res@cnLevelSpacingF     = 1.0          ; set contour spacing
  
  plot = gsn_csm_contour(wks,trans,res)  ; create plot
;********************************
; show transect on a map
;********************************
  mres              = True                ; plot mods desired
  mres@gsnFrame     = False               ; don't turn page yet
  mres@gsnDraw      = False               ; don't draw yet
  mres@tiMainString = "Transect Location" ; title
  map = gsn_csm_map(wks,mres)         ; create map

; add polyline to map
  pres                  = True           ; polyline mods desired
  pres@gsLineColor      = "red"          ; color of lines
  pres@gsLineThicknessF = 2.0            ; line thickness   
  id = gsn_add_polyline(wks,map,(/leftlon,rightlon/),(/leftlat,rightlat/),pres)
  draw(map)    ; draws map and polyline
  frame(wks)
end
