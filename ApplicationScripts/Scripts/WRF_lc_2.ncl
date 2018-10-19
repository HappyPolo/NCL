;----------------------------------------------------------------------
; WRF_lc_2.ncl
;
; Concepts illustrated:
;   - Plotting WRF data that's on a Lambert Conformal map projection
;   - Using gsn_csm_contour_map to plot WRF-ARW data in its native projection
;----------------------------------------------------------------------
; This script creates a color contour plot over the native map
; projection defined on the WRF output file.
;----------------------------------------------------------------------
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"   
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"   
; load "$NCARG_ROOT/lib/ncarg/nclscripts/wrf/WRFUserARW.ncl"

load "$NCARG_ROOT/lib/ncarg/nclscripts/wrf/WRF_contributed.ncl"

begin
;---Open file; substitute your own WRF output file here
  f = addfile ("wrfout.nc", "r")

  times = wrf_user_getvar(f,"times",-1)
  znu   = f->ZNU(0,:)                          ; (Time, bottom_top)

;---Read perturbation geopotential at all times and levels
  x     = f->PH       ; (Time, bottom_top, south_north, west_east)

;---Create plot  
  wks = gsn_open_wks("png","WRF_lc")

  res                       = True                  ; plot mods desired
  res@gsnMaximize           = True                  ; maximize plot size
  res@cnFillOn              = True                  ; color plot desired
  res@cnFillPalette         = "BlAqGrYeOrReVi200"   ; select color map
  res@cnLinesOn             = False                 ; turn off contour lines
  res@cnLineLabelsOn        = False                 ; turn off contour labels

  res = wrf_map_resources(f,res)
  res@gsnAddCyclic          = False                 ; regional data: not cyclic 
  res@tfDoNDCOverlay        = True                  ; set True for native projections

  res@pmTickMarkDisplayMode = "Always"         ; turn on nicer map tickmarks
;
; Loop over all times and levels ( uncomment )
; Demo: one arbitrarily closen time and level  
;
  dimx  = dimsizes(x)                          ; dimensions of x
  ntim  = dimx(0)                              ; number of time steps
  klev  = dimx(1)                              ; number of "bottom_top" levels

  nt    = ntim/2                               ; arbitrary time
  kl    =  6                                   ;     "     level
;;do nt=0,ntim-1                               ; uncomment for loop
;;  do ll=0,klev-1
       res@tiMainString     = times(nt)
       res@gsnLeftString    = x@description+"  z="+znu(kl)
       plot                 = gsn_csm_contour_map(wks,x(nt,kl,:,:),res)
;;  end do
;;end do
end

