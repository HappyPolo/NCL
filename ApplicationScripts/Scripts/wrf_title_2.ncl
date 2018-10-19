;----------------------------------------------------------------------
; wrf_title_1.ncl
;----------------------------------------------------------------------
; Concepts illustrated:
;   - Customizing or adding titles to plots created by wrf_xxxx functions
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

;---Open WRF output file and read first timestep of HGT variable
  a = addfile(fname,"r")
  hgt = wrf_user_getvar(a,"HGT",0)

;---Indicate where to send graphics
  wks = gsn_open_wks("png","wrf_title")

;---Create a contour plot with some titles changed or added.
  res           = True
  res@cnFillOn  = True
  res@TimeLabel = "'TimeLabel' string appears here"
  res@MainTitle = "'MainTitle' string appears here"
  contour = wrf_contour(a,wks,hgt,res)

;---Overlay contour plot you just created on a map and add an additional title.
  pltres             = True
  pltres@CommonTitle = True   ; Replace description (units) title with our own title
  pltres@PlotTitle   = "'PlotTitle' string appears here"
  plot = wrf_map_overlays(a,wks,contour,pltres,False)


end
