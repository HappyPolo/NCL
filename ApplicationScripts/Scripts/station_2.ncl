;----------------------------------------------------------------------
; station_2.ncl
;----------------------------------------------------------------------
;
; Concepts illustrated:
;   - Drawing markers on a map indicating the locations of station data
;   - Generating dummy data using "random_uniform"
;   - Drawing markers of different sizes and colors on a map
;   - Drawing a custom legend outside of a map plot
;   - Attaching a custom labelbar to a plot
;
; This example creates some dummy station data, and then plots each
; value by coloring and sizing it depending on which range of values 
; it falls in.
;
; It creates two plots: one with a legend with markers and text,
; and one with a labelbar.
;----------------------------------------------------------------------
;
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"

;----------------------------------------------------------------------
; This procedure draws a legend with markers and text at the bottom
; of the screen
;----------------------------------------------------------------------
procedure draw_legend(wks,lat[*][*]:numeric,lon[*][*]:numeric,\
                      arr[*]:numeric,colors)
local gsres, txres, xleg, xtxt, yleg, ytxt, i, labels, nitems
begin
  narr   = dimsizes(arr)
  nmarkers = narr+1
  labels = new(nmarkers,string)

;---Generate the labels for each marker.
  do i = 0, nmarkers-1
    if (i.eq.0) then
      labels(i) = "x < " + arr(0)
    end if
    if (i.eq.nmarkers-1) then
      labels(i) = "x >= " + max(arr)
    end if
    if (i.gt.0.and.i.lt.nmarkers-1) then       
      labels(i) = arr(i-1) + " <= x < " + arr(i)
    end if
  end do
;
;  Create logical variables to hold the marker and text resources.
;  These markers are different than the XY markers, because they are not
;  associated with an XY plot. You can put these markers on any plot.
;
  gsres               = True
  gsres@gsMarkerIndex = 16          ; Use filled dots for markers.

  txres               = True
  txres@txFontHeightF = 0.015

;
; Loop through each grouping of markers, and draw them one set at
; a time, assigning the proper color and size with gsn_marker.
;
; At the same time, draw a legend showing the meaning of the markers.
;

  xleg = (/0.07,0.07,0.32,0.32,0.57,0.57,0.82,0.82/)   ; Location of
  xtxt = (/0.16,0.16,0.41,0.41,0.66,0.66,0.91,0.91/)   ; legend markers
  yleg = (/0.22,0.17,0.22,0.17,0.22,0.17,0.22,0.17/)   ; and text
  ytxt = (/0.22,0.17,0.22,0.17,0.22,0.17,0.22,0.17/)   ; strings.

  do i = 0, dimsizes(lat(:,0))-1
    if (.not.ismissing(lat(i,0)))
      gsres@gsMarkerColor      = colors(i)
      gsres@gsMarkerThicknessF = 0.7*(i+1)
;---Add marker and text for the legend.
      gsn_polymarker_ndc(wks,          xleg(i),yleg(i),gsres)
      gsn_text_ndc      (wks,labels(i),xtxt(i),ytxt(i),txres)
    end if
  end do

end

;----------------------------------------------------------------------
; This function attaches a labelbar to the given plot.
;----------------------------------------------------------------------
function attach_labelbar(wks,map,arr[*]:numeric,colors[*])
local lbres, vph, vpw, nboxes
begin
  getvalues map
    "vpHeightF" : vph
    "vpWidthF"  : vpw
  end getvalues

  nboxes = dimsizes(colors)
   
  lbres                    = True          ; labelbar only resources
  lbres@lbAutoManage       = False          ; Necessary to control sizes
  lbres@lbFillColors       = colors
  lbres@vpWidthF           = 0.7 * vpw     ; labelbar width
  lbres@vpHeightF          = 0.2 * vph     ; labelbar height
  lbres@lbMonoFillPattern  = True          ; Solid fill pattern
  lbres@lbLabelFontHeightF = 0.01          ; font height. default is small
  lbres@lbOrientation      = "horizontal"
  lbres@lbPerimOn          = False
  lbres@lbLabelAlignment   = "InteriorEdges"
  lbid = gsn_create_labelbar(wks,nboxes,""+toint(arr),lbres)

  amres                  = True
  amres@amJust           = "TopCenter"
  amres@amParallelPosF   =  0.0    ; Center
  amres@amOrthogonalPosF =  0.6    ; Bottom
  annoid = gsn_add_annotation(map,lbid,amres)
  return(annoid)
