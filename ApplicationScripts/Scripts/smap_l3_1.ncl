;*************************************************************** 
; smap_l3_1.ncl 
; 
; Concepts illustrated: 
;   - Reading a SMAP HDF5 level 3 file with groups
;   - Use 'direct' syntax to access variable within groups
;   - Manually adding _FillValue to latitude and longitude
;   - Plot
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
;;===============================================================

;---Read specified h5 file
  diri = "./"
  fili = "SMAP_L3_SM_P_20150413_R13080_002.h5"
  pthi = diri + fili
  f    = addfile(pthi, "r")
    
;--Set group (begin and end with /); and desired variable
  grp_smrd  = "/Soil_Moisture_Retrieval_Data/"
  varName   = "soil_moisture"
  var_path  = grp_smrd + varName
  sm        = f->$var_path$
  printVarSummary(sm)
  printMinMax(sm, 0)

  latName   = "latitude"
  lat_path  = grp_smrd + latName
  lat2d     = f->$lat_path$
 ;printVarSummary(lat2d)
 ;printMinMax(lat2d, 0)

  lonName   = "longitude"
  lon_path  = grp_smrd + lonName
  lon2d     = f->$lon_path$
 ;printVarSummary(lon2d)
 ;printMinMax(lon2d, 0)

;---Manually add a _FillValue to lat/lon; not sure why 
;---_FillValue not associated with the variable
  lat2d@_FillValue = -9999.0
  lon2d@_FillValue = -9999.0
 ;printMinMax(lat2d, 0)
 ;printMinMax(lon2d, 0)

;---Sample plot options
  pltDir   = "./"
  pltType  = "png"
  pltName  = "smap_l3_1"
  pltTitle =  fili

;---
  pltPath = pltDir+pltName
  wks = gsn_open_wks(pltType,pltPath)

  res                  = True              ; Plot modes desired.
  res@gsnMaximize      = True              ; Maximize plot
  res@gsnAddCyclic     = False

  res@cnFillOn         = True              ; color plot desired
  res@cnLinesOn        = False             ; turn off contour lines
  res@cnLineLabelsOn   = False             ; turn off contour labels
  res@cnFillMode       = "RasterFill"      ; turn raster on      
  res@cnFillPalette    = "BlAqGrYeOrReVi200"

  if (varName.eq."soil_moisture") then
      res@cnLevelSelectionMode = "ManualLevels"     ; set manual contour levels
      res@cnMinLevelValF       = 0.05               ; set min contour level
      res@cnMaxLevelValF       = 0.95               ; set max contour level
      res@cnLevelSpacingF      = 0.05               ; set contour spacing
  end if

;---Resources for plotting original (source) data
  res@sfXArray         = lon2d
  res@sfYArray         = lat2d
  res@trGridType       = "TriangularMesh"  

  res@tiMainString     = fili
  res@gsnLeftString    = "SMAP: Soil Moisture"    ; default long_name is too long
  plot_smap = gsn_csm_contour_map(wks,sm,res)
