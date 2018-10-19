load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"   
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"   
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"

begin
  filename = "PSY3V3R1_1dAV_20110530_20110531_icemod_R20110608.nc"
  f        = addfile (filename, "r")
  icethk   = short2flt(f->iicethic)      ; ( time_counter, y, x )
                                         ; (1,1021,1442)
  lat2d    = f->nav_lat                  ; (y,x)
  lon2d    = f->nav_lon

;---Set all values equal to 0.0 to missing, for a different plot.
  icethk = where(icethk.eq.0,icethk@_FillValue,icethk)

;---Start the graphics
  wks = gsn_open_wks("ps","ORCA025_icemod")
  gsn_define_colormap(wks,"BlAqGrYeOrReVi200")    ; change colormap

;---Set some resources
  res              = True
  res@gsnMaximize  = True               ; Maximize size of plot

;---This will position data correctly on map.
  res@sfYArray     = lat2d
  res@sfXArray     = lon2d
  res@gsnAddCyclic = False              ; Don't add longitude cyclic point

  res@cnFillOn           = True
  res@cnLinesOn          = False
  res@cnLabelBarEndStyle = "IncludeMinMaxLabels"  ; turn on min/max labels
  res@lbOrientation      = "Vertical"

; res@cnFillMode         = "RasterFill"     ; For "blocky" contours.
                                            ; Possibly faster.

  res@mpDataSetName     = "Earth..4"    ; Database that contains the
  res@mpDataBaseVersion = "MediumRes"   ; ice shelves.

  nt = 0     ; time index

;---Create two plots, NH and SH
  res@gsnPolar     = "NH"          ; Northern Hemisphere
  res@mpMinLatF    = 50            ; Specify minimum latitude
  res@tiMainString = "Northern hemisphere"
  plot = gsn_csm_contour_map_polar(wks,icethk(nt,:,:),res)
  delete(res@mpMinLatF)

  res@gsnPolar     = "SH"          ; Southern Hemisphere
  res@mpMaxLatF    = -55           ; Specify maximum latitude
  res@tiMainString = "Southern hemisphere"
  plot = gsn_csm_contour_map_polar(wks,icethk(nt,:,:),res)
end

