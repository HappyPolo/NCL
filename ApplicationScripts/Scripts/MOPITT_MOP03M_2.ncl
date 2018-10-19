;=============================================================================
; MOPITT_MOP03M_2.ncl
;=============================================================================
;
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
  
; explore data
; ncl_filedump -v Latitude,Longitude,Pressure_Grid MOP03M-200606-L3V92.0.1.hdf | less

; ===============================  MAIN  =====================================

  dir    = "./"
  files  = "MOP03M-200606-L3V92.0.1.hdf"
  infile = addfile(dir+files, "r")
                                        ;    0   1   2   3   4   5   6   7   8 
  pres   = infile->Pressure_Grid        ; (/900,800,700,600,500,400,300,200,100 /)
  klvl   = dimsizes(pres)
                                        ;       0            1           2
                                        ; ( nlat_MOP03, nlon_MOP03, nprs_MOP03 )
  CO     = infile->Retrieved_CO_Mixing_Ratio_Profile_Day     ; (:,:,:)
  CO@_FillValue = -9999.                ; manually set. No info on the file.
  CO@units      = "???"
;;CO@long_name  = CO@hdf_name           ; too long for nice graphics header
  CO@long_name  = "CO Mixing Ratio"

  lat    = infile->Latitude
  lat@units = "degrees_north"           ; udunits

  lon    = infile->Longitude  
  lon@units = "degrees_east"
 
  pres@units = "hPa"                    ; manually assign units attribute
  pres!0     = "pres"
  pres&pres  =  pres

  CO!0   = "lat"   
  CO!1   = "lon"
  CO!2   = "pres"                       ; associate coordinates with variable
  CO&pres=  pres
  CO&lat =  lat
  CO&lon =  lon

;*****************************************************************
; Variable Overview plus statistical look at the variable
;*****************************************************************
  
  printVarSummary(CO)
  printMinMax(CO,0)

  opt     = True
  opt@PrintStat = True
  stat_CO = stat_dispersion(CO, opt )
  
;*****************************************************************
; PLOT  (panel) 
;*****************************************************************
  plot    = new ( klvl, "graphic")

  year    = str_get_cols(files, 7, 10)    ; parse file name 
  month   = str_get_cols(files,11, 12)
  yyyymm  = year+month
     
  wks     = gsn_open_wks("png" ,"MOPITT_MOP03M")   ; send graphics to PNG file 
      
  res                     = True          ; Use plot options
  res@gsnDraw             = False         ; do not draw
  res@gsnFrame            = False         ; do not advance frame

  res@cnFillOn            = True          ; Turn on color fill
  res@cnFillPalette       = "BlAqGrYeOrReVi200" ; set color map
  res@cnFillMode          = "RasterFill"  ; Turn on raster color
  res@cnLinesOn           = False         ; Turn off contourn lines

  res@cnLevelSelectionMode=  "ManualLevels"   
  res@cnMinLevelValF      =  20.
  res@cnMaxLevelValF      = 150.
  res@cnLevelSpacingF     =   5. 

  res@lbLabelBarOn        = False           ; turn off individual cb's
 ;res@mpCenterLonF        = 180           ; set map center at 180
      
  do kl=0,klvl-1
     res@gsnCenterString  = pres(kl)+"hPa"
     plot(kl) = gsn_csm_contour_map(wks,CO(:,:,kl), res)
  end do
  
  resP                     = True
  resP@gsnMaximize         = True          ; make ps, pdf, eps large
  resP@gsnPaperOrientation = "portrait"    ; force portrait mode
  resP@gsnPanelLabelBar    = True                ; add common colorbar
  resP@txString            = files
  gsn_panel(wks,plot,(/5,2/),resP)               ; now draw as one plot

