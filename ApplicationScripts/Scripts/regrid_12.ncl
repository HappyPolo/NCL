;*************************************************************
; regrid_12.ncl
;
; Concepts illustrated:
;   - Interpolating from a fixed grid to a lower resolution using conservative remapping
;   - Computing dispersion statistics
;   - Drawing a cylindrical equidistant map
;*************************************************************

load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"

begin
;*********************************************
; Read global grid   [180W to 180E]
; ELEV: [LAT | 5401] x [LON | 10801] *includes* cyclic pt
; We do *not* want to read the cyclic point.
;*********************************************

  diri  = "/Users/shea/Data/netCDF/"
  fili  = "ETOPO2_GLOBAL_2_ELEVATION.nc"   ; NGDC
  f     = addfile(diri+fili,"r")
  Z     = short2flt( f->ELEV(:,0:10799) )  ; Do not read the cyclic pt

  printVarSummary(Z)             ; Z: min=-10654   max=8593

;*********************************************
; areal average conservative remapping
;*********************************************
  NLATR = 180
  MLONR = 360

  LATR  = latGlobeFo(NLATR, "LATR", "latitude" , "degrees_north")
  LONR  = lonGlobeFo(MLONR, "LONR", "longitude", "degrees_east")   ; 0-360
  LONR  = (/LONR-180/)    ; -180 to 180
  LONR&LONR = LONR

  ZR    = area_conserve_remap_Wrap (Z&LON,Z&LAT,Z, LONR,LATR, False)  ; 5.2.0
 ;ZR    = area_hi2lores_Wrap (Z&LON,Z&LAT,Z, True, 1.0, LONR,LATR, False)  ; 5.1.0

  ZR@long_name = ZR@long_name +": 1x1 grid"
  printVarSummary(ZR)            ; ZR (1x1): min=-10439.7   max=5713.99

;*********************************************
; Calculate assorted statistics and print
; stat_dispersion is a bit slow for *large* variables
;*********************************************
  opt    = True
  opt@PrintStat = True
 ;statZ  = stat_dispersion(Z , opt )    ; bit slow (5401,10800)
  statZR = stat_dispersion(ZR, opt )

;*********************************************
; Plot
;*********************************************

  wks = gsn_open_wks ("ps", "regrid")
  gsn_define_colormap(wks, "BlAqGrYeOrReVi200")

  setvalues NhlGetWorkspaceObjectId()
    "wsMaximumSize": 500000000
  end setvalues

  res                             = True
  res@gsnMaximize                 = True
  res@gsnAddCyclic                = False  ; dataset allready has cyclic pt
  res@gsnSpreadColors             = True

  res@cnFillMode                  = "RasterFill" 
  res@cnLinesOn                   = False  ; Turn off contour lines
  res@cnFillOn                    = True   ; Turn on contour fill

  res@cnLevelSelectionMode        = "ManualLevels" ; set manual contour levels
  res@cnMinLevelValF              = -5000              ; set min contour level
  res@cnMaxLevelValF              =  5000              ; set max contour level
  res@cnLevelSpacingF             =   500

  res@lbLabelAutoStride           = True

  res@mpCenterLonF                = 0
  res@mpOutlineOn                 = True
  res@mpFillOn                    = False

  plot = gsn_csm_contour_map_ce(wks,Z , res)
  plot = gsn_csm_contour_map_ce(wks,ZR, res)
end
