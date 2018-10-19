;----------------------------------------------------------------------
; This script plots the first timestep for every variable on
; the "nemomed8_1y_2D.nc" file that is numeric, 3D, and 
; doesn't have min(x) equal to max(x).
;
; The purpose of this script is to get a quick visual look at
; all of the numeric variables on the file.
;----------------------------------------------------------------------
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"   
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"   
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"

begin
  filename = "nemomed8_1y_2D.nc"
  f        = addfile (filename, "r")
  lat2d    = f->nav_lat             ; (y,x)
  lon2d    = f->nav_lon             ; (y,x)
  nt       = 0                      ; time index to plot

;---Get all the variable names on the file
  varnames = getfilevarnames(f)
  nvars    = dimsizes(varnames)

;---Convert 'time' coordinate array to better units
  date = cd_calendar(f->time_counter, -3)   ; YYYYMMDDHH

;---Set some resources
  res              = True
  res@gsnMaximize  = True               ; Maximize size of plot

  res@tiMainString    = filename
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
  res@cnLinesOn       = False         ; Turn off contour lines

  res@mpLandFillColor        = "tan"
  res@mpOceanFillColor       = "LightBlue"
  res@mpInlandWaterFillColor = "LightBlue"

  res@pmTickMarkDisplayMode    = "Always"  ; tickmarks with degree symbol

  res@pmLabelBarOrthogonalPosF = 0.1       ; move labelbar away from plot
  res@tiMainOffsetYF           = -0.04     ; move title towards plot

  plot_count = 0                           ; plot counter

  do i=0,nvars-1
    x = f->$varnames(i)$
    if(isnumeric(x).and.dimsizes(dimsizes(x)).eq.3) then
;
; The missing value has to be fixed. The x@_FillValue value
; is not quite equal to the the actual data missing values.
;
      x = where(x.ge.x@_FillValue,x@_FillValue,x)

;---Don't plot if min of data equals max of data.
      if(min(x).eq.max(x)) then
        print("Min==Max for '" + varnames(i) + "'...won't plot")
        continue
      end if

;---Start the graphics
      wks = gsn_open_wks("png" ,"NEMO_plot_" + varnames(i))
      print("Plotting '" + varnames(i) + "...")

;---Set some titles
      res@tiMainString  = filename + " (" + varnames(i) + ")"
      res@gsnLeftString = x@long_name

;---Draw the plot
      plot = gsn_csm_contour_map(wks,x(nt,:,:),res)
    else
      print("Skipping '" + varnames(i) + "'...")
    end if
    delete(x)
  end do
end
