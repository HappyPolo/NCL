;********************************************************
; annotate_3.ncl
;
; Concepts illustrated:
;   - Adding a map to a contour plot as an annotation
;   - Attaching polylines to a contour plot
;   - Using "getvalues" to retrieve the size of a plot
;   - Adding text to a plot
;   - Generating dummy data using "generate_2d_array"
;   - Drawing a map using the high resolution map outlines
;   - Drawing a map using the medium resolution map outlines
;   - Creating a greyscale color map
;   - Changing the angle of text strings
;
;********************************************************
;
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"   
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"   

;
; Add a lat/lon box given a center lat/lon and width of the box.
;
function add_box(wks,map,center_lat,center_lon,degrees)
begin
  lat_start = center_lat - degrees/2.
  lon_start = center_lon - degrees/2.
  lat_end   = center_lat + degrees/2.
  lon_end   = center_lon + degrees/2.

  lat_box = (/lat_start,lat_start,lat_end,lat_end,lat_end,lat_start/)
  lon_box = (/lon_start,lon_end,lon_end,lon_start,lon_start,lon_start/)

  lnres                  = True
  lnres@gsLineColor      = "red"
  lnres@gsLineThicknessF = 3.0

; Attach box to map plot.
  ii = gsn_add_polyline(wks,map,lon_box,lat_box,lnres)  

  return(ii)     ; Need to keep this id alive for whole duration of program
end

begin
  min_lat =  2.0
  max_lat = 14.5
  min_lon =  8.0
  max_lon = 16.25
  nlat    = 180      ; Number of lat points in dummy data
  nlon    =  90      ; Number of lon points in dummy data

; Create some dummy data.
  lat         = fspan(min_lat,max_lat,nlat)
  lon         = fspan(min_lon,max_lon,nlon)
  lat@units   = "degrees_north"
  lon@units   = "degrees_east"

  dummy_data = generate_2d_array(10, 10, 0., 4100, 0, (/nlat,nlon/))

; Set up coordinate arrays so we can overlay on map.
  dummy_data!0   = "lat"
  dummy_data!1   = "lon"
  dummy_data&lat = lat
  dummy_data&lon = lon

  wks  = gsn_open_wks("png","annotate")     ; send graphics to PNG file

;---Create a grayscale RGB color map, using 17 shades of gray.
  ngray = 17
  gray_scales = conform_dims((/ngray,3/),fspan(1.0,0.35,ngray),0)

;---Set some resources for the base map/contour plot.
  res                       = True

; Generic stuff. 
  res@gsnMaximize       = True
  res@gsnAddCyclic      = False   ; Don't add cyclic point in longitude.
  res@gsnFrame          = False
  res@gsnDraw           = False

; Map stuff
;
; Note: in order to use the high-resolution coastal database
; (mpDataBaseVersion = "HighRes"), you must download and install RANGS
; (Regionally Accessible Nested Global Shorelines), the multi-resolution
; coastline database, developed by Rainer Feistel from Wessel and
; Smith's GSHHS (Global Self-consistent Hierarchical High-resolution
; Shoreline) database. For more information, visit:
;
;    http://www.ncl.ucar.edu/Document/Graphics/rangs.shtml
;
; If you don't have this database, or don't want to install it, 
; change this resource value to "MediumRes".
;
  res@mpDataBaseVersion ="HighRes"
  res@mpOutlineOn       = True

  res@mpMinLatF         = min_lat
  res@mpMaxLatF         = max_lat
  res@mpMinLonF         = min_lon
  res@mpMaxLonF         = max_lon

  res@mpLandFillColor         = "White"
  res@mpOceanFillColor        = "Gray25"
  res@mpInlandWaterFillColor  = "Gray25"

; Contour stuff
  res@cnFillOn                = True
  res@cnFillPalette           = gray_scales
  res@cnLinesOn               = False
  res@cnLevelSpacingF         = 250.
  res@cnFillMode              = "CellFill"

; Labelbar stuff
  res@lbOrientation           = "Vertical"

; Tickmark stuff
  res@pmTickMarkDisplayMode = "Always"
  res@tmXBLabelFontHeightF = 0.01

  map1 = gsn_csm_contour_map(wks,dummy_data,res)

; Add some boxes.
  lat_centers = (/4,3.5,10/)
  lon_centers = (/9.5,13.5,14/)
  nboxes = dimsizes(lat_centers)
  boxes = new(nboxes,graphic)
  do i=0,nboxes-1
    boxes(i) = add_box(wks,map1,lat_centers(i),lon_centers(i),2)
  end do

; Set up second, smaller map
  mpres                   = True

  mpres@gsnFrame          = False
  mpres@gsnDraw           = False

; Tickmark stuff
  mpres@pmTickMarkDisplayMode = "Always"
  mpres@tmXBLabelFontHeightF = 0.01

; Map stuff
  mpres@mpDataBaseVersion  ="MediumRes"
  mpres@mpOutlineOn       = True
  mpres@mpMinLatF         = -35.0
  mpres@mpMaxLatF         =  35.0
  mpres@mpMinLonF         = -20.0
  mpres@mpMaxLonF         =  50.0
 
  mpres@mpLandFillColor         = "White"
  mpres@mpOceanFillColor        = "Gray75"
  mpres@mpInlandWaterFillColor  = "Gray75"

; Width/height
  mpres@vpHeightF         = 0.2    ; Make this second map smaller.
  mpres@vpWidthF          = 0.2

  map2 = gsn_csm_map_ce(wks,mpres)

; Add text string to small map.
  txres               = True
  txres@txFontHeightF = 0.01
  txres@txAngleF      = -45.     ; Rotate text 45 degrees
  text_anno = gsn_add_text(wks,map2,"Atlantic Ocean",-5,-15,txres)

; Set up some resources to indicate where this text string will be
; attached to small map.
  amres                  = True
  amres@amParallelPosF   = -0.4   ; -0.5 is the left edge of the plot.
  amres@amOrthogonalPosF = -0.45   ; -0.5 is the top edge of the plot.
  amres@amJust           = "TopLeft"

  map_anno = gsn_add_annotation(map1, map2, amres)  ; Attach map to map.

  draw(map1)    ; This will draw map1 and map2
  frame(wks)
end
