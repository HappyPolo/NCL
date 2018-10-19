;----------------------------------------------------------------------
; time_labels_3.ncl
;
; Concepts illustrated:
;   - Drawing a time series plot
;   - Labeling the X axis with nicely-formatted time labels
;   - Converting WRF Times variable to numeric values
;   - Removing trailing zeros from tickmark labels
;   - Changing the width and height of a plot
;----------------------------------------------------------------------
;
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/wrf/WRFUserARW.ncl"
;
; These files still have to be loaded manually
load "$NCARG_ROOT/lib/ncarg/nclscripts/wrf/WRF_contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/contrib/time_axis_labels.ncl"

begin
;---Get some data to plot
  filename = "wrfout_d01_000000_25time.nc"
  a        = addfile(filename,"r")
  slp      = wrf_user_getvar(a,"slp",-1)   ; sea level pressure
  slp_avg  = dim_avg_n_Wrap(slp,(/1,2/))   ; Average across all lat/lon

;--------------------------------------------------
; The "Times" on the file are in the format:
;
;   2001-06-11_12:00:00
;   2001-06-11_13:00:00
;     ...
;
; Convert this to values representing 
;   "hours since 2001-06-11 12:00:00"
;--------------------------------------------------
  times  = wrf_times_c(a->Times,0)
  ntimes = dimsizes(times)

;---Start the graphics
  wks = gsn_open_wks("png","time_labels") ; send graphics to PNG file

;---Plotting options for time series plot
  res             = True

  res@gsnMaximize = True
  res@vpWidthF    = 0.8
  res@vpHeightF   = 0.3

  res@tmXTOn      = False
  res@tmYLFormat  = "f"      ; remove trailing ".0"

;--------------------------------------------------
; The time_axis_label function adds additional
; resources to "res" to produce nicely-formatted 
; time labels on X axis. This function only works 
; if you have a time "units" recognized by the 
; cd_calendar function.
;--------------------------------------------------
  restick           = True
  restick@ttmFormat = "%N/%D %H:%M"

  time_axis_labels(times,res,restick)

  res@tiMainString       = filename
  res@tiYAxisString      = "Average slp (" + slp_avg@units + ")"
  res@tiMainFontHeightF  = 0.025
  res@tiYAxisFontHeightF = 0.02

  plot = gsn_csm_xy(wks,times,slp_avg,res)
end
