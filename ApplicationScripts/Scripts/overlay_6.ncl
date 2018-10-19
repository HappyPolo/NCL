;----------------------------------------------------------------------
; overlay_6.ncl
;
; Concepts illustrated:
;   - Overlaying shaded contours on filled contours
;   - Filling contours with multiple shaded patterns
;   - Overlaying vectors on filled contours
;   - Using the "palette" resources to assign a color palette to color vectors and contours
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

;---Read variables off the file and do some conversions.
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

  wks = gsn_open_wks("png","overlay")

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
  vcres@vcLevelPalette           = "amwg_blueyellowred"   ; assign color map to vectors

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
  vcres@lbLabelAutoStride        = True

;---Make sure vectors are drawn in "predraw" phase.
  vcres@vcVectorDrawOrder        = "Predraw"

;---Turn on contour fill, and turn other things off.
  cnres@cnFillOn             = True
  cnres@cnLinesOn            = False
  cnres@cnInfoLabelOn        = False
  cnres@cnFillPalette        = "StepSeq25"
  cnres@lbOrientation        = "Vertical"
  cnres@lbTitleString        = "Sea Level Pressure"
  cnres@lbTitlePosition      = "Left"
  cnres@lbTitleFontHeightF   = 0.02
  cnres@lbLabelFontHeightF   = 0.015

;---Define contour levels
  cnres@cnLevelSelectionMode = "ManualLevels"
  cnres@cnMinLevelValF       = 980.0
  cnres@cnMaxLevelValF       = 1040.0
  cnres@cnLevelSpacingF      = 5.0

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
  mpres@mpOceanFillColor       = "lightskyblue1"
  mpres@mpLandFillColor        = "gray"

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
end
