;----------------------------------------------------------------------
; WRF_me_2.ncl
;
; Concepts illustrated:
;   - Plotting WRF data that's on a Mercator map projection
;   - Using gsn_csm_contour_map to plot WRF-ARW data
;----------------------------------------------------------------------
; This script creates a color contour plot at a specified time and 
; level, using the native Mercator map projection defined on the 
; WRF-ARW file.
;----------------------------------------------------------------------
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"   
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"   
; load "$NCARG_ROOT/lib/ncarg/nclscripts/wrf/WRFUserARW.ncl"

begin
;---Open file and read a variable at specified time/level
  f      = addfile("wrfout_d01_2003-07-15_00:00:00.nc","r")
  times  = wrf_user_getvar(f,"times",-1)

  nt     = 0                 ; select time index to plot
  nl     = 8                 ; select level index to plot
  znu   = f->ZNU(nt,:)                          ; (Time, bottom_top)

;---Read perturbation geopotential at all times and levels
  x     = f->T                                 ; (Time, bottom_top, south_north, west_east)

  wks = gsn_open_wks("png","WRF_me")

  res                       = True             ; plot mods desired
  res@gsnMaximize           = True             ; maximize plot size
  res@cnFillOn              = True             ; color plot desired
  res@cnFillPalette         = "BlAqGrYeOrReVi200" ; select color map
  res@cnLinesOn             = False            ; turn off contour lines
  res@cnLineLabelsOn        = False            ; turn off contour labels

  res = wrf_map_resources(f,res)
  res@gsnAddCyclic          = False       ; regional data: not cyclic 
  res@tfDoNDCOverlay        = True        ; set True for native mapping

  res@tiMainString     = times(nt)
  res@gsnLeftString    = x@description+"  z="+znu(nl)

  plot                 = gsn_csm_contour_map(wks,x(nt,nl,:,:),res)
end

