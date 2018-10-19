;*************************************************
; NCL Graphics: polar_5.ncl
;************************************************
;
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl" 
;************************************************
begin
;************************************************
; read in netCDF file and access data
;************************************************
  a = addfile("$NCARG_ROOT/lib/ncarg/data/cdf/uv300.nc","r")
  u = a->U(1,:,:)                                 ; read July zonal winds
;************************************************
; create polygon (remember the earth is a sphere)
;************************************************
  xpt = new(20,float)
  ypt = new(20,float)

  xpt(0:9)     = fspan(120.,240,10)  ; lon around edge
  xpt(10:14)   = 240                 ; up 240
  xpt(15:19)   = 120                 ; down 120

  ypt(0:9)     = 40                  ; lat around edge
  ypt(10:14)   = fspan(40.,90.,5)    ; lat up to pole
  ypt(15:19)   = fspan(90.,40.,5)    ; lat down from pole
;************************************************
; create plots
;************************************************
  wks = gsn_open_wks("png","polar")              ; send graphics to PNG file     
  plot=new(2,graphic)                            ; create graphical array

  res            = True                          ; plot mods desired
  res@gsnPolar   = "NH"                          ; specify the hemisphere
  res@mpMinLatF  = 40                            ; minimum latitude
  res@gsnDraw    = False                         ; don't draw 
  res@gsnFrame   = False			 ; don't advance frame

  plot(0) = gsn_csm_contour_map_polar(wks,u,res)        ; create the plot
  dum1    =  gsn_add_polygon(wks,plot(0),xpt,ypt,False) ; add polygon
;************************************************
; create second plot
;************************************************
  res@mpGridAndLimbDrawOrder = "PreDraw"
  plot(1) = gsn_csm_contour_map_polar(wks,u,res)    ; create the plot

  polyres            = True                         ; polygon mods desired
  polyres@gsFillColor= "white"                      ; change fill color

  dum2 = gsn_add_polygon(wks,plot(1),xpt,ypt,polyres) ; add polygon
;************************************************
; create panel
;************************************************
  gsn_panel(wks,plot,(/2,1/),False)
end

