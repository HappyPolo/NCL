;================================================-;
; eof_3_640.ncl
;
; Concepts illustrated:
;   - Calculating EOFs
;   - Drawing a time series plot
;   - Read 'time' and 'time_bound' across all files  
;   - Use 'cd_calendar' and adjust adjust for one-month-off
;   - Use 'ind' to find indices for applicable files 
;   - Read the desired variable
;   - Compute climatology and anomalies
;   - Mask all observations outside of desired region
;   - Area weight observations
;   - Compute EOFs
;================================================-;
; This script uses functions eofunc_n_Wrap and 
; eofunc_ts_n_Wrap, which were added in NCL V6.4.0
;================================================-;
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"

;=================================================;
; User settings
;=================================================;
   yrStrt  = 270                   ; start year
   yrLast  = 299                   ; last year
   var     = "TEMP"                ; variable name
   neof    = 3                     ; # eofs to compute
 
   region  = 6                     ; Atlantic
   latS    = -37.5                 ; plot region
   latN    =  70.
   lonL    = -102.5
   lonR    =  20.

   pltDir  = "./"
   pltType = "png"                 ; send graphics to PNG file
  ;pltName = "region_"+region+"_eof"
   pltName = "eof"

   popRoot = "g.b29.01.pop.h"
   diri    = "./"
;=================================================;
; Read all file names in directory 
;=================================================;
   fili    = systemfunc("cd "+diri+"  ; ls "+popRoot+"*nc")
   print(fili)        ; all file names

;=================================================;
; Establish list of all possible files for reading ... *no* reading is done
; 'f' is a variable of type 'list'
;=================================================;
   f       = addfiles(diri+fili, "r")          

;=================================================;
; Read 'time' from all files in directory    
;  Using variable 'time' would result in 'off-by-one' month
;  Use variable 'time_bound' lower bound to access date
;  Use "cd_calendar" to get years, months, ....
;  Use  "ind" to get index values for desired data period
;=================================================;
   TIME = f[:]->time                           ; all files [:]
   TIME = (/ f[:]->time_bound(:,0) /)          ; override values   
   DATE = cd_calendar(TIME, 0)                 ; year, month, day, hr, min, sec
                                               ; indices for specified years
   iYEAR= ind(DATE(:,0).ge.yrStrt .and. DATE(:,0).le.yrLast)
   if (ismissing(iYEAR(0))) then
       print("ind error: are the yrStrt and/or yrLast correct?")
       exit
   end if
                                    ; print time/date info for DEBUG
  ;print(TIME(iYEAR) +"  "+ DATE(iYEAR,0)+"   "+DATE(iYEAR,1))

   iStrt = iYEAR(0)                 ; index of 1st file used
;=================================================;
; Read 'var' from all files corresponding yrStrt-to-yrLast
;=================================================;
   x      = f[iYEAR]->$var$(:,0,:,:); all yrStrt-to-yrLast; Top level only
   x&time = (/ TIME(iYEAR) /)       ; over ride with correct dates
   printVarSummary(x)               ; x(time,nlat,nlon)    ... 3D

   delete([/ TIME, DATE ,iYEAR /] ) ; variables no longer needed
                                    ; *not* necessary
   
   lat2d     = f[iStrt]->TLAT       ; (nlat,nlon)   ... 2D
   lon2d     = f[iStrt]->TLONG
;=================================================;
; Remove the annual cycle 
;=================================================;
   xClm      = clmMonTLL(x)
  ;printVarSummary(xClm)                   ; (12,nlat,nlon)   
   x         = calcMonAnomTLL (x, xClm)    ; replace with anonamlies
   x@long_name = "ANOMALIES: "+x@long_name

;=================================================;
; Mask out all regions but that sprcified by the user =>'region'
;=================================================;
   rmask     = f[iStrt]->REGION_MASK       ; read region info from 1st file
  ;printVarSummary(rmask)                  ; (nlat,mlon)   ... 2D

   rmask_3D  = conform(x, rmask, (/1,2/) ) ; broadcast the mask to 3D
   x         = mask(x, rmask_3D.ne.region, False)     ; data for region  
   delete ( rmask_3D )                     ; not needed

;=================================================;
; Read [U/T]AREA for areal weighting
;  Set all warea to _FillValue outside region of interest
;=================================================;
   warea     = f[iStrt]->TAREA             ; area (cm^2) info from 1st file
  ;printVarSummary(warea)                  ; (nlat,nlon)   ... 2D
                                           ; set all wgts out srea to _FillValue
   warea     = mask(warea, ismissing(x(0,:,:)), False)

                                           ; not necessary but
   warea     = warea/max(warea)            ; nondimensionalize wgts 
