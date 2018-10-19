;*************************************************
; asr_2.ncl
;
; Concepts illustrated:
;   - Reading a variable
;   - Associating grid coordinates with a variable
;     via the reserved attributes 'lat2d' and 'lon2d'
;   - Plotting on a Polar Stereographic Projection
;************************************************
;
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"

;*******************************************
;read netCDF file
;*******************************************
    var = "T2M"
    diri= "./"
    fili= "asr30km.anl.2D.20000602.nc"      
    fi  = addfile(diri+fili, "r")      

    x   = fi->$var$ ; (Time, south_north, west_east) 
    printVarSummary(x)
    print("x: min="+min(x)+"   max="+max(x))

;*******************************************
; Get human readable time
;*******************************************
    yyyymmddhh = cd_calendar(x&Time, -3)
    print(yyyymmddhh)

;*******************************************
; Associate lat2d/lon2d with variable for georeferenced graphics 
;*******************************************
    x@lat2d = fi->XLAT
    x@lon2d = fi->XLONG

;*******************************************
; Create plot(s)
;*******************************************
    pltDir  = "./"
   ;pltName = "ASR_"+var
    pltName = "asr"
    pltType = "png"
    pltPath = pltDir+pltName+"."+pltType

    res                     = True              ; Plot modes desired.
    res@gsnMaximize         = True              ; Maximize plot
    res@cnFillPalette       = "amwg"            ; set color map
    res@cnFillOn            = True              ; color plot desired
    res@cnLinesOn           = False             ; turn off contour lines
    res@cnLineLabelsOn      = False             ; turn off contour line labels
    res@cnFillMode          = "RasterFill"      ; turn raster on       
    res@mpFillOn            = False
    res@mpCenterLonF        = -90.0

    res@gsnPolar   = "NH"                          ; specify the hemisphere
    res@mpMinLatF  = min(x@lat2d)

    nt   = 0
    res@tiMainString = fili
    res@gsnCenterString = yyyymmddhh(nt)
    
    wks = gsn_open_wks(pltType, pltPath)  
    plot = gsn_csm_contour_map_polar(wks,x(nt,:,:),res)   
