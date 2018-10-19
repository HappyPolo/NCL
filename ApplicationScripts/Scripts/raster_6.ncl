;***********************************************
; raster_6.ncl
;
; Concepts illustrated:
;   - Generating dummy data which have irregular X and Y coordinates
;   - Drawing raster contours 
;   - Forcing full-sized raster cells at the X,Y axis boundaries
;***********************************************
;
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"  
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"

;===================================================================
; Create bogus 2D histogram data with irregular X and Y axis bins 
;===================================================================

  xbnd  = (/0.3, 1.3, 3.6, 9.4, 23, 60, 100/)         ; bin boundaries (x)
  ybnd  = (/10, 180, 310, 440, 560, 680, 800, 1100/)  ; bin boundaries (y)

  nxbnd = dimsizes(xbnd)                              ; # of x bin boundaries   
  nybnd = dimsizes(ybnd)                              ; # of y bin boundaries 

  nx    = nxbnd-1
  ny    = nybnd-1

  data   = random_uniform(-1,1,(/ny,nx/))
  printVarSummary(data)

;=================================================;
; PLOT
;=================================================;
  wks  = gsn_open_wks("png","raster")      ; send graphics to PNG file


  res                      = True          ; plot mods desired
  res@gsnMaximize          = True          ; Maximize plot in frame.

  res@cnFillOn             = True          ; Turn on contour fill
  res@cnFillMode           = "RasterFill"  ; Turn on raster fill
  res@cnLinesOn            = False         ; Turn off contour lines
  res@cnLineLabelsOn       = False         ; turns off contour line labels
  res@cnFillPalette        = "BlAqGrYeOrReVi200"

  res@cnLevelSelectionMode = "ManualLevels"
  res@cnMinLevelValF       =  -1.0
  res@cnMaxLevelValF       =   1.0
  res@cnLevelSpacingF      =   0.1

  res@trYReverse           = True           ; reverses y-axis 

  res@lbLabelBarOn         = True
  res@lbOrientation        = "vertical"     ; vertical label bar

  res@trXMinF              = -0.5           ; extend x and y axes 
  res@trXMaxF              =  nx-0.5
  res@trYMinF              = -0.5
  res@trYMaxF              =  ny-0.5

  res@tmXBMode             = "Explicit"                ; explicit labels
  res@tmXBValues           = fspan(res@trXMinF,res@trXMaxF, nxbnd) 
  res@tmXBLabels           = xbnd           
  res@sfXArray             = res@tmXBValues    

  res@tmYLMode             = "Explicit"                ; explicit labels
  res@tmYLValues           = fspan(res@trYMinF,res@trYMaxF, nybnd) 
  res@tmYLLabels           = ybnd          
  res@sfYArray             = res@tmYLValues

  res@tiXAxisString        = "Bin Categories"          ; x-axis title
  res@tiYAxisString        = "P Bin Categories [hPa]"  ; y-axis title

  res@tiMainString         = "2D Histogram: Irregular X,Y Bin Boundaries" 

  plot = gsn_csm_contour(wks,data,res)       ; contour the variable
