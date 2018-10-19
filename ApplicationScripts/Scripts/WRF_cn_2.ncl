;----------------------------------------------------------------------
; WRF_cn_2.ncl
;
; Concepts illustrated:
;   - Plotting WRF data
;   - Plotting a cross section
;----------------------------------------------------------------------
; WRF: longitude-z cross section.
;----------------------------------------------------------------------
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"   
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"   
; load "$NCARG_ROOT/lib/ncarg/nclscripts/wrf/WRFUserARW.ncl"

begin
;---Open file; substitute your own WRF output file here
  f = addfile("wrfout_d01_000000_25time.nc","r")
;
; Read variables at given time and lat indexes
; Read W(bottom_top_stag,west_east) at Time=2, lat=15
; Read associated levels and longitudes
;
  ntim = 24
  nlat = 15
  times = wrf_user_getvar(f,"times",-1)  ; get all time values on file
  w     = f->W(ntim,:,nlat,:)            ; W(bottom_top_stag,west_east)
  znw   = f->ZNW(ntim,:)                 ; znw(bottom_top_stag)
  lon   = f->XLONG(ntim,nlat,:)          ; lon(west_east)    

;---Add/change meta data to conform to netCDF convention standards
  lon@units = "degrees_east"            ; CF recommended units
  w!0       = "lev"                     ; name dimensions
  w&lev     =  znw                      ; assign values to named dimensions
  w!1       = "lon"
  w&lon     =  lon

;---Use simple array syntax [like f90] to change units
  w         = w*100.                    ; for demo change units
  w@units   = "cm/s"                                             

;
; For labeling purposes only, determine the average 
; latitude of the cross section
;
  lat_avg = avg(f->XLAT(ntim,nlat,:))       ; avg is a built in function

;
; A "BlWhRe" color map is often selected when plus/minus are 
; of interest
; The "symMinMaxPlt" procedure determines contour limits that 
; are symmetric.
;
  wks = gsn_open_wks("png","WRF_cn")

  res                       = True            ; plot mods desired
  res@gsnMaximize           = True            ; maximize plot size
  res@cnFillOn              = True            ; turn on color
  res@cnFillPalette         = "BlWhRe"        ; set the color map
  res@cnLinesOn             = False           ; turn off contour lines
  res@trYReverse            = True            ; reverse y axis
  res@tmXBTickSpacingF      = 10.             ; force labeling every 10 deg lon
  symMinMaxPlt(w, 14, False, res)

  res@tiMainString = times(ntim)+"  avg(lat)="+lat_avg   ; main title
  plot             = gsn_csm_contour(wks,w,res)
end

