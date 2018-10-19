;----------------------------------------------------------------------
; minmax_4.ncl
;
; Concepts illustrated:
;   - Using the WhiteBlue color map
;   - Replacing colors in the existing color map with named colors
;   - Changing the contour level spacing
;   - Attaching polymarkers to a contour plot
;   - Calculating the local minima/maxima of your data
;   - Adding text strings at local minima/maxima locations
;   - Drawing a custom legend outside of a map plot
;----------------------------------------------------------------------
;
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"   
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"  

begin
;---Open file and read in Sea Surface Temperature Anomalies
  a   = addfile("sst8292a.nc","r")
  sst = a->SSTA(0,:,:)
  dims = dimsizes(sst)
  sst1d = ndtooned(sst)
  sst1d@lat1d = ndtooned(conform_dims(dims,sst&lat,0))
  sst1d@lon1d = ndtooned(conform_dims(dims,sst&lon,1))

;---Start the graphics
  wks = gsn_open_wks("x11","minmax")          ; send graphics to PNG file

  res                      = True

  res@gsnMaximize          = True               ; maximize plot in frame
;  res@gsnDraw              = False
;  res@gsnFrame             = False

  res@cnFillOn             = True               ; turn on contour fill
  res@cnFillMode           = "RasterFill"
  res@cnFillPalette        = "WhiteBlue"        ; set color map
  res@cnLinesOn            = False              ; turn off contour lines
  res@cnLineLabelsOn       = False              ; turn off contour labels
  res@cnLevelSpacingF      = 0.2

  res@tiMainString         = "January 1982"
;  res@mpFillDrawOrder      = "PostDraw"         ; Draw map fill last

;---Create plot
  nt = 0
  plot = gsn_csm_contour_map(wks,sst1d,res)
end
