; ***********************************************
; wrf_helicity_1.ncl
;
; Concepts illustrated:
;   - Drawing helicity plots from WRF/ARW data
;   - Plotting WRF data
;
;-----------------------------------------------------------------------
; Generate plots of storm-relative helicity.
;
; Reference:
; http://www.ncl.ucar.edu/Document/Functions/Built-in/wrf_helicity.shtml
;-----------------------------------------------------------------------

;-------------------------
; Load generic ncl library
;-------------------------
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"

;---------------------
; Load WRF ncl library
;---------------------
load "$NCARG_ROOT/lib/ncarg/nclscripts/wrf/WRFUserARW.ncl"

;======================================================================
; Main code
;======================================================================
begin

;---------------------
; Open WRF output file
;---------------------
  a = addfile("wrfout.nc","r")

;------------------------------------
; Read variables from WRF output file
;------------------------------------
  ua    = wrf_user_getvar(a,"ua",4)
  va    = wrf_user_getvar(a,"va",4)
  geopt = wrf_user_getvar(a,"geopt",4)
  ter   = wrf_user_getvar(a,"ter",4)

  ua1    = ua(::-1,:,:)
  va1    = va(::-1,:,:)
  geopt1 = geopt(::-1,:,:)

;--------------------------------
; Compute storm-relative helicity
;--------------------------------
  sreh = wrf_helicity(ua1, va1, geopt1, ter, 3000.)

;----------------
; Set plot format
;----------------
; type = "x11"
; type = "pdf"
  type = "ps"

;--------------------------
; Open graphics output file
;--------------------------
  wks = gsn_open_wks(type,"wrf_helicity")

;--------------------------
; Set default color palette
;--------------------------
  gsn_define_colormap(wks, "BlAqGrYeOrRe")

;----------------------------
; Set up some basic resources
;----------------------------
  cnres                      = True

  cnres@MainTitle            = "LEAD REAL-TIME WRF"

;---------------------
; Turn on contour smoothing
;---------------------
  cnres@cnFillOn             = True
  cnres@cnSmoothingOn        = True
  cnres@cnSmoothingDistanceF = .005

; cnres@ContourParameters    = (/ -20., 90., 5./)
; cnres@gsnSpreadColorEnd    = -3  ; End 3rd from the last color in color map

;--------------
; Generate plot
;--------------
  contour = wrf_contour(a,wks,sreh,cnres)

;---------------------
; Map/boundary options
;---------------------
  mpres                             = True
  mpres@mpGeophysicalLineColor      = "Black"
  mpres@mpNationalLineColor         = "Black"
  mpres@mpUSStateLineColor          = "Black"
  mpres@mpGridLineColor             = "Black"
  mpres@mpLimbLineColor             = "Black"
  mpres@mpPerimLineColor            = "Black"
  mpres@mpGeophysicalLineThicknessF = 1.0
  mpres@mpGridLineThicknessF        = 1.0
  mpres@mpLimbLineThicknessF        = 1.0
  mpres@mpNationalLineThicknessF    = 0.5
  mpres@mpUSStateLineThicknessF     = 0.5
  mpres@mpDataResolution            = "FinestResolution"

;---------------------
; Overlay contours on map
;---------------------
  pltres = True
pltres@NoTitles = True
pltres@NoHeaderFooter = True
pltres@InitTime = False
  plot   = wrf_map_overlays(a,wks,(/contour/),pltres,mpres)

end
