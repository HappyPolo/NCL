;**********************************************************************
; polyg_14.ncl
;
; Concepts illustrated:
;   - Drawing polylines and markers using great circle paths
;   - Using gc_latlon to calculate a great circle path
;   - Attaching polylines and markers to a map plot
;
;**********************************************************************
;
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"   
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"   

begin
  npts = 10              ; arbitrary
  lat1 = 20.
  lon1 = -120.
  lat2 = 60.
  lon2 = -64.
  
  wks  = gsn_open_wks("png","polyg")    ; send graphics to PNG file 

  res                    = True
  res@gsnMaximize        = True         ; make ps, pdf, eps, .. large
  res@gsnDraw            = False        ; don't draw plot yet
  res@gsnFrame           = False        ; don't advance frame yet

  space                  =   5          ; arbitrary
  res@mpMinLatF          = lat1-space   ; range to zoom in on
  res@mpMaxLatF          = lat2+space
  res@mpMinLonF          = lon1-space
  res@mpMaxLonF          = lon2+space

  res@tiMainString       = "1st method: Two Points and Great Circle Path"
  res@tiMainFontHeightF  = 0.015
  res@gsnCenterString    = "res@mpGreatCircleLinesOn = True"
  res@gsnCenterStringFontHeightF = 0.011
;----------------------------------------------------------------------
; For the first method, we will simply set:
;
;     res@mpGreatCircleLinesOn = True
;
; which means when we attach a polyline to the map later, it will be
; done using a great circle path. This uses more points than the
; second method we employ below.
;
  res@mpGreatCircleLinesOn = True

;---Create the map, but it won't be drawn yet.
  plot1 = gsn_csm_map_ce(wks,res)  

;---Resources for the polyline
  pres                  = True           ; polyline mods desired
  pres@gsLineThicknessF = 2.0            ; line thickness   
  pres@gsLineColor      = "blue"         ; color of lines

;---Attach the polyline
  dum1 = gsn_add_polyline(wks,plot1, (/lon1, lon2/) , (/lat1, lat2/) ,pres)

;---Drawing the plot will draw the attached polyline too.
  draw(plot1)
  frame(wks)

;----------------------------------------------------------------------
; For the second method, we will create the great circle path
; ourselves, using gc_latlon.
;----------------------------------------------------------------------

;---Recreate the map with this resource set to False (the default)
  res@tiMainString       = "2nd method: Two Points and Great Circle Path"
  res@gsnCenterString    = "gc_latlon used to calculate great circle points"

  res@mpGreatCircleLinesOn = False

  plot2 = gsn_csm_map_ce(wks,res)  

  gcdist = gc_latlon(lat1,lon1, lat2,lon2, npts,2)

  print (gcdist)
  print (gcdist@gclat+"  "+gcdist@gclon )  ; print the lats/lons
  
  pres@gsLineColor      = "red"         ; color of lines
  dum2 = gsn_add_polyline(wks,plot2, gcdist@gclon ,gcdist@gclat ,pres)

;
; Additionally add markers to each of the 'npts' on the 
; great circle path.
;
  mkres               = True
  mkres@gsMarkerIndex = 16     ; Filled circle
  mkres@gsMarkerSizeF = 0.035
  mkres@gsMarkerColor  = "black" 
  dum3 = gsn_add_polymarker(wks,plot2,gcdist@gclon ,gcdist@gclat ,mkres)

;---Drawing the plot will draw the attached polylines and markers.
  draw(plot2)
  frame(wks)

;
; The third plot compares the two methods.
;
;  pres             = True
;  pres@gsnMaximize = True
;  gsn_panel(wks,(/plot1,plot2/),(/2,1/),pres)
end

