;*************************************************
; mptick_12.ncl
;
; Concepts illustrated:
;   - Adding longitude/latitude labels to a Robinson map
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
; This function attaches lat/lon labels to a Robinson plot.
;
; You will likely need to change lat_values and/or lon_values to
; contain the locations where you want lat/lon labels.
;----------------------------------------------------------------------
function add_robinson_labels(wks,map,latspc,lonspc)
local lat_values, lon_values, nlat, nlon, txres, \
      dum_lft, dum_rgt, dum_bot
begin
  minlat =  -90
  maxlat =   90
  minlon = -180
  maxlon =  180

;---Pick some "nice" values for the latitude labels.
  lat_values = ispan(minlat,maxlat,latspc) * 1.
  lon_values = ispan(minlon,maxlon,lonspc) * 1.
  nlat       = dimsizes(lat_values)
  nlon       = dimsizes(lon_values)

;---Set some text resources
  txres               = True
  txres@txFontHeightF = 0.01
;
; Loop through lat values, and attach labels to the left and
; right edges of the Robinson plot.
;
  dum_lft = new(nlat,graphic)    ; Dummy arrays to hold attached strings.
  dum_rgt = new(nlat,graphic)

;
; Create the labels. Add space before right labels, and
; after left labels.
;
  lat_lft_label = where(lat_values.lt.0,abs(lat_values)+"~S~o~N~S",\
                                        lat_values+"~S~o~N~N")
  lat_lft_label = where(lat_values.eq.0,"0",lat_lft_label)
;---No label at lat=abs(90)
  lat_lft_label = where(abs(lat_values).eq.90,"",lat_lft_label)
  lat_rgt_label = "  " + lat_lft_label
  lat_lft_label =        lat_lft_label + "  "

  do n=0,nlat-1
;---Left label
    txres@txJust = "CenterRight"
    dum_lft(n) = gsn_add_text(wks,map,lat_lft_label(n),minlon,\
                                      lat_values(n),txres)
;---Right label
    txres@txJust = "CenterLeft"
    dum_rgt(n) = gsn_add_text(wks,map,lat_rgt_label(n),maxlon,\
                                       lat_values(n),txres)
  end do

;---Bottom label
  lon_bot_label = where(lon_values.lt.0,abs(lon_values)+"~S~o~N~W",\
                                        lon_values+"~S~o~N~E")
  lon_bot_label = where(lon_values.eq.0,"0",lon_bot_label)
;---No label at lon=abs(180)
  lon_bot_label = where(abs(lon_values).eq.180,"",lon_bot_label)

  dum_bot = new(nlon,graphic)

  do n=0,nlon-1
    txres@txJust = "TopCenter"
    dum_bot(n) = gsn_add_text(wks,map,lon_bot_label(n),lon_values(n),\
                                      minlat,txres)
  end do

;---Make sure these ids "live" outside this function.
  map@dumlft = dum_lft
  map@dumrgt = dum_rgt
  map@dumbot = dum_bot

  return(map)
end

;----------------------------------------------------------------------
; Main code.
;----------------------------------------------------------------------
begin
  wks = gsn_open_wks("png" ,"mptick")           ; send graphics to PNG file

  res                       = True              ; plot mods desired

  res@gsnDraw               = False
  res@gsnFrame              = False
  res@gsnMaximize           = True              ; Draw the plot at largest size

  res@mpProjection          = "Robinson"        ; choose projection
  res@mpPerimOn             = False

  res@mpGridAndLimbOn       = True  
  res@mpGridLatSpacingF     = 30
  res@mpGridLonSpacingF     = 90

  res@tiMainString          = "Adding lat/lon labels to Robinson map"

  plot  = gsn_csm_map(wks,res)    ; create map

;---Attach latitude labels
  map = add_robinson_labels(wks,plot,30,90)

;---Drawing the plot will also draw all the attached labels.
  draw(plot)
  frame(wks)
end
