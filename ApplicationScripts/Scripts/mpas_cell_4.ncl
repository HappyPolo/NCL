;======================================================================
; mpas_cell_4.ncl
;
; Concepts illustrated:
;   - Drawing cell-filled contours on an  MPAS-O (ocean) grid
;   - Turning on edges for cell-fill
;======================================================================
; For a faster version of this code, see "mpas_4.ncl", which uses
; RasterFill to draw the contours
;======================================================================
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"

begin
  start_cpu_time = get_cpu_time()

  POLAR_MAP = False         ; Whether to draw a polar stereographic map
  ZOOM      = True          ; Whether to zoom (can't use with POLAR_MAP=True)
  EDGES     = False          ; Whether to draw cell edges; more useful if ZOOM or POLAR also True

  if(POLAR_MAP.and.ZOOM) then
    print("You can't set POLAR_MAP and ZOOM both to True.")
    exit
  end if

  if(EDGES.and..not.ZOOM.and..not.POLAR_MAP) then
    print("Warning: this will be a busy plot with a global map and edges turned on.")
  end if

;--Open MPAS-O (ocean) file
  filename = "MPASOcean60km.nc"
  f        = addfile(filename,"r")

;---Read edge and lat/lon information
  RAD2DEG        = get_r2d("float") ; Radian to Degree
  lonCell        = f->lonCell * RAD2DEG
  latCell        = f->latCell * RAD2DEG

  lonVertex      = f->lonVertex * RAD2DEG
  latVertex      = f->latVertex * RAD2DEG
  verticesOnCell = f->verticesOnCell
  nEdgesOnCell   = f->nEdgesOnCell

  dims     = dimsizes(verticesOnCell)
  nCells   = dims(0)
  maxEdges = dims(1)

;
; In order to do a CellFill plot, you need to provide the boundaries
; of each cell.  
;
  latvoc = new((/ nCells, maxEdges /),double)
  lonvoc = new((/ nCells, maxEdges /),double)

  do i = 0, maxEdges - 1
    latvoc(:,i)  = latVertex(verticesOnCell(:,i) - 1)
    lonvoc(:,i)  = lonVertex(verticesOnCell(:,i) - 1)
  end do
  do i = 0, nCells - 1
    latvoc(i, nEdgesOnCell(i):maxEdges-1 ) = latvoc(i,nEdgesOnCell(i)-1)
    lonvoc(i, nEdgesOnCell(i):maxEdges-1 ) = lonvoc(i,nEdgesOnCell(i)-1)
  end do

;---Read data to contour
  ssh = f->ssh(0,:)    ; Only one timestep on file
  printMinMax(ssh,0)

;---levels for contours
  nlevels   = 253
  levels    = fspan(min(ssh),max(ssh),nlevels)

;---Start the graphics
  wtype = "png"
  wtype@wkWidth = 2000
  wtype@wkHeight = 2000
  wks = gsn_open_wks(wtype,"mpas_cell")

  res                       = True
  res@gsnMaximize           = True

  res@mpLandFillColor       = "wheat2"
  res@mpOceanFillColor      = "transparent"   ; no fill
  res@mpInlandWaterFillColor= "transparent"

  res@mpGridAndLimbOn       = False
  res@mpFillDrawOrder       = "PostDraw"

  res@cnFillOn              = True              ; turn on contour fill
  res@cnLinesOn             = False             ; turn off contour lines
  res@cnLineLabelsOn        = False             ; turn off contour labels
  res@cnFillMode            = "CellFill"      ; faster than "AreaFill"
  res@cnLevelSelectionMode  = "ExplicitLevels"
  res@cnLevels              = levels
  res@cnFillPalette         = "NCV_jet"

  res@lbLabelStrings        = sprintf("%5.2f",levels)

  res@lbBoxLinesOn          = False
  if(ZOOM) then
    res@lbOrientation         = "Vertical"
  end if
  res@sfXArray              = lonCell           ; where to overlay contours
  res@sfYArray              = latCell
  res@sfXCellBounds         = lonvoc       ; necessary for CellFill 
  res@sfYCellBounds         = latvoc

  res@tiMainFontHeightF     = 0.018
  if(EDGES) then
    res@cnCellFillEdgeColor   = "black" ; "Gray45"
    res@cnFillOpacityF = 0.75
    res@tiMainString          = filename + " (" + res@cnFillMode + " with edges turned on)"
  else
    res@tiMainString          = filename + " (" + res@cnFillMode + ")"
  end if

  if(POLAR_MAP) then
    res@gsnPolar            = "NH"
    res@mpMinLatF           = 70
  else if(ZOOM) then
    res@mpMinLonF           = -70
    res@mpMaxLonF           =  -5
    res@mpMinLatF           = -10
    res@mpMaxLatF           =  60
    res@pmTickMarkDisplayMode = "Always"   ; better map tickmarks
  end if
  end if
  map = gsn_csm_contour_map(wks,ssh,res)  ; Create the map, don't draw it.

  end_cpu_time = get_cpu_time()
  print("===> CPU elapsed time = " + (end_cpu_time-start_cpu_time))
end


