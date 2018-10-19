;----------------------------------------------------------------------
; indices_nino_1.ncl
;
; Concepts illustrated:
;   - Computing a climatology for a selected region and time period
;   - Calculating an area averaged anomaly time series
;   - Calculating a standardized time series
;   - Drawing a time series plot
;----------------------------------------------------------------------
;
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl" 
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl" 
;---------------------------------------------------------------------------
; There are four region based indices used to monitor the tropical Pacific: 
; Nino 1+2 (0-10S, 90W-80W), Nino 3 (5N-5S, 150W-90W), 
; Nino 3.4/ONI (5N-5S, 170W-120W) and Nino 4 (5N-5S, 160E-150W)
;---------------------------------------------------------------------------
;                         User input
;---------------------------------------------------------------------------

  latS  = -5.0
  latN  =  5.0
  lonL  = 190.0
  lonR  = 240.0
  
  nrun  = 5             ; length of running average

  yrStrt= 1870  
  yrLast= 2012      

  clStrt= 1950          ; climatology start    
  clLast= 1979          ;             last

  txtName = "NINO_34"

  pltType = "png"       ; send graphics to PNG file
  pltDir  = "./"        ; dir to which plots are sent
  pltName = "indices_nino"
 ;pltName = txtName+"."+yrStrt+"-"+yrLast
  pltTitle= txtName+": "+yrStrt+"-"+yrLast \
          + ": Base "+clStrt+"-"+clLast

  ASCII      = True         ; create ASCII
  ascDir     = "./"

  netCDF     = True         ; create netCDF
  cdfDir     = "./"

;-------------------- End User Input ---------------------------------------
  ymStrt = yrStrt*100 +  1            
  ymLast = yrLast*100 + 12

  clStrt = clStrt*100 +  1              ; redefine
  clLast = clLast*100 + 12

  diri   = "./"
  fili   = "MODEL.SST.HAD187001-198110.OI198111-201203.nc"
  in     = addfile(diri+fili,"r")

;*********************************
; The index code below assumes that each year has 12 months 
; 'mon_fullyear_n' (available c6.1.0) may expand to fill that condition
;*********************************
  X      = mon_fullyear( in->SST(:,{latS:latN},{lonL:lonR}), 0)   ; all times on file

  YYYYMM = cd_calendar(X&time, -1)      ; ALL dates assciated with X
  tStrt  = ind(YYYYMM.eq.ymStrt)        ; indices of selected times
  tLast  = ind(YYYYMM.eq.ymLast)
  delete(YYYYMM)

  x      = X(tStrt:tLast,:,:)           ; subset to desired time interval
  yyyymm = cd_calendar(x&time, -1) 
  dimx   = dimsizes(x)
  ntim   = dimx(0)

  delete(X)                             ; no longer needed

;*********************************
; time indices for base climatology 
;*********************************

  iClmStrt = ind(yyyymm.eq.clStrt)     
  iClmLast = ind(yyyymm.eq.clLast)    
 ;print(yyyymm(iClmStrt:iClmLast))

;*********************************
; Climatology and anomalies from base climatology   
;*********************************

  xClm     = clmMonTLL(x(iClmStrt:iClmLast,:,:))
  printVarSummary(xClm)

  xAnom    = calcMonAnomTLL (x,  xClm ) 
  xAnom@long_name = "SST Anomalies"
  printVarSummary(xAnom)

;*********************************
; Unweighted areal averages & anomalies (time series)
; Small latitudinal extent so no need to weight    
;*********************************

  x_avg     = wgt_areaave_Wrap(x    , 1.0, 1.0, 1)
  x_avg@long_name = "areal avg"

  xAnom_avg = wgt_areaave_Wrap(xAnom, 1.0, 1.0, 1)
  xAnom_avg@long_name = "areal avg anomalies"

  printVarSummary(xAnom_avg)

;*********************************
; Compute standardized anomalies; use clm period    
;*********************************

  xAnom_std = xAnom_avg
  xAnom_std = xAnom_avg/stddev(xAnom_avg(iClmStrt:iClmLast))
  xAnom_avg@long_name = "areal avg standardized  anomalies"
  printVarSummary(xAnom_std)

;*********************************
; Perform an unweighted nrun-month running average on the index
; 2 months lost at start & end if endopt=0  ... reflective if endopt=1
;*********************************

  endopt    = 1
  ii = ind(.not.ismissing(xAnom_std))
  xAnom_std(ii) = runave_n_Wrap (xAnom_std(ii), nrun, endopt, 0)

  print(yyyymm+"   "+x_avg+"   "+xAnom_avg+"   "+xAnom_std)

