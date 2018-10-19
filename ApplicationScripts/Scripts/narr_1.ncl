;***************************************************************************
; narr_1.ncl
;
;***************************************************************************
;
; These files are loaded by default in NCL 6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"  
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"  

begin
  f       = addfile ("./merged_AWIP32.1979010100.3D.NARR.grb", "r")
  lat2d   = f->gridlat_221
  lon2d   = f->gridlon_221
  dimlc   = dimsizes(lat2d)
  nlat    = dimlc(0)
  mlon    = dimlc(1)
  x       = f->U_GRD_221_ISBL              ; (lev,lat,lon)    
;*************create plots*******************
  wks  = gsn_open_wks ("png", "narr")             ; send graphics to PNG file  
  cmap = read_colormap_file("gui_default")        ; read color data
  
  res                        = True               ; plot mods desired for original grid
  res@cnFillOn               = True               ; color fill  
  res@cnFillPalette          = cmap(2:,:)         ; set color map
  res@cnLinesOn              = False              ; no contour lines
  res@mpGridAndLimbOn        = True
  res@pmTickMarkDisplayMode  = "Always"           ; turn on tickmarks
  res@tmXTOn                 = False  
  res@gsnAddCyclic           = False              ; regional data

  res@mpLimitMode            = "Corners"            ; choose range of map
  res@mpLeftCornerLatF       = lat2d(0,0)
  res@mpLeftCornerLonF       = lon2d(0,0)
  res@mpRightCornerLatF      = lat2d(nlat-1,mlon-1)
  res@mpRightCornerLonF      = lon2d(nlat-1,mlon-1)
  res@tfDoNDCOverlay         = True  
  res@mpProjection           = "LambertConformal" 
  res@mpLambertParallel1F    = lat2d@mpLambertParallel1F
  res@mpLambertParallel2F    = lat2d@mpLambertParallel2F
  res@mpLambertMeridianF     = lat2d@mpLambertMeridianF

  res@gsnCenterString         = "U@"+x&lv_ISBL0(10) + "hPa"		; draw center subtitle
  res@gsnLeftString           = "Original grid"				; draw left subtitle
  plot = gsn_csm_contour_map(wks,x(10,:,:),res)     			; Draw original grid on map
  end
