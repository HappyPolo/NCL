;******************************************************************
; hdf4eos_5.ncl
;
; Concepts illustrated:
;   - Plotting EOS-DIS data
;   - Reading HDF4 data
;   - Using dim_gbits to extract bits of information from a variable
;   - Creating a color map using named colors
;   - Drawing raster contours
;   - Using triangular meshes to create contours
;   - Turning off the addition of a longitude cyclic point
;   - Changing the center longitude/latitude for a cylindrical equidistant projection
;   - Setting contour levels using a min/max contour level and a spacing
;   - Overlaying contours on a map using two-dimensional lat,lon arrays
;   - Adding a title to a labelbar
;   - Centering the labels under the labelbar boxes
;   - Changing the labelbar labels
;   - Drawing country boundaries on a map
;   - Turning on map tickmark labels with degree symbols
;
;******************************************************************
;    Bit fields within each byte are numbered from the left: 
;    7, 6, 5, 4, 3, 2, 1, 0.                                                 
;    The left-most bit (bit 7) is the most significant bit.                  
;    The right-most bit (bit 0) is the least significant bit.                
;                                                                            
;    bit field    Description                        Key                     
;    ---------    -----------                        ---                     
;    2, 1         Unobstructed FOV Quality Flag    00 (0) = Cloudy           
;                                                  01 (1) = Uncertain        
;                                                  10 (2) = Probably  Clear  
;                                                  11 (3) = Clear          
;******************************************************************
;
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"  
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"  
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"  

begin
;******************************************************************
; open file
;******************************************************************
  fili   = "MOD35_L2.A2001094.0530.004.2003017124059.hdf"
  f      = addfile (fili, "r")
;******************************************************************
; read lat/lon [5km] and Cloud_Mask [1km]
;******************************************************************
  lat2d  = f->Latitude
  lon2d  = f->Longitude
  cldmsk = f->Cloud_Mask(0,:,:)  ; read data for first byte [NCL starts at 0]
;******************************************************************
; Latitude/Longitude arrays are every 5km. Cloud_Mask is every 1km
; It is necessary to decimate the Cloud_Mask to match lat/lon
;******************************************************************
  dimcm  = dimsizes(cldmsk)
  NY     = dimcm(0)                  ; "along"  swath  [1 km]
  MX     = dimcm(1)                  ; "across" swath  [1 km]
  cm     = cldmsk(4:NY-1:5,4:MX-1:5) ; decimate to match lat2d/lon2d dimsizes
  delete(cldmsk)                     ; no longer needed
 
;******************************************************************
; extract the desired bits and attach lat/lon arrays
; cmfov = 00 [0] cloudy          ; 01 [1] uncertain 
;         10 [2] probably clear  ; 00 [3] confidently clear
;******************************************************************
  dimll  = dimsizes(lat2d)
  ny     = dimll(0)                  ; "along"  swath  [5 km]
  mx     = dimll(1)                  ; "across" swath  [5 km]
                                     ; extract bit pair
  tmp    = dim_gbits(ndtooned(cm),5,2,6,ny*mx) ; flagS
  cmfov  = onedtond(tmp, (/ny,mx/))  ; flags

  cmfov@lat2d = lat2d                ; attach 5km lat/lon info
  cmfov@lon2d = lon2d                ; lat2d, lon2d are *reserved* attributes

;******************************************************************
; create plot
;******************************************************************
  wks = gsn_open_wks("png" ,"hdf4eos")          ; send graphics to PNG file
  colors = (/"gray"                    \        ; cloudy
            ,"red"                     \        ; uncertain
            ,"green"                   \        ; probably clear
            ,"white"                   /)       ; clear

  res                      = True     ; plot mods desired
;;res@gsnMaximize          = True     ; uncomment to maximize plot
  res@gsnAddCyclic         = False    ; data not cyclic

  res@cnFillOn             = True          ; turn on color fill
  res@cnFillPalette        = colors        ; set color map
  res@cnLinesOn            = False         ; turn on contour lines
  res@cnFillMode           = "RasterFill"  ; turn on raster mode

  res@cnLevelSelectionMode = "ManualLevels"     ; set manual contour levels
  res@cnMinLevelValF       =   1                ; set min contour level
  res@cnMaxLevelValF       =   3                ; one less than max
  res@cnLevelSpacingF      =   1                ; set contour spacing

  res@trGridType           = "TriangularMesh"   ; *faster* graphic rendering

  res@lbLabelStrings       = ispan(0,3,1)       ; 0, 1, 2, 3
  res@lbLabelPosition      = "Center"           ; label position
  res@lbLabelAlignment     = "BoxCenters"

  res@lbTitleString        = "0=cldy, 1=uncertain, 2=prob clr, 3=clr"
  res@lbTitlePosition      = "Bottom"
  res@lbTitleFontHeightF   = 0.0125             ; default 0.025

  res@mpProjection         = "Satellite" ; choose map projection
  res@mpFillOn             = False              ; turn off map fill
  res@mpCenterLonF         = (min(lon2d)+max(lon2d))*0.5
  res@mpCenterLatF         = (min(lat2d)+max(lat2d))*0.5

  res@mpLimitMode          = "LatLon"           ; required
  res@mpMinLatF            = min(lat2d)-1       ; min lat
  res@mpMaxLatF            = max(lat2d)+1       ; max lat
  res@mpMinLonF            = min(lon2d)-1       ; min lon
  res@mpMaxLonF            = max(lon2d)+1       ; max lon

  res@mpOutlineBoundarySets= "National"
  res@pmTickMarkDisplayMode= "Always"           ; turn on automatic tickmarks

  res@tiMainString         = "Unobstructed FOV Quality Flag"
  res@gsnCenterString      = fili

  map  = gsn_csm_contour_map(wks, cmfov, res)   ; map
end

