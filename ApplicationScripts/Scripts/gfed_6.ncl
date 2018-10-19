;*************************************************
; gfed_6.ncl
;
; Concepts illustrated:
;   - Specify a region
;   - Open & read a netCDF-4 file containing a single variable for the region
;   - Calculate the monthly climatology, minimum and maximum for period
;   - Calculate and plt a weighted areal mean time series
;   - Create a panel plot using a common label bar
;************************************************
; Requires NCL 6.4.0 or later
;************************************************
; Read single variable GFED (1997-2015)
;************************************************
; Specify lat and lon limits [Read a subset]
;************************************************
  latS = -40
  latN =   0
  lonL =   0
  lonR =  60
  
  VAR  = "BURNED_FRACTION"
  LONG_NAME = "Burned Fraction"              ; original is too long

  diri = "./"
  fili = "GFED4.1s_"+VAR+".nc"               ; netCDF-4
  pthi = diri+fili
  f    = addfile(pthi,"r")

  x    = f->$VAR$(:,{latS:latN},{lonL:lonR}) ; (time,lat,lon)
  x@long_name = LONG_NAME                    ; original lon_name is too long
  x    = x*100                               ; change units; convenience
  x@units = "%"

  dimx = dimsizes(x)                         ; dimension sizes
  ntim = dimx(0)                             ; total time steps
  nlat = dimx(1)
  mlon = dimx(2)

  yyyymm = f->yyyymm                         ; 199701, 199702,...
  yrStrt = yyyymm(0)/100
  yrLast = yyyymm(ntim-1)/100

;************************************************
; Where breg .ne. 9 create a _FillValue
;************************************************

  breg = f->BASIS_REGIONS({latS:latN},{lonL:lonR})    
  x@_FillValue = 1e20
                 
  BREG = conform(x, breg, (/1,2/))          ; BREG(ntim,nlat,mlon); convenience
  x    = where(BREG.ne.9, x@_FillValue, x)

  carea@_FillValue = 1e20
  delete(BREG)
;************************************************
; Calculate the monthly climatology
;************************************************
  xClm = clmMonTLL(x)
  printVarSummary(xClm)   ; [month | 12] x [ lat ] x [lon]
  printMinMax(xClm,0) 

  opt = True
  opt@PrintStat = True
  xClm = where(xClm.eq.0.0, xClm@_FillValue, xClm)
  statb = stat_dispersion(xClm, opt )

;************************************************
; For each month: determine the min and max values
;************************************************
  xMin = new( dimsizes(xClm), typeof(xClm), getVarFillValue(xClm)) 
  xMax = xMin
  
  nmos   = 12
  do nmo=0,nmos-1
     xMin(nmo,:,:) = dim_min_n(x(nmo::nmos,:,:),0)  ; array syntax
     xMax(nmo,:,:) = dim_max_n(x(nmo::nmos,:,:),0)
  end do
                   ; add meta data
  xMin@long_name   = "min burned fraction"
  xMin@units       = x@units
  xMin@information = "monthly climatology "+yrStrt+"-"+yrLast
  copy_VarCoords(xClm, xMin)
  printVarSummary(xMin)

  xMax@long_name   = "max burned fraction"
  xMax@units       = x@units
  xMax@information = "monthly climatology "+yrStrt+"-"+yrLast
  copy_VarCoords(xClm, xMax)
  printVarSummary(xMax)

;************************************************
; Calculate areal averages
;************************************************
  xAvg = wgt_areaave2(x, carea, 0)
  xAvg@long_name = "SHAF: Areal Average"

  time_plt = yyyymm_to_yyyyfrac(yyyymm, 0.0)
  delete(time_plt@long_name)
  
;************************************************
; create plots
;************************************************
  plot = new(6,graphic)                          ; create a plot array
  
  wks = gsn_open_wks("png","gfed")               ; send graphics to PNG file
  res                     = True
  res@gsnDraw             = False            ; don't draw
  res@gsnFrame            = False            ; don't advance frame
  res@gsnAddCyclic        = False            ; region here

  res@cnInfoLabelOn       = False            ; turn off cn info label
  res@cnFillOn            = True             ; turn on color
  res@cnFillMode          = "RasterFill"     ; Raster Mode
 ;res@cnFillMode          = "CellFill"       ; Raster Mode
  res@cnLevelSelectionMode= "ExplicitLevels"
  res@cnLevels            = (/ 0.010, 0.050, 0.100, 0.250, 0.500, 0.750 \
                             , 1.000, 1.250, 1.500, 2.000, 5.000,10.000 \
                             ,25.0  ,50.0  ,75.0/)
  res@cnFillPalette       = "example"
  res@cnSpanFillPalette   = True             ; default is True 
  res@cnLinesOn           = False            ; turn of contour lines
  res@cnLineLabelsOn      = False

  res@lbLabelBarOn        = False            ; turn off individual lb's
  res@mpFillOn            = False
  res@mpMinLatF           = latS     ; range to zoom in on
  res@mpMaxLatF           = latN
  res@mpMinLonF           = lonL
  res@mpMaxLonF           = lonR

  nmo = 0
  res@gsnCenterString     = "January"
  plot(0) = gsn_csm_contour_map(wks,xMin(nmo,:,:),res) 
  plot(2) = gsn_csm_contour_map(wks,xClm(nmo,:,:),res) 
  plot(4) = gsn_csm_contour_map(wks,xMax(nmo,:,:),res) 

  nmo = 6
  res@gsnCenterString     = "July"
  plot(1) = gsn_csm_contour_map(wks,xMin(nmo,:,:),res) 
  plot(3) = gsn_csm_contour_map(wks,xClm(nmo,:,:),res) 
  plot(5) = gsn_csm_contour_map(wks,xMax(nmo,:,:),res) 

;************************************************
; create panel
;************************************************
  resP                    = True                ; modify the panel plot
  resP@gsnMaximize        = True   
  resP@gsnPanelLabelBar   = True                ; add common colorbar
;;resP@lbBoxEndCapStyle   = "RectangleEnds"     ; RectangleEnds is the default
  resP@gsnPanelMainString = "Burned Fraction Climatology: "+yrStrt+"-"+yrLast
  gsn_panel(wks,plot(3),(/1,1/),resP)           ; draw one 
  gsn_panel(wks,plot,(/3,2/),resP)              ; now draw as one plot

;++++++++++++++++++++++++++++++++++++++++++++++++
; Plot areal average time series
;++++++++++++++++++++++++++++++++++++++++++++++++

  resxy          = True                   ; plot mods desired
  resxy@vpHeightF= 0.4                    ; change aspect ratio of plot
  resxy@vpWidthF = 0.8                  
  resxy@vpXF     = 0.1                    ; start plot at x ndc coord 
  resxy@trXMinF  = yrStrt                 ; min value on y-axis
  resxy@trXMaxF  = yrLast                 ; max value on y-axis
  resxy@xyLineThicknessF = 2
  resxy@xyLineColor      = "blue"

 ;resxy@tiYAxisString    = ""
  resxy@tiMainString     = "GFED: Region 9 (SHAF): Burned Fraction" ; title
  plot = gsn_csm_xy (wks,time_plt,xAvg,resxy)        ; create plot
