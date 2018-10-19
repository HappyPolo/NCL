;----------------------------------------------------------------------
; gpcp_2.ncl
;
; Concepts illustrated:
;   - Reading a GPCP Monthly netCDF file
;   - Use functions to calculate areal averages, zonal means
;     and the average over time and space.
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
   diri     = "./"         
   fili     = "V22_GPCP.1979-2010.nc"

   pltDir   = "./"
   pltName  = "gpcp"
   pltType  = "png"

   pltTitle = "V22_GPCP"

;***************************************************************
; End User Input
;***************************************************************
   f       = addfile (diri+fili, "r")
   date    = f->date
   prc     = f->PREC                               ; (time,lat,lon)  (0,1,2)

   prc      = where(prc.lt.0.05, 0.0, prc)         ; eliminate 'noise'

   clat     = latRegWgt(prc&lat, "double", 0)      ; lat weights

   prcAvg   = wgt_areaave_Wrap(prc, clat, 1.0, 0)  ; areal average each month 
   printVarSummary(prcAvg)                         ; (time)

   prcZon    = dim_avg_n_Wrap(prc, 2)              ; (time,lat)
   printVarSummary(prcZon)                         ; zonal avg at each time

   prcZonAvg = dim_avg_n_Wrap(prcZon,0)            ; (lat)
   prcZonAvg@long_name = "prc time average" 
   prcZonAvg@units     = prc@units

   prcGlbAvg = sum(prcZonAvg*clat)/sum(clat)       ; weight each lat
   prcGlbAvg@long_name = "Global Average"
   prcGlbAvg@units     = prc@units                   
   print(prcGlbAvg)  

;************************************************
; Create plot 
;************************************************
   ntim   = dimsizes(date)
   yrStrt = date(0)/10000
   yrLast = date(ntim-1)/10000

   pltPath= pltDir+pltName+"."+pltType
   
   plot   = new ( 2, "graphic")
   wks    = gsn_open_wks(pltType, pltDir+pltName)

   res                   = True        ; plot mods desired
   res@gsnDraw           = False
   res@gsnFrame          = False
   res@vpHeightF         = 0.4         ; change aspect ratio of plot
   res@vpWidthF          = 0.8                  
  
   res@trXMinF           = yrStrt      ; max value on x-axis
   res@trXMaxF           = yrLast+1    ; max value on x-axis
   res@tmXBFormat        = "f"         ; force no decimal points
   res@tmYLFormat        = "f" 
   res@xyLineThicknesses = (/2.0/)
   res@xyLineColors      = (/"blue"/) ; change line color

   res@vpXF              = 0.1         ; start plot at x ndc coord 
  
   res@tiYAxisString     = "Globe: prc (mm/day)"    ; y-axis label      
  
   res@gsnYRefLine       = avg(prcGlbAvg)           ; create a reference line   
   res@gsnCenterString   = "Areal Mean="+sprintf("%4.2f", avg(prcGlbAvg))+" mm/day"

   yyyymm = date/100
   yrfrac = yyyymm_to_yyyyfrac(yyyymm, 0.0)

   plot(0)  = gsn_csm_xy(wks,yrfrac, prcAvg, res)
   delete(res@gsnCenterString)

   res@tiYAxisString     = "Zonal Mean (mm/day)"    ; y-axis label      
   
   res@trXMinF  = -90
   res@trXMaxF  =  90
   plot(1)  = gsn_csm_xy(wks,prcZonAvg&lat, prcZonAvg, res)

   resP                        = True
   resP@gsnMaximize            = True
   resP@txString               = pltTitle+": Areal Precipitation: "+yrStrt+"-"+yrLast
   resP@gsnPanelBottom         = 0.1
   gsn_panel(wks,plot,(/2,1/), resP)	