end

;----------------------------------------------------------------------
; Main code
;----------------------------------------------------------------------
begin
;---Set some needed arrays
  arr = (/0.,5.,10.,15.,20.,23.,26./)    ; bin settings (bin0 = < 0., 
                                         ; bin1 = 0.:4.999, etc.)
  narr = dimsizes(arr)
  labels = new(narr+1,string)   ; Labels for legend.

  npts = 100                                    ; Number of points.
  lat  = random_uniform( 25., 50.,npts)         ; Create some dummy latitude
  lon  = random_uniform(235.,290.,npts)         ; and longitude data that
                                                ; will contain the position of
                                                ; our markers.

  R   = random_uniform(-1.2,35.,npts)   ; This is dummy data for determining
                                        ; how to color the markers.

;
; Create X and Y arrays to hold the points for each range and initialize
; them to missing values.  We want to use num_distinct_markers
; different colors, so we need num_distinct_markers sets of X and
; Y points.
;
  num_distinct_markers = dimsizes(arr)+1        ; number of distinct markers
  lat_new = new((/num_distinct_markers,dimsizes(R)/),float,-999)
  lon_new = new((/num_distinct_markers,dimsizes(R)/),float,-999)

;---Group the points according to which range they fall in.
  do i = 0, num_distinct_markers-1
    if (i.eq.0) then
      indexes = ind(R.lt.arr(0))
    end if
    if (i.eq.num_distinct_markers-1) then
      indexes = ind(R.ge.max(arr))
    end if
    if (i.gt.0.and.i.lt.num_distinct_markers-1) then       
      indexes = ind(R.ge.arr(i-1).and.R.lt.arr(i))
    end if
;
; Now that we have the set of indexes whose values fall within 
; the given range, take the corresponding lat/lon values and store
; them, so later we can color this set of markers with the appropriate
; color.
;
    if (.not.any(ismissing(indexes))) then 
      npts_range = dimsizes(indexes)   ; # of points in this range.
      lat_new(i,0:npts_range-1) = lat(indexes)
      lon_new(i,0:npts_range-1) = lon(indexes)
    end if
    delete(indexes)            ; Necessary b/c "indexes" may be a different
                               ; size next time.
  end do

;----------------------------------------------------------------------
; Begin plotting section.
;----------------------------------------------------------------------
  wks = gsn_open_wks("png","station")   ; send graphics to PNG file

;---Set up some map resources.
  mpres              = True
  mpres@gsnMaximize  = True             ; Maximize plot in frame.
  mpres@gsnFrame     = False            ; Don't advance the frame
  mpres@gsnDraw      = False            ; Don't advance the frame

;---Zoom in on United States.
  mpres@mpMinLatF    = 25.
  mpres@mpMaxLatF    = 50.
  mpres@mpMinLonF    = 235.
  mpres@mpMaxLonF    = 290.
  mpres@mpCenterLonF = 262.5

  mpres@mpFillColors = (/"transparent","transparent","gray","transparent"/)

  mpres@tiMainString = "Dummy station data colored according to range of values"
  map = gsn_csm_map(wks,mpres)

  gsres               = True
  gsres@gsMarkerIndex = 16          ; Use filled dots for markers.

;---Get nice spacing through color map for marker colors
  getvalues wks
    "wkColorMapLen" : clen     ; number of colors in color map
  end getvalues

  nstep = (clen-2)/narr
  colors = ispan(2,clen-1,nstep)

;---Loop through each "bin" and attach the markers to the map.
  do i = 0, num_distinct_markers-1
    if (.not.ismissing(lat_new(i,0)))
      gsres@gsMarkerColor      = colors(i)
      dumstr = unique_string("marker")
      map@$dumstr$ = gsn_add_polymarker(wks,map,lon_new(i,:),lat_new(i,:),gsres)
    end if
  end do

;----------------------------------------------------------------------
; First version of this plot has a legend at the bottom
;----------------------------------------------------------------------
  draw(map)                  ; Drawing the map will draw the markers
  draw_legend(wks,lat_new,lon_new,arr,colors) ; Draw a legend at the bottom

  frame(wks)    ; Advance the frame 

;----------------------------------------------------------------------
; Second version of this plot has a labelbar added.
;----------------------------------------------------------------------
  lbid = attach_labelbar(wks,map,arr,colors)   ; Attach a labelbar

  draw(map)     ; Drawing the map will draw everything
  frame(wks)    ; Advance the frame.
end     
