;======================================================================
; mpas_polygon_3.ncl
;
; Concepts illustrated:
;   - Drawing filled polygons on a 2,621,442 cell MPAS grid
;   - Setting 254 contour levels so we can use the full color map 
;   - Attaching a custom labelbar to a map
;   - Using functions for cleaner code
;======================================================================
; This script is similar to  mpas_3.ncl, except it draws the contours
; by filling in the individual polygon cells, rather than use NCL's
; "RasterFill" mode.
;
; The result is a slightly nicer plot, with no "holes" in the upper
; and lower left corners. The drawback is the script takes longer
; (40+ seconds versus 11 seconds) and you have to create your own 
; labelbar
;======================================================================
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"

;======================================================================
; Function to attach a custom label bar
;======================================================================
undef("attach_labelbar")
function attach_labelbar(wks,map,labels,colors)
local lbres, nlevels, amres
begin

  nlevels = dimsizes(labels)

  lbres = True
  lbres@lbPerimOn            = False               ; no label bar box
  lbres@lbOrientation        = "Horizontal"        ; orientation
  lbres@vpWidthF             = 0.8                 ; width of labelbar
  lbres@vpHeightF            = 0.10                ; height of labelbar
  lbres@lbLabelFontHeightF   = 0.015               ; label font height
  lbres@lbLabelAlignment     = "InteriorEdges"     ; where to label
  lbres@lbMonoFillPattern    = True                ; fill sold
  lbres@lbFillColors         = colors
  lbres@lbBoxLinesOn         = False

  lbid = gsn_create_labelbar (wks,nlevels+1,labels,lbres)

  amres                  = True
  amres@amJust           = "TopCenter"
  amres@amOrthogonalPosF = 0.6

  map@annoid             = gsn_add_annotation(map,lbid,amres)

  return(map)
end


;======================================================================
; Function to attach filled polygons
;======================================================================
undef("attach_polygons")
function attach_polygons(wks,map,t2m,latVertex,lonVertex,verticesOnCell,\
                         levels,colors)
local dims, nCells, maxEdges, latvoc, lonvoc, i, fill_segments, \
gscolors, cells, icolors, vind
begin
  dims     = dimsizes(verticesOnCell)
  nCells   = dims(0)
  maxEdges = dims(1)
  nlevels  = dimsizes(levels)
  icolors  = rgba_to_color_index(colors)

;
; Here the vertices are put into an array. Note that the number of
; vertices is variable. The second do loop sets all vertices greater than
; the actual count for the cell to the value of the last actual vertex. 
; The polygon code depends on having the extra vertices set up in this manner.
;
  latvoc = new((/ nCells, maxEdges /),double)
  lonvoc = new((/ nCells, maxEdges /),double)

  do i = 0, maxEdges - 1
    latvoc(:,i)  = latVertex(verticesOnCell(:,i) - 1)
    lonvoc(:,i)  = lonVertex(verticesOnCell(:,i) - 1)
  end do

;---Array to hold polygon segments to fill
  fill_segments = ispan(0,nCells * maxEdges,maxEdges)
  gscolors = new(nCells,integer)
  cell_count = 0
;
; This section determines which range of levels each element of
; "t2m" falls between, and sets the appropriate color for that
; range of values.
;

;--First level
  vind = ind(t2m .lt. levels(0))
  if (.not. ismissing(vind(0))) then
    cell_count = cell_count + dimsizes(vind)
    gscolors(vind) = icolors(0)
  end if

;--Middle levels
  do i = 1, nlevels-1
    vind := ind(t2m .ge. levels(i-1) .and. t2m .lt. levels(i))
    if (.not. ismissing(vind(0))) then
      cell_count = cell_count + dimsizes(vind)
      gscolors(vind) = icolors(i)
    else 
      print("no values found b/w levels " + level(i) + " and " + level(i+1))
    end if
  end do

;--Last level
  vind := ind(t2m .ge. levels(nlevels-1))
  if (.not. ismissing(vind(0))) then
    gscolors(vind) = icolors(nlevels-1)
    cell_count = cell_count + dimsizes(vind)
  end if
  if (any(ismissing(gscolors))) then
    gscolors(ind(ismissing(gscolors))) = 0
  end if

  print("===> " + cell_count + " cells to be filled...")

;---Resource list for polygons
  gsres            = True
  gsres@gsColors   = gscolors
  gsres@gsSegments = fill_segments

  print("===> Attaching the polygons...")
  polygon = gsn_add_polygon(wks,map,ndtooned(lonvoc),ndtooned(latvoc),gsres)
  return(polygon)
end

;======================================================================
; Main code
;======================================================================
begin
  code_start = get_cpu_time() 

;---Open MPAS file
  mpas_file = "x1.2621442.output.2010-10-23_00.00.00.nc"
  f         = addfile(mpas_file,"r")

;---Read a timestep of "t2m" 
  nt          = 3                   ; nt=0 is a constant field for t2m
  t2m         = f->t2m(nt,:)

;---Read lat/lon and convert to degrees
  RAD2DEG        = get_r2d("double")     ; Radian to Degree
  lonCell        = f->lonCell * RAD2DEG
  latCell        = f->latCell * RAD2DEG
  lonVertex      = f->lonVertex * RAD2DEG
  latVertex      = f->latVertex * RAD2DEG

;---Read other info needed from file.
  verticesOnEdge = f->verticesOnEdge
  verticesOnCell = f->verticesOnCell
  nEdgesOnCell   = f->nEdgesOnCell

  read_end  = get_cpu_time() 
  print("===> Reading data elapsed time = " + (read_end-code_start))

  dims     = dimsizes(verticesOnCell)
  nCells   = dims(0)
  maxEdges = dims(1)

;---Debug prints
  nCells = dimsizes(latCell)
  print("===> This MPAS file has " + nCells + " cells.")

  printMinMax(t2m,0)
  printMinMax(latCell,0)
  printMinMax(lonCell,0)

;---Start the graphics
  graphics_start = get_cpu_time()

;---Open PNG file to write graphics to. PS file will be too large
  wks = gsn_open_wks("png","mpas_polygon")

;---Settings for graphics options
  res                     = True              ; Plot modes desired.

  res@gsnMaximize         = True              ; Maximize plot
  res@gsnDraw             = False
  res@gsnFrame            = False

  res@mpFillOn            = False

;---Various titles
  res@tiMainString          = mpas_file
  res@gsnLeftString       = "t2m"
  res@gsnCenterString     = str_strip(tostring(f->xtime(nt,:)))
  res@gsnRightString      = nCells + " cells"

  res@pmTickMarkDisplayMode = "Always"   ; Nicer tickmark labels

  map = gsn_csm_map(wks,res)

;---Calculate levels for polygons and labelbar
  min_level = ceil(min(t2m))
  max_level = floor(max(t2m))
  nlevels   = 253
  levels    = fspan(min_level,max_level,nlevels)

;---Calculate colors for polygons and labelbar
  colors  = read_colormap_file("ncl_default")

  map  = attach_labelbar(wks,map,""+levels,colors)
  poly = attach_polygons(wks,map,t2m,latVertex,lonVertex,\
                         verticesOnCell,levels,colors)

  draw(map)
  frame(wks)

;---Print CPU timings
  graphics_end = get_cpu_time()
  print("===> graphics elapsed time  = " + (graphics_end-graphics_start))
  print("===> full code elapsed time = " + (graphics_end-code_start))
end
