;===========================================================================
; MOPITT_MOP03M_1.ncl
;===========================================================================
;
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
  
; explore data
; ncl_filedump -v Latitude,Longitude,Pressure_Grid MOP03M-200606-L3V92.0.1.hdf | less

;=======================  MAIN =============================================

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
;;CO@long_name  = CO@hdf_name           ; name too long for 'nice' graphics
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
; PLOT   
;*****************************************************************

      year    = str_get_cols(files, 7, 10)    ; parse file name 
      month   = str_get_cols(files,11, 12)
      yyyymm  = year+month
     
      wks     = gsn_open_wks("png" ,"MOPITT_MOP03M")  ; send graphics to PNG file
      
      res                     = True          ; Use plot options
      res@gsnMaximize         = True          ; make ps, pdf, eps large
      res@gsnPaperOrientation = "portrait"    ; force portrait mode
      res@cnFillOn            = True          ; Turn on color fill
      res@cnFillPalette       = "BlAqGrYeOrReVi200" ; set color map
      res@cnFillMode          = "RasterFill"  ; Turn on raster color
      res@cnLinesOn           = False         ; Turn off contour lines
      res@mpCenterLonF        = 180           ; set map center at 180
    ;;res@lbOrientation       = "vertical"
      res@tiMainString        = files
      res@gsnCenterString     = plvl+"hPa"
      plot = gsn_csm_contour_map(wks,CO, res)
