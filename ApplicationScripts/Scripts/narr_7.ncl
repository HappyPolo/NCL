;***************************************************************************
; narr_7.ncl
;***************************************************************************
; Concepts illustrated:
;   - Plotting a cross section
;   - Calculating a vertical interpolation on a curvilinear grid
;   - Regridding data from a rectilinear to curvilinear grid
;***************************************************************************
; [1] Objective: Determine values at user specified locations and heights
; [2] Read two variables from a NARR Grib file: HGT and TMP
; [3] Create a function that will perform 3 tasks:
;     (a) perform a vertical interpolation on the NARR grid 
;     (b) use the weight file created in ESMF Example 30
;         to regrid to a rectilinear grid
;     (c) Interpolate to a user specified suite of locations
; [4] Print the interpolated information
;**************************************************************

load "$NCARG_ROOT/lib/ncarg/nclscripts/esmf/ESMF_regridding.ncl"

undef("narr_to_points")
function narr_to_points (narrWgtPath[1]:string, narrHgt:numeric, narrVar:numeric \
                        ,hgt[*]:numeric, dimh[1]:integer,latPoints[*]:numeric, lonPoints[*]:numeric)
;
; Input:
; narrWgtPath - full path to ESMF weight file 
; narrVar     - NARR variable to be interpolated
; narrHgt     - NARR  geopotential variable
; hgt         - height levels *to which* variable will be interpolated
; dimh        - dimension # of 'narrVar' on which to interpolate
; {lat/lon}Points - locations
;
local varHeight, var_regrid, LONPTS, var_points
begin
 ;print(narrHgt(0,:,100,100)+"  "+narrVar(0,:,100,100))         ; arbitrary grid point
;
;-[1] Vertically interpolate. Still on NARR lat/lon grid
;
  VarHgt     = int2p_n_Wrap(narrHgt, narrVar, hgt, 1, dimh)
  VarHgt!1   = "hgt"
 ;printVarSummary(VarHgt)
 ;print(hgt+"   "+VarHgt(0,:,100,100))                          ; after vertical interpolation
;
;-[2] Interpolate to a rectilinear grid using existing weight file
;     This returns lon=[150..358.5] because the original weight file returned this orientation.
;
  var_regrid = ESMF_regrid_with_weights(VarHgt,narrWgtPath,False)
;
;-[3] Interpolate  user specified locations on the rectilinear grid
;     Handle the NARR -180 to 180 and the CESM 0 to 360
;
  LONPTS     = where(lonPoints.lt.0, lonPoints+360, lonPoints)  ; local 'work' variable
  var_points = linint2_points_Wrap(var_regrid&lon, var_regrid&lat, var_regrid, False \
                                  ,LONPTS, latPoints, 0)
  var_points@xcoord = where(var_points@xcoord.gt.180, var_points@xcoord-360, var_points@xcoord)
  return(var_points)
end
;============================================================
; NCL_TALK question:
; How can I interpolate NARR data to particular points in space (lat, lon, height). 
;============================================================
;                     MAIN
;============================================================

;---Specify locations and height(s)
  latPts   = (/  22.3,  47.8/)
  lonPts   = (/-135.3, 157.2/)
  hgt      = (/ 375, 1340, 1865 /)

;---ESMF File settings
  dir_esmf = "./"
  fil_esmf = "NARR_to_Rect.WgtFile_bilinear.nc"   ; 0.25 x 0.25   [150
  pth_esmf = dir_esmf + fil_esmf 

;---File settings

  setfileoption("grb","SingleElementDimensions","Initial_time") ; force time dimension

  dir_narr = "/Users/shea/Data/NARR/"
  fil_narr = "narr-a_221_20110508_0000_000.grb"
  pth_narr = dir_narr + fil_narr 
  f_narr   = addfile(pth_narr, "r")

;---Read variables
  h_narr   = f_narr->HGT_221_ISBL   ;          0               1            2          3
  x_narr   = f_narr->TMP_221_ISBL   ; ( initial_time0_hours, lv_ISBL4, gridx_221, gridy_221 )

 ;lat2d    = f_narr->gridlat_221
 ;lon2d    = f_narr->gridlon_221
 ;printMinMax(lat2d,0)
 ;printMinMax(lon2d,0)

;---Interpolate to user locations and levels for all times
  ndim     = 1
  x_pts    = narr_to_points (pth_esmf, h_narr, x_narr, hgt, ndim, latPts, lonPts)

  printVarSummary(x_pts)            ; [initial_time0_hours] x [hgt] x [pts]
 ;print(x_pts)

  dimx     = dimsizes(x_pts)
  ntim     = dimx(0)
  khgt     = dimx(1)
  npts     = dimx(2)

;---print results
  do nt=0,ntim-1
    do kh=0,khgt-1
       print("-----------------------")
       print("nt="+nt+"  hgt="+hgt(kh))
       print(" ")
      do np=0,npts-1
         print(sprintf("%6.2f", latPts(np))+"  "+sprintf("%6.2f", lonPts(np)) \
                                          +"   "+sprintf("%6.2f", x_pts(nt,kh,np)))
      end do
    end do
  end do
