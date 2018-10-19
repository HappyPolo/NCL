;*************************************************
; contour1d_4.ncl
;*************************************************
;
; Concepts illustrated:
;   - Contouring one-dimensional X, Y, Z data
;   - Reading an ASCII file with several columns of data
;   - Drawing filled and hollow dots on a map
;   - Subsetting a color map
;   - Drawing partially transparent filled contours
;   - Using cnFillPalette to assign a color palette to contours
;   - Color-coding markers based on data values
;   - Using "sprintf" to create nicely formatted labelbar labels
;*************************************************
; This example reads in station data represented by
; 1D arrays, and generates a filled contour plot.
;*************************************************
;
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
; Use "str_get_field" to indicate which fields to read in. Each field
; is separated by spaces.
;
  lat = tofloat(str_get_field(lines(1:),2," "))
  lon = tofloat(str_get_field(lines(1:),3," "))
  pwv = tofloat(str_get_field(lines(1:),4," "))

  wks = gsn_open_wks("png","contour1d")           ; send graphics to PNG file

;---Read in desired color map and reverse it
  cmap = read_colormap_file("WhViBlGrYeOrRe")     ; 101 x 4 (RGBA)   
  cmap = cmap(::-1,:)   ; Reverse color map       ; Still 101 x 4

  levels  = ispan(15000,50000,1125)/1000.         ; Contour levels
  nlevels = dimsizes(levels)  

;---Start setting plot resources
  res                             = True
  res@gsnMaximize                 = True
  res@gsnDraw                     = False
  res@gsnFrame                    = False

  res@cnFillPalette               = cmap(:90,:)   ; Don't use full color map.

  res@cnLevelSelectionMode        = "ExplicitLevels"
  res@cnLevels                    = levels
  res@lbOrientation               = "Vertical"
  res@lbLabelStrings              = sprintf("%5.2f",levels)    ; nicely formatted labels
  res@lbLabelFontHeightF          = 0.018

  res@cnFillOn                    = True
  res@cnLinesOn                   = False
  res@cnFillOpacityF              = 0.5       ; colors half transparent

  res@tiMainString                = "GPS PWV (18Z)"

;---Locations of data points
  res@sfXArray                    = lon
  res@sfYArray                    = lat

;---Map resources
  res@mpMinLatF                   = min(lat)-1
  res@mpMinLonF                   = min(lon)-1
  res@mpMaxLatF                   = max(lat)+1
  res@mpMaxLonF                   = max(lon)+1

  res@mpFillOn                    = False
  res@mpOutlineDrawOrder          = "PostDraw"
  res@mpOutlineBoundarySets       = "GeophysicalAndUSStates"
  res@mpUSStateLineColor          = "Gray10"
  res@mpUSStateLineDashPattern    = 2

  res@pmTickMarkDisplayMode       = "Always"

  map = gsn_csm_contour_map(wks,pwv,res)

;---Retrieve contour colors to use for markers
  getvalues map@contour
     "cnFillColors" : colors
  end getvalues

;---Add some markers to show where the original 1D points are.
  mkres               = True

  filled_marker = new(nlevels+1,graphic)
  hollow_marker = new(nlevels+1,graphic)

;---Group each set of markers based on levels they fall between
  do i=0,nlevels
    if(i.eq.0) then
      ii := ind(pwv.lt.levels(0))                          ; first level
    else if(i.eq.nlevels) then 
      ii := ind(pwv.ge.levels(nlevels-1))                  ; middle levels
    else
      ii := ind(levels(i-1).le.pwv.and.pwv.lt.levels(i))   ; last level
    end if
    end if
;
; Attach both a filled marker and a hollow 
; marker so you can see them better.
;
    if(.not.any(ismissing(ii))) then
;---Filled marker
      mkres@gsMarkerIndex      = 16
      mkres@gsMarkerColor      := colors(i)
      mkres@gsMarkerSizeF      = 0.009
      mkres@gsMarkerThicknessF = 1.0
      filled_marker(i) = gsn_add_polymarker(wks,map,lon(ii),lat(ii),mkres)

;---Hollow marker
      mkres@gsMarkerIndex      = 4
      mkres@gsMarkerColor      := "black"
      mkres@gsMarkerSizeF      = 0.01
      mkres@gsMarkerThicknessF = 2.0
      hollow_marker(i) = gsn_add_polymarker(wks,map,lon(ii),lat(ii),mkres)
    end if
  end do

  draw(map)    ; This draws map and attached markers
  frame(wks)

end 
