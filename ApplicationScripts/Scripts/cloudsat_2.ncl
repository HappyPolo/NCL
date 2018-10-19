;***************************************************************
; cloudsat_2.ncl
;
; Concepts illustrated:
;   - Read CLOUDSAT 'cloud_scenario' from a HDF-EOS2 file 
;   - Explore data (min, max); eliminate negative (bogus)  values
;     Would be better to use 'stat_dispersion'
;   - Plot the vertical profile at each time step
;   - Color map chosen to not show smaller values
;   - Show both horizontal and vertical label bars
;***************************************************************
;
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
; ==============================================================
; Open the file: ncl_filedump showed it is HDF-EOS with .hdf extension
; ==============================================================
  diri    = "./"                   		; path to file
  fili	  = "2010153190053_21792_CS_2B-CLDCLASS_GRANULE_P_R04_E03.hdf"
  varname = "cloud_scenario_2B_CLDCLASS"
  f       = addfile (diri+fili+".he2", "r")     ; open file as hdf-eos2

 ;tai     = f->TAI_start_2B_CLDCLASS
 ;utc     = f->UTC_start_2B_CLDCLASS

  data    = f->$varname$                ; (nray_2B_CLDCLASS,nbin_2B_CLDCLASS)
  printVarSummary(data)
  print("data: min="+min(data)+"  max="+max(data))

  dimd    = dimsizes(data)              ; (37082,125)
  nray    = dimd(0)                     ;  37082    ; nray_2B_CLDCLASS
  nbin    = dimd(1)                     ;  125      ; nbin_2B_CLDCLASS

  lat     = f->Latitude_2B_CLDCLASS     ; (nray_2B_CLDCLASS) => (37082)
  lon     = f->Longitude_2B_CLDCLASS    ; (nray_2B_CLDCLASS) => (37082)
  time    = f->Profile_time_2B_CLDCLASS ; (nray_2B_CLDCLASS) => (37082)

  hgt     = f->Height_2B_CLDCLASS       ; (nray_2B_CLDCLASS,nbin_2B_CLDCLASS )
  printVarSummary(hgt)
  print("hgt: min="+min(hgt)+"  max="+max(hgt))  ; min=-4917  max=25062

  hgt     = where(hgt.lt.0, hgt@_FillValue, hgt)  ; eliminate 'bogus' values
  print("hgt: min="+min(hgt)+"  max="+max(hgt))  ; min=0  max=25062

  res                  = True
  res@gsnMaximize      = True
  res@sfXArray         = conform(data, time, 0)  ; not necessary here
  res@sfYArray         = hgt                     ; 2D

  res@trGridType       = "TriangularMesh"  
  res@cnFillMode       = "RasterFill"            ; Raster Mode

  res@cnFillOn         = True
  res@cnFillPalette    = "WhBlGrYeRe"   ; set color map
  res@cnLinesOn        = False
  res@cnLineLabelsOn   = False
  res@trYMinF          = 0.0

  res@lbOrientation    = "vertical"     ; default is horizontal

  res@tiXAxisString    = "elapsed time"
  res@tiYAxisString    = "Height (m)"
  res@tiMainString     = fili

  wks  = gsn_open_wks("png","cloudsat") ; send graphics to PNG file

  plot  = gsn_csm_contour (wks, data, res) 

  res@lbOrientation    = "horizontal"
  if (.not.isatt(res,"lbOrientation") .or. \
      res@lbOrientation.eq."horizontal") then 
      res@pmLabelBarHeightF= 0.075          ; slightly smaller than default
      res@pmLabelBarOrthogonalPosF = 0.075  ; move down
      res@tiXAxisOffsetYF  = 0.11 
  end if
  plot  = gsn_csm_contour (wks, data, res) 
