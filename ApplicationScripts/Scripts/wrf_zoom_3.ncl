;--------------------------------------------------
; wrf_zoom_3.ncl
;--------------------------------------------------
; Concepts illustrated:
;   - Plotting WRF data on non-native grid
;   - Zooming in on a WRF map using special WRF resources
;   - Plotting data using wrf_xxxx and gsn_csm_xxxx_map functions
;--------------------------------------------------
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/wrf/WRFUserARW.ncl"

;----------------------------------------------------------------------
; Main code
;----------------------------------------------------------------------
begin
  filename = "wrfout_d03_2012-04-22_23_00_00"
  a = addfile(filename + ".nc", "r")

  td2   = wrf_user_getvar(a,"td2",0)
  lat2d = wrf_user_getvar(a,"lat",0)
  lon2d = wrf_user_getvar(a,"lon",0)

  minlat = min(lat2d)   ; for use later
  maxlat = max(lat2d)
  minlon = min(lon2d)
  maxlon = max(lon2d)

  td2@lat2d = lat2d   ; for plotting
  td2@lon2d = lon2d

  wks = gsn_open_wks("png","wrf_zoom")

;---Create filled contour plot of original domain (td2)
  res                       = True
  res@gsnMaximize           = True
  res@cnFillOn              = True
  res@gsnAddCyclic          = False         ; data is regional
  res@lbOrientation         = "Vertical"    ; default is horizontal

  res@mpDataBaseVersion     = "MediumRes"   ; LowRes is default
  res@pmTickMarkDisplayMode = "Always"      ; nicer tickmarks
  res@pmTitleZone           = 4             ; move main title down
  res@tiMainFont            = "helvetica"   ; default is helvetica-bold
 
;---Draw full domain over map
  res@mpMinLatF             = minlat-1      ; Leave a little bit of a margin
  res@mpMaxLatF             = maxlat+1      ; so you can see shape of actual
  res@mpMinLonF             = minlon-1      ; WRF domain
  res@mpMaxLonF             = maxlon+1

  res@tiMainString = "Full plot - non-native projection"
  plot_full = gsn_csm_contour_map(wks,td2,res)

;---Select new area of interest and redraw plot
  res@mpMinLatF = minlat
  res@mpMaxLatF = maxlat - (maxlat-minlat) * 0.25
  res@mpMinLonF = minlon + (maxlon-minlon) * 0.25
  res@mpMaxLonF = maxlon

  res@tiMainString = "Zoomed in plot - non-native projection"
  plot_zoom = gsn_csm_contour_map(wks,td2,res)
end
