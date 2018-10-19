;*************************************************************** 
; access_2.ncl 
; 
; Concepts illustrated: 
;   - Reading GRIB-2
;   - Specifying the names of desired variables
;     These can be obtained via NCL's   ncl_filedump 
;   - Manually set graphic levels
;   - Read each variable (type string) by enclosing with $ character
;   - Create zonal plots
;   - Change lat / lon label style
;   - Plotting a panel plot 
;***************************************************************
; User Input
;***************************************************************
                                             ; INPUT
   diri    = "./"                            ; input directory
   fili    = "IDY25000.APS2.all-flds.slv.2016040312.000.surface.grb2"

   varCloud= (/"TCDC_P0_2L1_8_GLL0","LCDC_P0_2L102_GLL0" \
              ,"MCDC_P0_2L102_GLL0","HCDC_P0_2L102_GLL0" /)  ; use ncl_filedump
   nCloud  = dimsizes(varCloud)              ; nCloud=4

   pltDir  = "./"                            ; directory for plot output
   pltName = "access"                        ; graphics name output
   pltType = "png"                                            

;***************************************************************
; End User Input
;***************************************************************
; Not required
; Force GRIB files with a single time step, to have an explicit 'time' dimension.
; Variables of type "string" must be enclosed by $
;***************************************************************
   setfileoption("grb","SingleElementDimensions","Initial_time") ; initial_time0_hours

   f   = addfile(diri+fili, "r")
  ;varNames  = getfilevarnames(f)            ; return all variable names on the file            
  ;nvar_f    = dimsizes(varNames)            ; number of variables on file
  ;print(varNames)

   ct  = f->$varCloud(0)$                    ; f->TCDC_P0_2L1_8_GLL0
   cl  = f->$varCloud(1)$                    ; f->LCDC_P0_2L102_GLL0
   cm  = f->$varCloud(2)$                    ; f->MCDC_P0_2L102_GLL0
   ch  = f->$varCloud(3)$                    ; f->HCDC_P0_2L102_GLL0
                                             
   printVarSummary(ct)                       ; (time,lat,lon) ... (1,769,1024) ... %
   printMinMax(ct,0)  

  ;dimcld = dimsizes(ct)                     ; dimension sizes
  ;ntim   = dimcld(0)
  ;nlat   = dimcld(1)
  ;mlon   = dimcld(2)

;************************************************
; Global averages
;************************************************
   rad = 4.*atan(1.0)/180.                   ; get_d2r(ct&lat_0) [6.4.0]
   clat= cos(ct&lat_0*rad)                   ; simple cosine weighting

   ctGlbAvg = wgt_areaave_Wrap(ct, clat, 1.0, 0)
   clGlbAvg = wgt_areaave_Wrap(cl, clat, 1.0, 0)
   cmGlbAvg = wgt_areaave_Wrap(cm, clat, 1.0, 0)
   chGlbAvg = wgt_areaave_Wrap(ch, clat, 1.0, 0)
   print(ctGlbAvg)
   print("clGlbAvg="+clGlbAvg)
   print("cmGlbAvg="+cmGlbAvg)
   print("chGlbAvg="+chGlbAvg)

;************************************************
; Create plot
;************************************************
   plot = new(nCloud,graphic)            ; create plot array

   wks  = gsn_open_wks(pltType, pltName)
   res                      = True                 ; plot mods desired
   res@gsnDraw              = False                ; don't draw yet
   res@gsnFrame             = False                ; don't advance frame

   res@gsnZonalMean         = True                 ; turn on zonal ave plot
   res@gsnZonalMeanXMinF    =  0 
   res@gsnZonalMeanXMaxF    = 100
 
   res@cnFillOn             =  True                ; color fill on
   res@cnFillMode           = "RasterFill"         ; raster mode
   res@cnLinesOn            =  False               ; Turn off contour lines
   res@cnLineLabelsOn       =  False               ; Turn off contour line labels
   res@cnLevelSelectionMode = "ManualLevels"       ; "ManualLevels" is the default              
   res@cnMinLevelValF       =   5.                 ; set min contour level
   res@cnMaxLevelValF       =  95.                 ; set max contour level
   res@cnLevelSpacingF      =   5.                 ; set contour spacing
   res@cnInfoLabelOn        = False                ; turn off cn info label
   res@cnFillPalette        = "WhViBlGrYeOrRe"     ; specify color palette
 
   res@lbLabelBarOn         = False                ; turn off individual lb's

  ;res@pmTickMarkDisplayMode= "Always"             ; use NCL default lat/lon labels

   res@mpCenterLonF         = 180.                 ; center on dateline
   res@mpFillOn             = False                ; turn off 
 
   nt      = 0                                         ; 1st time step
   res@gsnCenterString      = "GlbAvg="+sprintf("%4.1f", ctGlbAvg)
   plot(0) = gsn_csm_contour_map(wks,ct(nt,:,:), res)
   res@gsnCenterString      = "GlbAvg="+sprintf("%4.1f", clGlbAvg)
   plot(1) = gsn_csm_contour_map(wks,cl(nt,:,:), res)
   res@gsnCenterString      = "GlbAvg="+sprintf("%4.1f", cmGlbAvg)
   plot(2) = gsn_csm_contour_map(wks,cm(nt,:,:), res)
   res@gsnCenterString      = "GlbAvg="+sprintf("%4.1f", chGlbAvg)
   plot(3) = gsn_csm_contour_map(wks,ch(nt,:,:), res)

;************************************************
; create panel
;************************************************
  resP                     = True                ; modify the panel plot

; resP@gsnPanelMainString = fili                 ; use this for NCL V6.4.0 and later
  resP@txString           = fili
  resP@gsnPanelLabelBar   = True                 ; add common colorbar
  gsn_panel(wks,plot,(/2,2/),resP)

