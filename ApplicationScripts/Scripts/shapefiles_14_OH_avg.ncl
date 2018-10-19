;----------------------------------------------------------------------
; shapefiles_13.ncl
;
; Concepts illustrated:
;   - Reading shapefiles
;   - Plotting data from shapefiles
;   - Using shapefile outlines to average WRF-ARW data over counties
;----------------------------------------------------------------------
; The USA_adm2.shp shapefile was downloaded from 
;  http://www.gadm.oarg/country/
;----------------------------------------------------------------------
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"


;----------------------------------------------------------------------
; This function fills each county of Ohio in a color based on
; a data average. A shapefile is used to get the lat/lon outlines
; for each county. 
;----------------------------------------------------------------------
load "./shapefile_utils.ncl"
undef("plot_averages_by_state_counties")
function plot_averages_by_state_counties(wks,plot,data,fname:string,\
                                         state_name[1]:string,levels,\
                                         fill_colors)
local f, segments, geometry, segsDims, geomDims, geom_segIndex, \
geom_numSegs, segs_xyzIndex, segs_numPnts, numFeatures, i, lat, lon, \
startSegment, numSegments, seg, startPT, endPT, dims, 
minlat, maxlat, minlon, maxlon
begin
;
; Get the lat/lon area of interest so we can cull the lat/lon
; pairs that we have to check later.
;
  getvalues plot
    "mpMinLatF" : minlat
    "mpMaxLatF" : maxlat
    "mpMinLonF" : minlon
    "mpMaxLonF" : maxlon
  end getvalues
;
; Convert our 2D lat/lon grid to 1D. We will use these 1D arrays
; when checking which lat/lon pairs fall in which counties
; of Ohio.
;
  lat1d = ndtooned(data@lat2d)
  lon1d = ndtooned(data@lon2d)
  nlatlon = dimsizes(lat1d)

;---Debug prints
  printMinMax(lat1d,0)
  printMinMax(lon1d,0)
  print("minlat/maxlat = " + minlat + "/" + maxlat)
  print("minlon/maxlon = " + minlon + "/" + maxlon)
;
; Get the approximate index values that contain the area of interest.
;
; This will make our gc_inout loop below go faster, because we're
; not checking every single lat/lon point to see if it's within
; the area of interest.
;
  ii_latlon = ind(lat1d.ge.minlat.and.lat1d.le.maxlat.and.\
                  lon1d.ge.minlon.and.lon1d.le.maxlon)
  nii_latlon = dimsizes(ii_latlon)

;---Open the shapefile
  f = addfile(fname,"r")

;---Read data off the shapefile
  geomDims    = getfilevardimsizes(f,"geometry")
  numFeatures = geomDims(0)
  segments    = f->segments
  geometry    = f->geometry
  segsDims    = dimsizes(segments)

;---Read global attributes  
  geom_segIndex = f@geom_segIndex
  geom_numSegs  = f@geom_numSegs
  segs_xyzIndex = f@segs_xyzIndex
  segs_numPnts  = f@segs_numPnts

;---Read the lat/lon data off the shapefile
  lat = f->y
  lon = f->x

;---Read the state and county names off the file
  names1 = f->NAME_1    ; State names
  names2 = f->NAME_2    ; County names

;---Grab the indexes containing the counties from the desired state
  counties   = ind(names1.eq.state_name)
  ncounties  = dimsizes(counties)

;---Debug prints
  print("Number of " + state_name + " counties = " + ncounties)
  print("Number of lat/lon values   = " + nlatlon)
  print("Number of lat/lon values")
  print("   that will be checked    = " + nii_latlon)

;---Create array to hold new data mask, and set all values to 0 initially.
  data_mask_1d = new(nlatlon,integer)
  skip_check   = new(nlatlon,integer)
  skip_check   = 0

;---Make sure "data" has a missing value.
  if(.not.isatt(data,"_FillValue")) then
    data@_FillValue = default_fillvalue(typeof(data))
  end if

;---This is for the averages computation later.
  data_1d = ndtooned(data)

;---Array to hold data averages for each county
  data_avg = new(ncounties,typeof(data),data@_FillValue)

;
; This is the loop that loops across every county of the
; given state and collects all the lat/lon points that 
; are inside that county (data_mask_1d=1).
;
; It then takes an average of the data values for this county,
; and attaches it as a filled polygon to the given plot.
;
  gnres = True                       ; polygon resource list
  nfill = dimsizes(fill_colors)

  do i=0, ncounties-1
    print("--------------------------------------------------")
    print("Inspecting county '" + names2(i) + "'...")

    data_mask_1d = 0    ; Be sure to reset to 0 for every county

