;----------------------------------------------------------------------
; WRF_xy_1.ncl
;
; Concepts illustrated:
;   - Plotting WRF data
;   - Drawing a time series plot
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
; Import time series of perturbation geopotential (PH)
; Use variables to specify specific grid point
;
  kl    = 8                                ; arbitrary grid point
  nl    = (/ 10, 15, 35, 50, 75/)          ; multiple grid points
  ml    = (/ 75, 42,  5, 18, 75/)
  ph    = f->PH(:,kl,nl,ml)                ; read only specified points

;---create the y array used for plot.  There are other approaches.
  npts  = dimsizes(nl)                     ; # of lat/lon pts
  ntim  = dimsizes(Time)
  y     = new ( (/npts,ntim/), typeof(ph)) ; pre-allocate array
  do n=0,npts-1
     y(n,:) = ph(:,n,n)                    ; array syntax to transfer values 
  end do
  y@description = ph@description
  y@unit        = ph@units

;
; Create info used for plot legend [a legend is NOT required]
; Use "sprintf" for format control.
;
  leg      = new ( (/npts/), "string")     ; use for legend in plot
  do n=0,npts-1
     lat   = f->XLAT(0,nl(n),ml(n))        ; get lat/lons for above subscripts
     lon   = f->XLONG(0,nl(n),ml(n))
     leg(n)=  "("+sprintf("%3.1f",lat) +","+sprintf("%4.1f",lon)+")" 
  end do

;---Create plots  
  wks = gsn_open_wks("png","WRF_xy")

  res                        = True           ; plot mods desired
  res@gsnMaximize           = True            ; maximize plot size
  Time@long_name             = Time@units     ; will be label for X-axis
  res@tiMainString           = "Time series at multiple pts"
  res@xyLineThicknessF       = 2.0            ; make thicker

  res@pmLegendDisplayMode    = "Always"       ; create a legend
  res@pmLegendZone           = 0              ; legend inside plot
  res@pmLegendSide           = "Top"          ; Change location of 
  res@pmLegendParallelPosF   =  .15           
  res@pmLegendOrthogonalPosF = -0.4         

  res@pmLegendWidthF         = 0.10           ; Change width and
  res@pmLegendHeightF        = 0.10           ; height of legend.
  res@lgLabelFontHeightF     = .010           ; change font height
  res@xyExplicitLegendLabels = leg            ; explicit labels created above

  plot                       = gsn_csm_xy(wks,Time,y,res)

  res@vpHeightF              = 0.4            ; change aspect ratio of plot
  res@vpWidthF               = 0.70                 

  res@pmLegendParallelPosF   = -.30           ; move to different location           
  res@pmLegendOrthogonalPosF = -0.2         
  
  res@xyMonoDashPattern      = True            ; all solid lines
  res@xyLineColors           = (/"foreground","green","blue","red","brown"/)
  plot                       = gsn_csm_xy(wks,Time,y,res)
end

