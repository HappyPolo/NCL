; ***********************************************
; time_labels_2.ncl
;
; Concepts illustrated:
;   - Drawing Hovmueller plots
;   - Using time_axis_labels to generate nice "time" labels on the Y axis.
;   - Explicitly setting contour levels
;   - Reversing the Y axis
;   - Using coordinate subscripting to read a specified geographical region
;   - Merging two color maps
;
;------------------------------------------------------------------------------
; Contributed by:
; Carl Schreck (carl@atmos.albany.edu)
; March 2010
;------------------------------------------------------------------------------
; Description: Draw a time-lon (Hovmueller) plot of unfiltered OLR to 
; demonstrate time_axis_labels
;------------------------------------------------------------------------------
;
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
;
; This file still has to be loaded manually
load "$NCARG_ROOT/lib/ncarg/nclscripts/contrib/time_axis_labels.ncl"

begin
; Open the file
  inFileName = "olr.day.mean.nc"
  inFile = addfile( inFileName, "r" )

; Get the time units and set the first and last times that we want
  timeUnits = inFile->time@units
  startDate = cd_inv_calendar( 1997, 07, 01, 00, 0, 0, timeUnits, 0 )
  endDate   = cd_inv_calendar( 1997, 08, 31, 00, 0, 0, timeUnits, 0 )

  inData = short2flt( inFile->olr({startDate:endDate},{2.5:15},:) )
  data   = dim_avg_n_Wrap( inData, 1 )

  timeUnits = "days since 1800-01-01 00:00:00"
  data&time = ut_convert( data&time, timeUnits )

  cmap = read_colormap_file("BlueDarkRed18")

  wks = gsn_open_wks("png", "time_labels" ) ; send graphics to PNG file

  res = True

  res@gsnMaximize          = True

  res@cnFillOn             = True
  res@cnMonoFillColor      = False
  res@cnLineLabelsOn       = False
  res@cnInfoLabelOn        = False
  res@cnLinesOn            = False
  res@cnFillPalette        = cmap(9::-1,:)   ; subset and reverse colors used
  res@cnLevelSelectionMode = "ExplicitLevels"
  res@cnLevels             = (/ 160, 180, 200, 220, 240 /)

  res@trYReverse           = True

; Set special resources for the time axis
  resTick                = True
  resTick@ttmFormat      = "%d %c"
  resTick@ttmAxis        = "YL"
  resTick@ttmMajorStride = 10

; Set resources necessary to customize Y axis labels
  time_axis_labels( data&time,  res, resTick )

  plot = gsn_csm_hov( wks, data(:,{120:320}), res )

end
