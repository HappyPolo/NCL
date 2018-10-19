;***************************************************************
; hdf5_2.ncl
;
; Concepts illustrated:
;   - Reading a h5 file with groups and a compound data typey
;   - Using information in a group to create complete variable
;     Information was provided by 'ncl_filedump'
;   - Use print and printVarSummary to examine variables
;   - Use 'stat_dispersion' to examine the variable distribution
;   - Create regional standard cylindrical equidistant plot
;***************************************************************
; Always examine file contents:
; %> ncl_filedump foo.h5 | less
;************************************************
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"   
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"    
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"    
;************************************************
  PLOT = True
  NC   = True
  
 ;setfileoption("h5", "FileStructure", "Advanced")
  
  diri = "./"
  fili = "K1VHR_15NOV2013_1200_L02_OLR.h5"
  
  f    = addfile(diri+fili, "r")
  print(f)            ; same as  'ncl_filedump foo.h5'
 
  Latitude  = f->/OLR/OLR_Dataset.Latitude            
  Longitude = f->/OLR/OLR_Dataset.Longitude         
 
  print("---")
  printVarSummary(Latitude)                            ; [DIM_000 | 250601]
  print("Latitude: min="+min(Latitude)+"   max="+max(Latitude))
  print("---")
  printVarSummary(Longitude)                           ; [DIM_000 | 250601]
  print("Longitude: min="+min(Longitude)+"   max="+max(Longitude))
  print("---")
 ;print(Latitude+"   "+Longitude)
  print("---")
 
  gp    = f->GP_PARAM_INFO                   ; read group
  print(gp)
  print("---")
  
  latS  = gp@ValidBottomLat
  latN  = gp@ValidTopLat 
  lonL  = gp@ValidLeftLon
  lonR  = gp@ValidRightLon
  
  dlat  = gp@LatInterval
  nlat  = toint((latN-latS)/dlat)+1
  lat   = fspan(latS, latN, nlat)
  lat!0 = "lat"
  lat@units = "degrees_north"
 
  dlon  = gp@LonInterval
  mlon  = toint((lonR-lonL)/dlon)+1
  lon   = fspan(lonL, lonR, mlon)
  lon!0 = "lon"
  lon@units = "degrees_east"
  
 ;OLR = f->/OLR/OLR_Dataset.OLR
 ;printVarSummary(OLR)              ; [DIM_000 | 250601]
  
  olr     = onedtond( f->/OLR/OLR_Dataset.OLR, (/nlat,mlon/) )
  olr!0   = "lat"
  olr!1   = "lon"
  olr&lat =  lat
  olr&lon =  lon
;;olr@long_name = gp@GP_PARAM_NAME   ; original 'long_name'
;;olr@units     = gp@OLR_Unit        ; original units
  olr@long_name = "OLR"
  olr@units     = "W/m^2"
                  
  print("typeof(gp@MissingValueInProduct="+typeof(gp@MissingValueInProduct))   ; type double

  olr@_FillValue= tofloat(gp@MissingValueInProduct)  ; match olr type
  
  printVarSummary(olr)
  print("olr: min="+min(olr)+"   max="+max(olr))
  print("---")

;************************************************
; Examine distribution   
;************************************************

  opt = True
  opt@PrintStat = True
  stat = stat_dispersion(olr, opt )

  if (PLOT) then
;************************************************
; create plot
;************************************************
     wks = gsn_open_wks("png" ,"hdf5")        ; send graphics to PNG file
   
     res                       = True     ; plot mods desired
     res@gsnAddCyclic          = False    ; regional data
     res@gsnMaximize           = True     ; affects ps, eps, pdf, png only
   
     res@cnFillOn              = True     ; turn on color fill (default 6.1.0)
     res@cnFillPalette         = "BlAqGrYeOrRe"  ; set color map
     res@cnLinesOn             = False    ; turn of contour lines
     res@cnLineLabelsOn        = False    ; turn of contour lines labels
     res@cnFillMode            = "RasterFill"  ; fast
   
     res@pmTickMarkDisplayMode = "Always" ; use NCL default lat/lon labels
   
     res@mpFillOn             = False     ; default is True (gray land)				       
     res@mpMinLatF            = latS
     res@mpMaxLatF            = latN
     res@mpMinLonF            = lonL
     res@mpMaxLonF            = lonR

     res@tiMainString         = fili
     
     plot = gsn_csm_contour_map(wks,olr, res)
 end if   ; PLOT

 if (NC) then
     print("---")
     fbase = str_get_field(fili,1,".")
     print("fbase="+fbase)

     diro = "./"
     filo = fbase+".nc"
     ptho = diro+filo
     
     system("/bin/rm -f "+ptho) ; remove any pre-existing file
     ncdf = addfile(ptho ,"c")  ; open output netCDF file

                                          ; create global attributes of the file
     fAtt               = True            ; assign file attributes
     fAtt@title         = "NCL: H5 to netCDF"  
     fAtt@source        = "MOSDAC: Meteorological & Oceanographic Satellite Data Archival Center (India)"
     fAtt@source_file   =  fili
     fAtt@Conventions   = "None"   
     fAtt@creation_date = systemfunc ("date")        
     fileattdef( ncdf, fAtt )            ; copy file attributes    

     ncdf->OLR = olr

 end if
