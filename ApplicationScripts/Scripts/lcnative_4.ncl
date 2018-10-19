;*******************************************************
; lcnative_4.ncl
;*******************************************************
;
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"   
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"   
begin
;************************************************
; open file and read in data
;************************************************
  fili  = "ruc2.bgrb.20020418.i12.f00.grb"
  f     = addfile (fili, "r")

  u     = f->U_GRD_252_HTGL
  v     = f->V_GRD_252_HTGL

  lat2d = f->gridlat_252  
  lon2d = f->gridlon_252  
;************************************************
; create plot
;************************************************
  wks = gsn_open_wks("png","lcnative")      ; send graphics to PNG file
  gsn_define_colormap(wks,"gui_default")    ; choose colormap

  res                   =  True              ; plot mods desired
  res@gsnLeftString     = "Wind"
;************************************************
; lambert conformal projections are limited using
; the corners method rather than the latlon method
; seen for cylindrical equidistant projections
;************************************************
  res@mpLimitMode       = "Corners"         ; choose range of map
  res@mpLeftCornerLatF  = lat2d@corners(0)
  res@mpLeftCornerLonF  = lon2d@corners(0)
  res@mpRightCornerLatF = lat2d@corners(2)
  res@mpRightCornerLonF = lon2d@corners(2)
;************************************************
; native lambert grids read in from grib files are
; different than those read in from netCDF files.
; NCL automatically looks for the parallel and 
; meridian information on the grib file and attaches
; this information as attributes to the lat2d array.
;************************************************
  res@mpProjection          = "LambertConformal"
  res@mpLambertParallel1F   = lon2d@Latin1    ; ncl adds from grib file
  res@mpLambertParallel2F   = lon2d@Latin2    ; ncl adds from grib file
  res@mpLambertMeridianF    = lat2d@Lov       ; ncl adds from grib file

  res@pmTickMarkDisplayMode = "Always"
  res@mpFillOn              =  False          ; turn off map fill
  res@mpOutlineDrawOrder    = "PostDraw"      ; draw continental outline last
  res@mpOutlineBoundarySets = "GeophysicalAndUSStates" ; state boundaries
;****************************************************************************
; usually, when data is placed onto a map, it is TRANSFORMED to the specified
; projection. Since this model is already on a native lambert conformal grid,
; we want to turn OFF the tranformation.
;****************************************************************************
  res@tfDoNDCOverlay = True
;****************************************************************************
  res@gsnAddCyclic            = False            ; regional data 
  res@vcRefMagnitudeF         = 10.0             ; define vector ref mag
  res@vcRefLengthF            = 0.045            ; define length of vec ref
  res@vcGlyphStyle            = "CurlyVector"    ; turn on curly vectors
  res@vcMinDistanceF          = 0.017

  plot = gsn_csm_vector_map(wks,u,v,res)
end
