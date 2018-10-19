;----------------------------------------------------------------------
; If USE_SHAPEFILE is set to True, then you will need to download
; the France shapefile data from http://gadm.org/country/
;----------------------------------------------------------------------
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"   
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"   

begin
  USE_SHAPEFILE = True   ; Whether to add outlines of 
                         ; regions from shapefile

;---Open file and read data
  filename = "ForcT.DAT_france_0001.nc"
  f        = addfile (filename,"r")
  t        = f->T(0,:,:)              ; (time, y, x) ([8760] x 134 x 143)
  lat2d    = f->lat                   ; (y,x)
  lon2d    = f->lon                   ; (y,x)
  lc       = f->Lambert_Conformal     ; contains map projection information
  nlat     = dimsizes(lat2d(:,0))     ; Get lat dimension size
  mlon     = dimsizes(lon2d(0,:))     ; Get lon dimension size

;---Start the graphics
  wtype = "ps"
  if(wtype.eq."png")then
    wtype@wkWidth  = 2000      ; For publication
    wtype@wkHeight = 2000
  end if
  wks = gsn_open_wks(wtype ,"SAFRAN_temperature")        ; Open workstation

;---Retrieve a color table so we can subset it later
  cmap = read_colormap_file("WhiteBlueGreenYellowRed")   ; 254 x 4

  res              = True

  res@gsnMaximize  = True                      ; Maximize size of plot

  if(USE_SHAPEFILE) then
    res@gsnDraw      = False       ; Turn off draw
    res@gsnFrame     = False       ; Turn off frame
    res@mpOutlineOn  = False       ; Turn off map outlines; will
                                   ; use shapefile outlines
  end if

;---This will position data correctly on map.
  res@sfXArray     = lon2d
  res@sfYArray     = lat2d

  res@gsnAddCyclic = False      ; Data is not global, don't add lon cyclic pt

;---Use projection information on file
  res@mpProjection          = "LambertConformal"
  res@mpLambertParallel1F   = lc@standard_parallel(0)
  res@mpLambertParallel2F   = lc@standard_parallel(1)
  res@mpLambertMeridianF    = lc@longitude_of_central_meridian

;---Zoom in on map
  res@mpLimitMode           = "Corners"  
  res@mpLeftCornerLatF      = lat2d(0,0)
  res@mpLeftCornerLonF      = lon2d(0,0)
  res@mpRightCornerLatF     = lat2d(nlat-1,mlon-1)
  res@mpRightCornerLonF     = lon2d(nlat-1,mlon-1)

  res@mpFillOn              = False       ; Turn off map fill
  res@cnFillOn              = True        ; Turn on contour fill
  res@cnLinesOn             = False       ; Turn off contour lines
  res@tiMainString          = filename
  res@cnLevelSpacingF       = 1            ; NCL chose 2
  res@cnFillPalette         = cmap(23:,:)  ; Skip first 23 colors

  res@pmTickMarkDisplayMode = "Always"         ; turn on "nice" tickmarks
  res@lbOrientation         = "Vertical"       ; vertical labelbar

  plot = gsn_csm_contour_map(wks,t,res)

;---Attach outlines from shapefile. Try "FRA_adm2.shp" to see what happens.
  if(USE_SHAPEFILE) then
    filename = "FRA_adm/FRA_adm1.shp"
    lnres                  = True
;   lnres@gsLineThicknessF = 2.0      ; 1.0 is the default
    dum = gsn_add_shapefile_polylines(wks,plot,filename,lnres)

;---Draw and advance frame
    draw(plot)
    frame(wks)
  end if
end
