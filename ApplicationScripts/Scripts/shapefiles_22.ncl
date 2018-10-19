;----------------------------------------------------------------------
; This script generates dummy data over the Caspian Sea, and then
; uses two different shapefiles to first throw away any values that
; are not strictly in the Caspian Sea area, then to throw away any
; values that are inside isles of the Caspian Sea.
;----------------------------------------------------------------------
load "./shapefile_utils.ncl"

;----------------------------------------------------------------------
; Function to generate some dummy data over the given lat/lon area.
;----------------------------------------------------------------------
function dummy_data(nlat,nlon,minlat,maxlat,minlon,maxlon)
local nlat, nlon, lat, lon
begin
  lat       = fspan(minlat,maxlat,nlat)
  lon       = fspan(minlon,maxlon,nlon)
  lat@units = "degrees_north"
  lon@units = "degrees_east"

  data     = generate_2d_array(10, 25, -20, 15, 0, (/nlat,nlon/))
  data!0   = "lat"
  data!1   = "lon"
  data&lat = lat
  data&lon = lon
  
  return(data)
end

;----------------------------------------------------------------------
; Main code.
;----------------------------------------------------------------------
begin
  ADD_MARKERS       = True      ; Whether to draw dots at lat/lon locations of data
  DRAW_ZOOMED_PLOTS = True      ; Whether to draw zoomed maps (to help you see the masking better)

;----------------------------------------------------------------------
; Generate some dummy data with lat/lon coordinates.
;----------------------------------------------------------------------
  CS_minlat = 36   ; Approximate area that covers the Caspian Sea
  CS_maxlat = 48
  CS_minlon = 45
  CS_maxlon = 55

  data = dummy_data(300,150,CS_minlat,CS_maxlat,CS_minlon,CS_maxlon)

  print("======================================================================")
  print("Original data") 
  printMinMax(data,0)
  print("# Valid values = " + num(.not.ismissing(data)))
  print("# Msg values   = " + num(ismissing(data)))

;---Name of shapefiles that contain areas of interest to mask or protect.
  dir                = "caspSea/"
  caspian_shape_name = "GSHHS_h_caspSea.shp"     ; contains single outline of Caspian Sea
  isles_shape_name   = "GSHHS_h_L1_mysect.shp"   ; contains several outlines if isles inside Caspian Sea


;----------------------------------------------------------------------
; Mask the dummy data with the single Caspian outline. Set attribute
; "keep" to True, to indicate you want to *keep* values inside the
; shapefile outline.
;----------------------------------------------------------------------
  print("======================================================================")
  print("Masking data against " + caspian_shape_name)
  opt = True
  opt@keep = True   ; Keep values inside this shape
  data_mask_casp = shapefile_mask_data(data,dir+caspian_shape_name,opt)
  printMinMax(data_mask_casp,0)

  print("# Valid values = " + num(.not.ismissing(data_mask_casp)))
  print("# Msg values   = " + num(ismissing(data_mask_casp)))

;----------------------------------------------------------------------
; Mask the previouly masked with the shapefile containing outlines
; of isles. This time, set "keep" to False to indicate you *don't* want
; to *keep* values inside the shapefile outlines.
;----------------------------------------------------------------------
  print("======================================================================")
  print("Masking data against " + isles_shape_name)

  opt@keep = False
  data_mask_isles = shapefile_mask_data(data_mask_casp,dir+isles_shape_name,opt)

  printMinMax(data_mask_isles,0)
  print("# Valid values = " + num(.not.ismissing(data_mask_isles)))
  print("# Msg values   = " + num(ismissing(data_mask_isles)))

;----------------------------------------------------------------------
; Start the graphics
;----------------------------------------------------------------------
  wks = gsn_open_wks("png","shapefiles")

;---Set some common resources
  res                   = True

  res@gsnMaximize       = True     ; maximize plot in frame
  res@gsnDraw           = False    ; don't draw plot
  res@gsnFrame          = False    ; don't advance frame

  res@mpFillOn          = False    ; Turn these off because we're adding our
  res@mpOutlineOn       = False    ; own outlines via a shapefile.

;---Zoom in on map area of interest
  res@mpMinLatF         = CS_minlat
  res@mpMaxLatF         = CS_maxlat
  res@mpMinLonF         = CS_minlon
  res@mpMaxLonF         = CS_maxlon
  res@mpCenterLonF      = (CS_minlon + CS_maxlon)/2.

  res@cnFillOn          = True
  res@cnFillPalette     = "StepSeq25"
  res@cnLinesOn         = False
  res@cnFillOpacityF    = 0.6
  res@lbOrientation     = "vertical"

  res@gsnAddCyclic      = False

  res@pmTickMarkDisplayMode = "Always"
  res@tiMainFontHeightF = 0.015   ; make title smaller

;----------------------------------------------------------------------
; Create three plots
;----------------------------------------------------------------------
  res@tiMainString = "Data before masking"
  plot_orig = gsn_csm_contour_map(wks,data,res)

  res@tiMainString = "Data after masking against " + caspian_shape_name
  plot_casp = gsn_csm_contour_map(wks,data_mask_casp,res)

  res@tiMainString = "Data after masking against " + isles_shape_name
  plot_isles = gsn_csm_contour_map(wks,data_mask_isles,res)

;----------------------------------------------------------------------
; Add markers at data locations. This helps us see where the data is
; and isn't masked.
;----------------------------------------------------------------------
  if(ADD_MARKERS) then
    mkres                 = True
    mkres@gsnCoordsAttach = True
    mkres@gsMarkerSizeF   = 1.5
    mkres@gsnCoordsNonMissingColor = "transparent"
    mkres@gsnCoordsMissingColor    = "black"
    gsn_coordinates(wks,plot_orig,data,mkres)
    gsn_coordinates(wks,plot_casp,data_mask_casp,mkres)
    gsn_coordinates(wks,plot_isles,data_mask_isles,mkres)
  end if

;----------------------------------------------------------------------
; Add shapefile outlines to all three plots
;----------------------------------------------------------------------
  lnres = True
  lnres@gsLineColor      = "Black"
  lnres@gsLineThicknessF = 2.0         ; increase the thickness
  id_orig = gsn_add_shapefile_polylines(wks,plot_orig, dir+caspian_shape_name,lnres)
  id_casp = gsn_add_shapefile_polylines(wks,plot_casp, dir+caspian_shape_name,lnres)
  id_isle = gsn_add_shapefile_polylines(wks,plot_isles,dir+caspian_shape_name,lnres)

;----------------------------------------------------------------------
; Draw the three plots on their own frames.
;----------------------------------------------------------------------
  draw(plot_orig)
  frame(wks)
  draw(plot_casp)
  frame(wks)
  draw(plot_isles)
  frame(wks)

;----------------------------------------------------------------------
; Zoom in on the two masked plots so we can see masking better. 
;
; If you have the marker locations added, you will also see these
; better.
;----------------------------------------------------------------------
  if(DRAW_ZOOMED_PLOTS) then
    setvalues plot_casp
      "mpMinLatF"         : 43.5
      "mpMaxLatF"         : 46
      "mpMinLonF"         : 49.5
      "mpMaxLonF"         : 52.
    end setvalues
    setvalues plot_isles
      "mpMinLatF"         : 43.5
      "mpMaxLatF"         : 46
      "mpMinLonF"         : 49.5
      "mpMaxLonF"         : 52.
    end setvalues
    draw(plot_casp)
    frame(wks)
    draw(plot_isles)
    frame(wks)
  end if
end
