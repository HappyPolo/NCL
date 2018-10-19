;*************************************************
; xy_12.ncl
;
; Concepts illustrated:
;   - Emphasizing part of a curve in an XY plot
;   - Drawing longitude labels on the X axis
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
  u = a->U(0,:,:)
;************************************************
; part of method 1: split time series into two parts. 
;************************************************
  u_split = new((/2,64,128/),typeof(u),-999.)
  u_split(0,5:20,:)= u(5:20,:)                  ; part to be highlighted
  
  u_split(1,0:5,:) = u(0:5,:)                   ; stuff before and after
  u_split(1,20:,:) = u(20:,:)
;************************************************
; part of method 2: define a polygon centered the width of 2 sigma
;************************************************
  length = 20
  xp     = new( (/2*length/), float)
  yp     = new( (/2*length/), float)
  
  k = 5
  do i=0,length-1
    yp(i) = u(k,{60}) + 2.
    xp(i) = u&lat(k)
    xp(2*length-1-i) = u&lat(k)
    yp(2*length-1-i) = u(k,{60}) - 2.
    k = k + 1
 end do 
;************************************************
; plot parameters
;************************************************
  wks = gsn_open_wks("png","xy")                          ; send graphics to PNG file   
  
  res                        = True                       ; plot mods desired
  res@tiYAxisString          = u@long_name + " "+u@units  ; add units to title
  res@tfPolyDrawOrder        = "Predraw"                  ; put line on top
  res@tiMainString           = "Highlight Part of a Line" ; title
;************************************************
; method 1: highlight with line color
;************************************************
   res@xyLineColors      = (/"red", "foreground"/)        ; line colors
   res@xyLineThicknesses = (/3.,1./)                      ; line thicknesses 
   res@xyDashPatterns    = (/0.,0./)                      ; keep all solid
   
   plot = gsn_csm_xy(wks,u&lat,u_split(:,:,6),res)        ; create plot   
;************************************************
; method 1: line highlighted
;************************************************
   res@gsnFrame               = False                     ; don't draw yet
   res@gsnDraw                = False                     ; don't advance yet
   delete(res@xyLineThicknesses)                          ; don't want anymore
   delete(res@xyLineColors)                               ; ditto
   plot = gsn_csm_xy(wks,u&lat,u(:,{60}),res)             ; create plot
   
   gsres                   = True                         ; poly res
   gsres@gsFillColor       = "Salmon"                     ; color chosen
   dummy = gsn_add_polygon(wks,plot,xp,yp,gsres)          ; draw polygon
   draw(wks)
   frame(wks)
end
