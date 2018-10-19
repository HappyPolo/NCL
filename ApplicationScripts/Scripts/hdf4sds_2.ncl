;***************************************************************
; hdf4sds_2.ncl
;
; Concepts illustrated:
;   - Reading HDF4-SDS files
;   - Attaching coordinate arrays to a variable
;   - Adding a missing value (_FillValue)
;   - Using "stat_dispersion" to look at data
;   - Writing data to a NetCDF file using the easy but inefficient method
;   - Explicitly setting contour levels
;*********** Load Libraries ************************************
;
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl" 
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl" 
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl" 
;**************************************************************
begin
;***************************************************************
; User Input
;***************************************************************
                                             ; INPUT
   diri    = "./"                            ; input directory
   fili    = "May2009-1km-d01-IndiaSriLanka-chl.hdf"
   var     = "Mapped_Composited_mapped"
                                             ; OUTPUT
   PLOT    = True                            ; create a plot [?]
   pltDir  = "./"                            ; directory for plot output
   pltName = "hdf4sds"                       ; set plot name 
   pltType = "png"                           ; send graphics to PNG file

   netCDF  = True                            ; create a netCDF [?}

;***************************************************************
; End User Input
;***************************************************************
; Read hdf 
;***************************************************************

   f      = addfile (diri+fili, "r")
   x      = f->$var$                           ; (2530,3630)
   x@_FillValue    = -1
   x@missing_value = -1

   dimx   = dimsizes(x)
   
;*****************************************************
; Create netCDF coordinate variables. The lat are N->S            
;*****************************************************
   mapbnd     = x@Limit                        ; (4,62,27,95)
   
   nlat       = dimx(0)
   mlon       = dimx(1)
   lat        = fspan(mapbnd(2), mapbnd(0), nlat) 
   lon        = fspan(mapbnd(1), mapbnd(3), mlon) 

   lat@long_name = "latitude"
   lat@units  = "degrees_north"
   lat!0      = "lat"
   lat&lat    =  lat

   lon@long_name = "longitude"
   lon@units  = "degrees_east"
   lon!0      = "lon"
   lon&lon    =  lon

   printMinMax(lat, True)
   printMinMax(lon, True)

;***************************************************************
; Associate the spatial coordinates with variables
;***************************************************************
   x!0      = "lat"                   ; 1st ... name the dimensions
   x!1      = "lon"
   x&lat    =  lat                    ; create coordinate variable
   x&lon    =  lon                    

;***************************************************************
; Simple data exploration:   Distribution statistics
;***************************************************************

   opt = True
   opt@PrintStat = True
   statb = stat_dispersion(x, opt )        ; v5.1.1
   
   if (PLOT) then
;************************************************
; Create plot 
;************************************************
       wks    = gsn_open_wks(pltType, pltDir+pltName)

       setvalues NhlGetWorkspaceObjectId()
           "wsMaximumSize": 100000000      ; need some extra workspace
       end setvalues
   
       res                      = True     ; plot mods desired
       res@gsnAddCyclic         = False    ; data not global

       res@gsnMaximize          = True     ; make ps/eps/pdf large
       res@gsnPaperOrientation  = "portrait"
     
       res@cnFillOn             = True     ; turn on color fill
       res@cnFillPalette        = "amwg"   ; set color map
       res@cnLinesOn            = False    ; turn of contour lines
       res@cnLineLabelsOn       =  False       ; Turn off contour lines
      ;res@cnFillMode           = "CellFill"           ; Cell Mode
       res@cnFillMode           = "RasterFill"         ; Raster Mode
     
       res@cnLevelSelectionMode = "ManualLevels"     ; set manual contour levels
       res@cnMinLevelValF       = 0.10               ; set min contour level
       res@cnMaxLevelValF       = 0.4                ; set max contour level
       res@cnLevelSpacingF      = 0.025              ; set contour spacing

       res@lbOrientation        = "vertical"   ; vertical label barb's
       res@lbLabelFontHeightF   = 0.012        ; change font size [make smaller]
       res@pmLabelBarWidthF     =  0.1         ; make thinner

       res@mpMinLatF            = min(lat)     
       res@mpMaxLatF            = max(lat)
       res@mpMinLonF            = min(lon) 
       res@mpMaxLonF            = max(lon)
       res@mpCenterLonF         = x@Longitude_Center
       res@mpFillOn             = False
       res@mpOutlineOn          = True

       res@mpOutlineBoundarySets  = "National"  ; turn on country boundaries
       res@mpDataSetName        = "Earth..4"    ; database for non-USA divisions
       res@mpDataBaseVersion    = "MediumRes"   ; Medium resolution database
       res@mpOutlineSpecifiers  = (/"India:states"/)

       res@gsnLeftString        = fili
       plot    = gsn_csm_contour_map(wks,x, res)
   end if      ; PLOT

   if (netCDF) then
;**************************************************
; Create netCDF: Add additional information
;**************************************************
       sfx   = get_file_suffix(fili,0)  

       diro  = "./"
       filo  = sfx@fBase+".nc"
       print("filo="+filo)

       system ("/bin/rm -f "+diro+filo)

       fo    = addfile(diro+filo, "c")
       fo@creation_date = systemfunc("date")
       fo->$var$ = x
   end if      ; netCDF
end
