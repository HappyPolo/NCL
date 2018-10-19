;=======================================================
; 2dvertcoords_2.ncl
;=======================================================
; Concepts Illustrated:
;   - Creating a pressure-level-by-longitude plot
;   - Reordering array dimensions
;   - Using array subscripting
;   - Using the new color model
;   - Generating cell-fill plots
;
;=======================================================
; This script demonstrates how to create a pressure level by longitude
; plot. Pressure level by time or pressure level by latitude would
; be similar.
;=======================================================
;
; These files are loaded by default in NCL V6.2.0 and newer 
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"

begin
;
; Read the file.
;
  fili  = "./boyle.extract.cam2.h3.1998.nc"
  f     = addfile (fili, "r")  ; open CCSM netCDF file
;
; Pull the necessary variables off the file.
;
  lon   = f->lon
  lat   = f->lat
  time  = f->time

  hyai  = f->hyai                       ; hybrid coef (interface)
  hybi  = f->hybi
  hyam  = f->hyam                       ; hybrid coef (interface)
  hybm  = f->hybm
  klevi = dimsizes(hyai)                ; 27          
  klevm = dimsizes(hyam)                ; 26

                                        ; read subset for test
  PS    = f->PS                         ; sfc pres  (Pa)  
  T     = f->T                          ; temp: hybrid mid-levels
  P0    = f->P0                         ; Pa

                                        ; calculate interface pres
  pi   = pres_hybrid_ccm (PS, P0, hyai, hybi) ; pi(ntim,klevi,nlat,mlon)
;
; Name the dimensions of "pi" and "pm" and assign a coordinate
; variable and some attributes.
;
  pi!0         = "time"
  pi!1         = "lev"
  pi!2         = "lat"
  pi!3         = "lon"
  pi&lat       = lat
  pi@long_name = "interface-level pressures"
  pi@units     = "Pa"
                                        ; calculate mid-level pres
                                        ; pn(ntim,klevm,nlat,mlon)
  pm           = pres_hybrid_ccm (PS, P0, hyam, hybm)
  pm!0         = "time"
  pm!1         = "lev"
  pm!2         = "lat"
  pm!3         = "lon"
  pm&lat       = lat
  pm@long_name = "mid-level pressures"
  pm@units     = "Pa"

;================================================
;
; Create a pressure levels by longitude plot.
; Here we use the 11th timestep at latitude 40N.
; 
; For NCL if one coordinate is 2D they both must be,
; so it is necessary to create a 2D longitude coordinate.
; It will have the same value at all pressure levels.
;
;================================================

  wks   = gsn_open_wks ("png", "2dvertcoords")          ; send graphics to PNG file

;
; These coordinates bound the pressure levels but are centered on the
; latitude.
;
  dims_b   = dimsizes(pi(lev|:,time|10,{lat|40},lon|:))
  lon_b    = conform_dims(dims_b,lon-360,1)
  levels_b = pi(lev|:,time|10,{lat|40},lon|:)

;
; These are cell centered coordinates in both dimensions.
;
  dims_c   = dimsizes(pm(lev|:,time|10,{lat|40},lon|:))
  lon_c    = conform_dims(dims_c,lon-360,1)
  levels_c = pm(lev|:,time|10,{lat|40},lon|:)

;
; The data slice 
;
  slice = T(lev|::,time|10,{lat|40},lon|:)            

;
; Create a cell fill plot. Note that we are using a grid type of 
; "TriangularMesh". This is cheating a little bit, but it provides
; us with tickmarks, and automatically linearizes the plot.
;
  res                       = True
  res@trGridType            = "TriangularMesh"
  res@sfXArray              = lon_b
  res@sfYArray              = levels_b

  res@cnFillOn              = True
  res@cnFillPalette         = "gui_default"
  res@cnCellFillEdgeColor   = 2
  res@cnFillMode            = "CellFill"
  res@cnLinesOn             = False
  res@cnLineLabelsOn        = False
  res@cnMaxLevelCount       = 21
  res@tiMainString          = "Temperature at 40 N Latitude"
  res@trYReverse            = True

  res@lbPerimOn             = False
  
  contour = gsn_csm_contour(wks,slice,res)
end