;*********************************
; plot
;*********************************
  yrfrac = yyyymm_to_yyyyfrac(yyyymm, 0.0)

  wks = gsn_open_wks(pltType, pltDir+pltName)     
  plot = new(2, graphic )

  res                  = True       
  res@gsnDraw          = False       
  res@gsnFrame         = False     
  res@vpHeightF        = 0.4            ; change aspect ratio of plot
  res@vpWidthF         = 0.8            
  res@vpXF             = 0.1            ; start plot at x ndc coord 
  res@gsnYRefLine      = 0.0            ; create a reference line 
  res@gsnAboveYRefLineColor = "red"              ; above ref line fill red
  res@gsnBelowYRefLineColor = "blue"             ; below ref line fill blue
  
  res@trYMinF          = -4.0           ; min value on y-axis
  res@trYMaxF          =  4.0           ; max value on y-axis

  resP                 = True
  resP@gsnMaximize     = True
  resP@txString        = pltTitle                            
  
  res@tiYAxisString    = "Anomalies (C)"    ; y-axis label      
  plot(0) = gsn_csm_xy (wks,yrfrac,xAnom_avg,res)

  res@tiYAxisString    = "Standardized Anomalies"    ; y-axis label      
  plot(1) = gsn_csm_xy (wks,yrfrac,xAnom_std,res)

  gsn_panel(wks,plot,(/2,1/),resP)

  if (netCDF) then
;*************************************************************************
; Create netCDF: avg, anomalies, standardizes index
;*************************************************************************
      yyyymm!0 = "time"
      yyyymm&time = x_avg&time

      cdfName = txtName+"."+yrStrt+"-"+yrLast+".nc"
      cdfPath = cdfDir+cdfName

      system("/bin/rm -f "+cdfPath)         ; remove any pre-existing file
      ncdf     = addfile(cdfPath ,"c")      ; open output netCDF file

    ; make time and UNLIMITED dimension     ; recommended  for most applications
      filedimdef(ncdf,"time",-1,True)

      ncdf->yyyymm      =  yyyymm
      ncdf->SST_REGION  =  x_avg
      ncdf->SST_ANOM    =  xAnom_avg
      ncdf->NINO34      =  xAnom_std
  end if

  if (ASCII) then
;*************************************************************************
; Create 3 ASCII (text) files: avg, anomalies, standardizes index
;*************************************************************************
      nmos    = 12
      year    = ispan(yrStrt,yrLast,1)
      nyrs    = dimsizes(year)
      text    = new ( nyrs, "string")

      x_avg@_FillValue     = 9999.0   ; change for ascii
      xAnom_avg@_FillValue = 9999.0
      xAnom_std@_FillValue = 9999.0

; text file with area averages

      ascName = txtName+"."+yrStrt+"-"+yrLast+".AVG.txt"
      ascPath = ascDir+ascName
      system("/bin/rm -f "+ascPath)    ; remove any pre-existing file

      work    = onedtond(x_avg, (/nyrs,nmos/)) 
      do nyr=0,nyrs-1
         text(nyr) = sprinti("%0.4i", year(nyr))
        do nmo=0,nmos-1
           text(nyr) = text(nyr) + sprintf("%8.2f", work(nyr, nmo))
        end do
      end do
      asciiwrite(ascPath, text) 

      delete(work)

; text file with anomaly averages

      ascName = txtName+"."+yrStrt+"-"+yrLast+".ANOM.txt"
      ascPath = ascDir+ascName
      system("/bin/rm -f "+ascPath)    ; remove any pre-existing file

      work    = onedtond(xAnom_avg, (/nyrs,nmos/)) 
      do nyr=0,nyrs-1
         text(nyr) = sprinti("%0.4i", year(nyr))
        do nmo=0,nmos-1
           text(nyr) = text(nyr) + sprintf("%8.2f", work(nyr, nmo))
        end do
      end do
      asciiwrite(ascPath, text) 

      delete(work)

; text file with index values      

      ascName = txtName+"."+yrStrt+"-"+yrLast+".INDEX.txt"
      ascPath = ascDir+ascName
      system("/bin/rm -f "+ascPath)    ; remove any pre-existing file

      work    = onedtond(xAnom_std, (/nyrs,nmos/)) 
      do nyr=0,nyrs-1
         text(nyr) = sprinti("%0.4i", year(nyr))
        do nmo=0,nmos-1
           text(nyr) = text(nyr) + sprintf("%8.2f", work(nyr, nmo))
        end do
      end do
      asciiwrite(ascPath, text) 
  end if
