;----------------------------------------------------------------------
; gpcp_3.ncl
;
; Concepts illustrated:
;   - Reading a GPCP 1DD netCDF file
;   - Calculate daily annual cycle of areally averaged data over a region
;   - Use ezfft{f,b} to create a smooth plot
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
   fili     = "GPCP_1DD_v1.2_199610-201506.nc"

   pltDir   = "./"
   pltName  = "gpcp"
   pltType  = "png"

   pltTitle = "1DD_GPCP: 199610-201506: Annual Cycle"
   regName  = "Nino 3.4"

   latS     =  -5.0    ; Region (El Nino)
   latN     =   5.0
   lonL     = 190.0    ; -170
   lonR     = 240.0    ; -120

;***************************************************************
; End User Input
;***************************************************************
   f        = addfile (diri+fili, "r")
   prc      = f->PREC(:,{latS:latN},{lonL:lonR})   ; (time,lat,lon)  (0,1,2)
   printVarSummary(prc)

   clat     = latRegWgt(prc&lat, typeof(prc), 0)   ; create lat weights
   prcArea  = wgt_areaave_Wrap(prc, clat, 1, 0)    ; weighted area avg at each time

   ymd      = f->date                        ; yyyymmdd
   yyyy     = ymd/10000
   md       = ymd-yyyy*10000
   mm       = md/100                                
   dd       = md-mm*100

   ddd      = day_of_year(yyyy, mm, dd) 

   nday     = 366
   pday     = new ( nday, typeof(prc), prc@_FillValue)
   do nd=0,nday-2
      iday  = ind(ddd.eq.(nd+1))
      pday(nd) = avg(prcArea(iday))
      delete(iday)                                ; may change next ireration
   end do
   pday(nday-1) = 0.5*(pday(0)+pday(nday-2))

   prcAvgRegion = avg(prcArea)                    ; regional avg

;************************************************
; Create smooth annual cycle
;************************************************
                        
   cf       = ezfftf(pday)
   cf(:,3 ) = 0.75*cf(:,3)                        ; arbitrary wgts
   cf(:,4 ) = 0.50*cf(:,4)
   cf(:,5 ) = 0.25*cf(:,5)
   cf(:,6:) = 0.0                                 ; no contribution
   pday_smth= ezfftb (cf, cf@xbar)                ; reconstruct

;************************************************
; Create plot 
;************************************************
   ntim   = dimsizes(ymd)
   yrStrt = ymd(0)/10000
   yrLast = ymd(ntim-1)/10000

   PDAY   = new( (/2,nday/), typeof(pday), "No_FillValue")
   PDAY(0,:) = pday
   PDAY(1,:) = pday_smth

   pltPath= pltDir+pltName+"."+pltType
   
   wks    = gsn_open_wks(pltType, pltDir+pltName)

   res                   = True        ; plot mods desired
   res@gsnMaximize       = True
  ;res@vpHeightF         = 0.4         ; change aspect ratio of plot
   res@vpWidthF          = 0.8                  
  
   res@trXMinF           = 0           ; max value on x-axis
   res@trXMaxF           = nday+1      ; max value on x-axis
   res@xyLineThicknesses = (/2.0, 2.0/)
   res@xyLineColors      = (/"blue","black"/)  ; change line color
   res@xyMonoDashPattern = True

   res@vpXF              = 0.1         ; start plot at x ndc coord 
   res@tmYLFormat        = "f"
  
   res@tiYAxisString     = "prc (mm/day)"    ; y-axis label      
   res@tiXAxisString     = "day of year"     ; x
  
   res@gsnYRefLine       = prcAvgRegion           ; create a reference line   
   res@gsnRightString    = "Areal Mean="+sprintf("%4.2f", prcAvgRegion)+" mm/day"
   res@gsnLeftString     = regName

   res@tiMainString      = pltTitle
   plot  = gsn_csm_y(wks, PDAY, res)
