;*************************************************
; station_4.ncl
;************************************************
;
; Concepts illustrated:
;   - Plotting METAR reporting stations for a specific region
;   - Plotting station locations using markers
;   - Attaching lots of text strings to a map
;   - Attaching markers to a map
;
;********************************************************
; The purpose of this script is to plot all METAR reporting 
; stations for a specified region.
;
; This script takes general input from the stations.txt file
; available at from the UCAR-RAP Weather Page at:
; http://www.rap.ucar.edu/weather/surface/stations.txt
;
; Author: Jonathan Vigh, Colorado State University
;
; Program History:
;   circa 2004	Program created (originally read in a hand-edited file: stations.inp)
;   09/14/2007: Revised program input section to fix issues with reading directly from the stations.txt file (had been buggy before) 	
;   09/17/2007: Revised program to accept command line inputs - the NCL code is called from a script called run_mapper.
;   09/18/2007: Program now utilizes a much more efficient way of selecting the stations in the plotting domain.
;   07/19/2009: Fixed logic for indexing regional stations to account for a change in how NCL handles the _FillValue of logical variables.
;   07/21/2009: Fixed logic for ensuring strings are not missing - now uses the str_is_blank function in NCL 5.1.1. 
;
; Suggestions for improvements:
;   - *** Figure out how to take care of the overlapping labels problem (see the text example 10 code for ideas)
;   - Put some place names on the map, like for island groups.
;   - Have an option that can choose to plot all the stations in a specific country or state (use the two-letter code)
;   - Add a few default mapping options? Or plot several types of maps (i.e. high resolution close-up vs. regular resolution?
;   - Control font height of labels based on the size of the map (tie to span of lat/lon?)
;   - Read in topography from a database, so we could get some nice terrain maps.
;   - Have the program query the stations - only plot those which have given a recent report in a given time period (well, this would require getting all the worldwide data for that time period)

; *** NOTE ***
; This script requires NCL 5.1.1.
;
;********************************************************
;
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
;
; This file still has to be loaded manually
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl"
;********************************************************

begin

  integer_FillValue = -999
  float_FillValue   = -999
  logical_FillValue = _Missing

  nullChar = inttochar(0)	; could use this to test a single char to see if it's null

; Set some parameters to choose which region to plot, etc.
  map_name = "Colorado" ; This will be used in the plot title and to generate the output filename
  use_RANGS = False	; set to True to enable high res coastlines and inland water boundaries, set to False to use NCL's Earth..4 dataset

  minlat = 36.8
  maxlat = 41.2
  minlon = -109.2	; degW are negative
  maxlon = -101.8 
    

;********************************
; get data
;********************************
  tStr  = asciiread("stations.txt", -1,"string")  ;  Info includes type so cases can be weeded out
  tChr  = tochar(tStr)
  nrows = dimsizes(tStr)
  
  temptStr = new(nrows,"string")    
    
; Read in the entire file, put all the lines which actually contain station data into a new array of strings  
  nglobalstations = 0
  do irow = 0, nrows-1
     FIRST = tChr(irow,0)		; next read the first letter in as a string
     if ( .not.str_is_blank(tStr(irow)) .and. (FIRST .ne. "!") ) then	; only read the line if it's not a comment (!) or blank (test to see if the first character is the nullChar that was created using inttochar(0))
;     if ( (strlen(tStr(irow)) .gt. 0) .and. (FIRST .ne. "!") ) then   ; only read the line if it's not blank (string size greater than 0)    - this is an alternative to checking the first character against the null chararacter
;        print(tStr(irow))
; 	 print(" The first character is: "+FIRST)
;        print(" We know this line is not a comment or blank, continuing to read . . .")
	DASH = tChr(irow,25:25)		; read the line to see if there is a dash in the 25th column (indicating a country or state identifier)	
;        print(" The 25th character is: "+DASH)
	if (DASH .ne. "-") then	; don't read the line if it's a country/state identifier
	   if ( (tStr(irow) .ne. "CD  STATION         ICAO  IATA  SYNOP   LAT     LONG   ELEV   M  N  V  U  A  C") .and. \
                (tStr(irow) .ne. "CD  STATION         ICAO  IATA  SYNOP   LAT     LONG   ELEV   M  N  V  U  A  X") ) then
;	      print(" It looks like we have a valid station line, entering data into the arrays . . .")
	      temptStr(nglobalstations) = tStr(irow)
	      nglobalstations  = nglobalstations + 1
           end if
        end if
     end if
     
  end do

  print(nrows+" rows were read from the data file.")
  print(nglobalstations+" stations were read in for the entire world.")

  newtStr = temptStr(0:nglobalstations-1)	
  newtChr = tochar(newtStr)      

; Read in the individual station values (note that if we are doing any conversions from strings to numerical type, we should check each individual value)       
  CD    	 = tostring(newtChr(:,0:1))	; read the 2-letter state or province abbreviation (many international stations do not have this)
  NAME  	 = tostring(newtChr(:,3:18)) 
  ICAO  	 = tostring(newtChr(:,20:23))
  IATA  	 = tostring(newtChr(:,26:28))
  WMO_string   	 = tostring(newtChr(:,32:36))
  LAT_HR_string  = tostring(newtChr(:,39:40)) 
  LAT_MIN_string = tostring(newtChr(:,42:43))
  LON_HR_string  = tostring(newtChr(:,47:49))
  LON_MIN_string = tostring(newtChr(:,51:52))
  ELEV_string  	 = tostring(newtChr(:,55:58))
  METAR    	 = tostring(newtChr(:,62:62))  ; this flag specifies whether this is a METAR-reporting station
  NEXRAD   	 = tostring(newtChr(:,65:65))  ; this flag specifies whether this is a NEXRAD (WSR-88D) Radar site
  AVIATION 	 = tostring(newtChr(:,68:68))  ; this flag specifies some Aviation-specific stuff (V=AIRMET/SIGMET end point, A=ARTCC T=TAF U=T+V)
  UPPERAIR 	 = tostring(newtChr(:,71:71))  ; this flag specifies an upper air (rawinsonde=X) or wind profiler (W) site
  TYPE     	 = tostring(newtChr(:,74:74))  ; this flag specifies the station type: A = Auto (A=ASOS, W=AWOS, M=Meso, H=Human, G=Augmented) (H/G not yet impl.) 
  OFFICE   	 = tostring(newtChr(:,77:77))  ; this flag specifies the office type (F=WFO/R=RFC/C=NCEP Center)
  NorS     	 = tostring(newtChr(:,44:44))
  EorW     	 = tostring(newtChr(:,53:53))

  WMO     = new(nglobalstations,"integer",integer_FillValue)
  LAT_HR  = new(nglobalstations,"float",float_FillValue)
  LAT_MIN = new(nglobalstations,"float",float_FillValue)
  LON_HR  = new(nglobalstations,"float",float_FillValue)
  LON_MIN = new(nglobalstations,"float",float_FillValue)
  ELEV    = new(nglobalstations,"integer",integer_FillValue)
  lat     = new(nglobalstations,"float",float_FillValue)
  lon     = new(nglobalstations,"float",float_FillValue)
  inside  = new(nglobalstations,"logical",logical_FillValue)

; initialize inside to False - we assume that the station is not inside the region until proven otherwise
  inside = False
  

  IDEN = ICAO	; by default, use the ICAO as the station identifier, if this happens to be blank (rare), use the IATA (see code in loop below)
    
  do i=0,nglobalstations-1   
   
     if ( str_is_blank(ICAO(i)) .and. .not.str_is_blank(IATA(i)) ) then
        IDEN(i) = IATA(i)	
     end if

     if (.not.str_is_blank(WMO_string(i))) then
        WMO(i) = tointeger(WMO_string(i))
     end if

     if (.not.str_is_blank(LAT_HR_string(i))) then
        LAT_HR(i) = tofloat(LAT_HR_string(i))
     end if

     if (.not.str_is_blank(LAT_MIN_string(i))) then
        LAT_MIN(i) = tofloat(LAT_MIN_string(i))
     end if

     if (.not.str_is_blank(LON_HR_string(i))) then
        LON_HR(i) = tofloat(LON_HR_string(i))
     end if

     if (.not.str_is_blank(LON_MIN_string(i))) then
        LON_MIN(i) = tofloat(LON_MIN_string(i))
     end if

     if (.not.str_is_blank(ELEV_string(i))) then
        ELEV(i) = tointeger(ELEV_string(i))
     end if

     latMP = 1
     if (NorS(i) .eq. "S") then
        latMP = -1
     end if
    
     lonMP = 1
     if (EorW(i) .eq. "W") then
        lonMP = -1
     end if              
   
     lat(i) = latMP*(LAT_HR(i) + LAT_MIN(i)/60.0)
     lon(i) = lonMP*(LON_HR(i) + LON_MIN(i)/60.0)
  
; set a flag if the lat and lon are outside the desired map area (this logic is probably flawed for near the Dateline?)
     if ( (lat(i) .ge. minlat) .and. (lat(i) .le. maxlat) .and. (lon(i) .ge. minlon) .and. (lon(i) .le. maxlon) ) then
        inside(i) = True
     end if
  
  end do  
   

; Now pick off the indices of stations which are inside the desired region 
  localindex = ind( .not.ismissing(lat) .and. inside )
  nlocalstations = dimsizes(localindex)
  

;***** Define some NICE color maps to use.
   colors_6 = (/"White","Black","Black","MediumPurple1","MediumPurple3","Blue1",\
          "CadetBlue3","Aquamarine2","SeaGreen2","LawnGreen","Green4", \
          "GreenYellow","Gold","Tan1","Sienna1","Tomato","VioletRed1", \
          "Yellow","DarkGreen","Grey37","Red","Orange","GoldenRod1","DarkOrange","SteelBlue1","SlateBlue1", \
          "LightSlateBlue","DarkSeaGreen","Magenta","DodgerBlue","Moccasin","Blue"/)

 
   
;********************************
; create plot
;********************************

   wks = gsn_open_wks("png","station")           ; send graphics to PNG file

   gsn_define_colormap(wks,colors_6)
   
   res                  = True 

   res@tiMainString	= "METAR-reporting stations for " + map_name

   res@gsnMaximize 	= True
;   res@gsnPaperOrientation = "Landscape"
   res@gsnDraw          = False   ; so we can add poly stuff
   res@gsnFrame         = False   ; do not advance frame

   if (use_RANGS) then
      res@mpDataBaseVersion = "HighRes"	; set to HighRes to get nice coastlines
      res@mpDataResolution = "Finest"
   else
      res@mpDataBaseVersion = "MediumRes"	; set to HighRes to get nice coastlines
      res@mpDataSetName     = "Earth..4"	; we want county lines drawn (set to 3 for climate districts) 
   end if
       
   res@mpProjection	 = "Mercator"
;   res@mpProjection      = "LambertConformal" 
      
;   res@mpLambertParallel1F = 20.0
;   res@mpLambertParallel1F = 40.0
;   res@mpLambertMeridianF  = -60.0
   
   res@mpLimitMode 	= "LatLon"

   res@mpMinLatF        = minlat
   res@mpMaxLatF        = maxlat
   res@mpMinLonF        = minlon
   res@mpMaxLonF        = maxlon
  
   res@mpFillOn         = True    ; False to turn off gray continents
   res@mpOutlineOn      = True    ; turn on continental outline
   res@mpOutlineBoundarySets = "AllBoundaries" 

   res@mpLandFillColor        = "GoldenRod1"
   res@mpInlandWaterFillColor = "PaleTurquoise3"
   res@mpOceanFillColor       = "PaleTurquoise3"

   res@mpGeophysicalLineColor      = "Black"
   res@mpGeophysicalLineThicknessF = 0.5
   
   res@mpUSStateLineColor          = "Red"
   res@mpUSStateLineThicknessF     = 2.5
   
   res@mpNationalLineColor	   = "Black" 
   res@mpNationalLineThicknessF    = 2.5
   
   res@mpGridAndLimbOn        = "True"
   res@mpGridAndLimbDrawOrder = "Draw"
   if (res@mpDataBaseVersion .ne. "HighRes") then
      res@mpGridMaskMode         = "MaskLand"
   end if
   res@mpGridSpacingF         = 1.0
   res@mpGridLineColor        = "Blue"

   res@tmXBLabelFontHeightF = 0.005
   res@tmXBMajorLengthF     = -0.001

   res@pmTickMarkDisplayMode = "Always"


print("Now plotting the map")
  
;***************************************
; plot base map                        *
;***************************************

    plot = gsn_csm_map(wks,res)	     ; draw one of eight map projections

;   getvalues plot
;      "mpAreaNames" : anames
;   end getvalues
;   
;   print(anames)

   
;***************************************
; Draw METAR stations as polymarkers   *
;***************************************   
   res_mark = True

   res_mark@gsMarkerIndex    = 1        ; polymarker style
   res_mark@gsMarkerSizeF    = 0.018    ; polymarker size
   res_mark@gsMarkerColor    = "Red"    ; change marker color

   dum = gsn_add_polymarker(wks,plot,lon(localindex),lat(localindex),res_mark)


print("Now plotting text labels")


;***************************
; Plot some text labels    *
;***************************
   txres    = True

; Now draw the 4-letter ICAO station identifiers 

   txres@txFontHeightF 		= 0.008
   txres@txJust       		= "TopCenter"

   txres@txPerimOn             = True
   txres@txPerimColor          = "Black"
   txres@txPerimThicknessF     = 0.3
   txres@txPerimSpaceF         = 0.4
   txres@txBackgroundFillColor = "White"

; Calculate label offset as a function of map domain size
   dy = (maxlat - minlat)/125.
;   print(dy)

; Put the station labels onto the map as text strings
   dumb = new(nlocalstations,graphic)
   do j=1,nlocalstations-1
       i = localindex(j)	; return the value of the global station number from our big array
;      gsn_text(wks,plot,IDEN(i)+" "+ELEV(i),lon(i),lat(i)-dy,txres)  
      dumb(j) = gsn_add_text(wks,plot,IDEN(i)+"  "+ELEV(i)+" m~C~"+NAME(i),lon(i),lat(i)-dy,txres)  ; this is really slow
   end do
 
print(newtStr(localindex))
 
; Example of how to add a label using NDC coordinates 
 
 ;  txres@txFontHeightF        = 0.01
 ;  txres@txPerimThicknessF    = 1.5
 ;  txres@txPerimSpaceF        = 0.5
 ;  txres@txConstantSpacingF   = 1.0
 ;  txres@txFontAspectF        = 1.5
 ;  txres@txFontThicknessF     = 3.0
 ;  gsn_text_ndc(wks,"Azore Islands",0.5,0.72,txres)

   draw(plot)
   frame(wks)
  
end
