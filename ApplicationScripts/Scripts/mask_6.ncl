;*************************************************
; mask_6.ncl
;
; Concepts illustrated:
;   - Masking out areas of your data based on a mask shape
;   - Drawing filled contours over a satellite map
;   - Changing the view of a satellite map
;   - Labeling states on a map of the United States
;   - Drawing a circle on a map
;   - Creating a color map using RGB triplets
;   - Using draw order resources to mask areas in a plot
;
;************************************************
;
;  Description:  This example draws contours bands within a circle
;                on a satellite map projection. It also shows how to
;                use the gsn_add_polyline, gsn_add_polymarker, and
;                gsn_add_text routines  to draw lines, markers, and
;                text on a map projection.
;                
;
; This file is loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"

begin

; Initialize some variables used as dimension sizes later.
  NCLS    = 100
  NCIRC   = 100
  NTEXT    = 50
  NCOLORS = 23

;
; Define the state-labelling data, and the lat/lon locations of each.
;
  name = (/"AL","AK","AZ","AR","CA","CO","CT","DE","FL","GA","HI","ID","IL",\
           "IN","IA","KS","KY","LA","ME","MD","MA","MI","MN","MS","MO","MT",\
           "NE","NV","NH","NJ","NM","NY","NC","ND","OH","OK","OR","PA","RI",\
           "SC","SD","TN","TX","UT","VT","VA","WA","WV","WI","WY"/)

  slat = (/33.0, 65.0, 34.7, 35.0, 37.5, 39.0, 41.6, 39.0, 28.5, 32.5, 20.0, \
           43.5, 40.2, 40.0, 42.0, 38.5, 37.4, 31.2, 45.5, 39.2, 42.3, 44.0, \
           46.0, 32.5, 38.5, 47.0, 41.5, 39.8, 43.2, 39.7, 34.7, 43.0, 35.5, \
           47.5, 40.2, 35.6, 44.0, 40.8, 41.7, 34.0, 44.5, 36.0, 32.0, 39.5, \
           44.2, 37.6, 47.5, 38.5, 44.5, 43.0 /)

  slon = (/-86.5, -152.0, -111.5, -92.5, -120.5, -105.8, -72.6, -75.5, -82.0,\
           -83.0, -157.0, -114.0, -89.2, -86.0, -93.2, -98.2, -84.5, -92.5,\
           -69.0, -76.5, -72.0, -85.0, -94.5, -89.5, -92.5, -109.5, -99.5,\
           -117.0, -71.6, -74.5, -106.0, -75.0, -79.5, -100.5, -82.5, -97.5,\
           -120.2, -77.6, -71.5, -80.5, -100.5, -86.5, -100.0, -111.5, -72.5,\
           -78.6, -120.5, -80.8, -89.5, -107.5 /)
;
; Create a "great" circle in lat/lon coordinates. We don't want to draw
; any contour lines outside of this circle.
;
  cminlon = -115.
  cmaxlon = -95.
  cminlat = 32.
  cmaxlat = 48.
  ctrlat  = 40.
  ctrlon  = -105.
  xlonrng = cmaxlon - cminlon
  xlatrng = cmaxlat - cminlat
  ii      = ispan(0,NCIRC-1,1)
  clon    = ctrlon + 7.*cos((ii*6.28)/(NCIRC-1))
  clat    = ctrlat + 7.*sin((ii*6.28)/(NCIRC-1))
  delete(ii)
;
; Generate some dummy data to contour later.
;
  zdat    = new((/NCLS,NCLS/),float,1.e12)
  xlonstp = xlonrng/(NCLS-1);
  xlatstp = xlatrng/(NCLS-1);
  ii      = ispan(0,NCLS-1,1)
  x       = (1.*ii)/(NCLS-1)
  xlon    = cminlon + ii * xlonstp
  dist    = new((/NCLS/),float)
  delete(ii)

;
; Set data values to missing outside the given circle.
;
  do j = 0,NCLS-1
      xlat = cminlat + j * xlatstp
      dist = sqrt((ctrlat-xlat)*(ctrlat-xlat) + (ctrlon-xlon)*(ctrlon-xlon))
;
; If xlat/xlon falls outside of circle, then we don't
; want to contour this location.
;
      if (num(dist.le.7.0).ne.0) then
        y = (1.*j)/(NCLS-1)
        inds = ind(dist.le.7.0)
        zdat(j,(/inds/)) = x((/inds/))^2 + y^2 + x((/inds/))*y \
                           + sin(9.*x((/inds/)))*cos(9.*y)
        delete(inds)
      end if
      zdat(j,ind(dist.gt.7.0)) = zdat@_FillValue
  end do
  delete(dist)

