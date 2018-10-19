;----------------------------------------------------------------------
; gpcp_1.ncl
;
; Concepts illustrated:
;   - Reading a GPCP Monthly netCDF file
;   - Use functions to calculate climatology and weighted area average
;   - Use explicit colors
;----------------------------------------------------------------------
;
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl" 
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl" 
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl" 
;**************************************************************
; User Input
;***************************************************************
                                         ; INPUT
   diri   = "./"         
   fili   = "V22_GPCP.1979-2010.nc"
                                         ; graphics
   pltDir = "./"
   pltName= "gpcp"
   pltType= "png"                        ; send graphics to PNG file

   pltTitle = "V22_GPCP"

;***************************************************************
; End User Input
;***************************************************************
; Read variable; compute monthly climatology; annual mean
;***************************************************************
   f      = addfile (diri+fili, "r")
   PRC    = f->PREC                          ; (time,lat,lon)
   printVarSummary(PRC)                      ; variable overview
 
   prc_clm = clmMonTLL(PRC)                  ; compute monthly climatology
   printVarSummary(prc_clm)                  ; (12,lat,lon)

   prc_clm  = where(prc_clm.lt.0.10, 0.0, prc_clm)  ; set small values to 0.0
   prc_ann  = dim_avg_n_Wrap(prc_clm, 0)     ; compute annual mean (arithmetic)
                                             ; from monthly climatologies
   
   clat     = latRegWgt( prc_ann&lat, "float", 0)   ; lwt weights
   prcAvg   = wgt_areaave( prc_ann, clat, 1.0, 0)   ; areal average

;************************************************
; Create plot 
;************************************************
   DATE   = f->date
   ntim   = dimsizes(DATE)
   yrStrt = DATE(0)/10000
   yrLast = DATE(ntim-1)/10000

   pltPath= pltDir+pltName+"."+pltType

   wks    = gsn_open_wks(pltType, pltDir+pltName)

          ; manually specify colors
   colors = (/"Snow","PaleTurquoise" \
             ,"PaleGreen","SeaGreen3" ,"Yellow"       \
             ,"Orange","HotPink","Red","Violet"       \
             ,"Purple", "Brown", "Black"/)
   
   res                      = True     ; plot mods desired
   res@gsnMaximize          = True     ; make ps/eps/pdf large
 
   res@cnFillOn             = True     ; turn on color fill
   res@cnFillPalette        = colors   ; set color map
   res@cnLinesOn            = False    ; turn of contour lines
  ;res@cnFillMode           = "RasterFill" ; Raster Mode
   res@cnLineLabelsOn       =  False       ; Turn off contour lines

   res@cnLevelSelectionMode    = "ExplicitLevels"              
   res@cnLevels                = (/0.5,1,2,3,4,5,6,7,8,9,10/) ; "mm/day" 

   res@lbOrientation        = "vertical"   ; vertical label barb's
   res@lbLabelFontHeightF   = 0.012        ; change font size
   res@pmLabelBarWidthF     =  0.1     
   res@pmLabelBarOrthogonalPosF = -0.01    ; move a bit to left

   res@mpFillOn             = False
   res@mpCenterLonF         = 220.         ; don't split Africa

   res@tiMainString         = pltTitle+": "+yrStrt+"-"+yrLast
   res@gsnCenterString      = "Areal Mean="+sprintf("%4.2f",  prcAvg)+" mm/day"
   plot    = gsn_csm_contour_map_ce(wks,prc_ann, res)
