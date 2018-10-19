;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; ibtracs_1.ncl
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Carl Schreck (carl@cicsnc.org) ;; February 2012
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Description: Draw a blank map and put genesis locations on it
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"

begin
;;***************************************************************
;; These are some parameters that could be useful to have up top
;;***************************************************************

  plotType = "png"       ; send graphics to PNG file
  plotName = "ibtracs"
  plotDpi  = 150         ; only applicable if plotType = "png"

;;***************************************************************
;; data path
;;***************************************************************

  ibtDir  = "./"
  ibtPath = "Allstorms.ibtracs_wmo.v03r04.nc" 

;;***************************************************************
;; region
;; -1=All, 0=North Atlantic, 1=South Atlantic, 2=West Pacific,
;;  3=East Pacific, 4=South Pacific, 5=North Indian, 6=South Indian
;;***************************************************************

  basin = -1 
            
;; region

  minLon =  50        ; 30
  maxLon = 120
  minLat =  00
  maxLat =  30
  centerLon = 180     ; graphics

;;***************************************************************
;; time period
;;***************************************************************
  year = 2007
  timeUnits = "days since 1800-01-01 00:00:00"
  minTime = ut_inv_calendar( year, 01, 01, 00, 0, 0, timeUnits, 0 )
  maxTime = ut_inv_calendar( year, 12, 31, 18, 0, 0, timeUnits, 0 )

;;***************************************************************
;; Read the data
;;***************************************************************
  inFile     = addfile( ibtDir+ibtPath, "r" )

  stormYear  = inFile->Season
  stormBasin = inFile->Basin
  if( basin.ge.0 ) then
    stormInd = ind( ( year.eq.stormYear ).and.( basin.eq.stormBasin ) )
  else
    stormInd = ind( year.eq.stormYear )
  end if
;  stormLat = short2flt( inFile->Latitude(stormInd,:) )
;  stormLon = short2flt( inFile->Longitude(stormInd,:) )
  stormLat = short2flt( inFile->Latitude(stormInd) )
  stormLon = short2flt( inFile->Longitude(stormInd) ) 
  stormLon = where( stormLon.lt.0, stormLon+360, stormLon )

  printMinMax(stormLat, True)
  printMinMax(stormLon, True)

;;***************************************************************
;; Customize base plot
;;***************************************************************
  res = True
  res@gsnDraw  = False
  res@gsnFrame = False
  res@tiMainString = year

;; ...set the spacing of the lat/lon labels
  res@gsnMajorLonSpacing = 20
  res@gsnMinorLonSpacing = 10
  res@gsnMajorLatSpacing = 20
  res@gsnMinorLatSpacing = 10

;; ...map gridlines
  res@mpGridAndLimbOn = True
  res@mpGridLatSpacingF = 10
  res@mpGridLonSpacingF = 10
  res@mpGridMaskMode    = "MaskLand"
  res@mpGridLineColor   = "blue"

;; ...set the bounds of a map plot
  res@mpMinLatF    = minLat
  res@mpMaxLatF    = maxLat
  res@mpMinLonF    = minLon
  res@mpMaxLonF    = maxLon
  res@mpCenterLonF = centerLon

;; ...set map resources
  res@mpFillOn = False
  res@mpGeophysicalLineThicknessF = 2
  res@mpGeophysicalLineColor      = "darkgreen"
  res@mpNationalLineColor         = "darkgreen"
  res@mpUSStateLineColor          = "darkgreen"
  res@mpOutlineBoundarySets       = "AllBoundaries"
; res@mpDataBaseVersion           = "MediumRes"
; res@mpDataSetName               = "Earth..1"


;; Set up an x-y line graph
  xyRes = True
  xyRes@gsnDraw  = False
  xyRes@gsnFrame = False
  xyRes@xyMarkLineMode     = "MarkLines"
  xyRes@xyMonoDashPattern  = True
  xyRes@xyLineColor        = "red"
  xyRes@xyLineThicknessF   = 2
  xyRes@xyMarker           = 1
  xyRes@xyMarkerColor      = "black"


;; ...allows png or gif to work
  if( ( plotType.eq."png" ).or.( plotType.eq."gif" ) ) then
   ;plotTypeLocal = "eps"
    plotTypeLocal = "ps"
  else
    plotTypeLocal = plotType 
  end if

;; ...open the workstation
  wks = gsn_open_wks( plotType, plotName )
  gsn_define_colormap( wks, "default" )

  map = gsn_csm_map( wks, res )
  plot = gsn_csm_xy( wks, stormLon, stormLat, xyRes )
  overlay( map, plot )

  draw( map )
  frame( wks )

;; convert the image if necessary
  if( ( plotType.eq."png" ).or.( plotType.eq."gif" ) ) then
    system( "convert -trim +repage -density " + plotDpi + " " \\
      + plotName + "."+plotTypeLocal+" " + plotName + "." + plotType )
    system( "rm -f " + plotName + "."+plotTypeLocal )
  end if

end
