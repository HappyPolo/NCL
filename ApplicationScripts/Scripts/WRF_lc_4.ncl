;----------------------------------------------------------------------
; WRF_lc_4.ncl
;
; Concepts illustrated:
;   - Plotting WRF data that's on a Lambert Conformal map projection
;   - Using gsn_csm_contour_map to plot WRF-ARW data in its native projection
;   - Paneling plots on a page
;----------------------------------------------------------------------
; This script panels an individual variable from a WRF output file at 
; 6 hour time steps. You need to use a WRF output file that has multiple
; time steps, or else read data from a series of individual WRF output
; files.
;----------------------------------------------------------------------
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"   
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"   
; load "$NCARG_ROOT/lib/ncarg/nclscripts/wrf/WRFUserARW.ncl"

begin
;
; Open file and read in data.
; (1) Read Q2 at all times: convert to g/kg
; (2) Read character variable Times; Convert to string for plots
;
  f       = addfile ("wrfout_d01_000000_25time.nc","r")
  x       = f->Q2                              ; (Time, south_north, west_east)
  x       = x*1000.                            ; convert units
  x@units = "g/kg"                             ; upgrade attribute

  times = wrf_user_getvar(f,"times",-1)
  ntim    = dimsizes(times)                    ; # of time steps

  wks = gsn_open_wks("png","WRF_lc")

  res                       = True                 ; plot mods desired
  res@gsnMaximize           = True                 ; maximize plot size
  res@cnFillOn              = True                 ; color plot desired
  res@cnFillPalette         = "BlAqGrYeOrReVi200"  ; select color map
  res@cnLinesOn             = False                ; turn off contour lines
  res@cnLineLabelsOn        = False                ; turn off contour labels

  res = wrf_map_resources(f,res)
  res@gsnAddCyclic          = False                 ; regional data: not cyclic 
  res@tfDoNDCOverlay        = True                  ; set True for native projections

;---For individual plots 
  res@gsnDraw               = False            ; do not draw 
  res@gsnFrame              = False            ; do not advance 'frame'
  res@lbLabelBarOn          = False            ; turn off individual lb's 
;
; Using a common label bar for panel requires that
; all plots should be set to the same interval.
; Use built in function to determine "nice" limits.
;
  mnmxint                   = nice_mnmxintvl( min(x), max(x), 14, False)
  res@cnLevelSelectionMode  = "ManualLevels"   
  res@cnMinLevelValF        = mnmxint(0)
  res@cnMaxLevelValF        = mnmxint(1)
  res@cnLevelSpacingF       = mnmxint(2)/2.    ; twice as many levels

;---Allocate array to store plots: specify time step
  tstep                     = 6                ; time step to plot          
  plts = new (ntim/tstep , "graphic")          ; 1d array to hold plots

;---Loop over each forecast and create a plot with a unique left title
  n = 0                                    ; counter
  do nt=6,ntim-1,tstep                     ; plot every 6 hours 
     res@gsnLeftString = times(nt)
     plts(n) = gsn_csm_contour_map(wks,x(nt,:,:),res)
     n = n+1
  end do

;---Create panel: panel plots have their own set of resources
  resP                    = True                   ; modify the panel plot
  resP@gsnMaximize        = True                   ; maximize panel area
  resP@gsnPanelMainString = x@description          ; Main title
  resP@gsnPanelLabelBar   = True                   ; add common colorbar
  gsn_panel(wks,plts,(/2,2/),resP)                 ; now draw on one page
end

