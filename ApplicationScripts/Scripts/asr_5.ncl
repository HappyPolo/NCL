;*************************************************
; asr_5.ncl
;
; Concepts illustrated:
;   - Reading a multilevel variable
;   - Manually creating a coordinate variable
;   - Plotting a cross section              
;************************************************
;
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"

;*******************************************
;read netCDF file 
;*******************************************
begin
    var   = "SPD"
    diri  = "./"
    fili  = "asr30km.anl.3D.20000602.nc"      
    fi    = addfile(diri+fili, "r")      

    z     = fi->$var$ ; (Time, num_metgrid_levels, south_north, west_east) 
    printVarSummary(z)

    lat2d = fi->XLAT
    lon2d = fi->XLONG

;*******************************************
; Dimension information
;*******************************************

    dimz = dimsizes(z)
    ntim = dimz(0)
    klev = dimz(1)
    nlat = dimz(2)
    mlon = dimz(3)

;*******************************************
; Get the pressure levels. Manually associate values with variable 
; Rename the level dimension for convenience
;*******************************************
    plev   = fi->PRES
    plev!0 = "plev"        ; name dimension

    z!1    = "plev"
    z&plev =  plev 
    printVarSummary(z)

;*******************************************
; Get human readable time
;*******************************************
    yyyymmddhh = cd_calendar(z&Time, -3)
    print(yyyymmddhh)

;*******************************************
; Create plot(s)
;*******************************************
    pltDir  = "./"
   ;pltName = "ASR_"+var
    pltName = "asr"
    pltType = "png"                               ; send graphics to PNG file

    pltPath = pltDir+pltName
    wks = gsn_open_wks(pltType, pltPath)  


;*******************************************
; Draw the boundary and the two cross sections
;*******************************************
    resmp                     = True              ; Plot mods desired.
    resmp@gsnMaximize         = True

    resmp@gsnDraw             = False             ; turn off so we can add
    resmp@gsnFrame            = False             ;    polylines

    resmp@gsnPolar            = "NH"              ; specify the hemisphere
    resmp@mpFillOn            = False
    resmp@mpMinLatF           = min(lat2d)
    resmp@mpCenterLonF        = -90.0    

    plot = gsn_csm_map_polar(wks,resmp)

;*******************************************
; Add some polylines showing locations of
; cross sections.
;*******************************************
    respl                     = True              ; polyline resources
    respl@gsLineThicknessF    = 2.0               ; thickness of lines
    respl@gsLineColor         = "black" 

    id1 = gsn_add_polyline(wks,plot,lon2d(:,  0   ),lat2d(:,  0   ),respl)
    id2 = gsn_add_polyline(wks,plot,lon2d(:,mlon-1),lat2d(:,mlon-1),respl)
    id3 = gsn_add_polyline(wks,plot,lon2d(nlat-1,:),lat2d(nlat-1,:),respl)
    id4 = gsn_add_polyline(wks,plot,lon2d(  0   ,:),lat2d(  0   ,:),respl)

    ml4 = mlon/4              ; arbitrary
    respl@gsLineColor         = "blue" 
    id5 = gsn_add_polyline(wks,plot,lon2d(:, ml4  ),lat2d(:, ml4  ),respl)

    draw(plot)    ; this will draw the plot and all the added lines
    frame(wks)

;**************************************************
; Create resources for cross section(s)
;**************************************************
   nt   = ntim/2             ; arbitrary time

   resx = True
   resx@cnFillOn             = True            ; turn on color fill
   resx@cnLinesOn            = False           ; turn lines on/off         ; True is default
   resx@cnLineLabelsOn       = False           ; turn line labels on/off   ; True is default
   resx@cnFillPalette        = "ncl_default"   ; "ncl_default" is the default color map

   nLabels                   = 8               ; arbitrary  
   resx@tmXBLabels           = new(nLabels,"string")
   resx@tmXBMode             = "Explicit"

;**************************************************
; Draw Full cross section at a specified blue grid line
;**************************************************
    resx@tmXBValues         := toint( fspan(0,nlat-1,nLabels) )
    do i=0,nLabels-1
       x = lon2d(resx@tmXBValues(i),ml4)
       y = lat2d(resx@tmXBValues(i),ml4)
       resx@tmXBLabels(i) = sprintf("%5.1f", y)+"~C~"+sprintf("%5.1f", x)
    end do
   
    resx@tiMainString = "BLUE: Full Grid Line X-Section: ml="+ml4
    plot  = gsn_csm_pres_hgt(wks, z(nt,:,:,ml4), resx ) 
end
