;----------------------------------------------------------------------
; WRF_cn_1.ncl
;
; Concepts illustrated:
;   - Plotting WRF data
;----------------------------------------------------------------------
; This script creates two simple contour views of pressure at a 
; specific time and level. No map background is generated.
;----------------------------------------------------------------------
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"   
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"   
; load "$NCARG_ROOT/lib/ncarg/nclscripts/wrf/WRFUserARW.ncl"

begin
;---Open file; substitute your own WRF output file here
  f = addfile ("wrfout.nc", "r")

;--Read variables
  times = wrf_user_getvar(f,"times",-1)  ; get all time values on file
  p     = wrf_user_getvar(f,"p",-1)  ; calculate pressure across all time, levels

  printVarSummary(p)   ; Look at your data
  printMinMax(p,0)
  print(times)

  nt = 0 ; timestep to plot
  nl = 0 ; level to plot

;---Create simple contour plots  
  wks = gsn_open_wks("png" ,"WRF_cn")

  res                       = True            ; plot mods desired
  res@gsnMaximize           = True            ; maximize plot size
  res@tiMainString          = times(nt)       ; main title
  plot                      = gsn_csm_contour(wks,p(nt,nl,:,:),res)

  res@cnFillOn              = True                 ; turn on color
  res@cnFillPalette         = "BlAqGrYeOrReVi200"  ; change color map
  res@cnLinesOn             = False           ; turn off contour lines
  plot                      = gsn_csm_contour(wks,p(nt,nl,:,:),res)
end

