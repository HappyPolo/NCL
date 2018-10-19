;************************************************
; e20c_1.ncl
;
; Concepts illustrated:
;   - Reading GRIB data
;   - Plotting ERA-20C data
;   - Use standard indexing (nt) and coordinate subscripting {...} to access time/level
;   - Drawing color-filled contours over a cylindrical equidistant map
;   - Selecting a different color map
;
;*************************************************
;
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"  
;************************************************
begin
;************************************************
; create pointer to file and read in data
;************************************************
  in = addfile("e20c.oper.an.pl.3hr.128_248_cc.regn80sc.1909110100_1909113021.grb","r")
  cc = in->CC_GDS4_ISBL

  date = cd_calendar(cc&initial_time0_hours, -3)
;************************************************
; create default plot
;************************************************
  wks = gsn_open_wks("png","e20c")               ; send graphics to PNG file

  res                       = True               ; plot mods desired
  res@gsnMaximize           = True
  res@cnFillOn              = True               ; turn on color fill
  res@cnFillPalette         = "prcp_1"           ; set color map
  res@cnLinesOn             = False              ; turn off contour lines
  res@cnLineLabelsOn        = False              ; turn off contour line labels
  res@cnFillMode            = "RasterFill"
  nt   = 0                                       ; arbitrary time
  plvl = 700                                     ;     "     level
  res@tiMainString          = "ERA-20C: "+date(nt)
  res@gsnCenterString       = plvl+" hPa"
  plot = gsn_csm_contour_map(wks,cc(nt,{plvl},:,:),res)     
end


