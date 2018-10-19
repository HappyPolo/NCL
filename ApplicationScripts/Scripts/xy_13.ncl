;*************************************************
; xy_13.ncl
;
; Concepts illustrated:
;   - Drawing error bars on an XY plot
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
  u = a->V(0,:,30)
;************************************************
; create plot
;************************************************
  wks = gsn_open_wks("png","xy")                         ; send graphics to PNG file

  res                        = True                      ; plot mods desired
  res@tiYAxisString          = u@long_name + " "+u@units ; add units title 
  res@tiMainString           = "Example of error bars"   ; title
  res@gsnFrame               = False                     ; don't draw yet
  res@gsnDraw                = False                     ; don't advance frame

  plot = gsn_csm_y(wks,u,res)                            ; draw y plot
;************************************************
; add error bars
;************************************************  
  polyres                   = True                       ; marker resources
  polyres@gsMarkerIndex     = 1                          ; index for circle
  polyres@gsMarkerSizeF     = .02                        ; size 
  
; gsn_add* templates are functions that we set to dummy values. Since
; we are going to draw numerous error bars, we create two arrays to
; hold the dummy values.
  error_bar = new(dimsizes(u),graphic)
  centers   = new(dimsizes(u),graphic)

; loop through the points  
  do t=0,dimsizes(u)-1
; add a polymarker as the center of the error bar located at each data
; point
    centers(t)   = gsn_add_polymarker(wks,plot,t,u(t),polyres)
; the error bar is draw in two segements, above and below the true
; value of u(t). I made up these value. You would change this to 
; true error.      
    error_bar(t) = gsn_add_polyline(wks,plot,(/t,t/),(/u(t)+1.5,u(t)-1.0/),\
    polyres)
  end do
  draw(plot)
  frame(wks)
end
 
 
 
