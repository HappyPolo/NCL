;----------------------------------------------------------------------
; WRF_cn_4.ncl
;
; Concepts illustrated:
;   - Plotting WRF data
;   - Plotting a cross section
;----------------------------------------------------------------------
; WRF: time-z cross section.
;----------------------------------------------------------------------
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"   
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"   
; load "$NCARG_ROOT/lib/ncarg/nclscripts/wrf/WRFUserARW.ncl"

load "$NCARG_ROOT/lib/ncarg/nclscripts/wrf/WRF_contributed.ncl"

begin
;---Open file; substitute your own WRF output file here
  f = addfile ("wrfout_d01_000000_25time.nc","r")
;
; Read character variable Times 
; Convert to units of "hours since" for plotting purposes
;
  times = f->Times
  Time   = wrf_times_c(f->Times, 0)  ; convert to "hours since"
  print(Time)
;
; Read W(bottom_top_stag,west_east) at lat 
;    index 15, lon index nlon.
; Read associated levels and longitudes
;
  nlat = 15
  nlon = 70
  w       = f->W(:,:,nlat,nlon)             ; W(Time,bottom_top_stag)
  znw     = f->ZNW(0,:)                 ; znw(bottom_top_stag)

  printVarSummary(w)
  w&Time := Time
  printVarSummary(w)
  print(w&Time)
exit

;---Use simple array syntax [like f90] to change units
  w         = w*100.                    ; for demo change units
  w@units   = "cm/s"                                             

printVarSummary(w)
printMinMax(w,0)

;---Add/change meta data to conform to netCDF convention standards
  w!0       = "Time"
  w&Time    =  Time
  w!1       = "lev"                     ; name dimensions
  w&lev     =  znw                      ; assign values to named dimensions

;---For plot purposes only, read the specific lat/lon point
  lat       = f->XLAT(0,nlat,nlon)
  lon       = f->XLONG(0,nlat,nlon)
;
; create plots  
; (1) A "BlWhRe" is often selected when plus/minus are of interest
; (2) The "symMinMaxPlt" procedure determines contour limits 
;     that are symmetric.
; (3) Use the "sprintf" function to format the title
; (4) Because the rightmost dimension will become the "x" axis
;     use NCL's "dimension reordering" to reshape
;
  wks = gsn_open_wks("png","WRF_cn")

  res                       = True            ; plot mods desired
  res@gsnMaximize           = True            ; maximize plot size
  res@cnFillOn              = True            ; turn on color
  res@cnFillPalette         = "BlWhRe"        ; set the color map
  res@cnLinesOn             = False           ; turn off contour lines
  res@lbOrientation         = "vertical"      ; vertical label bar
  res@trYReverse            = True            ; reverse y axis
  res@tiXAxisString         = Time@units      ; label bottom axis with units attribute
  symMinMaxPlt(w, 14, False, res)             ; contributed.ncl

  res@tiMainString          = sprintf("%4.2f", lat)+"N  " \
                            + sprintf("%4.2f", fabs(lon))+"W" 
  plot                      = gsn_csm_contour(wks,w(lev|:,Time|:),res)
end