;---Some counties have multiple segments
    startSegment = geometry(counties(i), geom_segIndex)
    numSegments  = geometry(counties(i), geom_numSegs)
    do seg=startSegment, startSegment+numSegments-1
      startPT = segments(seg, segs_xyzIndex)
      endPT   = startPT + segments(seg, segs_numPnts) - 1

;---Loop through each point on data grid and see if it's in this county.
      do n=0,nii_latlon-1
        nn = ii_latlon(n)     ; Get index of point we're checking
;
; This "if" statement speeds up code, by making sure we don't
; needlessly check a lat/lon point if:
; 
; - we've already found it in another county
; - it doesn't fall within the general lat/lon box that covers this county
; 
        if(skip_check(nn).or.\
           lat1d(nn).lt.min(lat(startPT:endPT)).or.\
           lat1d(nn).gt.max(lat(startPT:endPT)).or.\
           lon1d(nn).lt.min(lon(startPT:endPT)).or.\
           lon1d(nn).gt.max(lon(startPT:endPT))) 
           continue
        end if

;---Here's the check if the point is in the county.
if(any(lat(startPT:endPT).ge.42)) then
print(names2(i) + " is above 42 lat")
printMinMax(lat(startPT:endPT),0)
printMinMax(lon(startPT:endPT),0)
end if
        if(gc_inout(lat1d(nn),lon1d(nn),\
                    lat(startPT:endPT),lon(startPT:endPT))) then
          data_mask_1d(nn) = 1    ; This point is inside this county
          skip_check(nn)   = 1    ; Don't check this point again
        end if
      end do
    end do    ; End of collecting points for this county

;---Count number of points found in this county
    ndm = num(data_mask_1d.eq.1) 
    print(ndm + " data values found in this county.")
;
; If there are values found in this county, then calculate
; the average, set a fill color for this county, and do the
; fill.
;
    if(ndm.gt.0) then
      data_avg(i)  = avg(where(data_mask_1d.eq.1,data_1d,data_1d@_FillValue))
      print("Average over this county = " + data_avg(i))

;---Set the fill color for this county to the appropriate color
      iiavg := ind(data_avg(i).lt.levels)
      if(.not.any(ismissing(iiavg))) then
        gnres@gsFillColor = fill_colors(iiavg(0))
      else
        gnres@gsFillColor = fill_colors(nfill-1)
      end if
      str = unique_string("poly")
      plot@$str$ = gsn_add_polygon(wks,plot,lon(startPT:endPT),\
                                            lat(startPT:endPT),gnres)
    end if
  end do

  return(data_avg)    ; Return data averages for each county
end

;----------------------------------------------------------------------
; Given an NCL map, a shapefile, and a list of requested features
; in the shapefile, this procedure adds the outlines of the
; requested shapefile features to the NCL map.
;----------------------------------------------------------------------
procedure add_shapefile_outlines_by_name(wks,plot,shp_file_name,
                                         shp_var_name,requested_features,color)
begin
;---Open the shapefile
  f = addfile(shp_file_name,"r")

;---Read data off the shapefile
  geomDims    = getfilevardimsizes(f,"geometry")
  numFeatures = geomDims(0)

  features = f->$shp_var_name$
  segments = f->segments
  geometry = f->geometry
  segsDims = dimsizes(segments)

;---Read global attributes  
  geom_segIndex = f@geom_segIndex
  geom_numSegs  = f@geom_numSegs
  segs_xyzIndex = f@segs_xyzIndex
  segs_numPnts  = f@segs_numPnts

;---Section to attach polygons to plot.
  lon = f->x
  lat = f->y

  npl = 0     ; polyline counter

  lnres                  = True
  lnres@gsLineThicknessF = 2.0
  lnres@gsLineColor      = color
  do i=0,numFeatures-1  
    if(.not.any(features(i).eq.requested_features)) then
      continue
    end if
    startSegment = geometry(i, geom_segIndex)
    numSegments  = geometry(i, geom_numSegs)
    do seg=startSegment, startSegment+numSegments-1
      startPT = segments(seg, segs_xyzIndex)
      endPT   = startPT + segments(seg, segs_numPnts) - 1
      plot@$unique_string("lines")$ = gsn_add_polyline(wks,plot,lon(startPT:endPT),lat(startPT:endPT),lnres)
    end do
  end do
end

