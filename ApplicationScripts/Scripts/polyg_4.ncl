;*************************************************
; polyg_4.ncl
;
; Concepts illustrated:
;   - Drawing a cylindrical equidistant map
;   - Zooming in on a particular area on a cylindrical equidistant map
;   - Attaching an outlined box to a map plot
;   - Attaching filled polygons to a map plot
;   - Filling in polygons with a shaded pattern
;   - Changing the color and thickness of polylines
;   - Changing the color of a filled polygon
;   - Labeling the lines in a polyline
;   - Changing the density of a fill pattern
;   - Adding text to a plot
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
  u = a->U(1,:,:)                                ; read July zonal winds
;************************************************
; create plot
;************************************************
  wks = gsn_open_wks("png","polyg")                 ; send graphics to PNG file

  res           = True                              ; plot mods desired
  res@gsnDraw   = False                             ; don't draw yet
  res@gsnFrame  = False                             ; don't advance yet

  res@mpMinLatF = -20                               ; zoom in on a subregion
  res@mpMaxLatF = 40
  res@mpMinLonF = -130
  res@mpMaxLonF = 0.

  plot = gsn_csm_contour_map_ce(wks,u,res)          ; create the map plot
;************************************************
; create points for box
;************************************************
 ypts = (/ 30.0,  30.0,  0.0,   0.0, 30.0/)
 xpts = (/-90.0, -45.0,-45.0, -90.0,-90.0/)
;************************************************
; add the box
;************************************************
  resp                  = True                      ; polyline mods desired
  resp@gsLineColor      = "red"                     ; color of lines
  resp@gsLineThicknessF = 2.0                       ; thickness of lines
  resp@gsLineLabelString= "test"                    ; adds a line label string

; create array of dummy graphic variables. This is required, b/c each line
; must be associated with a unique dummy variable.

  dum = new(4,graphic)  

; draw each line separately. Each line must contain two points.
  do i = 0 , 3
    dum(i)=gsn_add_polyline(wks,plot,xpts(i:i+1),ypts(i:i+1),resp)      
  end do 

;************************************************
; label the box with additional text
;************************************************
  tres       =  True
  tres@txFontHeightF = 0.02
  gsn_text(wks,plot,"sample",-60.0,15.0,tres)

  draw(plot)
  frame(wks)

; now fill in some polygons and add to plot.

  resp@gsFillIndex = 17
  resp@gsFillColor = "purple"
  dum2 = gsn_add_polygon(wks,plot,xpts,ypts,resp)      

  xtri = (/ -125, -115, -120 /)
  ytri = (/ -15,   -10,    5 /)

  resp@gsFillIndex  = 5
  resp@gsFillScaleF = 0.5
  resp@gsFillColor  = "brown"
  dum3 = gsn_add_polygon(wks,plot,xtri,ytri,resp)      

  resp@gsFillScaleF = 0.75
  resp@gsFillColor  = "blue"
  dum4 = gsn_add_polygon(wks,plot,xtri+10,ytri,resp)      

  resp@gsFillScaleF = 1.0          ; Default
  resp@gsFillColor  = "forestgreen"
  dum5 = gsn_add_polygon(wks,plot,xtri+20,ytri,resp)      

  draw(plot)
  frame(wks)

end
