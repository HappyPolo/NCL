;********************************************************
; annotate_5.ncl
;
; Concepts illustrated:
;   - Labeling a map with dots and text strings
;   - Reading a specific field from an ASCII file
;   - Reading a specific column from an ASCII file
;   - Reading an ASCII file with several columns of data
;   - Drawing the counties of Colorado
;*************************************************
;
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
;**************************************************
begin
   ncl_version = get_ncl_version()
; 
; Read columns using str_get_field and str_get_cols.
;
   data       = asciiread("annotate5.txt",-1,"string")
   lats       = tofloat(str_get_field(data,2," "))
   lons       = -tofloat(str_get_field(data,3," "))
   city_state = str_get_cols(data,22,-1)
   cities     = str_get_field(city_state,1,",")  ; Remove the ",CO"

;
; Remove duplicate cities.
;
   cities@_FillValue = "missing"
   do i=0,dimsizes(cities)-2
     if(any(cities(i).eq.cities(i+1:))) then
       cities(i) = cities@_FillValue
     end if
   end do

; Start the graphics.
   wks      = gsn_open_wks("png","annotate")         ; send graphics to PNG file

   res                       = True
   res@gsnDraw               = False                 ; don't draw
   res@gsnFrame              = False                 ; don't advance frame
   res@gsnMaximize           = True

; We want county outlines.
   res@mpDataBaseVersion     = "MediumRes"
   res@mpDataSetName         = "Earth..2"
   res@mpOutlineBoundarySets = "GeophysicalAndUSStates"
   res@mpOutlineSpecifiers   = (/"Land","Colorado:counties"/)

; No gray fill.
   res@mpFillOn              = False

; Zoom in on Colorado, U.S.
   res@mpLimitMode           = "LatLon"
   res@mpMinLatF             = 36.9
   res@mpMaxLatF             = 41.2
   res@mpMinLonF             = -109.1
   res@mpMaxLonF             = -102

; Turn off tickmarks.
   res@gsnTickMarksOn        = False

; Main title
   res@tiMainString          = "Cities of Colorado (NCL version " + ncl_version + ")"

   map = gsn_csm_map_ce(wks,res)                  ; create map
 
;
; Add some text strings. Note that no effort is made here
; to remove overlapping strings. See example 10 on the text
; applications page on how to do this.
;
   txres               = True
   txres@txJust        = "CenterLeft"
   txres@txFontHeightF = 0.01

   text = gsn_add_text(wks,map,"  " + cities,lons,lats,txres)

; Add dots
   mkres               = True
   mkres@gsMarkerIndex = 16
   mkres@gsMarkerColor = "blue"
   markers = gsn_add_polymarker(wks,map,lons,lats,mkres)

   draw(map)         ; Now draw map and advance frame.
   frame(wks)        ; Dots and text will be drawn too.  
end

