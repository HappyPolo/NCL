;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; timeLon.ncl
; Carl Schreck (carl@atmos.albany.edu)
; January 2010
;------------------------------------------------------------------------------
; Description: Draw a time-lon (Hovmoller) plot of unfiltered CLAUS overlaid 
; with wave-filtered contours
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
; User Contributed routines follow. They are NOT supported by the NCL team. 
load "$NCARG_ROOT/lib/ncarg/nclscripts/contrib/kf_filter.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/contrib/time_axis_labels.ncl"
;<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; Main
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
begin

  mis = -999
  mis@_FillValue = -999

  ; set the wave parameters
  tMin = 2.5
  tMax = 20
  kMin = 1
  kMax = 14
  hMin = 8
  hMax = 90
  waveName = "Kelvin"  

  ; number of timesteps in data for each day
  obsPerDay = 8

  ; number of days to filter on each side of the period we're interested in
  bufferDays = 90
  
  ; open the file
  inDir      = "./"
  inFileName = "claus.1997.nc"
  inFile     = addfile( inDir+inFileName, "r" )

  ; get the time units and set the first and last times that we want
  timeUnits = inFile->time@units
  startDate = ut_inv_calendar( 1997, 07, 01, 00, 0, 0, timeUnits, 0 )
  endDate   = ut_inv_calendar( 1997, 08, 31, 00, 0, 0, timeUnits, 0 )

  ; calculate our number of weights
  if( isStrSubset( timeUnits, "days" ) ) then
    buffer = bufferDays * 1
  else
    if( isStrSubset( timeUnits, "hours" ) ) then
      buffer = bufferDays * 24
    else
      print( "DANGER! DANGER! Unexpected time units" )
      return
    end if
  end if

  filtStart = startDate - buffer
  filtStart@units = timeUnits
  filtEnd   = endDate + buffer
  filtEnd@units = timeUnits

  print( "Reading..." )
  inData   = inFile->brtmp({filtStart:filtEnd},{2.5:15},:)
  origData = dim_avg_n_Wrap( inData, 1 )

  print( "Filtering..." )
  filtData = kf_filter( origData(time|:,lon|:), obsPerDay \
                      , tMin, tMax, kMin, kMax, hMin, hMax, waveName )

  printVarSummary( filtData )
  print( min(filtData) + " " + max(filtData) )

  wks = gsn_open_wks( "ps", "wkSpaceTime" )
  gsn_merge_colormaps( wks, "posneg_2", "default" )

  res = True

  res@cnFillOn = True
  res@cnFillMode          = "RasterFill"
  res@cnRasterSmoothingOn = True
  res@cnMonoFillColor     = False
  res@cnLineLabelsOn      = False
  res@cnInfoLabelOn       = False
  res@cnLinesOn           = False

  res@cnLevelSelectionMode= "ExplicitLevels"
  res@cnLevels            = (/ 240, 250, 260, 270, 280 /)
  res@gsnSpreadColors     = True
  res@gsnSpreadColorStart = 21
  res@gsnSpreadColorEnd   = 13
  res@cnMissingValFillColor = "gray"

;  res@gsnLeftString = ""
;  res@gsnRightString = ""
  res@gsnDraw = False
  res@gsnFrame = False

  res@trYReverse = True

  ; use tTick to set the time axis
  resTick = True
  resTick@ttFormat = "%d %c"
  resTick@ttAxis = "YL"
  resTick@ttMajorStride = 40
  tTick( origData&time,  res, resTick )

  plot = gsn_csm_hov( wks, origData({startDate:endDate},{120:320}), res )

  cnRes = True
  cnRes@cnLineThicknessF = 2
  cnRes@cnLineLabelsOn   = False
  cnRes@cnLineColor      = "black"
  cnRes@gsnLeftString    = ""
  cnRes@gsnRightString   = ""
  cnRes@gsnDraw          = False
  cnRes@gsnFrame         = False
  cnRes@cnLevelSelectionMode = "ExplicitLevels"
  cnRes@cnLevels         = (/ -15, -5 /)

  cont = gsn_csm_contour( wks, filtData, cnRes )
  overlay( plot, cont )

  draw( plot )
  frame( wks )

  print( "Thank you, come again." + systemfunc("date") )

end
