;*************************************************
; scatter_6.ncl
;
; Concepts illustrated:
;   - Drawing a scatter plot with markers of different colors and sizes
;   - Drawing outlined and filled markers on a polar map plot
;   - Generating dummy data using "random_uniform"
;   - Changing the marker colors on a polar map plot
;   - Changing the marker sizes on a polar map plot
;   - Turning off map tickmarks
;   - Turning off map fill
;   - Turning off map outlines
;
;*************************************************
;
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"

begin
;---Create some dummy lat,lon and data values.
  npts   = 100
  lat    = random_uniform(   5, 90,npts)
  lon    = random_uniform(-180,180,npts)
  dvals  = random_uniform(0,100,npts)

;---Generate some levels to group the data values by.
  levels  = ispan(0,100,10)
  nlevels = dimsizes(levels)

;---For each range, we want a different size and color.
  sizes  = ispan(25,75,5)/1000.    ; 0.0025 to 0.0075
  colors = (/"limegreen","orange","green","red","yellow","purple","blue",\
             "red","brown","red2","skyblue"/)

;---Start the graphics
  wks = gsn_open_wks("png","scatter")     ; send graphics to PNG file

;---Set some resources for a polar map.
  res              = True

  res@gsnMaximize  = True                 ; Maximize plot in frame
  res@gsnDraw      = False                ; Don't draw plot 
  res@gsnFrame     = False                ; Don't advance frame (page)

  res@gsnPolar     = "NH"                 ; North hemisphere

  res@mpFillOn     = False                ; Turn off map fill
  res@mpOutlineOn  = False                ; Turn off map outlines

;---Create a polar map with the given resources.
  map = gsn_csm_map_polar(wks,res)

;---Create a resource list for the markers.
  mkres = True

;---Arrays for attaching two sets of markers
  dum_fill   = new(nlevels-1,graphic)
  dum_hollow = new(nlevels-1,graphic)

  mkres@gsMarkerThicknessF = 2.0      ; Twice as thick
;
; For each range, gather the data that falls in this range
; and draw the set of markers at those lat/lon locations.
;
  do i=0,nlevels-2
    ii = ind(levels(i).le.dvals.and.dvals.lt.levels(i+1))
    
    mkres@gsMarkerIndex = 16          ; Filled dots
    mkres@gsMarkerSizeF = sizes(i)
    mkres@gsMarkerColor = colors(i)

    dum_fill(i) = gsn_add_polymarker(wks,map,lon(ii),lat(ii),mkres)

;---Draw the markers again, only this time hollow, to get an outline.
    mkres@gsMarkerIndex = 4           ; Hollow dots
    mkres@gsMarkerColor = "black"
    dum_hollow(i) = gsn_add_polymarker(wks,map,lon(ii),lat(ii),mkres)
    delete(ii)
  end do

;---Drawing the map plot will draw all the attached markers too.
  draw(map)
  frame(wks)
end

