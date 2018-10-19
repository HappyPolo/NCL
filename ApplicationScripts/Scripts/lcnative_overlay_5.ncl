;----------------------------------------------------------------------
; lcnative_overlay_5.ncl
;----------------------------------------------------------------------
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"   
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"   

begin
;---Open file and read in data
  fili  = "ruc2.bgrb.20020418.i12.f00.grb"
  f     = addfile (fili, "r")

  u     = f->U_GRD_252_HTGL
  v     = f->V_GRD_252_HTGL
  vpt   = f->VPTMP_252_HYBL
  lat2d = f->gridlat_252  
  lon2d = f->gridlon_252  

;---This is necessary so that data is overlaid properly on map
  u@lat2d = lat2d  
  u@lon2d = lon2d  
  v@lat2d = lat2d  
  v@lon2d = lon2d  
  vpt@lat2d = lat2d  
  vpt@lon2d = lon2d  

;---Create plot
  wks = gsn_open_wks("x11","lcnative")         ; open a workstation
  gsn_define_colormap(wks,"gui_default")       ; choose colormap

  cnres                   =  True              ; contour/map resources
  vcres                   =  True              ; vector resources

  cnres@gsnDraw           = False              ; Turn these off. We
  cnres@gsnFrame          = False              ; will overlay plots
  vcres@gsnDraw           = False              ; later.
  vcres@gsnFrame          = False
;
; Lambert conformal projections are limited using
; the corners method rather than the latlon method
; seen for cylindrical equidistant projections.
;
  cnres@mpLimitMode       = "Corners"         ; choose range of map
  cnres@mpLeftCornerLatF  = lat2d@corners(0)
  cnres@mpLeftCornerLonF  = lon2d@corners(0)
  cnres@mpRightCornerLatF = lat2d@corners(2)
  cnres@mpRightCornerLonF = lon2d@corners(2)

  cnres@mpProjection          = "LambertConformal"
  cnres@mpLambertParallel1F   = lat2d@mpLambertParallel1F
  cnres@mpLambertParallel2F   = lat2d@mpLambertParallel2F
  cnres@mpLambertMeridianF    = lat2d@mpLambertMeridianF

  cnres@pmTickMarkDisplayMode = "Always"
  cnres@mpFillOn              =  False          ; turn off map fill
  cnres@mpOutlineDrawOrder    = "PostDraw"      ; draw continental outline last
  cnres@mpOutlineBoundarySets = "GeophysicalAndUSStates" ; state boundaries

  cnres@gsnAddCyclic            = False            ; regional data 
  cnres@cnFillOn                = True
  cnres@cnLinesOn               = False           ; turn off contour lines


  vcres@vcRefMagnitudeF          = 10.0             ; define vector ref mag
  vcres@vcRefLengthF             = 0.045            ; define length of vec ref
  vcres@vcGlyphStyle             = "CurlyVector"    ; turn on curly vectors
  vcres@vcMinDistanceF           = 0.017            ; thin vectors
  vcres@vcRefAnnoOrthogonalPosF  = .1               ; move ref vector down
  vcres@gsnAddCyclic             = False            ; regional data 

;---Make sure vector plot doesn't have subtitles
  vcres@gsnLeftString     = ""
  vcres@gsnRightString    = ""

;---Add subtitles to contour plot
  cnres@gsnLeftString     = vpt@long_name + " (" + vpt@units + ")"
  cnres@gsnRightString    = "Wind (" + u@units + ")"

;---Create the two individual plots
  contour_fill_plot = gsn_csm_contour_map(wks,vpt(9,:,:),cnres)
  vector_plot       = gsn_csm_vector(wks,u,v,vcres)

;---Overlay the vectors on the contour/map plot
  overlay(contour_fill_plot,vector_plot)

  draw(contour_fill_plot)    ; This will draw everything
  frame(wks)
end