;=================================================;
; Area weight the data; use nondimensionalize for smaller eof_ts numbers
;=================================================;
   warea_3D  = conform(x, warea, (/1,2/) ) ; broadcast warea to 3D
   wx        = warea_3D*x                  ; array operation 

   copy_VarMeta(x, wx)                     ; copy attributes and coordinates
   wx@long_name = "AREA WGTED: "+x@long_name
  ;printVarSummary(wx)

   delete(warea_3D)                        ; no longer needed
;=================================================;
; EOF
;=================================================;
   optEof = True
   eof    = eofunc_n_Wrap(wx, neof, optEof, 0)  ; eof(neof,nlat,nlon)
   eof_ts = eofunc_ts_n_Wrap(x, eof, False, 0)  ; eof_ts(neof,ntim)

   ngrid  = num(.not.ismissing(warea))
   print("ngrid="+ngrid)                   ; # of non-missing grid points
 ;;eof_ts = eof_ts/ngrid                   ; per grid point

   printVarSummary(eof)
   printVarSummary(eof_ts)
  
;=================================================;
; resources (plot options)
;=================================================;
   res                      = True                ; contour plots
   res@gsnDraw              = False
   res@gsnFrame             = False
   res@cnFillOn             = True                ; turn on color
 ;;res@cnFillMode           = "RasterFill"        ; turn on raster mode
   res@cnLinesOn            = False               ; turn off contour lines
   res@cnFillPalette        = "temp_diff_18lev"   ; specify colormap
   res@gsnAddCyclic         = True                ; force cyclic value
   res@mpFillDrawOrder      = "PostDraw"          ; color of land
   res@mpLandFillColor      = "grey"              ; color of land
   res@lbLabelBarOn         = False               ; turn off individual lb's
   res@mpMinLatF            = latS                 ; range to zoom in on
   res@mpMaxLatF            = latN
   res@mpMinLonF            = lonL  
   res@mpMaxLonF            = lonR
                             
   resP                     = True                ; panel plots
   resP@gsnMaximize         = True                ; large format
   resP@gsnPanelLabelBar    = True                ; add common colorbar
   resP@gsnPaperOrientation = "portrait"          ; force portrait [landscape]

;=================================================;
; EOF stuff: panel
;=================================================;
   pltPath = pltDir+pltName
   wkseof  = gsn_open_wks(pltType,pltPath)

   ploteof = new ( neof, "graphic") 

   symMinMaxPlt(eof, 16, False, res)              ; contributed.ncl

   eof@lat2d = lat2d                              ; for plotting
   eof@lon2d = lon2d

   resP@txString         = popRoot+": "+yrStrt+"-"+yrLast
   do n=0,neof-1
      res@gsnLeftString  = "EOF "+(n+1)
      res@gsnRightString = sprintf("%5.1f", eof@pcvar(n)) +"%"
      ploteof(n) = gsn_csm_contour_map_ce(wkseof,eof(n,:,:),res)
   end do
   gsn_panel(wkseof,ploteof,(/neof,1/),resP)      ; draw all 'neof' as one plot

;*******************************************
; time series (principal component) plot
;*******************************************
   eof_ts@long_name = "Amplitude"
                           
   yyyymm = cd_calendar(eof_ts&time, -1)         ; create a yyyy.fraction_of_year
   eof_ts&time = yyyymm_to_yyyyfrac(yyyymm, 0.0) ; better time axis
   eof_ts&time@long_name = "YEAR"
   ntim   = dimsizes(yyyymm)
   

   rts           = True
   rts@gsnDraw   = False       ; don't draw yet
   rts@gsnFrame  = False       ; don't advance frame yet
   rts@tmXBFormat= "f"         ; no unnessary decimal pts

   rts@vpHeightF = 0.40        ; Changes the aspect ratio
   rts@vpWidthF  = 0.85
   rts@vpXF      = 0.10        ; change start locations
   rts@vpYF      = 0.75        ; the plot

   rts@gsnYRefLine           = 0.              ; reference line   
   rts@gsnAboveYRefLineColor = "red"           ; above ref line fill red
   rts@gsnBelowYRefLineColor = "blue"          ; below ref line fill blue

   rts@trXMinF   = yyyymm(0)/100    
   rts@trXMaxF   = yyyymm(ntim-1)/100 + 1      ; nicer end bound

; panel plot only resources
   rtsP                      = True            ; modify the panel plot
   rtsP@gsnMaximize          = True            ; large format

   delete(eof_ts&time@long_name)               ; leave more room for plot      

   rtsP@txString         = popRoot+": "+yrStrt+"-"+yrLast
   do n=0,neof-1
      rts@gsnLeftString  = "EOF "+(n+1)
      rts@gsnRightString = sprintf("%5.1f", eof@pcvar(n)) +"%"
      ploteof(n) = gsn_csm_xy (wkseof,eof_ts&time,eof_ts(n,:),rts)
   end do
   gsn_panel(wkseof,ploteof,(/neof,1/),rtsP)        ; draw all 'neof' as one plot
