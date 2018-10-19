;----------------------------------------------------------------------
; polyg_19.ncl
;
; Concepts illustrated:
;   - Adding lines and polygons to a map
;   - Adding a map to another map as an annotation
;   - Coloring shapefile outlines based on an array of values
;   - Drawing a custom labelbar on a map
;   - Using functions for cleaner code
;-----------------------------------------------------------------
; The USA_adm and PRI_adm shapefiles can be downloaded from
; gadm.org/country. The "states" shapefile can be downloaded
; from the NCL examples page, http://www.ncl.ucar.edu/Applications/Data
;-----------------------------------------------------------------

;----------------------------------------------------------------------
; This function creates a basic NCL map of mainland USA.
;----------------------------------------------------------------------
undef("mainland_map")
function mainland_map(wks,title)
local res
begin
  res                        = True
  res@gsnMaximize            = True
  res@gsnDraw                = False
  res@gsnFrame               = False
  res@mpFillOn               = True 

  res@mpOutlineDrawOrder     = "Draw"
  LC = True            ; This generates a nicer looking map of the U.S.
  if(LC) then
    res@mpProjection           = "LambertConformal"  ; choose projection
    res@mpLambertParallel1F    = 29.5  ; 33.0                ; two parallels
    res@mpLambertParallel2F    = 45.5  ; 45.0
    res@mpLambertMeridianF     = -95.0               ; central meridian
    res@mpLimitMode            = "LatLon"
    res@mpMinLatF           = 20.5         ; map area
    res@mpMaxLatF           = 51.0         ; latitudes
    res@mpMinLonF           = -120.0       ; and
    res@mpMaxLonF           = -71.0        ; longitudes
  else
    res@mpMinLatF           =  18.5
    res@mpMaxLatF           =  50
    res@mpMinLonF           = -128
    res@mpMaxLonF           =  -62
  end if
  res@mpPerimOn              = False
  res@mpLandFillColor        = "white"
  res@mpOceanFillColor       = "white"
  res@mpInlandWaterFillColor = "white"
  res@tiMainString           = title
  map = gsn_csm_map(wks,res)

  map@minlat = res@mpMinLatF
  map@maxlat = res@mpMaxLatF
  map@minlon = res@mpMinLonF
  map@maxlon = res@mpMaxLonF
  return(map)
end

;----------------------------------------------------------------------
; Create a simple NCL map of Hawaii and resize it to be a fraction
; of the size of the mainland USA map.
;----------------------------------------------------------------------
undef("hawaii_map")
function hawaii_map(wks,main_map)
local res, main_height
begin
  getvalues main_map
    "vpHeightF" : main_height
  end getvalues
  res                        = True
  res@vpHeightF              = 0.20*main_height
  res@gsnDraw                = False
  res@gsnFrame               = False
  res@mpFillOn               = True 
  res@mpOutlineOn            = False
  res@mpPerimOn              = False
  LC = True
  if(LC) then
    res@mpProjection           = "LambertConformal"  ; choose projection
    res@mpLambertParallel1F    =  8.   ; 33.0                ; two parallels
    res@mpLambertParallel2F    = 18.   ; 45.0
    res@mpLambertMeridianF     = -165.               ; central meridian
    res@mpLimitMode            = "LatLon"
  else
    res@gsnTickMarksOn         = False
  end if
  res@mpMinLatF              = 18.5
  res@mpMaxLatF              = 22.5
  res@mpMinLonF              = -161
  res@mpMaxLonF              = -154
  res@mpLandFillColor        = "transparent"
  res@mpOceanFillColor       = "transparent"
  res@mpInlandWaterFillColor = "transparent"
  map = gsn_csm_map(wks,res)
;---This is for later, when we add the shapefile outlines
  map@minlat = res@mpMinLatF
  map@maxlat = res@mpMaxLatF
  map@minlon = res@mpMinLonF
  map@maxlon = res@mpMaxLonF
  return(map)
end

