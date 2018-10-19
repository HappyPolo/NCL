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

  plotType = "x11"       ; send graphics to PNG file
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
  stormBasin = toint(inFile->Basin)

  if( basin.ge.0 ) then
    stormInd = ind( ( year.eq.stormYear ).and.( basin.eq.stormBasin ) )
  else
    stormInd = ind( year.eq.stormYear )
  end if

;;***************************************************************
;; This will be used to determine the beginning of each new
;; track.
;;***************************************************************
  nStorm   = dimsizes(stormInd)
  TrackNum = inFile->Num(stormInd)
  segments = new(nStorm,integer)
  segments(0) = 0
  nsegs = 1
  do n=1,nStorm-1
    if(TrackNum(n).ne.TrackNum(n-1)) then
      segments(nsegs) = n
      nsegs = nsegs+1
    end if
  end do  
  stormLat = inFile->Latitude(stormInd)
  stormLon = inFile->Longitude(stormInd)
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


;; Set up polyline resources
  lnres = True
  lnres@gsLineColor        = "red"
  lnres@gsLineThicknessF   = 2
  lnres@gsMarkerIndex      = 1
  lnres@gsMarkerColor      = "black"

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

  lnid = new(nsegs,graphic)
  do n=0,nsegs-1
    if(n.lt.(nsegs-1))
      seg_start = segments(n)
      seg_end   = segments(n+1)-1
    else
      seg_start = segments(n)
      seg_end   = nStorm-1
    end if
    lon := stormLon(seg_start:seg_end)
    lat := stormLat(seg_start:seg_end)
    print("==================================================")
    print("Segment #" + n)
    print(str_join(""+lat,",")) 
    print(str_join(""+lon,",")) 
    lnid(n) = gsn_add_polyline( wks, map, lon, lat, lnres)
    draw( map )
    frame( wks )
  end do

;; convert the image if necessary
  if( ( plotType.eq."png" ).or.( plotType.eq."gif" ) ) then
    system( "convert -trim +repage -density " + plotDpi + " " \\
      + plotName + "."+plotTypeLocal+" " + plotName + "." + plotType )
    system( "rm -f " + plotName + "."+plotTypeLocal )
  end if

end
