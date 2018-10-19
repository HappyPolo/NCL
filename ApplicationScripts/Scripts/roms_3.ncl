;***********************************************
; roms_3.ncl
;
; Concepts illustrated:
;   - Plotting ROMS data
;   - Drawing curly vectors
;***********************************************
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"  
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"  
begin
 diri  = "./"
;***********************************************
; the data and the grid info are in two different files
;***********************************************
 grid  = addfile (diri+"Bering_grid_4.nc", "r")

 angle = grid->angle
 dims  = dimsizes(angle)
 Lm    = dims(1)-2
 Mm    = dims(0)-2

 skip  = 3            ; plot every skip vectors in each direction

                      ; only plot interior points, averaged to rho points.
 lat2d = grid->lat_rho(1:Mm:skip,1:Lm:skip)
 lon2d = grid->lon_rho(1:Mm:skip,1:Lm:skip)
 ang2  = angle(1:Mm,1:Lm)

 f    = addfile (diri+"bering_avg_0124.nc", "r")
 u_stag = f->u(0,59,:,:)
 v_stag = f->v(0,59,:,:)
 u_stag = where(ismissing(u_stag), 0.0, u_stag)
 v_stag = where(ismissing(v_stag), 0.0, v_stag)

 u = 0.5*(u_stag(0:Mm-1,1:Lm) + u_stag(1:Mm,1:Lm))
 v = 0.5*(v_stag(1:Mm,0:Lm-1) + v_stag(1:Mm,1:Lm))

 ueast  = u*cos(ang2) - v*sin(ang2)
 vnorth = u*sin(ang2) + v*cos(ang2)

; since roms data has 2D lat/lon coordinates, we need to set these two 
;variables
 ueast@lat2d  = lat2d
 ueast@lon2d  = lon2d
 vnorth@lat2d = lat2d
 vnorth@lon2d = lon2d
;************************************************
; create plot
;************************************************
  wks   = gsn_open_wks ("ps", "roms")            ; open workstation
                                                 ; user defined color map
  cmap = (/(/1., 1., 1./), (/0., 0., 0./), \
	 (/.95,.95,.95/), (/.75,1., 1./), (/.5, 1., 1./), (/.25,1., 1./), \
	 (/0., .85,1./), (/0. ,.76,1./), (/0., .67,1./), (/0. ,.58,1./), \
	 (/0., .38,1./), (/0., 0., 1./), (/0., 0.,.90/), (/0., 0.,.75/), \
	 (/0., 0.,.60/), (/0., 0.,.45/), (/0., 0.,.30/), (/0., 0.,.15/), \
	 (/0., 0., 0./) /)
  ncolors = dimsizes(cmap(:,0)) - 2
  gsn_define_colormap(wks, cmap)

;
; This will not be necessary in V6.1.0 and later. Named colors can
; be used without having to first add them to the color map.
;
 i = NhlNewColor(wks,0.8,0.8,0.8)              ; add gray to colormap 
                                          
 res                       = True              ; plot mods desired
 res@gsnMaximize           = True
 res@gsnSpreadColors       = True              ; use total colormap
 res@gsnSpreadColorEnd     = -3
 res@vcRefMagnitudeF       = 1.                ; add a reference vector
 res@vcRefLengthF          = 0.045             ; what the ref length is
 res@vcMonoLineArrowColor  = False             ; vec's colored by their mag
 res@vcGlyphStyle          = "CurlyVector"     ; turn on curly vectors

 res@pmLabelBarDisplayMode = "Always"          ; Turn on a label bar.
 res@lbPerimOn             = False             ; no box around it

 res@lbLabelStride         = 2                 ; skip every other label
; res@lbLabelAutoStride    = True              ; don't overlap labels

; The following resources are REQUIRED to properly display
; data zoomed on a lambert conformal grid.  
 
 res@mpProjection        = "LambertConformal"
 res@mpLambertParallel1F = grid->PLAT(0)
 res@mpLambertParallel2F = grid->PLAT(1)
 res@mpLambertMeridianF  = 160
; res@mpLambertMeridianF  = grid->PLONG
 
 res@mpLimitMode         = "Corners"             ; choose range of map
 res@mpLeftCornerLatF    = 52.0  
 res@mpLeftCornerLonF    = 180.0 
 res@mpRightCornerLatF   = 58.   
 res@mpRightCornerLonF   = 208.0 

;res@mpDataBaseVersion      = "HighRes"          ; use high resolution coast
 res@mpDataBaseVersion      = "MediumRes"        ; use medium resolution coast
 res@pmTickMarkDisplayMode  = "Always"           ; turn on tickmarks

 plot = gsn_csm_vector_map(wks,ueast(::skip,::skip),vnorth(::skip,::skip),res)     

end
