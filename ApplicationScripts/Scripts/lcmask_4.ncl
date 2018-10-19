;*************************************************
; lcmask_4.ncl
;
; Concepts illustrated:
;   - Adding longitude/latitude labels to a masked Lambert Conformal map
;   - Moving the main title up
;   - Attaching text strings to the outside of a plot
;   - Converting lat/lon values to NDC values
;   - Changing the angle of text strings
;   - Adding a carriage return to a text string using a function code
;*************************************************
;
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl" 
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"   

;----------------------------------------------------------------------
; This procedure attaches lat/lon labels to a masked lambert plot
;
; You will likely need to change lat_values and/or lon_values to
; contain the locations where you want lat/lon labels.
;----------------------------------------------------------------------
procedure add_lc_labels(wks,map,minlat,maxlat,minlon,maxlon,\
                        lat_spacing[1]:integer,lon_spacing[1]:integer)
local lat_values, nlat, lat1_ndc, lat2_ndc, lon1_ndc, lon2_ndc,slope,txres, \
lon_values, PI, RAD_TO_DEG, dum_lft, dum_rgt, dum_bot
begin
  PI         = 3.14159
  RAD_TO_DEG = 180./PI

;---Pick some "nice" values for the latitude labels.
  lat_values = ispan(toint(minlat),toint(maxlat),lat_spacing) * 1.
  nlat       = dimsizes(lat_values)
;
; We need to get the slope of the left and right min/max longitude lines.
; Use NDC coordinates to do this.
;
  lat1_ndc = new(1,float)
  lon1_ndc = new(1,float)
  lat2_ndc = new(1,float)
  lon2_ndc = new(1,float)
  datatondc(map,minlon,lat_values(0),lon1_ndc,lat1_ndc)
  datatondc(map,minlon,lat_values(nlat-1),lon2_ndc,lat2_ndc)
  if(lon2_ndc.eq.lon1_ndc) then
      print("add_lc_labels: error: not enough valid latitude values to generate labels")
      print("    You may need to decrease the lat_spacing")
      exit
  end if
  slope_lft = (lat2_ndc-lat1_ndc)/(lon2_ndc-lon1_ndc)

  datatondc(map,maxlon,lat_values(0),lon1_ndc,lat1_ndc)
  datatondc(map,maxlon,lat_values(nlat-1),lon2_ndc,lat2_ndc)
  if(lat2_ndc.eq.lat1_ndc) then
      print("add_lc_labels: error: not enough valid longitude values to generate labels")
      print("    You may need to decrease the lon_spacing")
      exit
  end if
  slope_rgt = (lat2_ndc-lat1_ndc)/(lon2_ndc-lon1_ndc)

;---Set some text resources
  txres               = True
  txres@txFontHeightF = 0.01
  txres@txPosXF       = 0.1
;
; Loop through lat values, and attach labels to the left and
; right edges of the masked LC plot.  The labels will be 
; rotated to fit the line better.
;
  dum_lft = new(nlat,graphic)    ; Dummy array to hold attached strings.
  dum_rgt = new(nlat,graphic)    ; Dummy array to hold attached strings.
  do n=0,nlat-1
; Add extra white space to labels.
    lat_label_rgt = "          "  + lat_values(n) + "~S~o~N~"

;---Check if North, South, or Zero
    if(lat_values(n).lt.0) then
      lat_label_lft = lat_values(n) + "~S~o~N~S          "
      lat_label_rgt = lat_label_rgt + "S"
    end if
    if(lat_values(n).gt.0) then
      lat_label_lft = lat_values(n) + "~S~o~N~N          "
      lat_label_rgt = lat_label_rgt + "N"
    end if
    if(lat_values(n).eq.0) then
      lat_label_lft = lat_values(n) + "~S~o~N~           "
    end if

;---Left label
    txres@txAngleF = RAD_TO_DEG * atan(slope_lft) - 90
    dum_lft(n) = gsn_add_text(wks,map,lat_label_lft,minlon,lat_values(n),txres)

