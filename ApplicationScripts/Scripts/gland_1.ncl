;*************************************************
; gland_1.ncl
;
; Concepts illustrated:
;   - Plotting Greenland merged data
;   - Using projection data on the file 
;   - Use side-by-side paneling to examine the mapping difference
;   - draw via panels
;*****************************************************
; 
; NCL's mapping software operates in spherical space, but WGS84 
; and systems like it describe an ellipsoid not a sphere. 
; As a result, there are some slight differences from the
; native projection (left) and the map using lat2d/lon2d.
;*****************************************************
;
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"  
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"    
;************************************************
; read in netCDF file
;************************************************
  diri  = "./"
  fili  = "gland5.input.nc"
  f     = addfile(diri+fili,"r")

  nt    = 0
  lat2d = f->lat(nt,:,:)   ; (561,301)
  lon2d = f->lon(nt,:,:)

  printMinMax(lat2d, 0)    ; Latitude:  min=58.6293    max=84.4819
  printMinMax(lon2d, 0)    ; Longitude: min=-92.1301   max=10.3987

  dimgrd= dimsizes(lat2d)
  nlat  = dimgrd(0)        ; 561
  mlon  = dimgrd(1)        ; 301
;************************************************
; read variables; plot 
;************************************************
  wks = gsn_open_wks("png","gland")             ; send graphics to PNG file

  res                      = True               ; plot mods desired
  res@gsnDraw              = False
  res@gsnFrame             = False 
  res@cnFillOn             = True               ; turn on color
  res@cnFillMode           = "RasterFill"
  res@cnLinesOn            = False
  res@cnLineLabelsOn       = False
  res@lbLabelBarOn         = False              ; turn off individual lb's

  res@trGridType           = "TriangularMesh"

  res@mpProjection          = "Stereographic"
  res@mpDataBaseVersion     = "mediumres"
  res@mpFillOn              = False             ; turn off default land map fill

  res@mpLimitMode           = "Corners"  
  res@mpLeftCornerLatF      = lat2d(0,0)
  res@mpLeftCornerLonF      = lon2d(0,0)
  res@mpRightCornerLatF     = lat2d(nlat-1,mlon-1)
  res@mpRightCornerLonF     = lon2d(nlat-1,mlon-1)
  res@mpCenterLonF          = f->mapping@straight_vertical_longitude_from_pole
  res@mpCenterLatF          = f->mapping@standard_parallel

  res@gsnLeftString         = ""
  res@gsnRightString        = ""

  resP                      = True                ; panel resoources
  resP@gsnMaximize          = True
  resP@gsnPanelLabelBar     = True                ; add common colorbar
  resP@pmLabelBarHeightF    = 0.1                 ; wider than default
  resP@pmLabelBarWidthF     = 0.7                 ; smaller than default
  resP@lbLabelFontHeightF   = 0.0125              ; make label size
;************************************************
; Turn on lat / lon labeling
;************************************************
 ;res@pmTickMarkDisplayMode = "Always"         ; turn on tickmarks

  var  = (/ "presusurf", "thk", "topg", "presprcp" /)
  nvar = dimsizes(var)

  plots = new(2,graphic)
  do nv=0,nvar-1
     x  := f->$var(nv)$(nt,:,:)
     x@lat2d = lat2d
     x@lon2d = lon2d

     res@cnFillPalette = "WhiteBlueGreenYellowRed"
     if (var(nv).eq."topg") then
         res@cnFillPalette        = "testcmap"
         res@cnLevelSelectionMode = "ManualLevels"     ; set manual contour levels
         res@cnMinLevelValF       = -3000.
         res@cnMaxLevelValF       =  3000.
         res@cnLevelSpacingF      =   500. 
     end if

     res@tfDoNDCOverlay  = True
     res@gsnCenterString = "WGS84"
     plots(0) = gsn_csm_contour_map(wks,x,res)

     res@tfDoNDCOverlay = False 
     res@gsnCenterString = "NCL: lat2d/lon2d"
     plots(1) = gsn_csm_contour_map(wks,x,res)

     resP@txString      = "gland5: "+x@long_name+" ("+x@units+")" 
     gsn_panel(wks,plots,(/1,2/),resP)

     if (var(nv).eq."topg") then
         delete( [/ res@cnLevelSelectionMode, res@cnMinLevelValF, res@cnMaxLevelValF, res@cnLevelSpacingF /] )
     end if
  end do
