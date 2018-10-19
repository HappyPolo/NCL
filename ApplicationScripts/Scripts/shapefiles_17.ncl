;----------------------------------------------------------------------
; shapefiles_17.ncl
;
; Concepts illustrated:
;   - Reading shapefiles
;   - Adding shapefile outlines to an existing plot
;   - Adding shapefile polygons to an existing plot
;   - Masking a data array based on a geographical area obtained from a shapefile
;   - Specifying how many plots to draw in each row
;   - Generating dummy data
;----------------------------------------------------------------------
; This script generates some dummy data over a regional area, and then
; masks the contours over desert regions, using desert regions read
; off a shapefile.
;
; The shapefile was downloaded from:
;
; http://www.naturalearthdata.com/downloads/10m-physical-vectors/
;
; Note: this data file was found using a google search, and no
; attempt was made to validate the outlines in the file. This file
; is meant to be used for example purposes only. You should use 
; your own shapefile dataset of interest.
;----------------------------------------------------------------------
;
; This file still has to be loaded manually
load "./shapefile_utils.ncl"

;----------------------------------------------------------------------
; Procedure to fill in certain shapefile polygons based on a list
; of given region names.
;----------------------------------------------------------------------
undef("add_shapefile_desert_polygons")
procedure add_shapefile_desert_polygons(wks,plot:graphic,fname:string)
local f, geomDims, numFeatures, gnres
begin
;---Open the shapefile
  f = addfile(fname,"r")

;---Error checking
  if(ismissing(f)) then
    print("Error: add_shapefile_desert_polygons: Can't open shapefile '" + \
           fname + "'")
    print("       No shapefile information will be added.")
    return(new(1,graphic))
  end if

;---We can't use this routine to plot point data
  if(.not.any(f@geometry_type.eq.(/"polygon","polyline"/))) then
    print("Error: add_shapefile_desert_polygons: geometry_type attribute must be 'polygon' or 'polyline'")
    print("       No shapefile information will be added.")
    return(new(1,graphic))
  end if

  gnres             = True
  gnres@gsFillColor = "white"

;---Read data off the shapefile
  geomDims    = getfilevardimsizes(f,"geometry")
  numFeatures = geomDims(0)
  if(numFeatures.eq.0) then
    print("Error: add_shapefile_desert_polygons: the number of features in this file is 0.")
    print("       No shapefile information will be added.")
    return(new(1,graphic))
  end if

  segments = f->segments
  geometry = f->geometry
  segsDims = dimsizes(segments)

;---Read global attributes  
  geom_segIndex = f@geom_segIndex
  geom_numSegs  = f@geom_numSegs
  segs_xyzIndex = f@segs_xyzIndex
  segs_numPnts  = f@segs_numPnts

;---Create array to hold all polylines
  npoly = sum(geometry(:,geom_numSegs)) 
  poly  = new(npoly,graphic)

;---Section to attach polylines to plot.
  lon = f->x
  lat = f->y
  names = f->name
  npl = 0     ; polyline counter

  ii = str_match_ind_ic(names,"desert")
  nii = dimsizes(ii)
  do i=0, nii-1
     j = ii(i)
     startSegment = geometry(j, geom_segIndex)
     numSegments  = geometry(j, geom_numSegs)
     do seg=startSegment, startSegment+numSegments-1
        startPT = segments(seg, segs_xyzIndex)
        endPT   = startPT + segments(seg, segs_numPnts) - 1
        poly(npl) = gsn_add_polygon(wks, plot, lon(startPT:endPT),  \
                                    lat(startPT:endPT), gnres)
        npl = npl + 1
     end do
  end do
  plot@polygons = poly(0:npl-1)
end

;----------------------------------------------------------------------
; Function to create dummy rectilinear data over a map area of 
; interest, given nlat and nlon.
;----------------------------------------------------------------------
undef("create_dummy_array")
function create_dummy_array(minlat,maxlat,minlon,maxlon,nlon,nlat)
local lat1d, lon1d
begin
;---Generate some dummy data over map
  data            = generate_2d_array(10, 10, 0., 100., 0, (/nlat,nlon/))
  data@_FillValue = -9999

;---Add lat/lon coordinate array information.
  lat1d       = fspan(minlat,maxlat,nlat)
  lon1d       = fspan(minlon,maxlon,nlon)
  lat1d@units = "degrees_north"
  lon1d@units = "degrees_east"
  data!0      = "lat"
  data!1      = "lon"
  data&lat    = lat1d
  data&lon    = lon1d

  return(data)
end

;----------------------------------------------------------------------
; Procedure to attach the data's lat/lon grid. This is mainly so you
; can see which data values have been masked.
;----------------------------------------------------------------------
undef("add_latlon_points")
procedure add_latlon_points(wks,plot,data)
local mkres
begin
  mkres                 = True
  mkres@gsMarkerSizeF   = 0.001
  mkres@gsnCoordsAttach = True
  gsn_coordinates(wks,plot,data,mkres)