;---Right label
    txres@txAngleF = RAD_TO_DEG * atan(slope_rgt) + 90
    dum_rgt(n) = gsn_add_text(wks,map,lat_label_rgt,maxlon,lat_values(n),txres)
  end do

;----------------------------------------------------------------------
; Now do longitude labels. These are harder because we're not
; adding them to a straight line.
;
; Loop through lon values, and attach labels to the bottom edge of the
; masked LC plot.
;
  delete(txres@txPosXF)
  txres@txPosYF = -5.0

;---Pick some "nice" values for the longitude labels.
  lon_values = ispan(toint(minlon+10),toint(maxlon-10),lon_spacing) * 1.
  nlon       = dimsizes(lon_values)

  dum_bot = new(nlon,graphic)    ; Dummy array to hold attached strings.

  do n=0,nlon-1
;
; For each longitude label, we need to figure out how much to rotate
; it, so get the approximate slope at that point.
;
    datatondc(map,lon_values(n)-0.25,minlat,lon1_ndc,lat1_ndc)
    datatondc(map,lon_values(n)+0.25,minlat,lon2_ndc,lat2_ndc)
    slope_bot = (lat1_ndc-lat2_ndc)/(lon1_ndc-lon2_ndc)
    txres@txAngleF  = atan(slope_bot) * RAD_TO_DEG
;
; Create longitude label. Add extra carriage returns to
; move label away from plot.
;
;---Check if East, West, or Zero
    lon_label_bot = "  ~C~  ~C~" + abs(lon_values(n)) + "~S~o~N~"
    if(lon_values(n).lt.0) then
      lon_label_bot = lon_label_bot + "W"
    end if
    if(lon_values(n).gt.0) then
      lon_label_bot = lon_label_bot + "E"
    end if

;---Attach to map.
    dum_bot(n) = gsn_add_text(wks,map,lon_label_bot,lon_values(n),minlat,txres)
  end do
end


;----------------------------------------------------------------------
; Main code.
;----------------------------------------------------------------------
begin
;************************************************
; read in netCDF file
;************************************************
  a = addfile("atmos.nc","r")
  v = a->V

  minlat             =  20.                ; min lat to mask
  maxlat             =  80.                ; max lat to mask
  minlon             = -90.                ; min lon to mask
  maxlon             =  40.                ; max lon to mask

;************************************************
; create plot
;************************************************
  wks = gsn_open_wks("png","lcmask")            ; send graphics to PNG file

  res                       = True              ; plot mods desired
  res@gsnMaximize           = True              ; enlarge plot
  res@gsnDraw               = False             ; Don't draw yet
  res@gsnFrame              = False             ; Don't advance frame yet

  res@mpProjection          = "LambertConformal"; choose projection

  res@cnFillOn              = True              ; turn on color
  res@cnLinesOn             = False             ; turn off contour lines
  res@cnFillPalette         = "rainbow"         ; set color map

  res@mpMinLatF             = minlat
  res@mpMaxLatF             = maxlat
 
  res@mpMinLonF             = minlon
  res@mpMaxLonF             = maxlon

  res@gsnMaskLambertConformal = True            ; turn on lc masking
  res@mpGridAndLimbOn         = True  
  res@mpGridLatSpacingF       = 10
  res@mpGridLonSpacingF       =  5
  res@gsnAddCyclic            = False

  res@tiMainString            = "Adding lat/lon labels to a masked LC map"
  res@tiMainOffsetYF          = 0.01   ; Move title up a little
  res@gsnRightString          = ""
  res@gsnLeftString           = ""

  v&lon = v&lon-180                             ; make lon go -180 to 180 

  plot  = gsn_csm_contour_map(wks,v(0,0,{minlat:maxlat},{minlon:maxlon}),res); create plot

;---Attach latitude labels
  lat_spacing = 10   ; use integers here
  lon_spacing = 10
  add_lc_labels(wks,plot,minlat,maxlat,minlon,maxlon,lat_spacing,lon_spacing)

;---Drawing the plot will also draw all the attached labels.
  draw(plot)
  frame(wks)
end
