;----------------------------------------------------------------------
; scatter_10.ncl
;
; Concepts illustrated:
;   - Drawing a scatter plot over a map using the "overlay" procedure
;   - Using gsn_csm_blank_plot to create a scatter plot with filled polygons
;   - Generating dummy data using "random_uniform"
;   - Changing the draw order of filled polygons
;----------------------------------------------------------------------
;
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"

begin
;
; Generate 20 random integers from 1 to 10, and
; unique locations for each.
;
  nx   = 20     ; Make twice as long as x so
  ny   = 10     ; we get square boxes in map.
  tmin = 1
  tmax = 10
  t    = toint(random_uniform(tmin,tmax,(/ny,nx/)))

;---Start the graphics
  wks   = gsn_open_wks ("png","scatter")         ; send graphics to PNG file

;---Resources for blank plot
  bres                = True                     ; plot mods desired

  bres@gsnDraw        = False
  bres@gsnFrame       = False

  bres@trXMinF        = 0       ; polygons will go from 1,nx in x
  bres@trXMaxF        = nx+1
  bres@trYMinF        = 0       ; polygons will go from 1,ny in y
  bres@trYMaxF        = ny+1

  bres@tfDoNDCOverlay = True       ; Important for the overlay.

;---Turn off all tickmarks
  bres@tmXBOn         = False
  bres@tmXTOn         = False
  bres@tmYROn         = False
  bres@tmYLOn         = False

  plot = gsn_csm_blank_plot (wks,bres)        ; Create blank plot

;---Colors for each polygon
  colors = (/"tan","orange","green","purple","red","yellow","limegreen",\
             "blue","skyblue","brown"/)
  
;---Resources for filled squares
  gnres                 = True
  gnres@tfPolyDrawOrder = "PreDraw"    ; Draw before map outlines
;
; Loop through the integers tmin and tmax, and add
; a set of filled squares for each grouping.
;
  dum = new(nx*ny,graphic)      ; Dummy array to hold polygon id's.
  do j=1,ny
    do i=1,nx
      box_value = t(j-1,i-1)
      if(box_value.lt.3.or.box_value.gt.7) then
        continue
      end if  
      gnres@gsFillColor = colors(box_value)
      xbox = (/i-0.5,i+0.5,i+0.5,i-0.5,i-0.5/)
      ybox = (/j-0.5,j-0.5,j+0.5,j+0.5,j-0.5/)
      igon = ((j-1)*nx)+(i-1)
      dum(igon) = gsn_add_polygon(wks,plot,xbox,ybox,gnres)    ; Attach the box.
    end do
  end do

;---Resources for map plot
  mpres              = True

  mpres@gsnMaximize  = True
  mpres@gsnDraw      = False
  mpres@gsnFrame     = False

  mpres@mpOutlineOn  = True
  mpres@mpFillOn     = False

;  mpres@mpGeophysicalLineThicknessF = 2.0    ; Default is 1.0

  mpres@tiMainString = "Dummy markers over a map"
  map = gsn_csm_map(wks,mpres)        ; Create map

;
; Overlay scatter plot on map and draw.
; 
; Because we set "tfDoNDCOverlay" to True for the blank plot, this means
; that NCL doesn't care if the map and the blank plot are not in the
; same data space. It will simply line up the four corners of the blank
; plot with the four corners of the map.
; 
; *It is important that the axes of the blank plot are created such that
; they correspond with the four corners of your map plot.*  In this case,
; The following x,y values of the blank plot correspond with the following
; locations on the map:
;     x = 0    --> lon = -180
;     x = nx+1 --> lon =  180
;     y = 0    --> lon =  -90
;     y = ny+1 --> lon =   90
;
; The actual filled squares are centered about 
; locations y,x=(1,1), y,x(1,2), .. y,x(ny,nx).
;
  overlay(map,plot)

  draw(map)       ; This draws the filled polygons and the map.
  frame(wks)
end
