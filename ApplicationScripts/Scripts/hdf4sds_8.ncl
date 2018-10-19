;***************************************************************
; hdf4sds_8.ncl  
;
; Concepts illustrated:
;   - Reading variable ('correctZFactor') from a HDF4 file      
;   - Set undocumented 'missing' values (<0) to an _FillValue attribute
;   - Unscaling the values using the 'scale_factor' attribute
;   - At each pixel, extract max 'correctZFactor' over all vertical levels
;     Use dim_max_n to perform this task
;   - Find subregion indixes and extract subregion from a satellite swath
;   - Plot using subregion only
;   - Illustrate different ways of plotting the data
;***************************************************************
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"   
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
;***************************************************************
   varName         = "correctZFactor"      ; Radar obs "Reflectivity" is type short

   diri            = "./"
   fili            = "2A25.20090515.65505.7.HDF"
   pthi            = diri+fili
   hdf4_file       = addfile(pthi, "r") 
  ;print(hdf4_file)                        ; look at contents of data file

   longitude       =  hdf4_file->Longitude ; (:,:)
   latitude        =  hdf4_file->Latitude
  ;printVarSummary(latitude)
  ;printMinMax(latitude,0)
  ;printVarSummary(longitude)
  ;printMinMax(longitude,0)

;----------------------------------------------------
; Read data. Radar obs "Reflectivity" is type short
; (a) file does not have _FillValue or missing_value
; (b) -8888 is another undocumented bogus value
; (c) change (a) and (b)
;----------------------------------------------------
   Z_short         =  hdf4_file->$varName$   
   printVarSummary(Z_short)            ; [nscan|9247] x [nray|49] x [ncell1|80]
   printMinMax(Z_short,0)              ; -9999 , 5575      
  ;print(typeof(Z_short@scale_factor)) ; double

   Z_short@_FillValue = toshort(-9999) ;must be same type as variable
   printMinMax(Z_short,0)              ; -8888 , 5575      

   Z_short = where(Z_short.lt.0, Z_short@_FillValue, Z_short) 
   printMinMax(Z_short,0)              ; 0 , 5575      

   dimZ    = dimsizes(Z_short)         ; get dimension sizes
   nscan   = dimZ(0)
   nray    = dimZ(1)
   ncell   = dimZ(2)

;----------------------------------------------------
; unscale the variable
;----------------------------------------------------
   Z_fnl            =   Z_short/(Z_short@scale_factor)   ; [9247] x [49] x [80]
   copy_VarCoords(Z_short, Z_fnl)
   Z_fnl@long_name = Z_short@hdf_name
   Z_fnl@units     = Z_short@units 

   printVarSummary(Z_fnl)           ; [nscan|9247] x [nray|49] x [ncell1|80]
   printMinMax(Z_fnl,0)             ; 0, 55.75

;----------------------------------------------------
; For each pixel: find the maximum dBz in each column (cell)
; Make long_name appropriate for variable
;----------------------------------------------------

   max_Z = dim_max_n_Wrap(Z_fnl,2)  ; [nscan|9247] x [nray|49]
   max_Z@long_name = "MAX("+max_Z@long_name+")"
   printVarSummary(max_Z)
   printMinMax(max_Z,0)

;----------------------------------------------------
; plot
;----------------------------------------------------
   wks  =  gsn_open_wks("png","hdf4sds")

   res             = True
   res@cnFillOn    = True
   res@cnFillMode  = "CellFill"
   res@gsnAddCyclic= False                    ; data not cyclic
   res@cnLevelSelectionMode = "ExplicitLevels"
;----------------------------------------------------
; plot entire trajectory & indicate  data and no-data
;----------------------------------------------------
   res@cnLevels             = 0  
   res@cnFillPalette        = (/"black","yellow"/)  
   res@cnMissingValFillColor= "black"         ; foreground (black)
   res@gsnCenterString      = "[No Data, Data>0]"

   max_Z2 = max_Z                             ; make a copy
   max_Z2 = where(max_Z2.le.0, max_Z2@_FillValue, max_Z2)
;----------------------------------------------------
; associate lat/lon with variable to be plotted
;----------------------------------------------------
   max_Z2@lat2d = latitude
   max_Z2@lon2d = longitude
   plot   =  gsn_csm_contour_map(wks,max_Z2,res) ; whole trajectory

   delete([/ res@cnLevels, res@cnFillPalette, res@gsnCenterString \
           , max_Z2@lat2d, max_Z2@lon2d /]) 
;----------------------------------------------------
; plot sub area; for faster plot only use desired sub-region
;----------------------------------------------------

   minLat    =   5.
   maxLat    =  20.
   minLon    =  72.
   maxLon    =  84.
 
   res@mpMinLatF = minLat
   res@mpMaxLatF = maxLat
   res@mpMinLonF = minLon
   res@mpMaxLonF = maxLon

;----------------------------------------------------
; extract indices of desired sub-region
;----------------------------------------------------

   ji    = region_ind (latitude,longitude, minLat, maxLat, minLon, maxLon)
   jStrt = ji(0)      ; scan start
   jLast = ji(1)      ; scan last
   iStrt = ji(2)      ; ray  start
   iLast = ji(3)      ; ray  last
   
   Z_region       = max_Z2(jStrt:jLast,iStrt:iLast)  ; [nscan x nray]
   Z_region@lat2d = latitude(jStrt:jLast,iStrt:iLast)
   Z_region@lon2d = longitude(jStrt:jLast,iStrt:iLast)

   res@mpDataBaseVersion    = "MediumRes" ; Use slightly higher res; default is "LowRes" 

   res@cnLevels  := (/4,12,20,28,36,44,52/)  
   plot =  gsn_csm_contour_map(wks,Z_region,res)

   res@cnMissingValFillColor= "transparent"  
   plot =  gsn_csm_contour_map(wks,Z_region,res)

   res@mpFillOn   = False     ; tuen off land fill
   plot =  gsn_csm_contour_map(wks,Z_region,res)

