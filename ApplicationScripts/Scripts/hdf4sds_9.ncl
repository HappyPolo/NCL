;***************************************************************
; hdf4sds_9.ncl  
;
; Concepts illustrated:
;   - Reading radar variable (nearSurfZ) from a TRMM 2A25 HDF4 file      
;   - Changing the _FillValue (not necessary, just 'cultural')
;   - Unscaling the values using the 'scale_factor' attribute
;   - Use 'stat_dispersion' to examine the variable statistics
;   - Extract lat/lon from a 3D geolocation grid
;   - Draw light lat-lon outlines
;   - Illustrate different ways of plotting the data
;   - plot as panel
;***************************************************************
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"   
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
;***************************************************************

begin
  fil_root   = "2A25_CSI.990804.9692.KORA.6" ; use later in the plot title
  sds_file   = addfile(fil_root+".HDF", "r") ; Open file; add extension
  
  var_name   = "nearSurfZ"                   ; use later in plot
  data       = sds_file->$var_name$          ; data=sds_file->nearSurfZ is also available
  data@units = "dBz"                         ; not on file :-(
  
                         ; zero is not a good _FillValue
                         ; make all 0s _FillValue .... then -9999. Zero is not a good _FillValue
  data@_FillValue = 0h   ; the 'h' after the value is a shortcut for invoking toshort() 
  data@_FillValue = -9999h 
  
;--------------------------------------------------
; *golden rule of data processing: look at your data*
; http://www.ncl.ucar.edu/Document/Functions/Contributed/stat_dispersion.shtml
;---------------------------------------------------
  printVarSummary(data)  
  printMinMax(data,0); min=13.8091   max=49.0779  
  
  opt   = True                           ; print statistical dispersion overview
  opt@PrintStat = True
  stats = stat_dispersion(data, opt )    ; statistical overview
  
;--------------------------------------------------
; associate lat2d/lon2d for plotting
;---------------------------------------------------
  lat2d = sds_file->geolocation(:,:,0)
  lon2d = sds_file->geolocation(:,:,1)
  lat2d@units = "degrees_north"
  lon2d@units = "degrees_east"

  data@lon2d = lon2d     ; associate longitude and latitude for later graphics use
  data@lat2d = lat2d     ; here, both longitude and latitude are stored in the same data field,
                         ; but with different subsets.
;--------------------------------------------------
; plots
;---------------------------------------------------
  
 ;plt_name = fil_root+"_"+var_name       ; create name
  plt_name = "hdf4sds"
  wks=gsn_open_wks("png", plt_name)      ; open workstation
  
  plot= new(3,"graphic")  ; space for 3 graphical objects
  
  res=True ; plot mods desired
  res@gsnDraw    = False  ; do not immediately draw
  res@gsnFrame   = False  ; do not immediately flush
  res@gsnAddCyclic=False  ; data not cyclic
  
  res@cnFillOn=True       ; enable contour fill
  res@cnLinesOn=False     ; turn off contour lines
  res@cnLineLabelsOn= False   ; turn off contour line labels
  res@cnFillMode="RasterFill" ; "CellFill" may be faster
  res@cnMissingValFillPattern = 0 ; missing value pattern is set to "SolidFill"
  res@cnMissingValFillColor   = "Background"
  
  res@cnFillPalette           = "BlAqGrYeOrReVi200"  ; available in version 6.1.0 and later
  
  ;;;plot=gsn_csm_contour_map(xwks,data,res)   ; not worth it
  
  res@mpLimitMode = "LatLon"
  res@mpMinLatF	= min(data@lat2d)      ; Set limits of map, based on the min/max of the dataset latitude/longitude
  res@mpMaxLatF	= max(data@lat2d)       
  res@mpMinLonF	= min(data@lon2d)      
  res@mpMaxLonF	= max(data@lon2d)     
  
  res@mpDataBaseVersion    = "MediumRes" ; Use slightly higher res; default is "LowRes"  
                                         ; https://www.ncl.ucar.edu/Applications/Images/mapoutlines_zoom_5_2_lg.png
  
  res@mpGridAndLimbOn      = True        ; draw map grid lines
  res@mpGridLatSpacingF    = 1
  res@mpGridLonSpacingF    = 1
  res@mpGridLineColor      = "LightGray"
  res@mpGridLineDashPattern= 6           ; http://www.ncl.ucar.edu/Document/Graphics/Images/dashpatterns.png
  
  res@gsnMajorLatSpacing   = 1           ; override defaults
  res@gsnMajorLonSpacing   = 2
  res@lbLabelBarOn         = False       ; turn off individual label bars
  
  res@gsnCenterString="default"
  plot(0)=gsn_csm_contour_map(wks,data,res)  ; default [gray land not covered buy swath]
  
  res@cnMissingValFillColor   = "gray"        ; color swath _FillValue 
  res@mpFillOn = False                        ; turn off default gray land
  res@gsnCenterString="_FillValue=gray, land=transparent"
  plot(1)=gsn_csm_contour_map(wks,data,res)
  
  res@cnMissingValFillColor   = "background"  ; make swath clear (background)
  res@gsnCenterString="Values Only"
  plot(2)=gsn_csm_contour_map(wks,data,res)
  
  resP= True                                  ; panel mods
  resP@txString=fil_root+".HDF"               ; create title NCL V6.3.0 and earlier
 ;resP@gsnPanelMainString  = fil_root+".HDF"  ; 6.4.0 and later
  resP@gsnMaximize=True    ; make plot large
  resP@gsnPaperOrientation = "portrait"       ; force portrait orientation
  resP@gsnPanelLabelBar    = True             ; add common colorbar
  gsn_panel(wks,plot,(/3,1/),resP)          ; now draw as one plot
end