end

;----------------------------------------------------------------------
; Procedure to add *all* the shapefile outlines on the given
; shapefile to the given NCL plot.
;----------------------------------------------------------------------
undef("add_shapefile_outlines")
procedure add_shapefile_outlines(wks,plot,shp_file)
local lnres, dumstr
begin
  lnres                  = True
  lnres@gsLineColor      = "black"
  lnres@gsLineThicknessF = 2.0

  dumstr = unique_string("dummy")
  plot@$dumstr$ = gsn_add_shapefile_polylines(wks,plot,shp_file,lnres)
end


;----------------------------------------------------------------------
; Main code
;----------------------------------------------------------------------
begin
;---Create dummy data over a subset of the globe
  minlat = 0
  maxlat = 50
  minlon = 10
  maxlon = 60
  nlat   = 64
  nlon   = 128
  data   = create_dummy_array(minlat,maxlat,minlon,maxlon,nlat,nlon)

;----------------------------------------------------------------------
; Given a shapefile, a variable name on the shapefile, and list
; of region names, mask the data based on these regions.
;
; Downloaded shapefile from:
;
; http://www.naturalearthdata.com/downloads/10m-physical-vectors/
;----------------------------------------------------------------------
  shp_name     = "ne_10m_geography_regions_polys"
  shp_file     = "./" + shp_name + ".shp"
  a = addfile(shp_file,"r")
  
;---Get list of desert names
  desert_names = str_match_ic(a->name,"desert")  

  opt             = True
  opt@shape_var   = "name"   ; var name that contains region names
  opt@keep        = False    ; throw away points inside desert regions
  opt@shape_names = desert_names
  data_mask       = shapefile_mask_data(data,shp_file,opt)

;---Start the graphics
  wks = gsn_open_wks("png","shapefiles") ; send graphics to PNG file

  res                   = True
  res@gsnMaximize       = True        ; Maximize plot in frame
  res@gsnDraw           = False       ; Will draw later in panel
  res@gsnFrame          = False

  res@cnFillOn          = True        ; Turn on contour fill
  res@cnLinesOn         = False       ; Turn off contour lines
  res@cnLineLabelsOn    = False       ; Turn off line labels

  res@gsnAddCyclic      = False        ; Don't add longitude cyclic point

;---Zoom in on a region
  res@mpMinLatF         = minlat
  res@mpMaxLatF         = maxlat
  res@mpMinLonF         = minlon
  res@mpMaxLonF         = maxlon

  res@mpFillOn          = False
  res@mpOutlineOn       = False

;--Set the contour levels using "nice_mnmxintvl" function.
  mnmxint = nice_mnmxintvl( min(data), max(data), 18, False)
  res@cnLevelSelectionMode = "ManualLevels"
  res@cnMinLevelValF       = mnmxint(0)
  res@cnMaxLevelValF       = mnmxint(1)
  res@cnLevelSpacingF      = mnmxint(2)/4.  ; Decrease spacing for more levels
  res@lbLabelBarOn         = False          ; Will add labelbar in panel

  res@tiMainFontHeightF    = 0.025

;---Create plot of original data
  res@tiMainString = "Original data"
  plot_orig = gsn_csm_contour_map(wks,data,res)

;---Create plot of masked data
  res@tiMainString = "Data masked by desert regions"
  plot_mask = gsn_csm_contour_map(wks,data_mask,res)

;---Create plot of original data; we'll add desert polygons to this one
  res@tiMainString = "Desert regions filled in white"
  plot_pgon = gsn_csm_contour_map(wks,data,res)

;---Fill desert regions in white
  add_shapefile_desert_polygons(wks,plot_pgon,shp_file)

;---Attach the shapefile outlines
  ADD_SHAPEFILE_OUTLINES = True
  if(ADD_SHAPEFILE_OUTLINES) then
    add_shapefile_outlines(wks,plot_orig,shp_file)
    add_shapefile_outlines(wks,plot_pgon,shp_file)
    add_shapefile_outlines(wks,plot_mask,shp_file)
  end if

;---Attach coordinates of data's lat/lon grid if desired.
  ADD_LATLON_POINTS = False
  if(ADD_LATLON_POINTS) then
    add_latlon_points(wks,plot_orig,data)
    add_latlon_points(wks,plot_pgon,data)
    add_latlon_points(wks,plot_mask,data_mask)
  end if
  
;---Panel both plots
  pres                    = True
  pres@gsnMaximize        = True
  pres@gsnPanelLabelBar   = True
  pres@pmLabelBarWidthF   = 0.7
  pres@lbLabelFontHeightF = 0.01
  pres@gsnPanelRowSpec    = True
  gsn_panel(wks,(/plot_orig,plot_pgon,plot_mask/),(/1,2/),pres)
end
