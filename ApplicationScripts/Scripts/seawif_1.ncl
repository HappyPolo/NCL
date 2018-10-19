;*********************************************
; seawif_1.ncl
;*********************************************
;
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"

begin
  hdf = addfile("SWland.hdf","r")
  tmp  = hdf->NDVI

; NDVI on the file is short data and must be convert to float data. There
; is a function in contributed.ncl that does this for us. to get a float,
; you must multiply by the scale factor and add the offset.
  ndvi = short2flt(tmp)

; there is no lat/lon data on the file. It must be calculated from the
; formula given. you can see the info on the file by: print(hdf)

  dims      = dimsizes(ndvi)
  nrows     = dims(0)
  npixels   = dims(1)

  lat2d = new((/nrows,npixels/),float)  ; predefine arrays
  lon2d = new((/nrows,npixels/),float)

  y    = ispan(1,nrows,1)               ; create x/y arrays
  x    = ispan(1,npixels,1)

  lat = (1920.5 - y)*(90.0/2160.0)
  do i=0,npixels-1
    lat2d(:,i) = lat
  end do
  pi = 3.1415926

  do i=0,nrows-1
      lon2d(i,:) = 360.+((x-2639.5)/cos(lat(i)*pi/180.0))*(180./4320.)
  end do

  ndvi@lat2d = lat2d(::5,::5)
  ndvi@lon2d = lon2d(::5,::5)
;********************************
; plot
;********************************
  wks = gsn_open_wks("png","seawif")                ; send graphics to PNG file

; this plot is large, so we increase the amount of memory  
  setvalues NhlGetWorkspaceObjectId()
    "wsMaximumSize": 66556743
  end setvalues

  res                   = True               ; plot mods desired
  
  res@cnLinesOn         = False              ; turn off contour lines
  res@cnFillOn          = True               ; color plot desired
  res@cnFillPalette     = "BkBlAqGrYeOrReViWh200"  ; set color map
  res@cnLineLabelsOn    = False              ; turn off contour lines
  res@gsnAddCyclic      = False              ; non-global data
  res@cnFillMode        = "RasterFill"       ; turn on raster mode
  res@gsnMaximize       = True               ; blow up plot as much as poss

; zoom in the map. note, we DO NOT want to set the longitude boundaries
; by min(lon),max(lon) etc, b/c this data has a longitude range of -264 to 339
; It is necessary to set the longitude to the try geophysical extent.
  res@mpMinLatF       = min(lat2d)
  res@mpMaxLatF       = max(lat2d)
  res@mpMinLonF        = -170
  res@mpMaxLonF        = -20

; note, if you subsample the data above (e.g. lat2d(::5,::5) ), you 
; must also subsample here. this is why we also reverse the lat orientation
; here.  
  plot = gsn_csm_contour_map(wks,ndvi(::5,::5),res)
end
