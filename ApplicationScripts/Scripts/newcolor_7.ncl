;----------------------------------------------------------------------
; newcolor_7.ncl
;
; Concepts illustrated:
;   - Showing features of the new color display model
;   - Using opacity to emphasize or subdue overlain features
;   - Using cnFillPalette to assign a color palette to contours
;   - Using vcLevelPalette to assign a color palette to vectors
;   - Maximizing plots after they've been created
;----------------------------------------------------------------------
; Adapted from example "overlay_6.ncl" to illustrate use of the new 
; color model.
;
; This example recreates original plot from overlay_6.ncl, using 
; independent colormaps for contours and vectors, and direct 
; colors for the base map.
;
; It draws two additional plots, illustrating the use of opacity
; to emphasize or subdue overlain features.
;
; Statements from the original overlay_6.ncl that use older, 
; workstation-centric color are commented out with the prefix
; ";WKSCOLOR:", but otherwise left in the script for 
; comparing legacy and new ways of using color.
;----------------------------------------------------------------------
; Important note: in NCL V6.3.0 and earlier, there's a bug in which the
; colors in the labelbar do not correctly reflect the opacity applied
; to the filled contours.  This bug has been fixed in NCL V6.4.0.
; Set res@lbOverrideFillOpacity = True if you don't want the labelbar
; colors to have the opacity applied.
;----------------------------------------------------------------------
;
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"

begin
;---Open some netCDF files.
  dir   = ncargpath("data") + "/cdf/"
  uf    = addfile(dir + "Ustorm.cdf","r")
  vf    = addfile(dir + "Vstorm.cdf","r")
  pf    = addfile(dir + "Pstorm.cdf","r")
  tf    = addfile(dir + "Tstorm.cdf","r")
  u500f = addfile(dir + "U500storm.cdf","r")
  v500f = addfile(dir + "V500storm.cdf","r")
  
;--Read variables off the file and do some conversions.
  p    = pf->p
  t    = tf->t
  u    = uf->u
  v    = vf->v
  u500 = u500f->u
  v500 = v500f->v
  time = vf->timestep

;---Convert to different units
  p    = (/p/100.0/)
  t    = ((/t/) - 273.15) * 9.0/5.0 +32.0

  title = "January 1996 Snow Storm~C~    " + vf->reftime + " + " + time(0)

  wks = gsn_open_wks("png","newcolor") ; send graphics to PNG file
  ;WKSCOLOR:  gsn_merge_colormaps(wks,"amwg_blueyellowred","StepSeq25")
  ;WKSCOLOR:  newcolor = NhlNewColor(wks,0.70,0.70,0.70)   ; add gray70 to colormap

; 
; Set up some variables to hold various resource lists.  Turn
; off draw and frame for all plots, because we are going to do
; some overlays later and then we'll draw everything.
;
  vcres           = True
  vcres@gsnDraw   = False
  vcres@gsnFrame  = False
  stres           = vcres
  cnres           = vcres
  mpres           = vcres

;---Set up some vector resources.
  vcres@vcLevelSelectionMode     = "ManualLevels"
  vcres@vcMinLevelValF           = -20.0
  vcres@vcMaxLevelValF           =  100.0
  vcres@vcLevelSpacingF          = 10.0    ; 20.
  ;WKSCOLOR:  vcres@gsnSpreadColors = True
  ;WKSCOLOR:  vcres@gsnSpreadColorEnd = 17

;---Span a given color map for the vector colors.
  vcres@vcLevelPalette           = "amwg_blueyellowred"

;---Vector lengths and color
  vcres@vcFillArrowsOn           = True
  vcres@vcLineArrowThicknessF    =  2.0

  vcres@vcMinFracLengthF         = 0.33
  vcres@vcMinMagnitudeF          = 0.001
  vcres@vcMonoFillArrowFillColor = False
  vcres@vcMonoLineArrowColor     = False

  vcres@vcRefLengthF             = 0.045
  vcres@vcRefMagnitudeF          = 20.0
  vcres@vcRefAnnoOrthogonalPosF  = -0.12
  vcres@vcRefAnnoParallelPosF    =  0.997
  vcres@vcRefAnnoFontHeightF     = 0.015

  vcres@lbTitleString            = "Surface Temperature"
  vcres@lbTitleOffsetF           = -0.25
  vcres@lbTitleFontHeightF       = 0.02
  vcres@lbLabelFontHeightF       = 0.015

;---Make sure vectors are drawn in "predraw" phase.
  vcres@vcVectorDrawOrder        = "Predraw"
