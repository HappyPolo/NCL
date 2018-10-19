;*************************************************
; panel_1.ncl
;
; Concepts illustrated:
;   - Paneling three plots vertically on a page
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
  u = a->U(1,:,:)                                ; read July zonal winds
  v = a->V(1,:,:)
;************************************************
; create plots
;************************************************
  wks = gsn_open_wks("png","panel")              ; open a png file
  plot = new(3,graphic)                          ; create a plot array
  
  res          = True
  res@gsnDraw  = False                          ; don't draw
  res@gsnFrame = False                          ; don't advance frame
  res@cnInfoLabelOn = False                     ; turn off cn info label

  plot(0) = gsn_csm_contour_map(wks,u,res) 
  plot(1) = gsn_csm_contour_map(wks,v,res) 
 
  res@gsnLeftString = "Vector Wind"

  delete(res@cnInfoLabelOn)    ; To avoid a warning from vector plot routine

  plot(2) = gsn_csm_vector_map(wks,u(::4,::4),v(::4,::4),res)

;************************************************
; create panel
;************************************************
  gsn_panel(wks,plot,(/3,1/),False)             ; now draw as one plot
end
