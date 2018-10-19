;*************************************************
; gfed_5.ncl
;
; Concepts illustrated:
;   - Open & read a netCDF-4 file containing a single variable
;   - Calculate the monthly climatology, minimum and maximum for period
;   - Create a panel plot using a common label bar
;************************************************
; Requires NCL 6.4.0 or later
;************************************************
; Read single variable GFED (1997-2015)
;************************************************

  VAR  = "BURNED_FRACTION"
  LONG_NAME = "Burned Fraction"              ; original is too long

  diri = "./"
  diri = "/glade/p/work/shea/JKSHUMAN/GFED4_1s/NC4/VAR/"
  fili = "GFED4.1s_"+VAR+".nc"               ; netCDF-4
  pthi = diri+fili
  f    = addfile(pthi,"r")

  x    = f->$VAR$                            ; (time,lat,lon)
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
; Where 'Ocean' (breg=0) create a _FillValue
; graphical convenience
;************************************************

  breg = f->BASIS_REGIONS                    ; (lat,lon)    
  x@_FillValue = 1e20
  x    = where(conform_dims(dimx, breg, (/1,2/)).eq.0, x@_FillValue, x)

;************************************************
; Calculate the monthly climatology
;************************************************
  xClm = clmMonTLL(x)
  printVarSummary(xClm)   ; [month | 12] x [lat | 720] x [lon | 1440]
  printMinMax(xClm,0) 

;************************************************
; Examine the distribution of the climatology
;************************************************
  opt = True
  opt@PrintStat = True
  xClm = where(xClm.eq.0.0, xClm@_FillValue, xClm)
  statb = stat_dispersion(xClm, opt )

;************************************************
; For each month: determine the min and max values
;************************************************

  xMin = new( dimsizes(xClm), typeof(xClm), getVarFillValue(xClm)) 
  xMax = xMin
  
  nmos = 12
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
; create plots
;************************************************
  plot = new(6,graphic)                          ; create a plot array
  
  wks = gsn_open_wks("png","gfed")              ; send graphics to PNG file
  res                     = True
  res@gsnDraw             = False            ; don't draw
  res@gsnFrame            = False            ; don't advance frame
  res@cnInfoLabelOn       = False            ; turn off cn info label
  res@cnFillOn            = True             ; turn on color
 ;res@cnFillMode          = "RasterFill"     ; Raster Mode
  res@cnFillMode          = "CellFill"       ; Raster Mode
  res@cnLevelSelectionMode= "ExplicitLevels"
  res@cnLevels            = (/ 0.010, 0.050, 0.100, 0.250, 0.500, 0.750 \
                             , 1.000, 1.250, 1.500, 2.000, 5.000,10.000 \
                             ,25.0  ,50.0  ,75.0/)
  res@cnLinesOn           = False            ; turn of contour lines
  res@cnLineLabelsOn      = False
  res@cnFillPalette       = "example"        ; "WhBlGrYeRe" , "GHRSST_anomaly"
  res@cnSpanFillPalette   = True             ; default is True 

  res@lbLabelBarOn        = False            ; turn off individual lb's
  res@mpFillOn            = False

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
