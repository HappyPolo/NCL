;********************************************************
; unique_1.ncl
;
; Concepts illustrated:
;   - Plotting best tracks for a given season's storms
;   - Manually creating a legend using markers and text
;   - Attaching text strings to a map
;   - Attaching polylines to a map plot
;   - Drawing a custom legend inside a map plot
;   - Creating a color map using named colors
;   - Customizing the fill color of various map areas
;
;********************************************************
; The purpose of this script is to plot the best tracks
; for a given season storms including all data (subtropical
; storms, depressions, extratropical lows, etc.)
;********************************************************
;
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
;
; This file still has to be loaded manually
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl"

begin

; First set the year and number of storms in the season
;   yyyy = 2001
;   ncurves = 17
;   nstorms = 17
   
;   yyyy = 2002
;   ncurves = 14
;   nstorms = 17
   
   yyyy = 2003
   ncurves = 21
   nstorms = 21
   
   bcurve  = 0	; Start at first storm

; Next, set the plotting parameters (which cases to plot)
;
; Note that this script probably won't work for TypeOn = False, because
; we don't have the data file for it.
;
   TypeOn                    = True  ; If you just want the legend to have the basic (H, TS, and TD) designators (* and S), set TypeOn to False
				      ; NOTE -- this will cause the program to grab a different input file -- one in which all the 
				      ; extratropical (E), remnant low (L), and wave cases (W) have been taken out; additionally,
				      ; there will not be a distinction between the S and * cases (they will just be plotted according to
				      ; intensity

   PlotSubTropicalSegments   = True   ; If you wish to exclude all subtropical line segments, set to False 
   
; Note: if TypeOn is set to False, the following (W, L, E) cases won't be plotted regardless of their value   
   PlotWaveSegments          = True   ; If you wish to exclude all wave segments, set to False
   PlotLowSegments	     = True   ; If you wish to exclude all remnant low segments, set to False
   PlotExtraTropicalSegments = True   ; If you wish to exclude all extratropical line sements, set to False  

if (yyyy.eq.2001) then
   name = (/"Allison","Two","Barry","Chantal","Dean","Erin","Felix","Gabrielle","Nine","Humberto","Iris","Jerry","Karen","Lorenzo","Michelle","Noel","Olga"/)
   ssn = (/"1","2","3","4","5","6","7","8","9","10","11","12","13","14","15","16","17"/) 
end if  

if (yyyy.eq.2002) then
  name = (/"Arthur","Bertha","Cristobal","Dolly","Edouard","Fay","Seven","Gustav","Hanna","Isidore","Josephine","Kyle","Lili","Fourteen"/)
  ssn = (/"1","2","3","4","5","6","7","8","9","10","11","12","13","14"/) 
end if
  
if (yyyy.eq.2003) then
   name = (/"Ana","Two","Bill","Claudette","Danny","Six","Seven","Erika","Nine","Fabian","Grace","Henri","Isabel","Fourteen","Juan","Kate","Larry","Mindy","Nicholas","Odette","Peter"/)
   ssn = (/"1","2","3","4","5","6","7","8","9","10","11","12","13","14","15","16","17","18","19","20","21"/) 
end if

  
;********************************
; get data
;********************************
 if(TypeOn) then
    tStr  = asciiread("best_all_" + yyyy + ".inp", -1,"string")  ; Info includes type so cases can be weeded out
 else
    tStr  = asciiread("best_" + yyyy + ".inp", -1,"string")  ; Info includes type so cases can be weeded out
 end if   

  tChr  = tochar(tStr)
  
  nrows = dimsizes(tStr)
  
  sn    = tofloat( tostring(tChr(:,0:1)) )
  year  = tofloat( tostring(tChr(:,2:3)) )
  month = tofloat( tostring(tChr(:,4:5)) )  
  day   = tofloat( tostring(tChr(:,6:7)) )
  hour  = tofloat( tostring(tChr(:,8:9)) )
  
  lat   = tofloat( tostring(tChr(:,10:13)) )
  lon   = tofloat( tostring(tChr(:,15:18)) )
  vmax  = tofloat( tostring(tChr(:,21:23)) )
  
  type  =          tostring(tChr(:,30:30)) 
  
  beginning = new((/ncurves/),integer)
  ending    = new((/ncurves/),integer)

  ic = 0
  beginning(ic) = 0
  do i=1,dimsizes(hour)-1
  
; Look for end of storm record (first check to see if at end of file)
     if (i.eq.dimsizes(hour)-1) then
        ending(ic) = i
     else  
        if (sn(i-1).ne.sn(i)) then
           ending(ic) = i-1
	   ic = ic + 1
	   beginning(ic) = i
        end if  	
     end if
   
  end do

  lengths      = ending - beginning + 1
  max_npts     = max(lengths)                           ; Max # of points.


; Now rearrange the arrays to hold individual curve data
  msg_val  = -999.            ; Set to a safe missing value.
  
  new_lat    = new((/ncurves,max_npts/),float,msg_val) 
  new_lon    = new((/ncurves,max_npts/),float,msg_val)
  new_hour   = new((/ncurves,max_npts/),float,msg_val)
  new_day    = new((/ncurves,max_npts/),string,msg_val)
  new_vmax   = new((/ncurves,max_npts/),float,msg_val)

  new_type   = new((/ncurves,max_npts/),string,msg_val)


  do nc = bcurve,ncurves-1
     new_lat(nc,0:lengths(nc)-1) = lat(beginning(nc):ending(nc))/10.0
     new_lon(nc,0:lengths(nc)-1) = -lon(beginning(nc):ending(nc))/10.0
     new_hour(nc,0:lengths(nc)-1) = hour(beginning(nc):ending(nc))
     new_day(nc,0:lengths(nc)-1) = day(beginning(nc):ending(nc))
     new_vmax(nc,0:lengths(nc)-1) = vmax(beginning(nc):ending(nc))
      
     new_type(nc,0:lengths(nc)-1) = type(beginning(nc):ending(nc))  
        
  end do 
     
; Now create arrays that only hold the points for the 00z locations
  lat0 = mask(new_lat,new_hour,0)
  lon0 = mask(new_lon,new_hour,0) 
  
  lat12 = mask(new_lat,new_hour,12)
  lon12 = mask(new_lon,new_hour,12)
  day12 = mask(new_day,new_hour,12)
  

;********************************
; select sub-regions
;********************************
     minlat =     0.0	; deg N
     maxlat =    57.0	; deg N
     minlon =  -100.0	; - deg E = deg W
     maxlon =   -20.0	; - deg E = deg W

;***** Define some NICE color maps to use.
   colors_6 = (/"White","Black","Black","MediumPurple1","MediumPurple3","Blue1",\
          "CadetBlue3","Aquamarine2","SeaGreen2","LawnGreen","Green4", \
          "GreenYellow","Gold","Tan1","Sienna1","Tomato","VioletRed1", \
          "Yellow","DarkGreen","Grey37","Red","Orange","GoldenRod1","DarkOrange","SteelBlue1","SlateBlue1", \
          "LightSlateBlue","DarkSeaGreen","Magenta","DodgerBlue","Moccasin"/)

   
;********************************
; create plot
;********************************

   wks = gsn_open_wks("png","unique")     ; send graphics to PNG file

   res                  = True 
   res@gsnMaximize      = True
   res@gsnPaperOrientation = "Portrait"
   res@gsnDraw          = False   ; so we can add poly stuff
   res@gsnFrame         = False   ; do not advance frame

   res@mpDataBaseVersion = "MediumRes"     ; Alias 'MediumRes'
   res@mpDataSetName     = "Earth..1" 

   res@mpProjection        = "LambertConformal" 
   res@mpLambertParallel1F =  20.0
   res@mpLambertParallel2F =  40.0
   res@mpLambertMeridianF  = -60.0
   
   res@mpLimitMode = "LatLon"
   res@mpMinLatF   = minlat 
   res@mpMaxLatF   = maxlat
   res@mpMinLonF   = minlon
   res@mpMaxLonF   = maxlon
  
   res@mpFillOn               = True    ; False to turn off gray continents
   res@mpOutlineOn            = True    ; turn on continental outline
   res@mpOutlineBoundarySets  = "AllBoundaries" 

   res@mpLandFillColor        = "GoldenRod1"
   res@mpInlandWaterFillColor = "PaleTurquoise3"
   res@mpOceanFillColor       = "PaleTurquoise3"

   res@mpGeophysicalLineColor      = "Grey37"
   res@mpGeophysicalLineThicknessF = 0.5
   
   res@mpUSStateLineColor          = "Grey37"
   res@mpUSStateLineThicknessF     = 0.5
   
   res@mpNationalLineColor	   = "Grey37" 
   res@mpNationalLineThicknessF    = 0.5
   
   res@mpGridAndLimbOn        = "True"
   res@mpGridAndLimbDrawOrder = "Draw"
   res@mpGridMaskMode         = "MaskLand"
   res@mpGridSpacingF         = 5.0
   res@mpGridLineColor        = "Grey37"

   res@tmXBLabelFontHeightF = 0.005
   res@tmXBMajorLengthF     = -0.001

   res@pmTickMarkDisplayMode = "Always"

  
;***************************************
; plot base map                        *
;***************************************

    plot = gsn_csm_map(wks,res)	     ; draw one of eight map projections

   
;***************************************
; Draw best track history as polylines *
;***************************************   

   res_poly                    = True			; polyline mods desired
 
; Create array of dummy graphic variables. This is required, b/c each line
; must be associated with a unique dummy variable.

  dum  = new(dimsizes(hour),graphic)   

  ic = 0
  do i=0,ncurves-1
     do k=0,max_npts-2

        if(.not.ismissing(new_lat(i,k)))

	   res_poly@gsLineDashPattern  = 0
           res_poly@gsLineThicknessF   = 4    

if(.not. TypeOn) then

; Plot hurricane segments
           if((new_vmax(i,k).gt.64).and.(new_type(i,k).eq."*")) then
              res_poly@gsLineColor        = "Red"                        
              dum(ic) = gsn_add_polyline(wks,plot,new_lon(i,k:k+1),new_lat(i,k:k+1),res_poly)
              ic = ic + 1
           end if

; Plot tropical storm segments       
           if((new_vmax(i,k).lt.64).and.(new_vmax(i,k).gt.34).and.(new_type(i,k).eq."*")) then
              res_poly@gsLineColor        = "Yellow"                 
              dum(ic) = gsn_add_polyline(wks,plot,new_lon(i,k:k+1),new_lat(i,k:k+1),res_poly)
              ic = ic + 1	      
           end if  

; Plot tropical depression segments
           if((new_vmax(i,k).lt.34).and.(new_type(i,k).eq."*")) then
              res_poly@gsLineColor        = "DarkGreen"                 
              dum(ic) = gsn_add_polyline(wks,plot,new_lon(i,k:k+1),new_lat(i,k:k+1),res_poly)
              ic = ic + 1
           end if 

; Now plot the subtropical segments with dashed lines

; Plot hurricane segments of subtropical systems with dashed red lines
           if((new_vmax(i,k).gt.64).and.(new_type(i,k).eq."S")) then
              res_poly@gsLineColor        = "Red"                        
	      res_poly@gsLineDashPattern  = 2
	      res_poly@gsLineDashSegLenF  = 0.1
              dum(ic) = gsn_add_polyline(wks,plot,new_lon(i,k:k+1),new_lat(i,k:k+1),res_poly)
              ic = ic + 1
           end if

; Plot tropical storm segments of subtropical systems with dashed yellow lines       
           if((new_vmax(i,k).lt.64).and.(new_vmax(i,k).gt.34).and.(new_type(i,k).eq."S")) then
              res_poly@gsLineColor        = "Yellow"
	      res_poly@gsLineDashPattern  = 2
	      res_poly@gsLineDashSegLenF  = 0.1                 
              dum(ic) = gsn_add_polyline(wks,plot,new_lon(i,k:k+1),new_lat(i,k:k+1),res_poly)
              ic = ic + 1	      
           end if  

; Plot tropical depression segments of subtropical systems with dashed dark green lines
           if((new_vmax(i,k).lt.34).and.(new_type(i,k).eq."S")) then
              res_poly@gsLineColor        = "DarkGreen" 
	      res_poly@gsLineDashPattern  = 2
	      res_poly@gsLineDashSegLenF  = 0.1                
              dum(ic) = gsn_add_polyline(wks,plot,new_lon(i,k:k+1),new_lat(i,k:k+1),res_poly)
              ic = ic + 1
           end if 

else    ; if(TypeOn) -- plot pure tropical segments as solid lines (red for hurricane, etc.). 

; Plot hurricane segments
           if((new_vmax(i,k).gt.64).and.(new_type(i,k).eq."*")) then
              res_poly@gsLineColor        = "Red"                        
              dum(ic) = gsn_add_polyline(wks,plot,new_lon(i,k:k+1),new_lat(i,k:k+1),res_poly)
              ic = ic + 1
           end if

; Plot tropical storm segments       
           if((new_vmax(i,k).lt.64).and.(new_vmax(i,k).gt.34).and.(new_type(i,k).eq."*")) then
              res_poly@gsLineColor        = "Yellow"                 
              dum(ic) = gsn_add_polyline(wks,plot,new_lon(i,k:k+1),new_lat(i,k:k+1),res_poly)
              ic = ic + 1	      
           end if  

; Plot tropical depression segments
           if((new_vmax(i,k).lt.34).and.(new_type(i,k).eq."*")) then
              res_poly@gsLineColor        = "DarkGreen"                 
              dum(ic) = gsn_add_polyline(wks,plot,new_lon(i,k:k+1),new_lat(i,k:k+1),res_poly)
              ic = ic + 1
           end if 

   if(PlotWaveSegments) then  

; Plot tropical wave segments
           if(new_type(i,k).eq."W") then
              res_poly@gsLineColor        = "DarkGreen"                 
	      res_poly@gsLineDashPattern  = 2
	      res_poly@gsLineDashSegLenF  = 0.1
              dum(ic) = gsn_add_polyline(wks,plot,new_lon(i,k:k+1),new_lat(i,k:k+1),res_poly)
              ic = ic + 1
           end if 
   end if	   


   if(PlotLowSegments) then  

; Plot remanant low segments
           if(new_type(i,k).eq."L") then
              res_poly@gsLineColor        = "SlateBlue"                 
	      res_poly@gsLineDashPattern  = 2
	      res_poly@gsLineDashSegLenF  = 0.1
	      dum(ic) = gsn_add_polyline(wks,plot,new_lon(i,k:k+1),new_lat(i,k:k+1),res_poly)
              ic = ic + 1
           end if 
   end if
   

   if(PlotSubTropicalSegments) then
        
; Plot subtropical storm segments       
           if((new_vmax(i,k).gt.34).and.(new_type(i,k).eq."S")) then
              res_poly@gsLineColor        = "DarkOrange"                  
              dum(ic) = gsn_add_polyline(wks,plot,new_lon(i,k:k+1),new_lat(i,k:k+1),res_poly)
              ic = ic + 1	      
           end if 

; Plot subtropical depression segments
           if((new_vmax(i,k).lt.34).and.(new_type(i,k).eq."S")) then
              res_poly@gsLineColor        = "Blue1"                 
              dum(ic) = gsn_add_polyline(wks,plot,new_lon(i,k:k+1),new_lat(i,k:k+1),res_poly)
              ic = ic + 1
           end if 

   end if


   if(PlotExtraTropicalSegments) then   

; Plot extratropical segments
           if(new_type(i,k).eq."E") then
              res_poly@gsLineColor        = "Black"        
	      res_poly@gsLineDashPattern  = 2
	      res_poly@gsLineDashSegLenF  = 0.1
              dum(ic) = gsn_add_polyline(wks,plot,new_lon(i,k:k+1),new_lat(i,k:k+1),res_poly)
              ic = ic + 1
           end if 
   end if
end if
	
	end if

     end do
  end do
   

;***************************************
; Draw black polymarkers at 00Z locations
;*************************************** 
   res_mark = True

   res_mark@gsMarkerIndex    = 1       ; polymarker style
   res_mark@gsMarkerSizeF    = 0.012   ; polymarker size
   res_mark@gsMarkerColor    = "Black" ; change marker color

   duma = new(ncurves,graphic)

   do ic=bcurve,ncurves-1
      duma(ic) = gsn_add_polymarker(wks,plot,lon0(ic,:),lat0(ic,:),res_mark)
   end do
   
; Now draw white polymarkers at 12z locations
   res_mark@gsMarkerIndex    = 1
   res_mark@gsMarkerSizeF    = 0.012   ; polymarker size
   res_mark@gsMarkerColor    = "White" ; change marker color
      
   
   dumb = new(ncurves,graphic)
   
   do ic=bcurve,ncurves-1
      dumb(ic) = gsn_add_polymarker(wks,plot,lon12(ic,:),lat12(ic,:),res_mark)
   end do 

;***************************
; Plot some text labels    *
;***************************
 
   txres    = True

; Now draw the day labels each 00Z marker

   txres@txFontHeightF = 0.0035
   txres@txJust       = "TopCenter"
   
;
; Count number of text strings we'll be adding. There is probably
; a better way to do this (so you don't have to use a double do loop).
;
   ntext = 0
   do i=bcurve,ncurves-1
     do k=0,lengths(i)-1
        if(.not.ismissing(day12(i,k)).and..not.ismissing(lon12(i,k)).and.\
                                          .not.ismissing(lat12(i,k))) then
           ntext = ntext + 1
        end if
     end do
   end do

   dumt1 = new(ntext,graphic)
   dumt2 = new(ncurves-bcurve,graphic)
   dumt3 = new(ncurves-bcurve,graphic)

   ii = 0
   do i=bcurve,ncurves-1
     do k=0,lengths(i)-1
        if(.not.ismissing(day12(i,k)).and..not.ismissing(lon12(i,k)).and.\
                                          .not.ismissing(lat12(i,k))) then
          dumt1(ii) = gsn_add_text(wks,plot,day12(i,k),lon12(i,k),lat12(i,k)-0.45,txres)
          ii = ii + 1
       end if
     end do
   end do  

; Draw storm number (actually these are strings) at beginning of track      
   txres@txFontHeightF = 0.0044
   txres@txJust        = "CenterLeft"
   
   txres@txPerimOn             = True
   txres@txPerimColor          = "Black"
   txres@txPerimThicknessF     = 1.0
   txres@txPerimSpaceF         = 0.4
   txres@txBackgroundFillColor = "White"

   do i=bcurve,ncurves-1
      if(.not.ismissing(ssn(i)).and..not.ismissing(new_lon(i,0)).and.\
                                    .not.ismissing(new_lat(i,0))) then
        dumt2(i-bcurve) = gsn_add_text(wks,plot,ssn(i),new_lon(i,0)+0.6, \
                                                       new_lat(i,0),txres)
      end if
   end do

; Now draw them at the end
   txres@txJust = "BottomRight"
   do i=bcurve,ncurves-1
      if(.not.ismissing(ssn(i)).and. \
         .not.ismissing(new_lon(i,lengths(i)-1)).and.\
         .not.ismissing(new_lat(i,lengths(i)-1))) then
        dumt3(i-bcurve) = gsn_add_text(wks,plot,ssn(i), \
                                       new_lon(i,lengths(i)-1), \
                                       new_lat(i,lengths(i)-1),txres)
     end if
   end do

   txres@txFontHeightF        = 0.007
   txres@txJust               = "CenterCenter"
   txres@txPerimSpaceF        = 1.0
   txres@txPerimThicknessF    = 1.5
   txres@txConstantSpacingF   = 1.0
   txres@txFontAspectF        = 1.5
   txres@txFontThicknessF     = 0.4
   txres@gsnDraw              = False
;
; Note: the X and Y positions in this case don't matter, because the
; text will get repositioned in the "gsn_add_anotation" function.
;
   lambert_text = gsn_create_text(wks,"~F02~ Lambert Conformal Conic ~C~ True at 20~0557~ and 40~0557~ North ",txres)
	
if (.not. TypeOn) then
   txres@txFontHeightF        = 0.006
   txres@txJust               = "CenterCenter"
   txres@txPerimSpaceF        = 0.7
   txres@txPerimThicknessF    = 1.5
   txres@txConstantSpacingF   = 1.0
   txres@txFontAspectF        = 1.5
   txres@txFontThicknessF     = 0.8
   txres@gsnDraw              = True
   gsn_text_ndc(wks,"~F02~ Remnant low, tropical wave, and ~C~ extratropical stages are not shown. ~C~~C~ Subtropical stages are dashed.",0.715,0.680,txres)
end if

   txres@txFontHeightF        = 0.012
   txres@txPerimThicknessF    = 1.5
   txres@txPerimSpaceF        = 0.5
   txres@txConstantSpacingF   = 1.0
   txres@txFontAspectF        = 1.5
   txres@txFontThicknessF     = 1.6
   txres@gsnDraw              = False

;
; Note: the X and Y positions in this case don't matter, because the
; text will get repositioned in the "gsn_add_anotation" function.
;
   atlantic_text = gsn_create_text(wks,"~F02~ " + yyyy + " Atlantic Tropical Cyclones",txres)

   txres@txFontHeightF        = 0.005
   txres@txPerimThicknessF    = 1.5
   txres@txPerimSpaceF        = 1.0
   txres@txConstantSpacingF   = 1.0
   txres@txFontAspectF        = 1.5
   txres@txFontThicknessF     = 0.8

   if (yyyy .eq. 2001) then
      txres@gsnDraw              = True
      gsn_text_ndc(wks,"~F02~ 1  T Allison   05-17 Jun.     ~C~ 2  Two         11-12 Jul.     ~C~ 3  T Barry     02-07 Aug.     ~C~ 4  T Chantal   14-22 Aug.     ~C~ 5  T Dean      22-28 Aug.     ~C~ 6  H Erin      01-15 Sep.     ~C~ 7  H Felix     06-18 Sep.~C~",0.263,0.650,txres)       
      gsn_text_ndc(wks,"~F02~ 8  H Gabrielle 11-19 Sep.     ~C~ 9  Nine        19-20 Sep.     ~C~10  H Humberto  21-27 Sep.     ~C~11  H Iris      04-09 Oct.     ~C~12  T Jerry     06-08 Oct.     ~C~13  H Karen     12-15 Oct.     ~C~14  T Lorenzo   27-31 Oct.~C~",0.263,0.355,txres)
      gsn_text_ndc(wks,"~F02~15  H Michelle  29 Oct.-05 Nov.~C~16  H Noel      04-06 Nov.     ~C~17  H Olga      24 Nov.-04 Dec.~C~"                                                                                                                                   ,0.263,0.310,txres)
   end if   
   
   if (yyyy .eq. 2002) then
      txres@gsnDraw              = True
      gsn_text_ndc(wks,"~F02~ 1  T Arthur    14-16 Jul.     ~C~ 2  T Bertha    04-09 Aug.     ~C~ 3  T Cristobal 05-08 Aug.     ~C~ 4  T Dolly     29 Aug.-04 Sep.~C~ 5  T Edouard   01-06 Sep.     ~C~ 6  T Fay       05-08 Sep.     ~C~ 7  Seven       07-08 Sep.~C~",0.263,0.650,txres)
      gsn_text_ndc(wks,"~F02~ 8  H Gustav    08-12 Sep.     ~C~ 9  T Hanna     11-14 Sep.     ~C~10  H Isidore   14-26 Sep.     ~C~11  T Josephine 17-19 Sep.     ~C~12  H Kyle      20 Sep.-12 Oct.~C~13  H Lili      21 Sep.-04 Oct.~C~14  Fourteen    14-16 Oct.~C~",0.263,0.360,txres)
   end if
   
   if(yyyy .eq. 2003) then
      txres@txFontHeightF        = 0.0075
      txres@gsnDraw              = False
      ana_text = gsn_create_text(wks,"~F02~ 1  T Ana       20-24 Apr.     ~C~ 2  Two         10-11 Jun.     ~C~ 3  T Bill      29 Jun.-02 Jul.~C~ 4  H Claudette 08-17 Jul.     ~C~ 5  H Danny     16-21 Jul.     ~C~ 6  Six         19-21 Jul.     ~C~ 7  Seven       25-27 Jul.~C~",txres) 

     erika_text = gsn_create_text(wks,"~F02~ 8  H Erika     14-17 Aug.     ~C~ 9  Nine        21-22 Aug.     ~C~10  H Fabian    27 Aug.-08 Sep.~C~11  T Grace     30-02 Sep.     ~C~12  T Henri     03-08 Sep.     ~C~13  H Isabel    06-19 Sep.     ~C~14  Fourteen    08-10 Sep.~C~",txres)
      juan_text = gsn_create_text(wks,"~F02~15  H Juan      24-29 Sep.     ~C~16  H Kate      25 Sep.-07 Oct.~C~17  T Larry     01-06 Oct.     ~C~18  T Mindy     10-14 Oct.     ~C~19  T Nicholas  13-23 Oct.     ~C~20  T Odette    04-07 Dec.     ~C~21  T Peter     07-11 Dec.~C~",txres)

     amres                  = True
     amres@amParallelPosF   = -0.49
     amres@amOrthogonalPosF = -0.43
     amres@amJust           = "TopLeft"
     txid1 = gsn_add_annotation(plot,ana_text,amres)

     amres@amParallelPosF   = -0.49
     amres@amOrthogonalPosF =  0.35
     amres@amJust           = "BottomLeft"
     txid2 = gsn_add_annotation(plot,erika_text,amres)

     amres@amParallelPosF   = -0.49
     amres@amOrthogonalPosF =  0.35
     amres@amJust           = "TopLeft"
     txid3 = gsn_add_annotation(plot,juan_text,amres)
   end if

;******************
; Plot a legend   *
;******************
 lgres                    = True
 
 lgres@lgAutoManage       = False
  
 lgres@vpWidthF           = 0.1       ; was 0.08        ; width of legend (NDC)
 lgres@vpHeightF          = 0.1       ; was 0.08        ; height of legend (NDC)
; lgres@lgBottomMarginF    = 0.17     ; was 0.25

 lgres@lgPerimFill        = 0                     ; Use solid fill (0) instead of the default hollow fill
 lgres@lgPerimFillColor   = "Background"

; lgres@lgBoxMajorExtentF  = 0.4
 lgres@lgBoxMinorExtentF  = 0.2	; controls how wide the box holding the legend items (lines and markers) can be in relation to legend
 
; lgres@lgBoxBackground    = "PaleTurquoise3"
 
 lgres@lgMonoItemType        = False                 ; indicates that we wish to set the item types individually
 lgres@lgMonoMarkerIndex     = False
 lgres@lgMonoLineThickness   = False
 lgres@lgMonoMarkerThickness = False
 lgres@lgMonoMarkerSize      = False

; Position fine elements of legend relative to some positional values:

if (yyyy .eq. 2002) then
   xlegend = 0.710 
   ylegend = 0.350
else
   xlegend = 0.680 
   ylegend = 0.390
end if

if(TypeOn) then

   lgres@lgLabelFont             = 0
   lgres@lgLabelFontHeightF      = 0.04
   lgres@lgLabelFontAspectF      = 1.2
   lgres@lgLabelConstantSpacingF = 0.0

   lgres@lgItemCount        = 11
   lgres@lgLineDashSegLenF  = 0.1
   lgres@lgItemTypes        = (/"Markers","Markers","Markers","Lines","Lines","Lines","Lines","Lines","Lines","Lines","Lines"/)
   lgres@lgMarkerIndexes    = (/        1,        4,       16,      0,      0,     0,       0,       0,    0,       0,      0/)
   lgres@lgLineThicknesses  = (/      0.1,      0.1,      0.1,    4.0,    4.0,  4.0,      4.0,     4.0,  4.0,     4.0,    4.0/)
   lgres@lgMarkerColors     = (/  "White",  "Black", "Black"/)
   lgres@lgMarkerSizes      = (/   0.0001,   0.004,    0.004/)
   lgres@lgLineColors       = (/  "White", "Black",  "Black",\
                                "SlateBlue1",   "DarkGreen",     "Black",          "Blue1",         "Dark Orange",     "DarkGreen",        "Yellow",          "Red"       /) ; colors for legend lines
   lgres@lgDashIndexes      = (/       0,      0,     0,\
                                     2,             2,              2,               0,                   0,               0,                 0,               0         /) ; dash indexes

   legend_labels = (/"Tropical Cyclone No.","1200 UTC Position/Date", \
                     "0000 UTC Position","Remnant Low","Tropical Wave", \
                     "Extratropical","Subtropical Dep.","Subtropical Storm",\
                     "Tropical Dep.","Tropical Storm (T)","Hurricane (H)"/)
   legend = gsn_create_legend(wks,10,legend_labels,lgres)

   yoffset_day   = -0.0858
   yoffset_storm = -0.0910

else
 
   lgres@lgLabelFont             = 0
   lgres@lgLabelFontHeightF      = 0.004
   lgres@lgLabelFontAspectF      = 1.2
   lgres@lgLabelConstantSpacingF = 0.0

   lgres@lgItemCount        = 6
   lgres@lgItemTypes        = (/"Markers","Markers","Markers","Lines"    ,"Lines" ,"Lines"/)
   lgres@lgLineColors       = (/"White",  "Black"  ,"Black"  ,"DarkGreen","Yellow","Red"  /)    ; colors for legend lines
   lgres@lgLineThicknesses  = (/    0.1,        0.1,      0.1,        4.0,     4.0,    4.0/)
   lgres@lgDashIndexes      = (/      0,          0,        0,          0,       0,      0/)    
   lgres@lgMarkerIndexes    = (/      0,          4,       16,          0,       0,      0/)	
   lgres@lgMarkerColors     = (/"White",  "Black"  ,  "Black"/)
   lgres@lgMarkerSizes      = (/ 0.0001,      0.004,     0.004/)

   gsn_legend_ndc(wks,5,(/"Tropical Cyclone No.","1200 UTC Position/Date","0000 UTC Position",\
                          "Tropical Dep.","Tropical Storm (T)","Hurricane (H)"/),xlegend,ylegend,lgres)  

   yoffset_day   = -0.0750	; offsets for the case where we don't plot all the extra cases
   yoffset_storm = -0.0875

end if
 
; Now draw a day label on the legend

   txres@txPerimOn             = False
   txres@txFontHeightF         = 0.0022
   txres@txPerimSpaceF         = 0.0
   txres@txJust                = "CenterCenter"

   txres@gsnDraw               = False

;
; Note: the X and Y positions in this case don't matter, because the
; text will get repositioned in the "gsn_add_anotation" function.
;
   number_text = gsn_create_text(wks,"21",txres)

; Draw storm number on the legend      
   txres@txFontHeightF = 0.0028

   txres@txPerimOn             = True
   txres@txPerimColor          = "Black"
   txres@txPerimThicknessF     = 1.0
   txres@txPerimSpaceF         = 0.4
   txres@txBackgroundFillColor = "White"

   three_text = gsn_create_text(wks,"3",txres)  	

;
; Add the various text and legend annotations to the plot.
;
   amres@amParallelPosF   = -0.13
   amres@amOrthogonalPosF = -0.48
   amres@amJust           = "TopCenter"
   txid4 = gsn_add_annotation(plot,atlantic_text,amres)

   amres@amParallelPosF   = 0.383
   amres@amOrthogonalPosF = 0.470
   amres@amJust           = "BottomRight"
   txid5 = gsn_add_annotation(plot,number_text,amres)

   amres@amParallelPosF   = 0.3815
   amres@amOrthogonalPosF = 0.479
   amres@amJust           = "BottomRight"
   txid6 = gsn_add_annotation(plot,three_text,amres)

   amres@amParallelPosF   = 0.49
   amres@amOrthogonalPosF = 0.49
   amres@amJust           = "BottomRight"
   annoid1 = gsn_add_annotation(plot,legend,amres)

   amres@amJust           = "BottomCenter"
   amres@amParallelPosF   = 0.00
   amres@amOrthogonalPosF = 0.49
   annoid2 = gsn_add_annotation(plot,lambert_text,amres)

   draw(plot)

   frame(wks)
  
end
