;======================================================================
; mpas_faster_2.ncl
;
; Concepts illustrated:
;   - Drawing a subset of an MPAS-O (ocean) grid
;   - Using special "gsSegments" resource for faster primitive draws
;   - Drawing polylines on a map plot
;   - Drawing cylindrical equidistant or polar stereographic maps
;======================================================================
; This script is identical to mpas_2.ncl, except it uses a resource
; (gsSegments) that is only available in NCL V6.2.0. Use of this
; resource makes the polyline drawing go much faster.
; 
; On a Mac laptop, the "mpas_2.ncl" script took 105.9 CPU seconds,
; while this script took 0.58 CPU seconds.
;======================================================================
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"

begin
  POLAR_MAP = False            ; Whether to draw a polar stereographic map
  RAD2DEG   = get_r2d("float") ; Radian to Degree

;--Open MPAS-O (ocean) file
  filename = "MPASOcean60km.nc"
  f        = addfile(filename,"r")

;---Read edge and lat/lon information
  verticesOnEdge = f->verticesOnEdge
  lonCell        = f->lonCell * RAD2DEG
  latCell        = f->latCell * RAD2DEG
  lonVertex      = f->lonVertex * RAD2DEG
  latVertex      = f->latVertex * RAD2DEG

;---Start the graphics
  wks = gsn_open_wks("ps","mpas_faster")

  res                       = True
  res@gsnMaximize           = True
  res@gsnFrame              = False
  res@gsnDraw               = False

  res@mpDataBaseVersion     = "MediumRes"

  res@mpLandFillColor       = "tan"
  res@mpOceanFillColor      = "transparent"   ; no fill
  res@mpGridAndLimbOn       = False
  res@mpOutlineOn           = True

  res@tiMainString          = filename

  if(POLAR_MAP) then
    res@gsnPolar            = "NH"
    res@mpMinLatF           = 70
    map = gsn_csm_map_polar(wks,res)  ; Create the map, don't draw it.
  else
    res@mpProjection        = "CylindricalEquidistant"
    res@mpMinLonF           = -60
    res@mpMaxLonF           =   0
    res@mpMinLatF           =   0
    res@mpMaxLatF           =  40
    res@pmTickMarkDisplayMode = "Always"   ; better map tickmarks

    map = gsn_csm_map_ce(wks,res)  ; Create the map, don't draw it.
  end if



;---Code to attach MPAS edge lines to the existing map
  lnres                     = True
  lnres@gsLineThicknessF    = 0.10             ; default is 1
  lnres@gsLineColor         = "Navy"           ; default is black.

;---This is the code for the MPAS grid edges
  esizes = getfilevardimsizes(f,"latEdge")
  nedges = esizes(0)
  print("Number of edges = " + nedges)

  ecx = new((/nedges,2/),double)
  ecy = new((/nedges,2/),double)

  ecx(:,0) = lonVertex(verticesOnEdge(:,0)-1)
  ecx(:,1) = lonVertex(verticesOnEdge(:,1)-1)
  ecy(:,0) = latVertex(verticesOnEdge(:,0)-1)
  ecy(:,1) = latVertex(verticesOnEdge(:,1)-1)

  ii0 = ind((abs(ecx(:,0)-ecx(:,1)).gt.180.and.(ecx(:,0).gt.ecx(:,1))))
  ii1 = ind((abs(ecx(:,0)-ecx(:,1)).gt.180.and.(ecx(:,0).lt.ecx(:,1))))
  ecx(ii0,0) = ecx(ii0,0) - 360.0
  ecx(ii1,1) = ecx(ii1,1) - 360.0

;
; Attach the polylines using special "gsSegments" resource. This
; is *much* faster than attaching every line individually.
;
  start_cpu_time = get_cpu_time()

  print("Attaching the polylines...")
  lnres@gsSegments = ispan(0,nedges * 2,2)
  poly = gsn_add_polyline(wks,map,ndtooned(ecx),ndtooned(ecy),lnres)

  draw(map)
  frame(wks)
  end_cpu_time = get_cpu_time()
  print("CPU elapsed time = " + (end_cpu_time-start_cpu_time))
end


