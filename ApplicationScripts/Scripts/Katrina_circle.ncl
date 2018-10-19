;----------------------------------------------------------------------
; Katrina_circle.ncl
;
; Concepts illustrated:
;   - Using nggcog to create a great circle
;   - Using gc_inout to mask data inside a great circle
;   - Using "cd_string" to produce a nice time label for a title
;   - Creating animations
;----------------------------------------------------------------------
; This script was contributed by Jake Huff, a Masters student in the
; Climate Extremes Modeling Group at Stony Brook University.
;
; It shows how to use nggcog to generate a great circle, and gc_inout
; to mask the data inside the circle.
;
; An animation is created using "convert" to convert from a PDF file
; to an animated GIF.
;----------------------------------------------------------------------
load "$NCARG_ROOT/lib/ncarg/nclscripts/contrib/cd_string.ncl"

begin
  latS = 25
  latN = 45
  lonW = 260
  lonE = 290

  kat_ind = 6278         ; one of the indexes associated with Hurricane Katrina on the track file

;---Read lat/lon data from Track file
  dir      = "./"
  obtracks = addfile(dir + "Allstorms.ibtracs_wmo.v03r05.nc","r")
  lat_wmo = short2flt(obtracks->lat_wmo)
  lon_wmo = short2flt(obtracks->lon_wmo)

;---Set all values outside the lat/lon box of interest to missing.
  lat_wmo@_FillValue = default_fillvalue("float")
  lon_wmo@_FillValue = default_fillvalue("float")
  lon_wmo = where( lon_wmo.lt.0,lon_wmo+360,lon_wmo)
  lat_wmo = where(lat_wmo .ge. latS .and. lat_wmo .le. latN,lat_wmo,lat_wmo@_FillValue)
  lon_wmo = where(lon_wmo .ge. lonW .and. lon_wmo .le. lonE,lon_wmo,lon_wmo@_FillValue)

;---Convert time on the file to a nicely formatted string (for plotting)
  nice_date_str = cd_string(obtracks->time_wmo(kat_ind,:),"%D-%c %Y (%HH)")

;---Read in TRMM precipitation data that is a 5 day running average for just 2005 
  date_idx      = 7 ; Index where 2005 data starts
  datefile      = addfile("TRMMprecip.nc","r")
  AvgYearlyTRMM = datefile->AvgYearlyTRMM(date_idx,:,:)
  latTRMM       = datefile->lat
  lonTRMM       = datefile->lon

;---Start the graphics
  wks = gsn_open_wks("pdf","Katrina_circle")

  res                       = True
  res@gsnMaximize           = True
  res@gsnPaperOrientation   = "portrait"    ; to keep plot from being rotated in PDF file

  res@gsnAddCyclic          = False

  res@mpMinLonF             = lonW
  res@mpMaxLonF             = lonE
  res@mpMinLatF             = latS
  res@mpMaxLatF             = latN
  res@mpCenterLonF          = (lonW+lonE)/2
  res@mpDataBaseVersion     = "MediumRes"  ; higher map resolution  
  res@pmTickMarkDisplayMode = "Always"     ; nicer tickmarks for regional plots
  res@mpOutlineBoundarySets = "GeophysicalAndUSStates"

  res@cnFillOn              = True
  res@cnLinesOn             = False
  res@cnFillMode            = "RasterFill"
  res@cnFillPalette         = "WhiteBlueGreenYellowRed"

;---Select a 'nice' contour level range for all plots
  mnmxint = nice_mnmxintvl( min(AvgYearlyTRMM), max(AvgYearlyTRMM), 18, False)
  res@cnLevelSelectionMode  = "ManualLevels"
  res@cnMinLevelValF        = mnmxint(0)
  res@cnMaxLevelValF        = mnmxint(1)
  res@cnLevelSpacingF       = mnmxint(2)/2

;  res@cnLevelSelectionMode  = "ExplicitLevels"          ; "mm/day
;  res@cnLevels              = (/0.1,1,2.5,5,10,15,20,25,30,35,40,45,\
;                                50,55,60,70,75,100,125,150/)

  res@pmTitleZone                  = 4      ; move main title down
  res@gsnStringFontHeightF         = 0.015  ; make subtitles smaller
  res@gsnRightStringOrthogonalPosF = 0.02   ; move subtitles down
  res@gsnLeftStringOrthogonalPosF  = 0.02

;---Get indexes where we have valid lat/lon values for the Katrina index.
  ii   = ind(.not.ismissing(lat_wmo(kat_ind,:)).and..not.ismissing(lon_wmo(kat_ind,:)))
  nind = dimsizes(ii)

;
; Loop through non-missing lat/lon tracks for the storm and create a
; filled contour plot within the calculated lat/lon circle.
; 
  clat = new(25,float)   ; arrays to hold great circle
  clon = new(25,float)
  radius = 5.0

  do ni=0,nind-1  
    j = ii(ni)
    lat_location = lat_wmo(kat_ind,j)  
    lon_location = lon_wmo(kat_ind,j)
    nggcog(lat_location,lon_location,radius,clat,clon)   ; Calculate great circle

    min_lat = min(clat)
    min_lon = min(clon)
    max_lat = max(clat)
    max_lon = max(clon)

;---Subset the desired rectagle of data 
    newTRMMyearly := AvgYearlyTRMM({min_lat:max_lat},{min_lon:max_lon})

;---Set points that are outside of the circle of data to missing
    lat2d := conform(newTRMMyearly,newTRMMyearly&lat,0)
    lon2d := conform(newTRMMyearly,newTRMMyearly&lon,1)
    in_circle := gc_inout(lat2d,lon2d,clat,clon)
    newTRMMyearly = where(in_circle,newTRMMyearly,newTRMMyearly@_FillValue)

;---Print some information about the data
    print("===========================================================")
    print("   Date:             " + nice_date_str(j))
    print("   Lat/Lon location: " + lat_location + "/" + lon_location)
    print("   Min/max of data:  " + min(newTRMMyearly) + "/" + \
                                    max(newTRMMyearly))

;---Create a plot with the date as the main title
    res@tiMainString = nice_date_str(j)
    plot = gsn_csm_contour_map(wks,newTRMMyearly,res)
  end do

;---Convert PDF to animated GIF.
  delete(wks)
  system("convert -delay 10 Katrina_circle.pdf Katrina_circle.gif")
end
