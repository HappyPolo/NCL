;************************************************
;  gfed_2.ncl
;
; Concepts illustrated:
;   - Importing variables from different groups
;   - Using masking and 'where' function
;   - Using 'stat_dispersion' to examine a variable's distribution
;   - Set two different color maps
;   - Creating a panel plot
;************************************************
; Requires 6.4.0
;************************************************

  diri  = "./"                          ; input directory
  fili  = "GFED4.1s_1997.hdf5"    
  f     = addfile (diri+fili, "r")

  mgrp  = "01"                          ; month group

  path  = "/biosphere/"+mgrp+"/BB" 
  bb    = f->$path$                     ; group: biosphere; month: 01; variable=BB    
  bb@long_name = "Biomass Burning Carbon Emissions"    ; original is too long
  printVarSummary(bb)
  printMinMax(bb,0)
                                        ; group: emissions/partitioning; month: 01; variable=C_AGRI
  path  = "/emissions/"+mgrp+"/partitioning/C_AGRI" 
  cagri = f->$path$
  cagri@long_name = "Agricultural Waste to Total"    ; original is too long
  printVarSummary(cagri)
  printMinMax(cagri,0)

  lat2d = f->lat
  lon2d = f->lon
  lat2d@units = "degrees_north"
  lon2d@units = "degrees_east"

;************************************************
; Where 'Ocean' (breg=0) create an _FillValue
; Also, where the variable is 0.0
; Graphical convenience
;************************************************

  breg = f->/ancill/basis_regions                    ; (lat,lon)    

  bb@_FillValue = 1e20
  bb   = where(breg.eq.0 .or. bb.eq.0, bb@_FillValue, bb)

  cagri@_FillValue = 1e20
  cagri   = where(breg.eq.0 .or. cagri.eq.0, cagri@_FillValue, cagri)

;************************************************
; Distribution information
; When variable highly skewed, thie information can better be used for contour setting
;************************************************
  opt = True
  opt@PrintStat = True
  stat_bb = stat_dispersion(bb, opt )
  stat_cagri = stat_dispersion(cagri, opt )

;************************************************
; create plot
;************************************************
  bb@lat2d    = lat2d
  bb@lon2d    = lon2d

  cagri@lat2d = lat2d
  cagri@lon2d = lon2d

  plot        = new (2, "graphic")

  wks = gsn_open_wks("png","gfed")           ; send graphics to PNG file
  res                  = True                ; plot mods desired
  res@gsnDraw          = False
  res@gsnFrame         = False
  res@gsnMaximize      = True 

  res@cnFillOn         = True                ; color Fill 
 ;res@cnFillMode       = "RasterFill"        ; Raster Mode
  res@cnFillMode       = "CellFill"          ; Cell Mode
  res@cnLinesOn        = False               ; Turn off contour lines

  res@mpCenterLonF     = 0                   ; set map center
  res@mpFillOn         = False

  res@cnLevelSelectionMode = "ManualLevels"     ; set manual contour levels
  res@cnMinLevelValF       =  0.10              ; set min contour level
  res@cnMaxLevelValF       =  5.00              ; set max contour level
  res@cnLevelSpacingF      =  0.10              ; set contour spacing

  res@cnFillPalette        = "GHRSST_anomaly"
  res@cnSpanFillPalette    = True               ; default is True 
  plot(0) = gsn_csm_contour_map_ce(wks, bb  , res) ; create plot

  res@cnMinLevelValF       =  0.05              ; set min contour level
  res@cnMaxLevelValF       =  0.95              ; set max contour level
  res@cnLevelSpacingF      =  0.05              ; set contour spacing
  res@cnFillPalette        = "BlAqGrYeOrReVi200"
  plot(1) = gsn_csm_contour_map_ce(wks,cagri, res) ; create plot

;************************************************
; create panel
;************************************************
  resP                    = True                 ; modify the panel plot
  resP@gsnPanelMainString = "Jan: "+fili         ; 6.4.0 resource                 
  gsn_panel(wks,plot,(/2,1/),resP)               ; now draw as one plot
