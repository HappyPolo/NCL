;----------------------------------------------------------------------
; shapefiles_10.ncl
;
; Concepts illustrated:
;   - Reading shapefiles
;   - Plotting geologic data from a polygon shapefile
;   - Zooming in on Colorado on a cylindrical equidistant map
;   - Drawing several labelbars on one page
;   - Modifying gsn_add_shapefile_polygons to color the polygons a certain way 
;   - Reading a colormap from an ASCII file
;   - Using functions for cleaner code
;----------------------------------------------------------------------
; This example shows how to plot polygon data from a shapefile that
; contains geologic units and structural features in Colorado. 
;
; The shapefile comes with a recommended color map to use, which
; is included in this NCL script.
;
; The shapefile (COgeol_dd.zip) was downloaded from 
;
;     http://mrdata.usgs.gov/geology/state/state.php?state=CO
;
; You have to run "unzip" on it to uncompress the files:
;
;    unzip COgeol_dd.zip
;
; The color map was downloaded from:
;
;  http://mrdata.usgs.gov/catalog/lithclass-color.php
;
; According to the website above, these colors provide the lithologic 
; legend for their state geological map compilation.
;
;----------------------------------------------------------------------
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"

;----------------------------------------------------------------------
; This function reads the lithrgb.txt provided at 
;
;   http://mrdata.usgs.gov/catalog/lithclass-color.php
;
; and returns an RGB array and an array of labels as a List.
;
; The RGB array and labels look like this:
;
;      rgb_array         rock_type
;   -----------------------------------------
;   255   255   255   background color
;     0     0     0   foreground color
;   253   244    63   unconsolidated material
;   255   255   137   alluvium
;   255   211    69   silt
;   255   203    35   sand
;    .     .      .    
;   255   255   255   ice
;   153   204   255   water
;    .     .      .    
;   107   195   255   Dolomite
;   160    53     0   Komatiite
;
; The background and foreground colors are added by this script.
; They are not part of the original lithclass-color.php file.
;----------------------------------------------------------------------
undef("read_lithrgb_file")
function read_lithrgb_file()
local lines, nlines, line, tab, i, ncols
begin
  lines  = asciiread("lithrgb.txt",-1,"string")
  nlines = dimsizes(lines)
  tab    = str_get_tab()

;---Don't includer header line, the extra 2 colors are for background/foreground
  rgb_array = new((/nlines+1,3/),float)
  rock_type = new((/nlines+1/),string)

  rgb_array(0,:) = (/1.,1.,1./)    ; background
  rgb_array(1,:) = (/0.,0.,0./)    ; foreground
  rock_type(0)   = "background color"
  rock_type(1)   = "foreground color"

;
; Loop through each line and parse RGB triplets and rock type string.
; Some lines have 5 columns, some have 4.
;
  do i=1,nlines-1     ; Skip the header line
    line             := str_split(lines(i),tab)
    ncols            = dimsizes(line)
    rgb_array(i+1,:) = toint(line(ncols-4:ncols-2))/255.
    rock_type(i+1)   = str_lower(line(ncols-1))
  end do

;---Return the RGB values and the rock type as a List.
  return([/rgb_array,rock_type/])
end

;----------------------------------------------------------------------
; Some of the rock types in the shapefile don't match what's in the
; lithrgb.txt file, so try to fix them. 
;
; NOTE: the person that wrote this script is NOT a geologist, and has 
; no idea if these corrections are, well, correct.
;----------------------------------------------------------------------
undef("fix_rock_types")
function fix_rock_types(rtype)
local orig_type, fix_type,i
begin
  orig_type = (/"clastic","mixed clastic/volcanic",\
               "plutonic rock (phaneritic)"/)
  fix_type = (/"clastic rock","mixed volcanic/clastic rock","plutonic rock"/)

  rtype_new = rtype
  do i=0,dimsizes(orig_type)-1
    rtype_new = where(rtype.eq.orig_type(i),fix_type(i),rtype_new)
  end do
  return(rtype_new)
end

;----------------------------------------------------------------------
; This function creates a cylindrical equidistant map of Colorado
; so you you can add polylines, polygons, or point data to it later.
;----------------------------------------------------------------------
function create_colorado_map(wks,res)
local a, mpres
begin
  mpres                       = res

  mpres@gsnMaximize           = True
  mpres@gsnPaperOrientation   = "portrait"

  mpres@gsnDraw               = False
  mpres@gsnFrame              = False

  mpres@mpFillOn              = False  

;---Turn on fancier tickmark labels.
  mpres@pmTickMarkDisplayMode = "Always"

;---Zoom in on area of interest
  mpres@mpLimitMode           = "LatLon"
  mpres@mpMinLatF             =   37
  mpres@mpMaxLatF             =   41
  mpres@mpMinLonF             = -109.05
  mpres@mpMaxLonF             = -102.05

  mpres@mpUSStateLineThicknessF  = 5.0
  mpres@mpNationalLineThicknessF = 5.0

;Don't use NCL map outlines; use shapefile out lines
;  mpres@mpOutlineOn           = True
;  mpres@mpOutlineBoundarySets    = "AllBoundaries"
;  mpres@mpDataBaseVersion        = "MediumRes"
;  mpres@mpDataSetName            = "Earth..2"      ; U.S. counties

  mpres@mpOutlineOn           = False

;---Create map.
  map = gsn_csm_map(wks,mpres)

  return(map)
end

;----------------------------------------------------------------------
; This procedure adds counties of Colorado via a shapefile.
;----------------------------------------------------------------------
undef("add_county_outlines")
procedure add_county_outlines(wks,map)
begin
  lnres = True
  lnres@gsLineColor = "black"
  map@id = gsn_add_shapefile_polylines(wks,map,"./USA_adm2.shp",lnres)
