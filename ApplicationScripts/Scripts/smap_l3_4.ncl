;*************************************************************** 
; smap_l3_4.ncl 
; 
; Concepts illustrated: 
;   - Read multiple HDF5 SMAP Level-3 files with groups
;   - Use 'direct' syntax to access variable within groups
;   - Manually adding _FillValue to latitude and longitude
;   - Create a base 'super variable'
;   - Select the non-missing values from each file. Add to super variable.
;   - Read a file containg the EASE SMAP grid
;   - Use these lat/lon for location 
;   - Plot 'super variable'
;***************************************************************
; These library files are loaded by default in NCL V6.2.0 and newer
;
;;load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl" 
;;load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl" 
;**************************************************************
;
;;===============================================================
; SMAP values are provided on the global cylindrical EASE-Grid 2.0.
; Each grid cell has a nominal area of approximately 36 x 36 km2 
; regardless of longitude and latitude. Using this projection, all 
; global data arrays have dimensions of 406 rows and 964 columns. 
;===============================================================

;---Read h5 file(s)

  diri = "./"
  fili = systemfunc("cd "+diri+" ; ls SMAP_L3_SM_P_2015*h5")
  nfili= dimsizes(fili)
  print(fili)
  print("================")

  pthi = diri + fili
  print(pthi)
  print("================")

;---Open files; 'f' is type list
  f    = addfiles(pthi, "r")

;---Set group; begin and end with /
  grp_smrd  = "/Soil_Moisture_Retrieval_Data/"
  var_long_name = "SMAP: Soil Moisture"    ; default long_name is too long

;---Set variable name  
  varName   = "soil_moisture"

;---Loop over each file
  do nf=0,nfili-1
    print("nf="+nf+"; "+fili(nf))
  
;---Same lat/lon dimension sizes but maybe different -9999.0
    latName   = "latitude"
    lat_path  = grp_smrd + latName
    lat2d     = f[nf]->$lat_path$
   ;printVarSummary(lat2d)
   ;printMinMax(lat2d, 0)
  
    lonName   = "longitude"
    lon_path  = grp_smrd + lonName
    lon2d     = f[nf]->$lon_path$
   ;printVarSummary(lon2d)
   ;printMinMax(lon2d, 0)
  
;---Manually add _FillValue
    lat2d@_FillValue = -9999.0
    lon2d@_FillValue = -9999.0
   ;printMinMax(lat2d, 0)
   ;printMinMax(lon2d, 0)
  
;---Set variable and group path
    var_path  = grp_smrd + varName
   ;printMinMax(var, 0)
  
;---VAR will contain values from all the files. A 'super' variable
    if (nf.eq.0) then
        VAR       = f[nf]->$var_path$
       ;printVarSummary(VAR)
    else
        var = f[nf]->$var_path$
        VAR = where(.not.ismissing(lat2d) .and. .not.ismissing(lon2d) .and. \
                    .not.ismissing(var), var, VAR)
    end if

  end do
  
  dimVAR = dimsizes(VAR)
  nlat   = dimVAR(0)
  mlon   = dimVAR(1)

;---Get lat & ln for SMAP EASE grid
  dir_EASE = "./"
  fil_EASE = "SMAP_EASE.406x964.nc"
  pth_EASE = dir_EASE + fil_EASE
  f_EASE   = addfile(pth_EASE,"r")
  lat2d    = f_EASE->LAT2D
  lon2d    = f_EASE->LON2D

;---Plot options
  pltDir   = "./"
  pltType  = "png"
  pltName  = "smap_l3_4"
  pltTitle = "Multiple SMAP: SMAP_L3_SM_P_2015*h5"

;---Plot 'super variable'
  pltPath = pltDir+pltName
  wks = gsn_open_wks(pltType,pltPath)

  res                      = True              ; Plot modes desired.
  res@gsnMaximize          = True              ; Maximize plot
  res@gsnAddCyclic         = False

  res@cnFillOn             = True              ; color plot desired
  res@cnLinesOn            = False             ; turn off contour lines
  res@cnLineLabelsOn       = False             ; turn off contour labels
  res@cnFillMode           = "RasterFill"      ; turn raster on      
  res@cnFillPalette        =  "BlAqGrYeOrReVi200"

  if (varName.eq."soil_moisture") then
      res@cnLevelSelectionMode = "ManualLevels"     ; set manual contour levels
      res@cnMinLevelValF       = 0.05               ; set min contour level
      res@cnMaxLevelValF       = 0.95               ; set max contour level
      res@cnLevelSpacingF      = 0.05               ; set contour spacing
  end if

 ;---Resources for plotting original (source) data
  res@sfXArray             = lon2d
  res@sfYArray             = lat2d
  res@trGridType           = "TriangularMesh"   

  res@tiMainString  = pltTitle
  res@gsnLeftString = "Soil Moisture"          ; real long_name is too long
  plot_smap = gsn_csm_contour_map(wks,VAR,res)
