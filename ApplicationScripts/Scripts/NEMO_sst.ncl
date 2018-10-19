load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"   
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"   
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"

begin
  filename = "nemomed8_1y_2D.nc"
  f        = addfile (filename, "r")
  sst      = f->sosstsst            ; (time_counter, y, x) 
  lat2d    = f->nav_lat             ; (y,x)
  lon2d    = f->nav_lon             ; (y,x)
  nt       = 0                      ; time index to plot
;
; The missing value had to be fixed. They didn't seem exactly
; equal to the _FillValue associated with the variable.
;
  sst = where(sst.ge.sst@_FillValue,sst@_FillValue,sst)

;---Convert 'time' coordinate array to better units
  date = cd_calendar(sst&time_counter, -3)   ; YYYYMMDDHH

;---Start the graphics
  wks = gsn_open_wks("ps" ,"NEMO_sst")
  gsn_define_colormap(wks,"BlAqGrYeOrReVi200")     ; change color map

;---Set some resources
  res              = True
  res@gsnMaximize  = True               ; Maximize size of plot

  res@tiMainString    = filename
  res@gsnLeftString   = sst@long_name
  res@gsnCenterString = date(nt)

;---This will position data correctly on map.
  res@sfXArray     = lon2d
  res@sfYArray     = lat2d

  res@gsnAddCyclic = False      ; Data not global, don't add lon cyclic pt

  res@mpDataBaseVersion      = "MediumRes"

;---Zoom in on map
  res@mpMinLatF    = min(lat2d)
  res@mpMaxLatF    = max(lat2d)
  res@mpMinLonF    = min(lon2d)
  res@mpMaxLonF    = max(lon2d)

  res@cnFillOn        = True          ; Turn on contour fill
  res@cnFillMode      = "RasterFill"    ; "AreaFill","CellFill","RasterFill
  res@cnLinesOn       = False         ; Turn off contour lines
  res@cnLevelSpacingF = 0.5           ; NCL was using 1.0

  res@mpFillOn        = False

  res@pmTickMarkDisplayMode    = "Always"  ; tickmarks with degree symbol
  res@pmLabelBarOrthogonalPosF = 0.1       ; move labelbar away from plot
  res@tiMainOffsetYF           = -0.04     ; move title towards plot

  plot = gsn_csm_contour_map(wks,sst(nt,:,:),res)
end
