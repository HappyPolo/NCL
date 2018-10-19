;******************************************************************
; hdf5eos_3.ncl
;
; Concepts illustrated:
;   - Reading HDF-EOS5 ['he5'] data
;   - Plotting trajectories
;   - Drawing markers on a map
;   - Reversing the Y axis in a contour plot
;   - Drawing raster contours
;   - Smoothing raster contours
;
;************************************************
; Look at MLS-AURA  data
;************************************************
; Basic User input
;************************************************
diri = "./"
fili = "MLS-Aura_L2GP-Temperature_v02-20-c01_2006d138.he5"

<<<<<<< .mine
pltType  = "png"                       ; send graphics to PNG file
pltName  = "hdf5eos"
=======
pltType  = "ps"
pltName  = "hdf5eos"
>>>>>>> .r12444

;************************************************
<<<<<<< .mine
;
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"   
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"    
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"    
;
; This file still has to be loaded manually
=======
; the following load lines are not needed after 6.2.0
;************************************************
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"   
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"    
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"    
>>>>>>> .r12444

;************************************************
;             MAIN
;************************************************

begin
    f  = addfile(diri + fili, "r")
   ;print(f)
    
; read some data

    lat  = f->Latitude_Temperature
    lon  = f->Longitude_Temperature
    lev  = f->Pressure_Temperature    ; ( nLevels_Temperature) 
    time = f->Time_Temperature        ; ( nTimes_Temperature )
    ntim = dimsizes(time)

    T    = f->L2gpValue_Temperature   ; ( nTimes_Temperature, nLevels_Temperature )

    printVarSummary(T)
    printMinMax(T, True)
    print("==============")

; time units: NCL does not *yet* have a function analogous
; to cd_calendar for TAI93 (International Atomic Time). 
; Create an "elapsed time" variable.

    telapse           = (time - time(0))/60
    telapse@long_name = "Elapsed Time (minutes)"
    telapse@units     = "minutes since "+time(0)

;************************************************
; plot
;************************************************
    wks   = gsn_open_wks (pltType,pltName)        ; open workstation
 
    res   = True
    res@gsnMaximize          = True               ; make ps/eps/pdf
   ;res@gsnPaperOrientation  = "portrait"         ; force portrait

    res@tiMainString         = fili

    res@cnFillOn             = True
    res@cnFillPalette        = "amwg"             ; set color map
    res@cnLinesOn            = False
    res@cnLineLabelsOn       = False
    res@cnFillMode           = "RasterFill"       ; faster
    res@cnRasterSmoothingOn  = True

    res@lbOrientation        = "Vertical"

    res@cnLevelSelectionMode = "ManualLevels"     ; set manual contour levels
    res@cnMinLevelValF       = 160.               ; set min contour level
    res@cnMaxLevelValF       = 260.               ; set max contour level
    res@cnLevelSpacingF      =  10.               ; set contour spacing

    res@trYReverse           = True               ; reverse y-axis
    T&nLevels_Temperature    = lev                ; assign "pressure" coordinates
    T&nTimes_Temperature     = telapse            ; assign temporal coordinates

    res@gsnYAxisIrregular2Linear = True
    res@tmYLFormat           = "f"                ; force minimal precision 
    res@tiYAxisString        = "Pressure (hPa)"

    res@gsnLeftString        = T@Title

    plot  = gsn_csm_contour (wks,T(nLevels_Temperature|:,nTimes_Temperature|:) , res)

;***************************************
; create trajectory plot
;***************************************

    mpres                    = True        ; Plot options desired.
    mpres@gsnFrame           = False       ; Don't advance the frame
    mpres@gsnMaximize        = True
    mpres@mpLandFillColor    = "gray70"    ; color of land
   ;mpres@gsnPaperOrientation= "portrait"  ; force portrait
    mpres@tiMainString       = fili
    plot = gsn_csm_map(wks,mpres)          ; Draw map   

    gsres                    = True        ; "Graphic Style" resources
    gsres@gsMarkerSizeF      = 10.0        ; Marker size
    gsres@gsMarkerThicknessF = 1.0         ; Marker thickness
    gsres@gsMarkerColor      = "Blue"      ; Marker color
    gsres@gsMarkerIndex      = 1           ; Marker style

    gsn_polymarker(wks,plot,lon,lat,gsres) ; plot trajectory
    frame(wks)
  end
