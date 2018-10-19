;----------------------------------------------------------------------
; WRF_lc_1.ncl
;
; Concepts illustrated:
;   - Plotting WRF data that's on a Lambert Conformal map projection
;   - Using gsn_csm_contour_map to plot WRF-ARW data in its native projection
;----------------------------------------------------------------------
; This script creates a basic black-and-white contour plot at a 
; specified time and level, using the native Lambert Conformal map 
; projection defined on the WRF-ARW file
;----------------------------------------------------------------------
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"   
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"   
; load "$NCARG_ROOT/lib/ncarg/nclscripts/wrf/WRFUserARW.ncl"

begin
;---Open file; substitute your own WRF output file here
  f = addfile ("wrfout.nc", "r")

;--Read variables
  nt = 12
  nl = 8
  times = wrf_user_getvar(f,"times",-1)  ; get all time values on file
  x      = f->PH(nt,nl,:,:)              ; perturbation geopotential
;
; The following are read to extract information
; that will be used for correct plotting and labeling
;
  znu    = f->ZNU(nt,:)                    ; (Time, bottom_top)

  wks = gsn_open_wks("png","WRF_lc")
  res                       = True        ; plot mods desired
  res@gsnMaximize           = True        ; maximize plot size
  res@cnLineThicknessF      = 2.0         ; make twice as thick as default
  res@cnInfoLabelOrthogonalPosF = 0.1     ; move contour info label down

  res = wrf_map_resources(f,res)
  res@gsnAddCyclic          = False       ; regional data: not cyclic 
  res@tfDoNDCOverlay        = True        ; set True for native mapping
                                          ; will result in faster plotting

  res@tiMainString          = times(nt)+"  z="+znu(nl)
  plot                      = gsn_csm_contour_map(wks, x, res)
end