;----------------------------------------------------------------------
; Main code
;----------------------------------------------------------------------
begin
;---Name of shapefile that contains U.S county outlines
  shapefile_name = "USA_adm/USA_adm2.shp"

;---Read "HGT" (terrain) variable and lat/lon coordinates off WRF output file.
  wrf_filename  = "wrfout_d01_2002-01.nc"
  a = addfile(wrf_filename,"r")

  nt        = 0                 ; First time step
  hgt       = a->HGT(nt,:,:)
  hgt@lat2d = a->XLAT(nt,:,:)
  hgt@lon2d = a->XLONG(nt,:,:)

  wks = gsn_open_wks("x11","shapefiles")

;---Set some common resources
  res                   = True

  res@gsnMaximize       = True     ; maximize plot in frame
  res@gsnDraw           = False    ; don't draw plot
  res@gsnFrame          = False    ; don't advance frame

  res@mpFillOn          = False    ; Turn these off because we're
  res@mpOutlineOn       = False    ; adding our own outlines

;---Zoom in on map if desired
  res@mpMinLatF         = 38
  res@mpMaxLatF         = 43
  res@mpMinLonF         = -85
  res@mpMaxLonF         = -78
  res@mpCenterLonF      = (res@mpMinLonF + res@mpMaxLonF) / 2.

  res@tiMainFontHeightF = 0.018

  res@pmTickMarkDisplayMode = "Always"    ; better tickmark labels

;---Set additional contour resources
  cnres                   = res
  cnres@gsnAddCyclic      = False

  cnres@cnFillOn          =  True
  cnres@cnLinesOn         = False
  cnres@cnLineLabelsOn    = False
  cnres@lbLabelBarOn      = False

;---Generate nice contour levels
  cnres@cnFillPalette        = "OceanLakeLandSnow"
  cnres@cnLevelSelectionMode = "ManualLevels"
  cnres@cnMinLevelValF       = 1
  cnres@cnMaxLevelValF       = 1100
  cnres@cnLevelSpacingF      = 20

  cnres@gsnRightString = ""
  cnres@gsnLeftString = ""
;---Create two plots so we can compare original with averaged one

;---Create contour plot over map
  cnres@tiMainString = "Original data"
  plot_orig = gsn_csm_contour_map(wks,hgt,cnres)

;---Create a map with the same map limits as previous plot
  res@tiMainString = "Data averaged over counties"
  plot_avg  = gsn_csm_map(wks,res)

;---This gives us the colors and levels to use for the filled polygons
  getvalues plot_orig@contour
    "cnLevels"     : levels
    "cnFillColors" : fill_colors
  end getvalues

  county_avg = plot_averages_by_state_counties(wks,plot_avg,hgt,shapefile_name,\
                                               "Ohio",levels,fill_colors)

  add_shapefile_outlines_by_name(wks,plot_orig,shapefile_name,"NAME_0","United States","gray")
  add_shapefile_outlines_by_name(wks,plot_avg,shapefile_name,"NAME_0","United States","gray")
  add_shapefile_outlines_by_name(wks,plot_orig,shapefile_name,"NAME_1","Ohio","navyblue")
  add_shapefile_outlines_by_name(wks,plot_avg,shapefile_name,"NAME_1","Ohio","navyblue")

;---Attach coordinates
  mkres                 = True
  mkres@gsMarkerSizeF   = 0.002
  mkres@gsMarkerColor   = "coral1"
  mkres@gsnCoordsAttach = True
;  gsn_coordinates(wks,plot_orig,hgt,mkres)

;---Set all hgt values to missing except for those over Ohio.
  opt             = True
  opt@debug       = True
  opt@shape_var   = "NAME_1"
  opt@shape_names = "Ohio"
  hgt_mask  = shapefile_mask_data(hgt,shapefile_name,opt)

  lat2d = hgt@lat2d
  lon2d = hgt@lon2d
  hgt_mask@lat2d = lat2d
  hgt_mask@lon2d = lon2d
  mkres@gsnCoordsMissingColor = "red"
  mkres@gsnCoordsNonMissingColor = "black"
  gsn_coordinates(wks,plot_avg,hgt_mask,mkres)

;---Panel both plots for comparison.
  pres                  = True
  pres@gsnMaximize      = True
  pres@gsnPanelLabelBar = True
  pres@pmLabelBarWidthF = 0.8
  pres@lbLabelFontHeightF = 0.015
  gsn_panel(wks,(/plot_orig,plot_avg/),(/1,2/),pres)

end
