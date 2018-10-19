;======================================================================
; mpas_4.ncl
;
; Concepts illustrated:
;   - Drawing raster-filled contours on an  MPAS-O (ocean) grid
;======================================================================
; For a "nicer" looking graphics, but slower version of this code, see
; "mpas_cell_4.ncl", which uses CellFill to draw the contours. 
;======================================================================
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"

begin
  start_cpu_time = get_cpu_time()

  POLAR_MAP = False            ; Whether to draw a polar stereographic map
  ZOOM      = False            ; Whether to zoom (can't use with POLAR_MAP=True)
  RAD2DEG   = get_r2d("float") ; Radian to Degree

  if(POLAR_MAP.and.ZOOM) then
    print("You can't set POLAR_MAP and ZOOM both to True.")
    exit
  end if

;--Open MPAS-O (ocean) file
  filename = "MPASOcean60km.nc"
  f        = addfile(filename,"r")

;---Read edge and lat/lon information
  verticesOnEdge = f->verticesOnEdge
  lonCell        = f->lonCell * RAD2DEG
  latCell        = f->latCell * RAD2DEG
  lonVertex      = f->lonVertex * RAD2DEG
  latVertex      = f->latVertex * RAD2DEG

;---Read data to contour
  ssh = f->ssh(0,:)    ; Only one timestep on file
  printMinMax(ssh,0)

;---levels for contours
  nlevels   = 254
  levels    = fspan(min(ssh),max(ssh),nlevels)

;---Start the graphics
  wks = gsn_open_wks("ps","mpas")

  res                       = True
  res@gsnMaximize           = True

  res@mpDataBaseVersion     = "MediumRes"

  res@mpLandFillColor       = "wheat2"
  res@mpOceanFillColor      = "transparent"   ; no fill
  res@mpGridAndLimbOn       = False
  res@mpOutlineOn           = True
  res@mpFillDrawOrder       = "PostDraw"

  res@cnFillOn              = True              ; turn on contour fill
  res@cnLinesOn             = False             ; turn off contour lines
  res@cnLineLabelsOn        = False             ; turn off contour labels
  res@cnFillMode            = "RasterFill"      ; faster than "AreaFill"
  res@cnLevelSelectionMode  = "ExplicitLevels"
  res@cnLevels              = levels
  res@cnFillPalette         = "NCV_jet"

  res@lbBoxLinesOn          = False

  res@sfXArray              = lonCell           ; where to overlay contours
  res@sfYArray              = latCell

  res@tiMainString          = filename + " (" + res@cnFillMode + ")"

  if(POLAR_MAP) then
    res@gsnPolar            = "NH"
    res@mpMinLatF           = 70
  else if(ZOOM) then
    res@mpMinLonF           = -70
    res@mpMaxLonF           =  15
    res@mpMinLatF           =   0
    res@mpMaxLatF           =  60
    res@pmTickMarkDisplayMode = "Always"   ; better map tickmarks
  end if
  end if
  map = gsn_csm_contour_map(wks,ssh,res)  ; Create the map, don't draw it.

  end_cpu_time = get_cpu_time()
  print("===> CPU elapsed time = " + (end_cpu_time-start_cpu_time))
end


