;----------------------------------------------------------------------
; mptick_10.ncl
;
; Concepts illustrated:
;   - Adding longitude/latitude labels to a masked Lambert Conformal map
;   - Moving the main title up
;   - Attaching text strings to the outside of a plot
;   - Converting lat/lon values to NDC values
;   - Changing the angle of text strings
;   - Adding a carriage return to a text string using a function code
;----------------------------------------------------------------------
; This script should work in the northern or southern hemisphere, but 
; hasn't been tested extensively. If there are problems with this
; script, please post them to ncl-talk@ucar.edu 
;----------------------------------------------------------------------
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
procedure add_lc_labels(wks,map,minlat,maxlat,minlon,maxlon)
local lat_values, nlat, lat1_ndc, lat2_ndc, lon1_ndc, lon2_ndc,slope,txres, \
lon_values, PI, RAD_TO_DEG, dum_lft, dum_rgt, dum_bot, rotate_val
begin
  PI         = 3.14159
  RAD_TO_DEG = 180./PI

;---Determine whether we are in northern or southern hemisphere
  if(minlat.ge.0.and.maxlat.gt.0) then
    HEMISPHERE = "NH"
  else
    HEMISPHERE = "SH"
  end if

;---Pick some "nice" values for the latitude labels.
  lat_values = ispan(toint(minlat),toint(maxlat),10) * 1.
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
  slope_lft = (lat2_ndc-lat1_ndc)/(lon2_ndc-lon1_ndc)

  datatondc(map,maxlon,lat_values(0),lon1_ndc,lat1_ndc)
  datatondc(map,maxlon,lat_values(nlat-1),lon2_ndc,lat2_ndc)
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
;---Left label
    if(HEMISPHERE.eq."NH") then
      rotate_val = -90
      direction  = "N"
    else
      rotate_val = 90
      direction  = "S"
    end if

; Add extra white space to labels.
    lat_label_lft = abs(lat_values(n)) + "~S~o~N~" + direction + \
                    "          "   
    lat_label_rgt = "          "  + abs(lat_values(n)) + "~S~o~N~" + \
                    direction

    txres@txAngleF = RAD_TO_DEG * atan(slope_lft) + rotate_val
    dum_lft(n) = gsn_add_text(wks,map,lat_label_lft,minlon,lat_values(n),txres)

;---Right label
    if(HEMISPHERE.eq."NH") then
      rotate_val = 90
    else
      rotate_val = -90
    end if
    txres@txAngleF = RAD_TO_DEG * atan(slope_rgt) + rotate_val
    dum_rgt(n) = gsn_add_text(wks,map,lat_label_rgt,maxlon,lat_values(n),txres)
  end do

;----------------------------------------------------------------------
; Now do longitude labels. These are harder because we're not
; adding them to a straight line.
;
; Loop through lon values, and attach labels to the bottom edge
; for northern hemisphere, or top edge for southern hemisphere.
;
  delete(txres@txPosXF)
  txres@txPosYF = -5.0

;---Pick some "nice" values for the longitude labels.
  lon_values = ispan(toint(minlon+10),toint(maxlon-10),10) * 1.
  nlon       = dimsizes(lon_values)
  lon_values = where(lon_values.gt.180,360-lon_values,lon_values)

  dum_bot = new(nlon,graphic)    ; Dummy array to hold attached strings.

  lon_labels = "" + lon_values
  lon_labels = where(lon_values.lt.0, abs(lon_values) + \
                    "~S~o~N~W",""+lon_labels)
  lon_labels = where(lon_values.eq.0,"0",lon_labels)
  lon_labels = where(lon_values.gt.0,lon_values + "~S~o~N~E",lon_labels)
  if(HEMISPHERE.eq."NH") then
    lon_labels = "  ~C~  ~C~" + lon_labels
    lat_val   = minlat
  else
    lon_labels = lon_labels + "~C~ ~C~ "
    lat_val    = maxlat
  end if

  do n=0,nlon-1
;
; For each longitude label, we need to figure out how much to rotate
; it, so get the approximate slope at that point.
;
    if(HEMISPHERE.eq."NH") then
;---Add labels to bottom of LC plot
      datatondc(map,lon_values(n)-0.25,minlat,lon1_ndc,lat1_ndc)
      datatondc(map,lon_values(n)+0.25,minlat,lon2_ndc,lat2_ndc)
    else
;---Add labels to top of LC plot
      datatondc(map,lon_values(n)+0.25,maxlat,lon1_ndc,lat1_ndc)
      datatondc(map,lon_values(n)-0.25,maxlat,lon2_ndc,lat2_ndc)
    end if
    slope_bot = (lat1_ndc-lat2_ndc)/(lon1_ndc-lon2_ndc)
    txres@txAngleF  = atan(slope_bot) * RAD_TO_DEG
;
; Create longitude label. Add extra carriage returns to
; move label away from plot.
;

;---Attach to map.
    dum_bot(n) = gsn_add_text(wks,map,lon_labels(n),lon_values(n),\
                              lat_val,txres)
  end do
end


;----------------------------------------------------------------------
; Main code.
;----------------------------------------------------------------------
begin
  minlon             = -90.                ; min lon to mask
  maxlon             =  40.                ; max lon to mask

  wks = gsn_open_wks("png" ,"mptick")            ; open a ps file

  res                       = True              ; plot mods desired
  res@gsnMaximize           = True              ; enlarge plot
  res@gsnDraw               = False             ; Don't draw yet
  res@gsnFrame              = False             ; Don't advance frame yet

  res@mpProjection          = "LambertConformal"; choose projection
  res@gsnMaskLambertConformal = True            ; turn on lc masking

  res@mpMinLonF             = minlon
  res@mpMaxLonF             = maxlon

  res@mpGridAndLimbOn         = True  
  res@mpGridLatSpacingF       = 10
  res@mpGridLonSpacingF       =  5

  res@tiMainFontHeightF       = 0.01
  res@tiMainOffsetYF          = 0.02   ; Move title up a little
  res@gsnRightString          = ""
  res@gsnLeftString           = ""

;---Northern hemisphere
  minlat           =  20.                ; min lat to mask
  maxlat           =  80.                ; max lat to mask
  res@mpMinLatF    = minlat
  res@mpMaxLatF    = maxlat
  res@tiMainString = "Adding lat/lon labels to a masked LC map (northern hemisphere)"

  plot  = gsn_csm_map(wks,res)    ; create map

;---Attach latitude labels
  add_lc_labels(wks,plot,minlat,maxlat,minlon,maxlon)

;---Drawing the plot will also draw all the attached labels.
  draw(plot)
  frame(wks)

;---Southern hemisphere
  minlat           = -80.                ; min lat to mask
  maxlat           = -20.                ; max lat to mask
  res@mpMinLatF    = minlat
  res@mpMaxLatF    = maxlat
  res@tiMainString = "Adding lat/lon labels to a masked LC map (southern hemisphere)"
  plot  = gsn_csm_map(wks,res)    ; create map

;---Attach latitude labels
  add_lc_labels(wks,plot,minlat,maxlat,minlon,maxlon)

;---Drawing the plot will also draw all the attached labels.
  draw(plot)
  frame(wks)
end