;
; Set up some contour resources.
;
; Turn on contour fill, and turn other things off.
;
  cnres@cnFillOn             = True
  cnres@cnLinesOn            = False
  cnres@cnInfoLabelOn        = False
  cnres@lbOrientation        = "Vertical"
  cnres@lbTitleString        = "Sea Level Pressure"
  cnres@lbTitlePosition      = "Left"
  cnres@lbTitleFontHeightF   = 0.02
  cnres@lbLabelFontHeightF   = 0.015

;---Define contour levels and their colors.
  cnres@cnLevelSelectionMode = "ManualLevels"
  cnres@cnMinLevelValF       = 980.0
  cnres@cnMaxLevelValF       = 1040.0
  cnres@cnLevelSpacingF      = 5.0
  ;WKSCOLOR:  cnres@gsnSpreadColors = True
  ;WKSCOLOR:  cnres@gsnSpreadColorStart = 18
  ;WKSCOLOR:  cnres@gsnSpreadColorEnd = 42

;---Span a given color map for the vector colors.
  cnres@cnFillPalette = "StepSeq25"
  
;---Make sure contours are drawn in "predraw" phase.
  cnres@cnFillDrawOrder      = "Predraw"

;---Control appearance of map.
  mpres@mpProjection           = "LambertEqualArea"
  mpres@mpLabelsOn             = False
  mpres@mpPerimOn              = True
  mpres@mpGridAndLimbOn        = False
  mpres@mpFillOn               = True
  mpres@mpOutlineOn            = True
  mpres@mpOutlineDrawOrder     = "PostDraw"
  mpres@mpFillDrawOrder        = "Predraw"
  ;WKSCOLOR:  mpres@mpOceanFillColor       = 9
  ;WKSCOLOR:  mpres@mpLandFillColor        = 43
  ; Specify colors directly, rather than relative to some colormap...
  mpres@mpOceanFillColor       = (/ 0.824, 0.961, 1.0 /)
  mpres@mpLandFillColor        = (/ 0.7, 0.7, 0.7 /)

;---Zoom in on area that is roughly the United States.
  mpres@mpLimitMode            = "LatLon"
  mpres@mpMinLatF              =   18.
  mpres@mpMaxLatF              =   65.
  mpres@mpMinLonF              = -128.
  mpres@mpMaxLonF              =  -58.
  mpres@mpCenterLonF           = -100.0
  mpres@mpCenterLatF           = 40.0

  mpres@mpGridAndLimbDrawOrder = "Predraw"
  mpres@tiMainString           = title
;
; Create, but don't draw, a vector, streamline, contour
; and map plot. Stride the vector and contour data to
; thin it a little.
;
  vcid = gsn_csm_vector_scalar(wks,u(0,::2,::2),v(0,::2,::2), \
                                   t(0,::2,::2),vcres)
  stid = gsn_csm_streamline(wks,u500(0,:,:),v500(0,:,:),stres)
  cnid = gsn_csm_contour(wks,p(0,::2,::2),cnres)
  mpid = gsn_csm_map(wks,mpres)

;---Overlay contour, streamline, and vector plots on the map plot.
  overlay(mpid,cnid)
  overlay(mpid,stid)
  overlay(mpid,vcid)
;  draw(mpid)
;  frame(wks)

  maximize_output(wks,True)

; -----------------------------------------------------------
; Redraw the map, applying translucency to contour colors...
;
  cnres@cnFillOpacityF = 0.5

  vcid = gsn_csm_vector_scalar(wks,u(0,::2,::2),v(0,::2,::2), \
                                   t(0,::2,::2),vcres)
  stid = gsn_csm_streamline(wks,u500(0,:,:),v500(0,:,:),stres)
  cnid = gsn_csm_contour(wks,p(0,::2,::2),cnres)
  mpid = gsn_csm_map(wks,mpres)
  overlay(mpid,cnid)
  overlay(mpid,stid)
  overlay(mpid,vcid)
;  draw(mpid)
;  frame(wks)
  maximize_output(wks,True)

; -----------------------------------------------------------
; Redraw again, also muting streamline color...
;
  stres@stLineOpacityF = 0.5

  vcid = gsn_csm_vector_scalar(wks,u(0,::2,::2),v(0,::2,::2), \
                                   t(0,::2,::2),vcres)
  stid = gsn_csm_streamline(wks,u500(0,:,:),v500(0,:,:),stres)
  cnid = gsn_csm_contour(wks,p(0,::2,::2),cnres)
  mpid = gsn_csm_map(wks,mpres)
  overlay(mpid,cnid)
  overlay(mpid,stid)
  overlay(mpid,vcid)
;  draw(mpid)
;  frame(wks)
  maximize_output(wks,True)
end
