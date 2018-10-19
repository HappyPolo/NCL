;*************************************************
; barb_3.ncl
;
; Concepts illustrated:
;   - Drawing colored wind barbs vectors over a cylindrical equidistant map
;   - Changing the length of the wind barbs
;   - Changing the size of the wind barbs
;   - Decreasing the number of vectors drawn
;   - Adding a color to an existing color map
;   - Using the full color map for colored wind barbs
;   - Changing the length of a wind barb tick
;   - Changing the distance between wind barb ticks
;   - Turning off the vector reference annotation label
;   - Drawing a map using the medium resolution map outlines
;   - Thinning vectors using a minimum distance resource
;
;************************************************
;
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl" 
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"    
;************************************************
begin
;************************************************
; read in netCDF file
;************************************************
  a = addfile("83.nc","r")
;************************************************
; read in zonal [u] and meridional [v] winds 
;************************************************
  u = a->U(0,12,:,:) 
  v = a->V(0,12,:,:)   
  t = a->T(0,12,:,:)   
;************************************************
; create plot
;************************************************
  wks = gsn_open_wks("png","barb")                 ; send graphics to PNG file

  res                         = True               ; plot mods desired
  res@lbOrientation           = "vertical"         ; vertical label bar

  res@vcLevelPalette          = "BlAqGrYeOrReVi200" ; set color map
  res@vcRefMagnitudeF         = 10.                ; make vectors larger
  res@vcRefLengthF            = 0.040              ; ref vec length
  res@vcMinDistanceF          = 0.017              ; thin out vectors
  res@vcGlyphStyle            = "WindBarb"         ; choose wind barbs
  res@vcMonoWindBarbColor     = False              ; color barbs by scalar 
  res@vcMinDistanceF          = 0.025              ; thin out windbarbs

  res@vcWindBarbTickLengthF   = 0.4                ; length of the barb tick
  res@vcWindBarbTickSpacingF  = 0.3                ; distance between ticks
  res@vcRefAnnoOn             = False              ; turn off ref wind barb

  res@gsnAddCyclic            = False              ; regional data

; zoom in on map

  minlat                      = 0
  maxlat                      = 25
  minlon                      = 95
  maxlon                      = 115

  res@mpMinLatF               = minlat
  res@mpMaxLatF               = maxlat
  res@mpMinLonF               = minlon
  res@mpMaxLonF               = maxlon

  res@mpDataBaseVersion       = "MediumRes"       ; medium resolution coastline

; if we want the color bar to reflect only those values within our chosen
; subregion, then we need to pass the plot template the subset of the data
; in addition to zooming in on the map.
  plot=gsn_csm_vector_scalar_map_ce(wks,u({minlat:maxlat},{minlon:maxlon}),\
  v({minlat:maxlat},{minlon:maxlon}),t({minlat:maxlat},{minlon:maxlon}),res) 

end
