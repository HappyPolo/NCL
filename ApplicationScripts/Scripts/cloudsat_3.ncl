;***************************************************************
; cloudsat_2.ncl
;
; Concepts illustrated:
;   - Similar to cloudsat_2
;   - Read CLOUDSAT 'cloud_scenario' from a HDF-EOS2 file 
;   - Explore data (min, max); eliminate negative (bogus)  values
;     Would be better to use 'stat_dispersion'
;   - Plot trajectory
;   - Specify a region of interest
;   - Plot the vertical profile at each time step over region of interest only
;   - Color map chosen to not show smaller values
;   - Manually specigy a fine contour spacing
;***************************************************************
;
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
;===============================================================
; Open the file: ncl_filedump showed it is HDF-EOS with .hdf extension
;===============================================================
  diri    = "./"                   		; path to file
  fili	  = "2010153190053_21792_CS_2B-CLDCLASS_GRANULE_P_R04_E03.hdf"
  varname = "cloud_scenario_2B_CLDCLASS"
  f       = addfile (diri+fili+".he2", "r")     ; open file as hdf-eos2

;===============================================================
; Read variables
;===============================================================
 ;tai     = f->TAI_start_2B_CLDCLASS
 ;utc     = f->UTC_start_2B_CLDCLASS

  data    = f->$varname$                ; (nray_2B_CLDCLASS,nbin_2B_CLDCLASS)
  printVarSummary(data)                 ; type short
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

;===============================================================
; Specify a region which will later be used to subset data regionally
;===============================================================
  latS = -45.0
  latN =  45.0
  lonL =  30.0
  lonR = 120.0

;===============================================================
; Plots
;===============================================================

  wks  = gsn_open_wks("png","cloudsat")  ; send graphics to PNG file

;***************************************
; satlellite trajectory plot (all times)
;***************************************
  mpres                    = True        ; Plot options desired.
  mpres@gsnFrame           = False       ; Don't advance the frame
  mpres@gsnMaximize        = True
 ;mpres@gsnPaperOrientation= "portrait"  ; force portrait

 ;mpres@mpLandFillColor    = "gray70"    ; make darker than default
  mpres@mpCenterLonF       = (lonL+lonR)*0.5   ; Cent in box  (arbitrary)
  mpres@tiMainString       = "Trajectory"
  mpres@gsnCenterString    = fili
  plot = gsn_csm_map(wks,mpres)          ; Draw map   
                                         ; trajectory
  gsres                    = True        ; "Graphic Style" resources
  gsres@gsMarkerSizeF      = 10.0        ; Marker size
  gsres@gsMarkerThicknessF = 1.0         ; Marker thickness
  gsres@gsMarkerColor      = "Blue"      ; Marker color
  gsres@gsMarkerIndex      = 1           ; Marker style
  gsn_polymarker(wks,plot,lon,lat,gsres) ; plot trajectory

;************************************************
; add the box
;************************************************

  ypts = (/ latS, latS, latN, latN, latS/)
  xpts = (/ lonL, lonR, lonR, lonL, lonL/)

  gsresx                  = True
  gsresx@gsLineColor      = "red"                     ; color of lines
  gsresx@gsLineThicknessF = 2.0                       ; thickness of lines
  gsn_polyline(wks,plot,xpts,ypts,gsresx)      

  frame(wks)

;***************************************
; Identify all regions outside 'box'
;***************************************
  ii = ind(lat.lt.latS .or. lat.gt.latN .or. \
           lon.lt.lonL .or. lon.gt.lonR)          
  data@_FillValue = toshort(-999)
  data(ii,:)      = data@_FillValue

;***************************************
; Plot data only area within region of interest
;***************************************

  res                  = True
  res@gsnMaximize      = True
  res@sfXArray         = conform(data, time, 0)  ; not necessary here
  res@sfYArray         = hgt                     ; 2D

  res@trGridType       = "TriangularMesh"  
  res@trYMinF          = 0.0

  res@cnFillMode       = "RasterFill"            ; Raster Mode
  res@cnLevelSelectionMode = "ManualLevels"     ; set manual contour levels
  res@cnMinLevelValF       = 2000.              ; set min contour level
  res@cnMaxLevelValF       = 12500.             ; set max contour level
  res@cnLevelSpacingF      = 500.                ; set contour spacing

  res@cnFillOn         = True
  res@cnFillPalette    = "WhBlGrYeRe"   ; set color map
  res@cnLinesOn        = False
  res@cnLineLabelsOn   = False

  res@lbOrientation    = "vertical"     ; default is horizontal

  res@tiXAxisString    = "elapsed time"
  res@tiYAxisString    = "Height (m)"
  res@tiMainString     = fili
  res@gsnCenterString  = "Box Region"

  plot  = gsn_csm_contour (wks, data, res) 

