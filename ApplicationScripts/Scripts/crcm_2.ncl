;*******************************************
; crcm_2.ncl
;
; Concepts illustrated:
;   - Reading multiple CRCM netCDF files containing 3-hrly data
;   - Computing daily averages using simple loop plus array syntax
;   - Dealing with (possibly) packed data on netCDF file
;***************************************************************
;
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"  
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"  
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"  
;***************************************************************

begin
; diri    = "/project/cas/shea/DEBASISH/"        ; input dir
 diri    = "./"
 fili    = systemfunc("cd "+diri+" ; ls pr_CRCM_*nc") ; input file name(s)
 nfil    = dimsizes(fili)
 print(fili)

 varName = "pr"
 netCDF  = True
 PLOT    = True

 if (netCDF) then
     ncDir   = "./"                        ; directory for netCDF output
     ncPack  = True                        ; True=>create "short"; False=>float
     if (ncPack) then
         scale   = 1000.
         optPack = True
         optPack@scale_factor = 1./scale   ; COARDS/CF convention attributes
         optPack@add_offset   = 0.
     end if
 end if

 if (PLOT) then
     pltDir  = "./"                        ; directory for plot output
     pltName = "crcm"                      ; netCDF name output
     pltType = "png"                       ; send graphics to PNG file
 end if

;*******************************************
; Loop over files                                    
;*******************************************
 do nf=0,nfil-1
    f       = addfile (diri+fili(nf), "r")
    x3      = f->$varName$           ; (time,yc, xc) 3 hrly

    dimx3   = dimsizes(x3)
    NTIM    = dimx3(0)               ; TOTAL number of time steps
    print("NTIM="+NTIM)

;*******************************************
; Create daily averages                              
;*******************************************
    ntJump  = 8                      ; 3-hrly values
    x       = x3(::ntJump,:,:)       ; trick: create array with meta
    printVarSummary(x)               ; values will be overwritten with averages

    ntStrt  = 0
    ntLast  = ntJump-1
    do nt=0,NTIM-1,ntJump            ; dim_avg_n v5.1.1
       x(nt/ntJump,:,:) = (/ dim_avg_n(x3(ntStrt:ntLast,:,:), 0) /)   ; (/.../) ignore meta
       ntStrt  = ntStrt+ntJump
       ntLast  = ntLast+ntJump
    end do
    x@info_tag     = "daily average"

;*******************************************
; Convert units kg/(m2-s) to mm/day
; multiply by (10^3mm m-1 x 86400 s day-1) and
; divide by density_H2O (1000 kg m-3):
; [kg/m2-s][1000 mm/m][86400 s/day][(1/1000) m3/kg] ==> mm/day
;*******************************************

    x = x*86400.
    x@units = "mm/day"

;*******************************************
; Miscellaneous for netCDF or graphics
;*******************************************
    time    = x&time                 ; time associated with daily averages
    lat     = f->lat                 ; lat(yc, xc)
    lon     = f->lon                 ; lon(yc, xc)

    filSfx  = get_file_suffix(fili(nf),0)  
    filRoot = filSfx@fBase           ; naming convenience
    print("filRoot="+filRoot)

    ymd     = cd_calendar(time,-2)   ; yyyymmdd (integer)
    yfrac   = cd_calendar(time, 4)   ; year.fraction_of_year

    ntim    = dimsizes(time)              
    print("ntim="+ntim)
       
    yyyy    = ymd/10000
    mmdd    = ymd - (yyyy*10000)
    mm      = mmdd/100
    dd      = mmdd-(mm*100)
    hh      = 12             ; center of 'mass' for the day

    yrStrt  = yyyy(0)
    yrLast  = yyyy(ntim-1)

;********************************************
; create plot
;********************************************
    if (PLOT) then
        pltNamV = pltName+"."+yrStrt+"-"+yrLast+"."+varName
        wks     = gsn_open_wks(pltType, pltDir+pltName)
                                             
        colors = (/"Snow","PaleTurquoise","PaleGreen","SeaGreen3" ,"Yellow"  \
               ,"Orange","HotPink","Red","Violet", "Purple", "Brown"/)

        x@lat2d = lat                 
        x@lon2d = lon
   
        res                       = True               ; plot mods desired
        res@gsnMaximize           = True               ; make ps/pdf large
        res@tiMainString          = fili
   
        res@cnFillOn              = True               ; color fill  
        res@cnFillPalette         = colors             ; set color map
        res@cnLinesOn             = False              ; no contour lines
        res@cnLineLabelsOn        = False              ; no contour labels
        res@cnInfoLabelOn         = False              ; no contour info label
        res@cnFillMode            = "RasterFill"       ; Raster Mode
        res@cnLevelSelectionMode  = "ExplicitLevels" 
        res@cnLevels              = (/0.1,1,2.5,5,10,15,20,25,50,75/) ; "mm/day"

        res@gsnAddCyclic          = False  
        res@mpFillOn              = False              ; no color fill
        res@mpMinLatF             = min(lat)           ; Entire grid
        res@mpMaxLatF             = max(lat)
        res@mpMinLonF             = min(lon)
        res@mpMaxLonF             = max(lon)
        
        res@gsnCenterString       = ymd(0)
        plot  = gsn_csm_contour_map(wks,x(0,:,:),res)  ; 1st time only     
   end if   ; PLOT

;************************************************
; Create netCDF: Use NCL's Simple Method
;************************************************
  
   if (netCDF) then
       if (isatt(x,"lat2d")) then
           delete(x@lat2d)
           delete(x@lon2d)
       end if

       if (ncPack) then
           x = round(x*scale, 0)/scale     ; avoid truncation bias
       end if

       xMin  = min(x)
       xMax  = max(x)
       x@actual_range = (/ xMin, xMax /)

       date     = yyyy*1000000 + mm*10000 + dd*100 
       date!0   = "time"
       date@units = "yyyymmdd"
       
       globeAtt              = 1
       globeAtt@title        = "CRCM: daily averages"
      ;globeAtt@data_source  = "..."
       globeAtt@acronym      = "CRCM: Canadian Regional Climate Model"
       globeAtt@description  = "http://www.cccma.ec.gc.ca/models/crcm.shtml"
       globeAtt@creation_date= systemfunc ("date" )

       ncVarName = str_upper(varName)  ; make nc name upper case

       ncFil     = "DailyAvg."+yrStrt+"-"+yrLast+"."+ncVarName+".nc"
     
       NCFILE    = ncDir + ncFil
       system ("/bin/rm -f " +  NCFILE)    ; remove any pre-exist file 
           
       ncdf   = addfile(NCFILE,"c")     
     
       fileattdef( ncdf, globeAtt )        ; create the global [file] attributes
       filedimdef(ncdf,"time",-1,True)     ; force "time" to be unlimited
                                         
       ncdf->time   = time
       ncdf->lat    = lat
       ncdf->lon    = lon
       ncdf->date   = date


       if (ncPack) then
           x_short = pack_values(x, "short", optPack)
           ncdf->$ncVarName$ = x_short
       else
           ncdf->$ncVarName$ = x 
       end if
   end if   ; netCDF

            ; delete all variables that may change size
   delete(x)
   delete(x3)
   delete(time)
   delete(ymd)
   delete(yfrac)
   delete(yyyy)
   delete(mmdd)
   delete(mm)
   delete(dd)

 end do     ; nf

end
