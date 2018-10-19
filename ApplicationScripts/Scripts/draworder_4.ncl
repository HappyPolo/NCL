;*************************************************
; draworder_4.ncl
;
; Concepts illustrated:
;   - Controlling the draw order of polygons, lines, and markers
;   - Attaching an outlined box to a map plot
;   - Attaching filled polygons to a map plot
;   - Filling in polygons with a shaded pattern
;   - Changing the color and thickness of polylines
;   - Changing the color of a filled polygon
;   - Changing the density of a fill pattern
;   - Creating a special "LogLin" object
;
;************************************************
;
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"  
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"  
;************************************************
begin
;
; Read in netCDF file and read in zonal wind
;
  a = addfile("$NCARG_ROOT/lib/ncarg/data/cdf/uv300.nc","r")
  u = a->U(1,:,:)                                ; read July zonal winds

;
; Start graphics
;
  wks = gsn_open_wks("png","draworder")             ; send graphics to PNG file

  res                 = True                        ; plot mods desired

  res@gsnMaximize     = True                        ; maximize size of plot

  res@gsnDraw         = False                       ; don't draw yet
  res@gsnFrame        = False                       ; don't advance yet

  res@mpMinLatF       =  -20                        ; zoom in on a subregion
  res@mpMaxLatF       =   40
  res@mpMinLonF       = -130
  res@mpMaxLonF       =    0
  res@mpFillDrawOrder = "PreDraw"                   ; Default is "PostDraw"
  res@cnLineDrawOrder = "PostDraw"                  ; Default is "Draw"

  plot = gsn_csm_contour_map_ce(wks,u,res)          ; Create the map plot

;
; Create points for a box.
;
 ypts = (/ 35.0,  35.0, 10.0,  10.0, 35.0/)
 xpts = (/-90.0, -45.0,-45.0, -90.0,-90.0/)

;
; Add a red box. It will be drawn in the "predraw" phase, and 
; should appear under the filled land areas.
;
; Note that the setting for "tfPolyDrawOrder" is going to apply
; to *every* primitive that you add to "plot". If you need to
; change this value for a different primitive, see the code
; below that adds the blue and green triangles.
;
  resp                  = True                      ; polyline mods desired
  resp@tfPolyDrawOrder  = "PreDraw"
  resp@gsLineColor      = "red"                     ; color of lines
  resp@gsLineThicknessF = 2.0                       ; thickness of lines

  dum1 = gsn_add_polyline(wks,plot,xpts,ypts,resp)      

; Put some stippling in the same box and add.

  resp@gsFillIndex = 17                             ; stipple
  resp@gsFillColor = "purple"
  dum2 = gsn_add_polygon(wks,plot,xpts,ypts,resp)      

; Add some filled triangles. Note that the first triangle
; is still in the "PreDraw" phase that we set earlier.
;
; To force the blue and green triangles to be drawn in 
; "Draw" and "PostDraw" phases, you have to:
;
;    1. Create a new object for each one.
;    2. Overlay that object on "plot".
;    3. Set "tfPolyDrawOrder" for each new object.
;    4. Add the primitive to the new object instead
;       of "plot".
;
; This all works like magic because this new object has 
; been overlaid on the map. Don't question it!
;
  xtri = (/ -85, -75, -80 /)
  ytri = (/ -19, -14,   1 /)

  resp@gsFillIndex = 0          ; solid fill
  resp@gsFillColor = "brown"
  dum3 = gsn_add_polygon(wks,plot,xtri,ytri,resp)      

;
; Create a dummy "LogLin" object and overlay this on the map. We
; can now draw primitives on this, and use a different value
; for "tfPolyDrawOrder".
;
  llid1 = create "ll" logLinPlotClass wks end create
  overlay(plot,llid1)

  resp@tfPolyDrawOrder = "Draw"             ; Draw during middle phase.
  resp@gsFillColor     = "blue"
  dum4 = gsn_add_polygon(wks,llid1,xtri+10,ytri,resp)      

  llid2 = create "ll" logLinPlotClass wks end create
  overlay(plot,llid2)

  resp@tfPolyDrawOrder = "PostDraw"         ; Draw during last phase.
  resp@gsFillColor     = "ForestGreen"
  dum5 = gsn_add_polygon(wks,llid2,xtri+20,ytri,resp)      

  draw(plot)
  frame(wks)

end
