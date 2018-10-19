;----------------------------------------------------------------------
; gpcp_4.ncl
;
; Concepts illustrated:
;   - Reading a GPCP 1DD netCDF file
;   - Plot a user specified date
;----------------------------------------------------------------------
;
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl" 
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl" 
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl" 
;**************************************************************
; User Input
;***************************************************************
   diri     = "./"         
   fili     = "GPCP_1DD_v1.2_199610-201510.nc4"

   ymdPlot  = 20090620

   pltDir   = "./"
   pltName  = "gpcp"
   pltType  = "png"                               ; send graphics to PNG file 
   pltTitle = "1DD_GPCP: "+ymdPlot

;***************************************************************
; End User Input
;***************************************************************
   f        = addfile (diri+fili, "r")
   yyyymmdd = f->date          
   iday     = ind(yyyymmdd.eq.ymdPlot)
   prc      = f->PREC(iday:iday,:,:)              ; (time,lat,lon)  (0,1,2)

;************************************************
; Create plot 
;************************************************
   wks    = gsn_open_wks(pltType, pltDir+pltName)
                                                  ; manually specify specific colors
   colors = (/"gray98"    \        
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
 
   nt   = 0
   res@gsnCenterString      = ymdPlot 
   plot = gsn_csm_contour_map(wks,prc(nt,:,:), res)
