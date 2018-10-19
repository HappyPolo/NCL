;*******************************************************
; lcnative_2.ncl
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

  vpt   = f->VPTMP_252_HYBL     
  lat2d     = f->gridlat_252  
  lon2d     = f->gridlon_252  

;************************************************
; create plot
;************************************************
  wks = gsn_open_wks("png","lcnative")      ; send graphics to PNG file

  res                   = True              ; plot mods desired
  res@tiMainString      = "Native Lambert Conformal"
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
  res@mpLambertParallel1F   = lat2d@mpLambertParallel1F
  res@mpLambertParallel2F   = lat2d@mpLambertParallel2F
  res@mpLambertMeridianF    = lat2d@Lov       ; ncl adds from grib file

  res@pmTickMarkDisplayMode = "Always"
  res@mpFillOn              = False           ; turn off map fill
  res@mpOutlineDrawOrder    = "PostDraw"      ; draw continental outline last
  res@mpOutlineBoundarySets = "GeophysicalAndUSStates" ; state boundaries
;****************************************************************************
; usually, when data is placed onto a map, it is TRANSFORMED to the specified
; projection. Since this model is already on a native lambert conformal grid,
; we want to turn OFF the tranformation.
;****************************************************************************
  res@tfDoNDCOverlay = True
;****************************************************************************
  res@cnFillOn              = True            ; color plot desired
  res@cnLinesOn             = False           ; turn off contour lines
  res@cnFillPalette         = "gui_default"   ; set color map
  res@gsnAddCyclic          = False           ; regional data 

  plot = gsn_csm_contour_map(wks,vpt(9,:,:),res)
end
