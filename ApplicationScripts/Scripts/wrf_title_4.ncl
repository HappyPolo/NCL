;----------------------------------------------------------------------
; wrf_title_4.ncl
;----------------------------------------------------------------------
; Concepts illustrated:
;   - Customizing or turning off titles in plots created by wrf_xxxx functions
;----------------------------------------------------------------------
; These files are loaded by default in NCL V6.4.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/wrf/WRFUserARW.ncl"

begin
;---Open WRF output file and read first timestep of HGT variable
  fname = "wrfout_d01_2003-07-15_00:00:00"
  fname = fname + ".nc"
  a     = addfile(fname,"r")
  slp   = wrf_user_getvar(a,"slp",0)

;---Indicate where to send graphics
  wks = gsn_open_wks("png","wrf_title")

;---Default plot with footer turn off
  res           = True
  res@cnFillOn  = True
  res@Footer    = False                  ; Turn off footer strings

  contour = wrf_contour(a,wks,slp,res)
  plot    = wrf_map_overlays(a,wks,contour,False,False)

;---Change the title at top left of plot
  res@FieldTitle = "SEA LEVEL PRESSURE"    ; Change variable description
  res@UnitLabel  = "mb"                    ; Change variable units
  res@lbTitleOn  = False                   ; Turn off title on labelbar

  contour = wrf_contour(a,wks,slp,res)
  plot    = wrf_map_overlays(a,wks,contour,False,False)

;
; Add more text to FieldTitle and increase its size and the init time size.
; I don't understand why you have to set SubFieldTitle with the wrf_contour
; resources, but the font height with the wrf_map_overlays resources!
;
  res@FontHeightF   = 0.015    ; this increases the 
  res@SubFieldTitle = "[extra text b/f units]"

  pltres = True
  pltres@FontHeightF   = 0.015
  contour = wrf_contour(a,wks,slp,res)
  plot    = wrf_map_overlays(a,wks,contour,pltres,False)

end