;----------------------------------------------------------------------
; Create a simple NCL map of Puerto Rico and resize it to be a
; fraction of the size of the mainland USA map.
;----------------------------------------------------------------------
undef("puerto_rico_map")
function puerto_rico_map(wks,main_map)
local res, main_height
begin
  getvalues main_map
    "vpHeightF" : main_height
  end getvalues

  res                        = True
  res@vpHeightF              = 0.10*main_height
  res@gsnDraw                = False
  res@gsnFrame               = False
  res@mpFillOn               = True 
  res@mpOutlineOn            = False
  res@mpPerimOn              = False
  LC = True
  if(LC) then
    res@mpProjection           = "LambertConformal"  ; choose projection
    res@mpLambertParallel1F    = 18.03
    res@mpLambertParallel2F    = 18.43
    res@mpLambertMeridianF     = -66.43
    res@mpLimitMode            = "LatLon"
  else
    res@gsnTickMarksOn         = False
  end if
  res@mpMinLatF              = 17.85
  res@mpMaxLatF              = 18.6
  res@mpMinLonF              = -68
  res@mpMaxLonF              = -65
  res@mpLandFillColor        = "transparent"
  res@mpOceanFillColor       = "transparent"
  res@mpInlandWaterFillColor = "transparent"
  map = gsn_csm_map(wks,res)

;---This is for later, when we add the shapefile outlines
  map@minlat = res@mpMinLatF
  map@maxlat = res@mpMaxLatF
  map@minlon = res@mpMinLonF
  map@maxlon = res@mpMaxLonF
  return(map)
end

;----------------------------------------------------------------------
; Create a simple NCL map of Alaska and resize it to be a fraction of 
; the size of the mainland USA map.
;----------------------------------------------------------------------
undef("alaksa_map")
function alaska_map(wks,main_map)
local res, main_height
begin
  getvalues main_map
    "vpHeightF" : main_height
  end getvalues
  res                        = True
  res@vpHeightF              = 0.3*main_height
  res@gsnDraw                = False
  res@gsnFrame               = False
  res@mpFillOn               = True 
  res@mpOutlineOn            = False
  res@mpPerimOn              = False
  LC = True
  if(LC) then
    res@mpProjection           = "LambertConformal"  ; choose projection
    res@mpLambertParallel1F    = 55.0                ; two parallels
    res@mpLambertParallel2F    = 65.0
    res@mpLambertMeridianF     = -150.
    res@mpLimitMode            = "LatLon"
  else
    res@gsnTickMarksOn         = False
  end if
  res@mpMinLatF              = 53.
  res@mpMaxLatF              = 71.5
  res@mpMinLonF              = -172
  res@mpMaxLonF              = -129
  res@mpLandFillColor        = "transparent"
  res@mpOceanFillColor       = "transparent"
  res@mpInlandWaterFillColor = "transparent"
  map = gsn_csm_map(wks,res)

;---This is for later, when we add the shapefile outlines
  map@minlat = res@mpMinLatF
  map@maxlat = res@mpMaxLatF
  map@minlon = res@mpMinLonF
  map@maxlon = res@mpMaxLonF
  return(map)
end

;----------------------------------------------------------------------
; This function color fills in each state with a corresponding color
; using state outlines read in from a shapefile.  This function can be 
; slow, because some states (like Alaska) have a lot of segments 
; to draw.
;----------------------------------------------------------------------
undef("add_shapefile_polygons")
procedure add_shapefile_polygons(wks,plot,sname,states[*]:string,\
                                 colors[*][*]:numeric)
begin
;---Open the shapefile
  f = addfile(sname,"r")

;---Read data off the shapefile
  geomDims    = getfilevardimsizes(f,"geometry")
  numFeatures = geomDims(0)

  if(isfilevar(f,"HASC_1")) then
    states_ab = f->HASC_1   ; "US.AL", "US.AK", etc
    is_pr = False
  else if(isfilevar(f,"STATE_ABBR")) then
    states_ab = "US." + f->STATE_ABBR   ; "US.AL", "US.AK", etc
    is_pr = False
  else
    if(isfilevar(f,"NAME_ENGLI").and.f->NAME_ENGLI.ne."Puerto Rico") then
      print("I don't know what to do with the " + sname + " shapefile")
      exit
    end if
    is_pr = True
  end if
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
  poly  = new(npoly*2,graphic)

