;***********************************************
; radar_1.ncl
;
; Concepts illustrated:
;   - Plotting radar (r,theta) data
;   - Adding shading or color fill to areas on a contour plot with missing data
;   - Drawing raster contours
;   - Drawing cell-filled contours
;   - Using triangular meshes to create contours
;***********************************************
;
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"

begin
  f            = addfile("dz.nc","r")
;
; The "DZ" variable on the file looks like this:
;
;      short DZ ( Time, maxCells )
;         long_name :    Reflectivity factor
;         variable_type :        data
;         units :        DBZ
;         scale_factor : 0.01
;         add_offset :    0
;         missing_value :        -32768
;         _FillValue :   -32768
;         polarization : Horizontal
;         Frequencies_GHz :      -999
;         InterPulsePeriods_secs :       0.003108816919848323
;         num_segments : 1
;         cells_in_segment :     960
;         meters_to_first_cell : -375
;         meters_between_cells : 250
;
  dz           = f->DZ
  dsizes       = dimsizes(dz)

; 
; The "Azimuth" variable looks like this:
;
;     float Azimuth ( Time )
;         long_name :    Earth relative azimuth of the ray
;         Comment :      Degrees clockwise from true North
;         units :        degrees
;         valid_range :  ( -360, 360 )
;         missing_value :        -32768
;         _FillValue :   -32768
;
  angles       = f->Azimuth
  angles(0:63) = angles(0:63)-360     ; fix to make angles monotonic

  DEGTORAD = 0.017453292519943
  xcenter  = 0.0
  ycenter  = 0.0
  radius   = 960 * 0.25 ; this is radius in kilometers

;
; Create 2D coordinate arrays.
;
  inc      = radius / (dsizes(1) - 1)
  x        = inc * ispan(0,dsizes(1)-1,1) 
  angles2d = conform(dz,angles,0)
  x2d      = conform(dz,x,1)
  xarr     =  xcenter + x2d  * cos(DEGTORAD * angles2d)
  yarr     =  ycenter + x2d  * sin(DEGTORAD * angles2d)

  wks = gsn_open_wks("png","radar")           ; send graphics to PNG file

  cnres                   = True
  cnres@gsnMaximize       = True
  cnres@sfXArray          = xarr
  cnres@sfYArray          = yarr
  cnres@cnFillOn          = True
  cnres@cnFillPalette     = "gui_default"     ; set color map
  cnres@cnLinesOn         = False
  cnres@cnFillMode        = "RasterFill"      ; this mode is fastest
  cnres@trGridType        = "TriangularMesh"
  contour = gsn_csm_contour(wks,dz,cnres)

; The CellFill mode is slower but draws more outlying data
; and lets you fill in the missing value arrays, giving a good
; sense of the circular extent of the plot.

  cnres@cnFillMode            =  "CellFill"
;
; This will not be necessary in V6.1.0 and later. Named colors can
; be used without having to first add them to the color map.
;
  cnres@cnMissingValFillColor = "gray"

  contour = gsn_csm_contour(wks,dz,cnres)
end

