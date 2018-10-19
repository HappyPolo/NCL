;----------------------------------------------------------------------
; wrf_title_1.ncl
;----------------------------------------------------------------------
; Concepts illustrated:
;   - Understanding default titles created by wrf_xxxx plotting scripts
;----------------------------------------------------------------------
; These files are loaded by default in NCL V6.4.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/wrf/WRFUserARW.ncl"

begin
;---Open WRF output file and read first timestep of HGT variable
  fname = "wrfout_d01_2003-07-15_00:00:00"
  fname = fname + ".nc"
  a     = addfile(fname,"r")
  hgt   = wrf_user_getvar(a,"HGT",0)

;---Indicate where to send graphics
  wks = gsn_open_wks("png","wrf_title")

;---Create a contour plot. Note the default titles you get.
  res          = True
  res@cnFillOn = True

  contour = wrf_contour(a,wks,hgt,res)

;---Overlay contour plot you just created on a map.
  plot = wrf_map_overlays(a,wks,contour,False,False)
end