;---Section to attach polygons to plot.
  lon = f->x
  lat = f->y

  gnres = True
  gnres@gsEdgesOn        = True   ; this draws the shapefile outlines
  gnres@gsEdgeThicknessF = 1.5    ; in a slightly thicker line

  do i=0, numFeatures-1  
     if(.not.is_pr) then
       ic = ind(states_ab(i).eq.states)
     else
       ic = ind("US.PR".eq.states)
     end if
     gnres@gsFillColor = colors(ic,:)
     startSegment = geometry(i, geom_segIndex)
     numSegments  = geometry(i, geom_numSegs)
     do seg=startSegment, startSegment+numSegments-1
        startPT = segments(seg, segs_xyzIndex)
        endPT   = startPT + segments(seg, segs_numPnts) - 1
;---This extra "if" statement is to make the code run a little faster.
        if(min(lat(startPT:endPT)).gt.plot@maxlat.or.\
           max(lat(startPT:endPT)).lt.plot@minlat.or.\
           min(lon(startPT:endPT)).gt.plot@maxlon.or.\
           max(lon(startPT:endPT)).lt.plot@minlon) then
          continue
        end if
        plot@$unique_string("poly")$ = gsn_add_polygon(wks, plot, lon(startPT:endPT), \
                                                                  lat(startPT:endPT), gnres)
     end do
  end do
end

;----------------------------------------------------------------------
; Given an array of values, an array of levels, and a color map or
; RGB/A array, return a color value for each value, depending on which
; range of levels it falls in.
;----------------------------------------------------------------------
undef("bin_values_between_levels")
function bin_values_between_levels(values,levels,colors)
local nlevels, nvalues, icolors, binned_colors, nc, nl
begin
  nlevels = dimsizes(levels)
  nvalues = dimsizes(values)
  icolors = span_color_indexes(colors,nlevels+1)
  binned_colors = new((/nvalues,4/),typeof(colors))
  do nc=0,nvalues-1
    do nl=0,nlevels
      if(nl.eq.0.and.values(nc).lt.levels(0)) then
        binned_colors(nc,:) = colors(icolors(0),:)
      else if(nl.gt.0.and.nl.lt.nlevels.and.\
              values(nc).ge.levels(nl-1).and.values(nc).lt.levels(nl)) then
        binned_colors(nc,:) = colors(icolors(nl),:)
      else if(nl.eq.nlevels.and.values(nc).ge.levels(nl-1)) then
        binned_colors(nc,:) = colors(icolors(nl),:)
      end if         
      end if         
      end if         
    end do
    if(all(ismissing(binned_colors(nc,:)))) then
      print("bin_values_between_levels: we have a problem! Didn't find a range for value " + values(nc))
    end if
  end do
  return(binned_colors)
end

;----------------------------------------------------------------------
; Given a map, title, list of strings, a list of colors, and an
; orientation (horizontal or vertical), draw a labelbar either 
; below the map or to the right of the map.
;----------------------------------------------------------------------
undef("draw_labelbar")
procedure draw_labelbar(wks,map,level_strings[*]:string,\
                        full_colors[*][*],orientation[1]:string)
local nlevels, icolors, color_dims, ncolors, lbres
begin
  nlevels = dimsizes(level_strings)
  icolors = span_color_indexes(full_colors,nlevels+1)
  colors = full_colors(icolors,:)
  color_dims = dimsizes(icolors)
  ncolors    = color_dims(0)

  getvalues map
    "vpXF"      : vpx
    "vpYF"      : vpy
    "vpWidthF"  : vpw
    "vpHeightF" : vph
  end getvalues

  lbres = True
  lbres@lbPerimOn            = False              ; no label bar box
  lbres@lbOrientation        = orientation        ; orientation
  lbres@vpWidthF             = vpw                ; size
  lbres@vpHeightF            = 0.1
  lbres@lbLabelFontHeightF   = 0.013
