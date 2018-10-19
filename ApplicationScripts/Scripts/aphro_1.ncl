;----------------------------------------------------------------------
; aphro_1.ncl
;
; Concepts illustrated:
;   - Reading an APHRODITE netCDF file
;   - Plot a user specified date
;----------------------------------------------------------------------
; the following 'load *' are NOT needed from NCL 6.2.0 onward
;----------------------------------------------------------------------
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl" 
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl" 
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl" 
;**************************************************************
; User Input
;***************************************************************
   diri     = "./"         
   fili     = "APHRO_RU_025deg_V1101.2007.nc"

   ymdPlot  = 20070620

   pltDir   = "./"
   pltName  = "aphro"
   pltType  = "png"                                 ; send graphics to PNG file 
   pltTitle = "APHRO: "+ymdPlot

;***************************************************************
; End User Input
;***************************************************************
   f        = addfile (diri+fili, "r")
   yyyymmdd = cd_calendar(f->time, -2)         
   iday     = ind(yyyymmdd.eq.ymdPlot)
   prc      = f->precip(iday:iday,:,:)              ; (time,lat,lon)  (0,1,2)

   printMinMax(prc,0)

;************************************************
; Create plot 
;************************************************
   wks    = gsn_open_wks(pltType, pltDir+pltName)
                                                  ; manually specify specific colors
   colors = (/"white","black", "gray98"    \        
           ,"PaleTurquoise","PaleGreen","SeaGreen3" ,"Yellow"  \
           ,"Orange","HotPink","Red","Violet", "Purple", "Brown"/) 
    
   res                      = True     ; plot mods desired
   res@gsnMaximize          = True                ; make ps/eps/pdf large [no effect x11]
  ;res@gsnPaperOrientation  = "Portrait"          ; force portrait

   res@cnFillOn             = True     ; turn on color fill
   res@cnFillPalette        = colors   ; set color map
   res@cnLinesOn            = False    ; turn of contour lines
   res@cnLineLabelsOn       =  False       ; Turn off contour lines
   res@cnFillMode           = "RasterFill"         ; Raster Mode
   res@cnLevelSelectionMode = "ExplicitLevels"
   res@cnLevels             = (/0.1,1,2.5,5,10,15,20,25,50,75/) ; "mm/day"
   res@gsnAddCyclic         = False    ; data is regional

   res@mpMinLatF            = min(prc&latitude)
   res@mpMaxLatF            = max(prc&latitude)
   res@mpMinLonF            = min(prc&longitude)
   res@mpMaxLonF            = max(prc&longitude)
   res@mpCenterLonF         = 0.5*(res@mpMinLonF + res@mpMaxLonF)

   nt   = 0
   res@tiMainString        = "APHRODITE: RU: "+ymdPlot
   res@gsnRightString      = ""

   plot = gsn_csm_contour_map(wks,prc(nt,:,:), res)
