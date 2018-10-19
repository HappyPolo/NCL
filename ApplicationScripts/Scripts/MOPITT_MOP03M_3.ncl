;=========================================================================
; MOPITT_MOP03M_3.ncl
;=========================================================================
;
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
  
; explore data
; ncl_filedump -v Latitude,Longitude,Pressure_Grid MOP03M-200606-L3V92.0.1.hdf | less

; ================================= MAIN ==================================

  klvl   = 4                            ; specify index of desired level
  
  dir    = "./"
  files  = "MOP03M-200606-L3V92.0.1.hdf"
  infile = addfile(dir+files, "r")
                                        ;    0   1   2   3   4   5   6   7   8 
  pres   = infile->Pressure_Grid        ; (/900,800,700,600,500,400,300,200,100 /)
  pres@units = "hPa"                    ; manually assign units attribute
  plvl   = pres(klvl)       

                                        ; ( nlat_MOP03, nlon_MOP03, nprs_MOP03 )
  CO     = infile->Retrieved_CO_Mixing_Ratio_Profile_Day(:,:,klvl)   ; (nlat_MOP03, nlon_MOP03)
  CO@_FillValue = -9999.                ; manually set. No info on the file.
  CO@units      = "???"
;;CO@long_name  = CO@hdf_name
  CO@long_name  = "CO Mixing Ratio"

  lat    = infile->Latitude
  lat@units = "degrees_north"           ; udunits

  lon    = infile->Longitude  
  lon@units = "degrees_east"

  CO!0   = "lat"                        ; associate coordinates with variable
  CO!1   = "lon"
  CO&lat =  lat
  CO&lon =  lon
  
  printVarSummary(CO)
  printMinMax(CO,0)
  
;*****************************************************************
; Fill in missing area before interpolating: only north of 52S
;*****************************************************************

  poisson_grid_fill( CO({-52:},:), True, 1, 1500, 1e-2, 0.6, 0)
  
;*****************************************************************
; REGRID 
;*****************************************************************

  nlat = 46
  LAT  = latGlobeFo(nlat, "LAT", "latitude", "degrees_north")
 ;print(LAT)

  mlon = 72
  LON  = lonGlobeFo(mlon, "LON", "longitude", "degrees_east")
 ;print(LON)              ; start a GM

  LON = (/ LON - 180. /)  ; subtract 180 from all values
  LON&LON = LON           ; update coordinates
 ;print(LON)              ; start at dateline

  CO_linint2 = linint2_Wrap (lon,lat,CO, True, LON,LAT, 0)
  printVarSummary(CO_linint2)
  printMinMax(CO_linint2,0)

  wgt        = cos(lat*0.01745329)   ; simple cosine weigting
  opt_area   = True
  opt_area@critpc = 70
  CO_area    = area_hi2lores_Wrap (lon,lat,CO, True, wgt, LON,LAT, opt_area)
  printVarSummary(CO_area)
  printMinMax(CO_area,0)
  
;*****************************************************************
; PLOT   
;*****************************************************************
  plot    = new( 3, "graphic")

  year    = str_get_cols(files, 7, 10)    ; parse file name 
  month   = str_get_cols(files,11, 12)
  yyyymm  = year+month
     
  wks     = gsn_open_wks("png" ,"MOPITT_MOP03M")  ; send graphics to PNG file

  res                     = True          ; Use plot options
  res@gsnDraw             = False         ; do not draw
  res@gsnFrame            = False         ; do not advance frame

  res@cnFillOn            = True          ; Turn on color fill
  res@cnFillPalette       = "BlAqGrYeOrReVi200"   ; set color map
  res@cnFillMode          = "RasterFill"  ; Turn on raster color
  res@cnLinesOn           = False         ; Turn off contourn lines
  res@cnLineLabelsOn      = False         ; Turn off contourn lines

  res@cnLevelSelectionMode=  "ManualLevels"   
  res@cnMinLevelValF      =  20.
  res@cnMaxLevelValF      = 150.
  res@cnLevelSpacingF     =   5. 

  res@lbLabelBarOn        = False           ; turn off individual cb's
 ;res@mpCenterLonF        = 180           ; set map center at 180
      
  res@gsnCenterString     = plvl+"hPa"

  res@gsnRightString = "Original grid"
  plot(0) = gsn_csm_contour_map_ce(wks,CO, res)
  res@gsnRightString = "linint2 (46,72)"
  plot(1) = gsn_csm_contour_map_ce(wks,CO_linint2, res)
  res@gsnRightString = "area (46,72)"
  plot(2) = gsn_csm_contour_map_ce(wks,CO_area, res)
  
  resP                     = True
  resP@gsnMaximize         = True          ; make ps, pdf, eps large
  resP@gsnPaperOrientation = "portrait"    ; force portrait mode
  resP@gsnPanelLabelBar    = True                ; add common colorbar
  resP@txString            = files
  gsn_panel(wks,plot,(/3,1/),resP)               ; now draw as one plot


