;======================================================================
; datagrid_8.ncl
;
; Concepts illustrated:
;   - Drawing unstructured mesh using gsn_coordinates
;   - Drawing the outline of MPAS lat/lon vertices
;======================================================================

;======================================================================
; This procedure prints the elapsed time.
;======================================================================
undef("print_elapsed_time")
procedure print_elapsed_time(stime,title)
local diff_time
begin
  diff_time = get_cpu_time() - stime
  print("=====> CPU Elapsed Time: " + title + ": " + diff_time + \
        " seconds <=====")
end

;======================================================================
; Function to draw hexagonal structure. This example is doing the 
; MPAS hexagonal structure.
;
; Things you need to know:
;
;  - Is each cell polygon closed? The data in this particular
;    example isn't, which means we have to add a closed point.
;    You have to set close_polygons=True to force the closed point
;    to be added.
;
;  - Do we have to provide vertices for the lat/lon, or is the
;    lat/lon already provided? I.e. in this example, we have to
;    provide a 1D array of lat/lon values, and then a separate
;    2D array of indices into that 1D array that provide the 
;    polygon outlines.
;
;  - Are the vertices provided 0-base or 1-based?  That is, do
;    they go from 1 to ncells or 0 to ncells-1?  If the former,
;    then you need to set "one_based" to True.
;======================================================================
undef("attach_polylines")
function attach_polylines(wks,map,latvert[*]:numeric,lonvert[*]:numeric,\
                          vertices[*][*],nedges[*],\
                          minlat,maxlat,minlon,maxlon)
local dims, ncells, max_edges, latvoc, lonvoc, i, line_segments
begin
;
; To plot mesh data, there's a 1D array of lat/lon values (ncells), 
; and a 2D array of vertices (ncells x max_edges) containing vertices
; into the 1D array. To plot this data using gsSegments, we need to 
; create a 2D array of lat/lon values (ncells x nedges). There are a 
; few considerations that need to be taken into account:
;
;   - the number of vertices can be variable for each cell
;   - the polygon may not be closed, so an additional point may
;      need to be added
;   - the indexes of the vertices may be 0-based or 1-based
;
  one_based      = True  ; whether index values are 0-based or 1-based
  close_polygons = True  ; whether we need to add an extra point to close 
                         ; each polygon
  debug      = True  ; this will do some extra debugging

  dims      = dimsizes(vertices)
  ncells    = dims(0)
  max_edges = dims(1)

  if(debug) then
    print("==================================================")
    print("attach_polylines:")
    print("  Data has " + ncells + " cells and a maximum of " +  \
          max_edges + " edges.")
    print("  min/max lat = " + min(latvert) + "/" + max(latvert))
    print("  min/max lon = " + min(lonvert) + "/" + max(lonvert))
    print("  The selected min/max lat/lon = " + \
          minlat + "/" + maxlat + ", " + minlon + "/" + maxlon)
    min_vertices = min(vertices)
    max_vertices = max(vertices)
    print("  The min/max vertices are " + min_vertices + "/" + max_vertices)
    if(min_vertices.eq.1.and.max_vertices.eq.ncells)  then
      print("  Since the min/max vertices are 1/" + ncells + ", ")
      print("  this means you likely have 1-based indexes.")
      if(one_based) then
        print("  'one_based' is set to True, so you should be good there.")
      else
        print("  'one_based' is NOT set to True, so you may have a problem.")
      end if  
    end if
  end if

;---If you have n edges, then you have n+1 vertices
  if(close_polygons) then
    total_edges = max_edges+1
  else
    total_edges = max_edges
  end if
  latlon_start_time = get_cpu_time()
  ii = new(ncells,typeof(ncells))
  if(one_based) then
    do i=0,ncells-1
      if(any(latvert(vertices(i,:)-1).ge.minlat.and.\
             latvert(vertices(i,:)-1).le.maxlat.and.\
             lonvert(vertices(i,:)-1).ge.minlon.and.\
             lonvert(vertices(i,:)-1).le.maxlon)) then
        ii(i) = i
      end if
    end do
  else
    do i=0,ncells-1
      if(any(latvert(vertices(i,:)).ge.minlat.and.\
             latvert(vertices(i,:)).le.maxlat.and.\
             lonvert(vertices(i,:)).ge.minlon.and.\
             lonvert(vertices(i,:)).le.maxlon)) then
        ii(i) = i
      end if
    end do
  end if

  if(all(ismissing(ii))) then
    print("attach_polylines: Error: couldn't find any values inside")
    print("  the lat/lon range you provided: ")
    print("  " + minlat + "/" + maxlat + ", " + minlon + "/" + maxlon)
    print("  Won't add any polylines.")
    return(new(1,graphic))
  end if

  ii_nomsg = ii(ind(.not.ismissing(ii)))
  ncells = dimsizes(ii_nomsg)    ; recalculate ncells

  if(debug) then
    print("  The number of values inside the min/max lat/lon range is " + \
          ncells)
  end if
  latvoc  = new((/ncells,total_edges/),typeof(latvert))
  lonvoc  = new((/ncells,total_edges/),typeof(lonvert))
  nedges2 = nedges(ii_nomsg)
  if(one_based) then
    do i = 0,max_edges-1
      latvoc(:,i) = latvert(vertices(ii_nomsg,i)-1)
      lonvoc(:,i) = lonvert(vertices(ii_nomsg,i)-1)
    end do
  else
    do i = 0,max_edges-1
      latvoc(:,i) = latvert(vertices(ii_nomsg,i))
      lonvoc(:,i) = lonvert(vertices(ii_nomsg,i))
    end do
  end if

  if(close_polygons) then
    do i = 0,ncells-1
      latvoc(i,nedges2(i)) = latvoc(i,0)
      lonvoc(i,nedges2(i)) = lonvoc(i,0)
    end do
  end if
  print_elapsed_time(latlon_start_time,"Putting values into lat/lonvoc")
  line_segments = ispan(0,ncells*total_edges,total_edges)

