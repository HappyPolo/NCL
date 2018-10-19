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

load "./shapefile_utils.ncl"

begin
;---Open file and read in Sea Surface Temperature Anomalies
  a   = addfile("sst8292a.nc","r")
  sst = lonFlip(a->SSTA(0,:,:))

;
; Create a mask array the same size as "u", using
; lat/lon data read off a shapefile.
;
  shpfile   = "GSHHS_shp/c/GSHHS_c_L1.shp"
print_shapefile_info(shpfile)
printVarSummary(sst)

  opt             = True
  opt@return_mask = True
  land_mask = shapefile_mask_data(sst,shpfile,opt)
  sst_mask_land = where(land_mask.eq.1,sst,sst@_FillValue)
  sst_mask_ocean = where(land_mask.eq.0,sst,sst@_FillValue)

  dims = dimsizes(sst_mask_land)
  sst1d_land       = ndtooned(sst_mask_land)
  sst1d_land@lat1d = ndtooned(conform_dims(dims,sst&lat,0))
  sst1d_land@lon1d = ndtooned(conform_dims(dims,sst&lon,1))
  sst1d_ocean       = ndtooned(sst_mask_ocean)
  sst1d_ocean@lat1d = ndtooned(conform_dims(dims,sst&lat,0))
  sst1d_ocean@lon1d = ndtooned(conform_dims(dims,sst&lon,1))

;---Start the graphics
  wks = gsn_open_wks("x11","minmax")          ; send graphics to PNG file

  res                      = True

  res@gsnMaximize          = True               ; maximize plot in frame
;  res@gsnDraw              = False
;  res@gsnFrame             = False

  res@cnFillOn             = True               ; turn on contour fill
;  res@cnFillMode           = "RasterFill"
  res@cnLinesOn            = False              ; turn off contour lines
  res@cnLineLabelsOn       = False              ; turn off contour labels
  res@cnLevelSpacingF      = 0.2

  res@tiMainString         = "January 1982"
  res@mpFillOn             = False
;  res@mpFillDrawOrder      = "PostDraw"         ; Draw map fill last

;---Create plot
  nt = 0
  res@cnFillPalette        = "MPL_reds"
  plot_land = gsn_csm_contour_map(wks,sst1d_land,res)
  res@cnFillPalette        = "WhiteBlue"        ; set color map
;  plot_ocean = gsn_csm_contour_map(wks,sst1d_ocean,res)
  res@lbOrientation = "Vertical"
  plot_ocean = gsn_csm_contour(wks,sst1d_ocean,res)

  overlay(plot_land,plot_ocean)
  draw(plot_land)
  frame(wks)

end