;  lbres@lbTitleString        = title
  lbres@lbTitleFontHeightF   = 0.013
  lbres@lbLabelAlignment     = "InteriorEdges"  
  lbres@lbMonoFillPattern    = True                ; fill sold
  lbres@lbFillColors         = colors
  lbres@lbLabelAutoStride    = False
  if(orientation.eq."horizontal") then
    xpos = (1.-vpw)/2.
    ypos = (vpy-vph)+0.01
  else
    xpos = vpx+vpw-0.07
    ypos = vpy-(vph-(vph*0.5))/2.
  end if
  gsn_labelbar_ndc (wks,ncolors,level_strings,xpos,ypos,lbres)
end


;----------------------------------------------------------------------
; Add three smaller maps to larger map as annotations.
;----------------------------------------------------------------------
undef("add_small_maps_to_big_map")
procedure add_small_maps_to_big_map(main_map,ak_map,hi_map,pr_map)
local amres
begin
  amres                  = True
  amres@amJust           = "BottomLeft"
  amres@amOrthogonalPosF = 0.50   ; 0.5 is the bottom edge of the plot.

  amres@amParallelPosF   = -0.5   ; -0.5 is the left edge of the plot.
  main_map@$unique_string("ak")$  = gsn_add_annotation(main_map, ak_map, amres)

  amres@amParallelPosF   = -0.2   ; -0.5 is the left edge of the plot
  main_map@$unique_string("h")$ = gsn_add_annotation(main_map, hi_map, amres)

  amres@amJust           = "BottomRight"
  amres@amParallelPosF   = 0.4   ; 0.5 is the right edge of the plot
  main_map@$unique_string("h")$ = gsn_add_annotation(main_map, pr_map, amres)
end

;----------------------------------------------------------------------
; Main driver 
;----------------------------------------------------------------------
begin
;----------------------------------------------------------------------
; Read population data off ASCII file
;----------------------------------------------------------------------
   us_population = "us_state_population.txt"
   usa_data      = asciiread(us_population,-1,"string")
   states        = "US." + str_upper(str_get_field(usa_data(1:),1," "))
   population    = tofloat(str_get_field(usa_data(1:),2," "))/1000000.

   printMinMax(population,0)

;----------------------------------------------------------------------
; Start the graphics
;----------------------------------------------------------------------
  sname1 = "states.shp"    ; Use this for mainland USA b/c it has better Great Lakes outlines than the USA_adm1.shp file
  sname2 = "USA_adm/USA_adm1.shp"   ; Use this for Hawaii and Alaska
  pname  = "PRI_adm/PRI_adm0.shp"   ; Puerto Rico

;---This is just informational; we don't use the sorted values in the code.
  isort = dim_pqsort(population,1)
  print(states(isort) + " : " + population(isort))

;---These are the levels for binning.
  levels = (/1,2.5,3,4,5,6,7,8,9,10,12,25,38/)

;---Read in the desired color maps to use
  color_map   = "StepSeq25"
  cmap_rgba   = read_colormap_file(color_map)
  color_indexes = (/6,11,16,21,26,4,9,14,19,24,2,7,12,17,22/)-2
  colors      = cmap_rgba(color_indexes,:)

  wks  = gsn_open_wks("png","polyg")

;---Create the various maps
  main_map = mainland_map(wks,"Population  in millions (2014)")
  ak_map   = alaska_map(wks,main_map)
  hi_map   = hawaii_map(wks,main_map)
  pr_map   = puerto_rico_map(wks,main_map)

;---Create the binned array of colors based on the levels.
  binned_colors = bin_values_between_levels(population,levels,colors)

;---Add colored polygons based on binned color arrays for each state
  add_shapefile_polygons(wks,main_map,sname1,states,binned_colors)
  add_shapefile_polygons(wks,ak_map,sname2,states,binned_colors)
  add_shapefile_polygons(wks,hi_map,sname2,states,binned_colors)
  add_shapefile_polygons(wks,pr_map,pname,states,binned_colors)

;---Add three smaller maps to larger map as annotations.
  add_small_maps_to_big_map(main_map,ak_map,hi_map,pr_map)

;---Draw everything and add a labelbar
  draw(main_map)                                                ; This draws all four maps and the filled polygons
  draw_labelbar(wks,main_map,""+levels,colors,"horizontal")
  frame(wks)

end
