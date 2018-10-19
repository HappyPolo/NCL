;----------------------------------------------------------------------
; wrf_title_3.ncl
;----------------------------------------------------------------------
; Concepts illustrated:
;   - Turning off titles created by wrf_xxxx plotting scripts
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
  res           = True
  res@cnFillOn  = True
  res@NoHeaderFooter = True   ; Turn off init time title at top right above plot
                              ; and the bottom titles at lower left under plot.

;---You can also set these resources to individually turn off these titles
;  res@InitTime  = False    
;  res@Footer    = False

  contour = wrf_contour(a,wks,hgt,res)

;---Overlay contour plot you just created on a map.
  pltres          = True
  pltres@NoTitles = True           ; Turn off top left title just above plot
  plot = wrf_map_overlays(a,wks,contour,pltres,False)

end
