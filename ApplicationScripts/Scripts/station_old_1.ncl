;----------------------------------------------------------------------
; station_old_1.ncl
;----------------------------------------------------------------------
; Concepts illustrated:
;   - Contouring one-dimensional X, Y, Z data
;   - Reading an ASCII file with several columns of data
;   - Drawing lat/lon locations as filled dots using gsn_polymarker
;   - Controlling which contour lines get drawn
;   - Using opacity to emphasize or subdue overlain features
;   - Reversing a color map
;----------------------------------------------------------------------
; This example reads in station data represented by
; 1D arrays, and generates a filled contour plot over a map.
;
; It uses an older method (pre NCL V6.4.0) for specifying the
; lat/lon information via sfXArray and sfYArray. See 
; station_1.ncl for the newer method of attaching special 
; lat1d/lon1d attributes to your data. 
;----------------------------------------------------------------------
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"

begin
;
; Data is stored in four columns:  station_name  lat  lon  pwv
; Read in each line as a string, and use "str_get_field" to 
; read in the fields of interest.
;
  fname = "pw.dat"
  lines = asciiread(fname,-1,"string")
;
; Use "str_get_field" to indicate which fields to read in.
; Each field is separated by an arbitrary number of spaces.
;
  pwv = tofloat(str_get_field(lines(1:),4," "))
  lat = tofloat(str_get_field(lines(1:),2," "))
  lon = tofloat(str_get_field(lines(1:),3," "))

  wks = gsn_open_wks("png","station_old")       ; send graphics to PNG file

  cmap = read_colormap_file("WhViBlGrYeOrRe") ; read color map
  cmap = cmap(::-1,:)                         ; reverse the color map

  res                             = True
  res@gsnMaximize                 = True
  res@gsnFrame                    = False   ; Want to draw markers later.

  res@cnLineLabelPlacementMode    = "Constant"
  res@cnLineLabelFontColor        = "Gray15"
  res@cnLineDashSegLenF           = 0.3

  res@cnLevelSelectionMode        = "ManualLevels"
  res@cnMinLevelValF              = 15         	; 15.25
  res@cnMaxLevelValF              = 50		; 49.75
  res@cnLevelSpacingF             = 0.25

  res@cnFillOn                    = True
  res@cnFillPalette               = cmap(2:88,:)
  res@cnFillOpacityF              = 0.75 
  res@cnLinesOn                   = True
  res@cnLineLabelsOn              = True
  res@cnLevelFlags		  = new(139,"string")
  res@cnLevelFlags(:)		  = "NoLine"
  res@cnLevelFlags(0::20)         = "LineAndLabel"

  res@lbOrientation               = "vertical"
  res@lbBoxLinesOn                = False
;
; These resources are required if plotting 1D data over a map
; In newer versions of NCL, you can use the special lat1d / lon1d
; attributes. See station_1.ncl
;
  res@sfXArray                    = lon
  res@sfYArray                    = lat

;---Zoom in on map area of interest
  res@mpMinLatF                   = min(lat)-.5
  res@mpMinLonF                   = min(lon)-.5
  res@mpMaxLatF                   = max(lat)+.5
  res@mpMaxLonF                   = max(lon)+.5

  res@mpFillOn                    = False
  res@mpOutlineDrawOrder          = "PostDraw"
  res@mpFillDrawOrder             = "PreDraw"
  res@mpOutlineBoundarySets       = "GeophysicalAndUSStates"
  res@mpUSStateLineColor          = "Gray10"
  res@mpUSStateLineDashPattern    = 2

  res@pmTickMarkDisplayMode       = "Always"   ; nicer map tickmarks

;---Create the plot; it won't get drawn because gsnFrame was set to False.
  res@tiMainString = "GPS PWV (18Z)"
  plot = gsn_csm_contour_map(wks,pwv,res)
;
; Draw markers on the plot showing the lat/lon locations.
; You could also use gsn_coordinates here (see station_1.ncl)
;
  mkres               = True
  mkres@gsMarkerIndex = 16     ; Filled circle

  gsn_polymarker(wks,plot,lon,lat,mkres)
  frame(wks)   ; Now advance the frame.
end 