;---Resource list for polylines
  addlines_start_time = get_cpu_time()
  gsres                  = True
  gsres@gsLineColor      = "NavyBlue"
  gsres@gsLineThicknessF = 2.0
  gsres@gsSegments       = line_segments

  print("===> Attaching the polylines...")
  polyline = gsn_add_polyline(wks,map,ndtooned(lonvoc),ndtooned(latvoc),gsres)

;;  latvoc_avg = dim_avg_n(latvoc,1)
;;  lonvoc_avg = dim_avg_n(lonvoc,1)
;;
;;  txres = True
;;  txres@txFontHeightF = 0.01
;;  text = gsn_add_text(wks,map,""+ii_nomsg,lonvoc_avg,latvoc_avg,txres)
;;
;;  txres@txFontHeightF = 0.015
;;  do i = 0,ncells-1
;;    if(.not.any(ii_nomsg(i).eq.(/120541,489476,1060869/))) then
;;      continue
;;    end if
;;    print("==================================================")
;;    print("          " + ii_nomsg(i))
;;    print("  # edges " + nedges2(i))
;;    do n=0,nedges2(i)
;;      print(n + ": " + latvoc(i,n) + "/" + lonvoc(i,n))
;;    end do
;;    map@$unique_string("text")$ = gsn_add_text(wks,map,""+ispan(0,nedges2(i),1),lonvoc(i,:),latvoc(i,:),txres)
;;    
;;  end do
  print_elapsed_time(addlines_start_time,"Adding polylines to map")
  return(polyline)
end

;======================================================================
; Main code
;======================================================================
begin
  code_start_time = get_cpu_time() 

;---Open MPAS file
  read_start_time = get_cpu_time()
  mpas_file = "x1.2621442.output.2010-10-23_00.00.00.nc"
  f         = addfile(mpas_file,"r")

;---Read a timestep of "t2m" 
  nt          = 3                   ; nt=0 is a constant field for t2m

;---Read lat/lon and convert to degrees
  RAD2DEG        = get_r2d("double")     ; Radian to Degree
  lonCell        = f->lonCell * RAD2DEG
  latCell        = f->latCell * RAD2DEG
  lonVertex      = f->lonVertex * RAD2DEG
  latVertex      = f->latVertex * RAD2DEG

  printMinMax(latCell,0)
  printMinMax(lonCell,0)
  printMinMax(latVertex,0)
  printMinMax(lonVertex,0)

;---Read other info needed from file.
  verticesOnEdge = f->verticesOnEdge
  verticesOnCell = f->verticesOnCell
  nEdgesOnCell   = f->nEdgesOnCell

  print_elapsed_time(read_start_time,"Reading data")

  dims     = dimsizes(verticesOnCell)
  ncells   = dims(0)
  max_edges = dims(1)

;---Debug prints
  ncells = dimsizes(latCell)

;---Start the graphics
  graphics_start_time = get_cpu_time()

;---Open PNG file to write graphics to. PS file will be too large
  wks = gsn_open_wks("png","datagrid_minmax")

;---Settings for graphics options
  res                     = True              ; Plot modes desired.

  res@gsnMaximize         = True              ; Maximize plot
  res@gsnDraw             = False
  res@gsnFrame            = False

  res@mpFillOn            = False

;---Various titles
  res@tiMainString          = "MPAS mesh"  ; mpas_file
  res@pmTickMarkDisplayMode = "Always"   ; Nicer tickmark labels

  minlat             =   39.5
  maxlat             =   40.1  ; 40.5
  minlon             = -105.5
  maxlon             = -105.0  ;  -104.5

  res@mpLimitMode           = "LatLon"
  res@mpMinLatF             = minlat
  res@mpMaxLatF             = maxlat
  res@mpMinLonF             = minlon
  res@mpMaxLonF             = maxlon

  res@mpOutlineBoundarySets = "AllBoundaries"
  res@mpDataBaseVersion     = "MediumRes"
  res@mpDataSetName         = "Earth..4"

  map = gsn_csm_map(wks,res)
  poly = attach_polylines(wks,map,latVertex,lonVertex,\
                          verticesOnCell,nEdgesOnCell,\
                          minlat,maxlat,minlon,maxlon)
  draw(map)
  frame(wks)

;---Print CPU timings
  print_elapsed_time(graphics_start_time,"Total graphics")
  print_elapsed_time(code_start_time,"datgarid_8.ncl")
end
