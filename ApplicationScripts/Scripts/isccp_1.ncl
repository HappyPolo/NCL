;*************************************************
; isccp_1.ncl           
;
; Concepts illustrated:
;   - Contouring ISCCP data
;   - Contouring one-dimensional X, Y, Z data
;   - Drawing filled contours over a Lambert Equal Area map
;   - Drawing raster contours
;   - Smoothing raster contours
;   - Drawing a map using the medium resolution map outlines
;   - Zooming in on a particular area on a Lambert Equal Area map
;======================================================================
;
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"

begin
  f = addfile("isccp.nc","r")
  topo = f->topo

  wks = gsn_open_wks("png","isccp")     ; send graphics to PNG file

;
; Set bare number of resources needed to just create a plot,
; so we can get some information on the axis limits.
;
  res                   = True

  res@gsnDraw           = False    ; Don't draw plot just yet
  res@gsnFrame          = False
  
  res@sfXArray          = f->lon
  res@sfYArray          = f->lat

  contour = gsn_csm_contour(wks,topo,res)   ; Just create plot.

  delete(res@gsnDraw)
  delete(res@gsnFrame)

;
; Now set the resources that we want to apply when
; we draw the contours over the map.
;
  res@gsnMaximize       = True

  res@cnFillOn          = True
  res@cnFillPalette     = "wh-bl-gr-ye-re"; set color map
  res@cnFillMode        = "RasterFill"    ; Default is "AreaFill"
  res@cnMaxLevelCount   = 255

  res@cnLineLabelsOn    = False
  res@cnLinesOn         = False

  res@lbBoxLinesOn      = False

  res@tiMainString      = "ISCCP grid topology"

;
; Retrieve the start and end values of the axis values
; so we can use them for the map limits.
;
  getvalues contour@data
    "sfXCActualStartF" : xs
    "sfXCActualEndF"   : xe
    "sfYCActualStartF" : ys
    "sfYCActualEndF"   : ye
  end getvalues

  res@mpDataBaseVersion     = "MediumRes"
  res@mpLimitMode           = "LatLon"
  res@mpMinLonF             = xs
  res@mpMaxLonF             = xe
  res@mpMinLatF             = ys
  res@mpMaxLatF             = ye
  res@mpCenterLatF          = 0
  res@mpCenterLonF          = -130

;  res@pmTickMarkDisplayMode = "Always"    ; Nice map tickmarks

  map = gsn_csm_contour_map(wks,topo,res)

  res@cnRasterSmoothingOn = True
  res@tiMainString        = "Topology with smoothing on" 

  map = gsn_csm_contour_map_ce(wks,topo,res)

  res@tiMainString = "Topology on a Lambert Equal Area map"
  res@mpProjection = "LambertEqualArea"
  res@mpCenterLatF = 40

  map = gsn_csm_contour_map(wks,topo,res)
end
