;----------------------------------------------------------------------
; lcnative_5.ncl
;----------------------------------------------------------------------
; This script calls "gsn_csm_vector_scalar_map" to overlay
; vectors on top of filled contours. 
;
; If you want more control over the individual plots, it is better to
; use gsn_csm_contour_map and gsn_csm_vector to create two plots, and
; then overlay them yourself using the "overlay" procedure.
;
; See "lcnative_overlay_5.ncl" for an example of this. 
;----------------------------------------------------------------------
;
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"   
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"   

begin
;---Open file and read in data
  fili  = "ruc2.bgrb.20020418.i12.f00.grb"
  f     = addfile (fili, "r")

  u     = f->U_GRD_252_HTGL
  v     = f->V_GRD_252_HTGL
  vpt   = f->VPTMP_252_HYBL
  lat2d = f->gridlat_252  
  lon2d = f->gridlon_252  

;---Create plot
  wks = gsn_open_wks("png","lcnative")      ; open a workstation

  res                   =  True              ; plot mods desired
  res@gsnLeftString     = "Wind"
;
; Lambert conformal projections are limited using
; the corners method rather than the latlon method
; seen for cylindrical equidistant projections
;
  res@mpLimitMode       = "Corners"         ; choose range of map
  res@mpLeftCornerLatF  = lat2d@corners(0)
  res@mpLeftCornerLonF  = lon2d@corners(0)
  res@mpRightCornerLatF = lat2d@corners(2)
  res@mpRightCornerLonF = lon2d@corners(2)
;
; Native lambert grids read in from grib files are
; different than those read in from netCDF files.
; NCL automatically looks for the parallel and 
; meridian information on the grib file and attaches
; this information as attributes to the lat2d array.
;
  res@mpProjection          = "LambertConformal"
  res@mpLambertParallel1F   = lat2d@mpLambertParallel1F
  res@mpLambertParallel2F   = lat2d@mpLambertParallel2F
  res@mpLambertMeridianF    = lat2d@mpLambertMeridianF

  res@pmTickMarkDisplayMode = "Always"
  res@mpFillOn              =  False          ; turn off map fill
  res@mpOutlineDrawOrder    = "PostDraw"      ; draw continental outline last
  res@mpOutlineBoundarySets = "GeophysicalAndUSStates" ; state boundaries
;
; Usually, when data is placed onto a map, it is TRANSFORMED to the
; specified projection. Since this model is already on a native lambert
; conformal grid, we want to turn OFF the tranformation.
;
  res@tfDoNDCOverlay           = True

  res@gsnAddCyclic             = False            ; regional data 
  res@vcRefMagnitudeF          = 10.0             ; define vector ref mag
  res@vcRefLengthF             = 0.045            ; define length of vec ref
  res@vcGlyphStyle             = "CurlyVector"    ; turn on curly vectors
  res@vcMinDistanceF           = 0.017            ; thin vectors
  res@vcRefAnnoOrthogonalPosF  = .1               ; move ref vector down

  res@gsnScalarContour        = True
  res@cnFillOn                = True
  res@cnFillPalette           = "gui_default"     ; set color map
  res@cnLinesOn               = False             ; turn off contour lines

  plot = gsn_csm_vector_scalar_map(wks,u,v,vpt(9,:,:),res)
end
