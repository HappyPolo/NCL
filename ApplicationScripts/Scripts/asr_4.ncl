;*************************************************
; asr_4.ncl
;
; Concepts illustrated:
;   - Reading a multiple variables
;   - Associating grid coordinates with a variable
;     via the reserved attributes 'lat2d' and 'lon2d'
;   - Plotting all variables on a panel plot
;************************************************
;
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
    
;*******************************************
;read netCDF file 
;*******************************************
    diri= "./"
    fili= "asr30km.anl.2D.20000602.nc"
    fi  = addfile(diri+fili, "r")      

    psfc= fi->PSFC         ; (Time, south_north, west_east)
    pmsl= fi->PMSL       

    q2m = fi->Q2M          ; (Time, south_north, west_east)
    q2m = q2m*1000
    q2m@units = "g/kg"     ; nicer plots

    sst = fi->SST          ; values over land are set to 0.0  
    lmask = fi->LANDMASK   ; (1 FOR LAND, 0 FOR WATER)
    sst@_FillValue = 1e20
    sst   = where(lmask.eq.1, sst@_FillValue, sst)

;*******************************************
; Get dimensions
;*******************************************
    dim_data = dimsizes(psfc)     ; any variable 
    ntim     = dim_data(0)
    nlat     = dim_data(1)
    mlon     = dim_data(2)

;*******************************************
; Get human readable time
;*******************************************
    yyyymmddhh = cd_calendar(fi->Time, -3)
    print(yyyymmddhh)

;*******************************************
; Associate lat2d/lon2d with variables for georeferenced graphics 
;*******************************************
    psfc@lat2d = fi->XLAT
    psfc@lon2d = fi->XLONG

    pmsl@lat2d = fi->XLAT
    pmsl@lon2d = fi->XLONG

    q2m@lat2d  = fi->XLAT
    q2m@lon2d  = fi->XLONG

    sst@lat2d  = fi->XLAT
    sst@lon2d  = fi->XLONG

;*******************************************
; Create plot(s)
;*******************************************
    pltDir  = "./"
   ;pltName = "ASR_"+var
    pltName = "asr"
    pltType = "png"                             ; send graphics to PNG file

    pltPath = pltDir+pltName

    nplt    = 4
    plot    = new( nplt, "graphic")
    
    wks = gsn_open_wks(pltType, pltPath)

    res                     = True              ; Plot modes desired.
    res@gsnDraw             = False
    res@gsnFrame            = False
    res@gsnPolar            = "NH"              ; specify the hemisphere
   ; res@cnFillPalette       = "amwg"            ; set color map
    res@cnFillOn            = True              ; color plot desired
    res@cnLinesOn           = False             ; turn off contour lines
    res@cnLineLabelsOn      = False             ; turn off contour line labels
    res@cnFillMode          = "RasterFill"      ; turn raster on       

    res@mpFillOn            = False
    res@mpMinLatF           = min(psfc@lat2d)
    res@mpCenterLonF        = -90.             

    nt   = ntim/2

    plot(0) = gsn_csm_contour_map_polar(wks,psfc(nt,:,:),res)   
    plot(1) = gsn_csm_contour_map_polar(wks,pmsl(nt,:,:),res)   
    plot(2) = gsn_csm_contour_map_polar(wks,q2m (nt,:,:),res)   
    plot(3) = gsn_csm_contour_map_polar(wks, sst(nt,:,:),res)   

;************************************************
; create panel
;************************************************
    resP                     = True                ; modify the panel plot
    resP@gsnMaximize         = True                ; Maximize plot
    resP@txString            = fili+":    t="+yyyymmddhh(nt)
    gsn_panel(wks,plot,(/2,2/),resP)               ; now draw as one plot