end

;----------------------------------------------------------------------
; This function draws polygons from a shapefile. The polygons
; are listed by lithographic features, which have a specific
; color associated with them.
;----------------------------------------------------------------------
undef("add_lithographic_polygons")
procedure add_lithographic_polygons(wks,plot,fname:string,lith_colors[*][*]:float,lithtypes:string)
local f, segments, geometry, segsDims, geomDims, geom_segIndex, \
geom_numSegs, segs_xyzIndex, segs_numPnts, numFeatures, i, lat, lon, \
startSegment, numSegments, seg, startPT, endPT, npl, gnres
begin
;---Open the shapefile
  f = addfile(fname,"r")

;---Error checking
  if(ismissing(f)) then
    print("Error: add_lithographic_polygons: Can't open shapefile '" + \
           fname + "'")
    print("       No shapefile information will be added.")
    return(new(1,graphic))
  end if

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

;---Section to attach polygons to plot.
  lon = f->x
  lat = f->y

;---Rock types to plot.
  rocktype1 = str_lower(f->ROCKTYPE1)
  rocktype1_fixed = fix_rock_types(rocktype1)  ; fix the "bad" types

  gnres = True
  do i=0, numFeatures-1  
    ii = ind(rocktype1_fixed(i).eq.lithtypes)    ; Get the color index
    startSegment = geometry(i, geom_segIndex)
    numSegments  = geometry(i, geom_numSegs)
    do seg=startSegment, startSegment+numSegments-1
      startPT = segments(seg, segs_xyzIndex)
      endPT   = startPT + segments(seg, segs_numPnts) - 1
      if(ismissing(ii(0))) then
        print("missing rocktype = '" + rocktype1_fixed(i) + "'")
        dumstr = unique_string("polyline")
        plot@$dumstr$ = gsn_add_polyline(wks, plot, lon(startPT:endPT),  \
                                                    lat(startPT:endPT), gnres)
      else
        dumstr = unique_string("polygon")
        gnres@gsFillColor = lith_colors(ii(0),:)
        plot@$dumstr$ = gsn_add_polygon(wks, plot, lon(startPT:endPT),  \
                                                   lat(startPT:endPT), gnres)
      end if
    end do
  end do
end

;----------------------------------------------------------------------
; Procedure to draw labelbars associated with lithologic legend.
;----------------------------------------------------------------------
undef("draw_labelbars")
procedure draw_labelbars(wks,lith_colors[*][*]:float,lith_types:string)
local nboxes, lbid, lbres, vpx, vpy, vpw, vph
begin
  nboxes = dimsizes(lith_types)-2   ; Remove background/foreground colors
  nboxes_per_bar = 45

  lbres                      = True

  lbres@lbOrientation        = "vertical"
  lbres@vpHeightF            = 0.9       ; Height and width
  lbres@vpWidthF             = 0.1       ; of labelbar.

;---Allow more control over labelbars.
  lbres@lbAutoManage         = False
  lbres@lbLabelFontHeightF   = 0.008

;---Turn various features on and off.
  lbres@lbPerimOn            = False
  lbres@lbTitleOn            = False
  lbres@lbMonoFillPattern    = True
  lbres@lbLabelJust          = "CenterLeft"
  lbres@lbLabelAlignment     = "BoxCenters"

;---How many labelbars do we need to create?
  nlabelbars = (nboxes/nboxes_per_bar) + 1
  lbid = new(nlabelbars,graphic)

;
; Loop through each set of labelbars and draw them. Each
; one will be to the right of the previous one.
;
  vpx = 0.00       ; Start at the leftmost edge.
  vpy = 0.95       ; Close to top of the screen.

  do i=0,nlabelbars-1
    istart = i*nboxes_per_bar+2
    iend   = min((/istart+nboxes_per_bar-1,nboxes+1/))
    if((iend-istart+1).lt.nboxes_per_bar)
      lbres@vpHeightF = (iend-istart+1.)/nboxes_per_bar
    end if
    lbres@lbFillColors := lith_colors(iend:istart,:)
    gsn_labelbar_ndc(wks,min((/nboxes,iend-istart+1/)), \
                     lith_types(istart:iend:-1),vpx,vpy,lbres)
    vpx = vpx+0.21   ; Move to right each time
  end do

;---Draw a title at the top
  txres               = True
  txres@txFontHeightF = 0.02
  gsn_text_ndc(wks,"Legend for lithology colors",0.5,0.98,txres)
end

;----------------------------------------------------------------------
; Main code
;----------------------------------------------------------------------
begin
;---Read the lithographic RGB array and rock types
  lith_list = read_lithrgb_file()
  lith_colors = lith_list[0]
  lith_type = lith_list[1]

;---Open PNG file to send graphics to.
  wks = gsn_open_wks("png","shapefiles")  ; send graphics to PNG file

;---Create a map of Colorado
  res                   = True
  res@tiMainString      = "Geologic units and structural features in Colorado"
  res@tiMainFontHeightF = 0.015
  map = create_colorado_map(wks,res)

;---Add the shapefile polygons
  add_lithographic_polygons(wks,map,"cogeol_dd_polygon.shp",lith_colors,lith_type)

;---Add the shapefile outlines
  add_county_outlines(wks,map)

;---This draws everything
  draw(map)
  frame(wks)

;---Draw the label bars on a separate page.
  reset_device_coordinates(wks)    ; Necessary b/c we maximized last frame.
  draw_labelbars(wks,lith_colors,lith_type)
  frame(wks)
end
