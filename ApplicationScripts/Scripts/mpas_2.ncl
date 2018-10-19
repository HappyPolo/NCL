;======================================================================
; mpas_2.ncl
;
; Concepts illustrated:
;   - Drawing a subset of an MPAS-O (ocean) grid
;   - Drawing polylines on a map plot
;   - Drawing cylindrical equidistant or polar stereographic maps
;======================================================================
; For a faster version of this code, see "mpas_faster_2.ncl", which
; uses the new resource "gsSegments" to significantly speed up the 
; drawing of polylines.  You need NCL V6.2.0 in order to use this 
; resource.
;======================================================================
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"

begin
  POLAR_MAP = False              ; Whether to draw a polar stereographic map
  RAD2DEG   = get_r2d("double")  ; Radian to Degree

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
  wks = gsn_open_wks("ps","mpas")

  res                       = True
  res@gsnMaximize           = True
  res@gsnFrame              = False

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



;---Code to draw MPAS edge lines on the existing map
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
; Use gsn_polyline here. gsn_add_polyline is extremely slow!
;
; NCL Version 6.2.0 has a faster algorithmfor drawing polylines
; and polygons. See mpas_faster_2.ncl
;
  start_cpu_time = get_cpu_time()
  print("Drawing the polylines...")
  do j=0,nedges-1
     gsn_polyline(wks,map,ecx(j,:),ecy(j,:),lnres)
  end do
  end_cpu_time = get_cpu_time()
  print("CPU elapsed time = " + (end_cpu_time-start_cpu_time))

  frame(wks)
end