;-------------------Start the graphics---------------------

  wks = gsn_open_wks("png","mask")    ; send graphics to PNG file

; Create a color map.
  cmap = new((/NCOLORS,3/),float)
  cmap(0:6,:) = (/ (/1., 1., 1./), (/0., 0., 0./), (/.6, .6, .6/), \
                    (/0., 0., 0./), (/1., 1, 1./), (/.4, .4, .4/), \
                    (/1., 1., 0./)/)

  ii = ispan(8,NCOLORS,1)
  cmap(7:NCOLORS-1,0) = (NCOLORS-ii)/15.
  cmap(7:NCOLORS-1,1) = 0
  cmap(7:NCOLORS-1,2) = (ii-8)/15.
  delete(ii)

  gsn_define_colormap(wks,cmap)    ; Set the color map.

;
; Set up resource list for contours and map.
;
  res                             = True

  res@gsnMaximize                 = True      ; maximize plot in frame
  res@gsnDraw                     = False     ; Don't draw plot or
  res@gsnFrame                    = False     ; advance frame.

  res@sfXCStartV                  = cminlon   ; Location to overlay
  res@sfXCEndV                    = cmaxlon   ; contour data on map.
  res@sfYCStartV                  = cminlat
  res@sfYCEndV                    = cmaxlat

;
; Set the contour levels and colors.
;
  res@cnLevels                    = 15
  res@cnFillOn                    = True
  res@cnFillColors                = ispan(7,22,1)
  res@cnLineLabelsOn              = False
  res@cnLinesOn                   = False
  res@cnInfoLabelOn               = False

; 
; Set map projection and attributes.
;
  res@mpProjection                = "satellite"

  res@mpLimitMode                 = "angles"
  res@mpLeftAngleF                = 20.
  res@mpRightAngleF               = 20.
  res@mpTopAngleF                 = 20.
  res@mpBottomAngleF              = 20.

  res@mpCenterLatF                = 38.
  res@mpCenterLonF                = -76.
  res@mpCenterRotF                = 75.
  res@mpSatelliteAngle1F          = 7.*57.2957795130823*asin(1./1.3)/8.
  res@mpSatelliteAngle2F          = 90.
  res@mpSatelliteDistF            = 1.3

  res@mpFillOn                    = True
  res@mpFillDrawOrder             = "PreDraw"
  res@mpFillColor                 = "gray40"
  res@mpMonoFillColor             = True

  res@mpPerimOn                   = True

  res@mpGridAndLimbDrawOrder      = "draw"
  res@mpGridLineColor             = "gray60"
  res@mpGridLineThicknessF        = 2.0
  res@mpGridSpacingF              = 1.0

  res@mpOutlineBoundarySets       = "GeophysicalAndUSStates"
  res@mpOutlineDrawOrder          = "PostDraw"
  res@mpUSStateLineThicknessF     = 2.0
  res@mpGeophysicalLineThicknessF = 2.0

; Main title
  res@tiMainString                = "Satellite view of contour bands in a limited area"
  res@tiMainFontHeightF           = 0.015


; Create the contours over the map, but nothing will get drawn yet.
  map = gsn_contour_map(wks,zdat,res)

; Attach some text strings.
  txres               = True
  txres@txAngleF      = -45.
  txres@txFontColor   = "yellow"
  txres@txFontHeightF = 0.02

  text = new(NTEXT,graphic)
  do i=0,NTEXT-1
    text(i) = gsn_add_text(wks,map,name(i),slon(i),slat(i),txres)
  end do

; Attach a circle around the contours.
; We can share the marker and line resource list here.
;
  gsres                  = True
  gsres@gsLineColor      = "black"
  gsres@gsLineThicknessF = 2.
  circ = gsn_add_polyline(wks,map,clon,clat,gsres)
;
; Attach a polymarker at the position of Boulder, Colorado
; (where NCAR is located).
;
  gsres@gsMarkerColor      = "yellow"
  gsres@gsMarkerSizeF      = 0.014
  gsres@gsMarkerThicknessF = 2.
  mark = gsn_add_polymarker(wks,map,ctrlon,ctrlat,gsres)

;
; Drawing the map will cause everything we've added with
; gsn_add_xxxx to be drawn as well.
;
  draw(map)
  frame(wks)
end
