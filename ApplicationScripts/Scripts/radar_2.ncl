;***********************************************
; radar_2.ncl
;
; Concepts illustrated:
;   - Reading CF radial data
;   - Plotting radar (r,theta) data
;   - Adding shading or color fill to areas on a contour plot with missing data
;   - Drawing raster contours
;   - Drawing cell-filled contours
;   - Using triangular meshes to create contours
;   - Applying scale and offset attributes to radar data
;***********************************************
;
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"

begin
  dir = "./"
  f  = addfile(dir + "cfrad.20080604_002217.nc","r")

;---To see a list of all the variables on the file
  print(getfilevarnames(f))

;
; The "DBZ" variable on the file looks like this:
;
;      short DBZ ( time, range )
;         long_name :    Computed Horizontal Co-polar Reflectivit
;         standard_name :        equivalent_reflectivity_factor
;         units :        dBZ
;         threshold_field_name : 
;         threshold_value :         0
;         sampling_ratio :          1
;         _FillValue :   -32768
;         scale_factor : 0.001776635
;         add_offset :   0.07500076
;         grid_mapping : grid_mapping
;         coordinates :  time range
  dbz          = short2flt(f->DBZ)
  dsizes       = dimsizes(dbz)
  dbz@long_name = dbz@long_name + "y" ; "Reflectivity" was missing the "y" on the file
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
  angles       = f->azimuth
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
  angles2d = conform(dbz,angles,0)
  x2d      = conform(dbz,x,1)
  xarr     =  xcenter + x2d  * cos(DEGTORAD * angles2d)
  yarr     =  ycenter + x2d  * sin(DEGTORAD * angles2d)

  wks = gsn_open_wks("png","radar")           ; send graphics to PNG file

  cnres                   = True
  cnres@gsnMaximize       = True
  cnres@sfXArray          = xarr
  cnres@sfYArray          = yarr
  cnres@cnFillOn          = True
  cnres@cnFillPalette     = "rainbow"         ; set color map
  cnres@cnLinesOn         = False
  cnres@cnFillMode        = "RasterFill"      ; this mode is fastest
  cnres@trGridType        = "TriangularMesh"

  contour = gsn_csm_contour(wks,dbz,cnres)

end

