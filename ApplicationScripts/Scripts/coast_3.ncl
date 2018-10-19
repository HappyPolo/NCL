;************************************
; coast_3.ncl
;************************************
;
; Concepts illustrated:
;   - Drawing a map using the high resolution map outlines
;   - Drawing three different resolutions for map outlines
;   - Reading shapefiles
;   - Plotting data from shapefiles
;   - Using data from shapefiles to draw areas of interest in Australia
;   - Zooming in on Australia on a cylindrical equidistant map
;   - Moving the labelbar away from the plot
;   - Comparing shapefile data with NCL's map databases
;
;
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"

;----------------------------------------------------------------------
; This procedure attaches polyline data from a shapefile
;----------------------------------------------------------------------
undef("attach_shapefile_polyline")
function attach_shapefile_polyline(f:file,wks,plot,line_color)
local lnres
begin
  gsn_define_colormap(wks,(/"white","black","tan","LightBlue",\
                            "brown","yellow","navyblue","green"/))

  lnres                  = True      ; resources for polylines
  lnres@gsLineThicknessF = 2.0       ; 2x as thick
;  lnres@gsLineDashPattern = 2
  lnres@gsLineColor      = line_color
;
; Loop through files that we want to read geographic information from.
;
; If this loop is extremely slow, consider using gsn_polyline instead
; of gsn_add_polyline. This can have a significant effect. Remember
; that gsn_polyline is a procedure, not a function, and it draws the
; lines right when you call it, so you need to make sure your plot is
; already drawn to the frame.
;
;---Read data off the shapefile
  segments = f->segments
  geometry = f->geometry
  segsDims = dimsizes(segments)
  geomDims = dimsizes(geometry)

;---Read global attributes  
  geom_segIndex = f@geom_segIndex
  geom_numSegs  = f@geom_numSegs
  segs_xyzIndex = f@segs_xyzIndex
  segs_numPnts  = f@segs_numPnts
  numFeatures   = geomDims(0)

;---Section to draw polylines on plot.
  lon = f->x
  lat = f->y
  do i=0, numFeatures-1  
     startSegment = geometry(i, geom_segIndex)
     numSegments  = geometry(i, geom_numSegs)
     do seg=startSegment, startSegment+numSegments-1
        startPT = segments(seg, segs_xyzIndex)
        endPT   = startPT + segments(seg, segs_numPnts) - 1
;
; This call adds the line segment.
;
; Can use gsn_polyline here to make it faster.
;
        dumstr = unique_string("primitive")
        plot@$dumstr$ = gsn_add_polyline(wks, plot, lon(startPT:endPT),  \
                                        lat(startPT:endPT), lnres)
     end do
  end do

;---Clean up before we read in same variables again.
  delete(lat)
  delete(lon)
  delete(segments)
  delete(geometry)

;---We have to return plot so that attached lines are not lost.
  return(plot)
end


;----------------------------------------------------------------------
; This function creates a cylindrical equidistant map of Australia
; so you you can add polylines, polygons, or point data to it later.
;
; The default map outline provided by NCL is turned off, and instead
; one from a shapefile is used.
;----------------------------------------------------------------------
undef("create_map")
function create_map(wks,title,resolution)
local a, res2
begin
  res2               = True
  res2@mpDataBaseVersion = resolution
  res2@gsnMaximize   = True
  res2@gsnDraw       = False
  res2@gsnFrame      = False

  res2@mpOutlineOn   = True
  res2@mpFillOn      = False  

;---Turn on fancier tickmark labels.
  res2@pmTickMarkDisplayMode = "Always"

;---Zoom in on area of interest
  res2@mpLimitMode           = "LatLon"
  res2@mpMinLatF             = -45
  res2@mpMaxLatF             =  -6
  res2@mpMinLonF             = 110
  res2@mpMaxLonF             = 155

  res2@tiMainString          = title

;---Create map.
  map = gsn_csm_map(wks,res2)

  return(map)
end

;----------------------------------------------------------------------
; Main code
;----------------------------------------------------------------------
begin
;--- Open workstation.
  wks = gsn_open_wks("png","coast") ; send graphics to PNG file

  resltn = (/"LowRes","MediumRes","HighRes"/)
  nres   = dimsizes(resltn)

  dir      = "./"
  filename = "AUS_adm0.shp"
  a        = addfile(dir + filename,"r")

  lnres = True
  txres = True
  txres@txFontHeightF    = 0.015
  txres@txJust           = "CenterLeft"
  lnres@gsLineThicknessF = 2.0

  lon  = 112
  lat1 = -40
  lat2 = -42

  ln1 = new(nres,graphic)
  txt1 = new(nres,graphic)
  ln2 = new(nres,graphic)
  txt2 = new(nres,graphic)
  do i=0,nres-1
    if(str_lower(resltn(i)).eq."highres") then
      title = "RANGS/GSHHS coastal database"
    else
      title = "NCL's " + resltn(i) + " map database"
    end if
    map = create_map(wks,title,resltn(i))

;---Attach shapefile outline of Australia
    map = attach_shapefile_polyline(a,wks,map,"brown")

    lnres@gsLineColor = "brown"
    ln1(i)  = gsn_add_polyline(wks,map,(/lon,lon+1/),(/lat1,lat1/),lnres)
    txt1(i) = gsn_add_text(wks,map,"outlines from " + filename,lon+2,lat1,txres)

    lnres@gsLineColor = "black"
    ln2(i) = gsn_add_polyline(wks,map,(/lon,lon+1/),(/lat2,lat2/),lnres)
    if(str_lower(resltn(i)).eq."highres") then
      str = "outlines from RANGS/GSHHS"
    else
      str = "outlines from NCL"
    end if
    txt2(i) = gsn_add_text(wks,map,str,lon+2,lat2,txres)

    draw(map)
    frame(wks)
  end do

end
