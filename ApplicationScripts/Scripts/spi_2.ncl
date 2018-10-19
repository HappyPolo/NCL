;----------------------------------------------------------------------
; spi_2.ncl
;
; Concepts illustrated:
;   - Computing the Standardized Precipitation Index (SPI)
;   - Reading data from the GPCP (Global Precipitation Climatology Project)
;----------------------------------------------------------------------
;
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"

  diri   = "./"
  fili   = "V22_GPCP.1979-2010.nc"
  f      = addfile(diri+fili, "r")

  prc    = flt2dble(f->PREC)
  pmsg   = prc@_FillValue      ; convenience

  printVarSummary(prc)
  printMinMax(prc,0)

  runlen = (/ 12, 24 /)   
  nrun   = dimsizes(runlen)
;*********************************
; plot parameters
;*********************************
  dimprc = dimsizes(prc)
  ntim   = dimprc(0)
  nlat   = dimprc(1)
  mlon   = dimprc(2)

  yyyymm = f->date
  yyyymm = yyyymm/100
  
  year    = yyyymm/100
  yrStrt  = year(0)
  yrLast  = year(ntim-1)
  nyear   = yrLast-yrStrt+1
  yyyymm  = yyyymm_time(yrStrt, yrLast, "integer") 
  yrfrac  = (/ yyyymm_to_yyyyfrac(yyyymm, 0.0) /)

  prc&time = (/ yyyymm /)

;=================================

  wks          = gsn_open_wks ("png","spi") ; send graphics to PNG file
  cmap = read_colormap_file("BlueWhiteOrangeRed")  ; read color data

  res          = True                   
  res@gsnDraw          = False              ; don't draw
  res@gsnFrame         = False              ; don't advance frame

  res@cnFillOn         = True               ; color fill
  res@cnFillPalette    = cmap(::-1,:)       ; set and reverse color map 
  res@cnFillMode       = "RasterFill"       ; Raster Mode
  res@cnLinesOn        =  False             ; Turn off contour lines
  res@cnLevelSelectionMode = "ManualLevels" ; set manual contour levels
  res@cnMinLevelValF   = -3.0               ; set min contour level
  res@cnMaxLevelValF   =  3.0               ; set max contour level
  res@cnLevelSpacingF  =  0.5               ; set contour spacing
  res@lbLabelBarOn     = False              ; turn off individual cb's

  resP                 = True               ; panel resources
  resP@txString        = "SPI: 1979-2010 (GPCP)"  ; add center string
  resP@gsnPanelLabelBar= True               ; add common colorbar

  plot = new ( 2, "graphic")

  do nr=0,nrun-1
    spi    = dim_spi_n(prc, runlen(nr), False, 0)

    spi@long_name = "SPI"
    spi@units = "run="+runlen(nr)
    copy_VarCoords(prc, spi)

    res@gsnCenterString  = yyyymm({200007})
    plot(0) = gsn_csm_contour_map(wks,spi({200007},:,:), res) 

    res@gsnCenterString  = yyyymm({201012})
    plot(1) = gsn_csm_contour_map(wks,spi({200612},:,:), res) 

    gsn_panel(wks,plot,(/2,1/),resP)          ; now draw as one plot
  end do

