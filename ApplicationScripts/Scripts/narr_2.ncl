;***************************************************************************
; narr_2.ncl
;
; Concepts illustrated:
;   - Plotting NARR data
;***************************************************************************
;
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"  
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"  
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"

begin
;*******************************************
; open file and read in data
;*******************************************
  diri    = "./"                              ; input directory
  f       = addfile (diri+"air.200001.nc", "r")
                                              ; convert short=>float
  x       = short2flt( f->air(10,:,:,:) )     ; (11th time index,lev,lat,lon)    

  lat2d   = f->lat                            ; coordinates
  lon2d   = f->lon
  dimlc   = dimsizes(lat2d)                   ; dimension sizes
  nlat    = dimlc(0)
  mlon    = dimlc(1)
;*************create plots*******************
  wks  = gsn_open_wks ("png", "narr")             ; send graphics to PNG file  
  cmap = read_colormap_file("gui_default")        ; read color data
  
  res                        = True               ; plot mods desired for original grid
  res@cnFillOn               = True               ; color fill  
  res@cnFillPalette          = cmap(2:,:)         ; set color map
  res@cnLinesOn              = False              ; no contour lines
  res@gsnSpreadColors        = True               ; use total colormap
  res@gsnSpreadColorStart    = 4 
  res@gsnSpreadColorEnd      = -1   
  res@mpGridAndLimbOn        = True
  res@pmTickMarkDisplayMode  = "Always"           ; turn on tickmarks
  res@tmXTOn                 = False  
  res@gsnAddCyclic           = False              ; regional data

  res@mpLimitMode            = "Corners"          ; choose range of map
  res@mpLeftCornerLatF       = lat2d(0,0)
  res@mpLeftCornerLonF       = lon2d(0,0)
  res@mpRightCornerLatF      = lat2d(nlat-1,mlon-1)
  res@mpRightCornerLonF      = lon2d(nlat-1,mlon-1)
  res@tfDoNDCOverlay         = True               ; direct plot
  res@mpProjection           = "LambertConformal" 
  res@mpLambertParallel1F    = f->Lambert_Conformal@standard_parallel(0)	; lat2d@mpLambertParallel1F
  res@mpLambertParallel2F    = f->Lambert_Conformal@standard_parallel(1)
  res@mpLambertMeridianF     = f->Lambert_Conformal@longitude_of_central_meridian

  res@gsnCenterString         = "T@"+x&level(3) + "hPa"	  ; draw center subtitle
  res@gsnLeftString           = "Original grid"		  ; draw left subtitle
  plot = gsn_csm_contour_map(wks,x(3,:,:),res)     	  ; Draw original grid on map
  end
