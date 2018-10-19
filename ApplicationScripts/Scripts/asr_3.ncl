;*************************************************
; asr_3.ncl
;
; Concepts illustrated:
;   - Reading a multilevel variable
;   - Associating grid coordinates with a variable
;     via the reserved attributes 'lat2d' and 'lon2d'
;   - Manually creating a 'coordinate variable'
;   - Accessing selected levels using 'coordinate variable' syntax
;   - Plotting selected levels on panel plot
;************************************************
;
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"

;*******************************************
;read netCDF file 
;*******************************************
    var = "RH"
    diri= "./"
    fili= "asr30km.anl.3D.20000602.nc"      
    fi  = addfile(diri+fili, "r")      

    x   = fi->$var$ ; (Time, num_metgrid_levels, south_north, west_east) 
    printVarSummary(x)

;*******************************************
; Dimension information
;*******************************************

    dimx = dimsizes(x)
    ntim = dimx(0)
    klev = dimx(1)
    nlat = dimx(2)
    mlon = dimx(3)

;*******************************************
; Get the pressure levels. Manually associate values with variable 
; Rename the level dimension for convenience
;*******************************************
    plev   = fi->PRES
    plev!0 = "plev"        ; name dimension

    x!1    = "plev"
    x&plev =  plev 
    printVarSummary(x)

;*******************************************
; Print min and max at each level over all times
;*******************************************
  
    do kl=0,klev-1
       print(var+"  plev="+x&plev(kl)+" min="+min(x(:,kl,:,:)) \
                                     +" max="+max(x(:,kl,:,:)) )
    end do

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
    pltType = "png"                             ; send graphics to PNG file

    pltPath = pltDir+pltName+"."+pltType

    plev_plt= (/ 950, 850, 700, 600 /)*100      ; desired plev (Pa)
    nplt    = dimsizes(plev_plt)
    plot    = new( nplt, "graphic")
    
    wks = gsn_open_wks(pltType, pltPath)  

    res                     = True              ; Plot modes desired.
    res@gsnDraw             = False
    res@gsnFrame            = False
   ;res@gsnSpreadColors     = True              ; use full range of colormap
    res@cnFillOn            = True              ; color plot desired
    res@cnLinesOn           = False             ; turn off contour lines
    res@cnLineLabelsOn      = False             ; turn off contour line labels
    res@cnFillMode          = "RasterFill"      ; turn raster on       

    res@cnLevelSelectionMode =  "ManualLevels"   
    res@cnMinLevelValF       =  25.
    res@cnMaxLevelValF       =  95.
    res@cnLevelSpacingF      =   5. 

    res@gsnPolar            = "NH"              ; specify the hemisphere
    res@mpFillOn            = False
    res@mpMinLatF           = min(x@lat2d)
    res@mpCenterLonF        = -90.0    
    res@lbLabelBarOn        = False             ; turn off individual lb's

    nt   = ntim/2

    do np=0,nplt-1
       res@gsnCenterString ="p="+plev_plt(np)
       plot(np) = gsn_csm_contour_map_polar(wks,x(nt,{plev_plt(np)},:,:),res)   
    end do

;************************************************
; create panel
;************************************************
    resP                     = True                ; modify the panel plot
    resP@gsnMaximize         = True                ; Maximize plot
    resP@txString            = fili+":    t="+yyyymmddhh(nt)
    resP@gsnPanelLabelBar    = True                ; add common colorbar
    gsn_panel(wks,plot,(/2,2/),resP)               ; now draw as one plot
