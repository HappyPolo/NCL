;*************************************************************** 
; access_1.ncl 
; 
; Concepts illustrated: 
;   - Reading netCDF- 4
;   - Calculating areal averages 
;   - Specifying unequal contour levels
;***************************************************************
; User Input
;***************************************************************
                                             ; INPUT
   diri    = "./"                            ; input directory
   fili    = "IDY25000.APS2.prec.surf.2016040312.000.surface.nc4"   

   pltDir  = "./"                            ; directory for plot output
   pltName = "access"                        ; graphics name output
   pltType = "png"                                            

;***************************************************************
; End User Input
;***************************************************************

   f   = addfile(diri+fili, "r")
   modl_vrsn = f@modl_vrsn                   ; model version: "ACCESS-G" 

   prc = f->accum_prcp                       ; accumulated prc over 3-hrs; 
                                             ; kg/m2 => mm  ; [kg/m2][1000 mm/m][m3/1000kg] ==> mm
   printVarSummary(prc)                      ; (time,lat,lon) ... (1,769,1024)
   printMinMax(prc,0)

   rad = 4.*atan(1.0)/180.                   ; get_d2r(prc&lat) [6.4.0]
   clat= cos(prc&lat*rad)                    ; simple cosine weighting

   prcGlbAvg = wgt_areaave_Wrap(prc, clat, 1.0, 0)
   print(prcGlbAvg)

  ;dimprc = dimsizes(prc)
  ;ntim   = dimprc(0)
  ;nlat   = dimprc(1)
  ;mlon   = dimprc(2)

;************************************************
; Create plot
;************************************************
   prc@units = "mm/3hr"

   wks    = gsn_open_wks(pltType, pltName)
   
   res                      = True                 ; plot mods desired
  ;res@gsnMaximize          = True                 ; applies to ps, eps, pdf .. no-op for png, x11
 
   res@cnFillOn             =  True                ; color fill on
   res@cnFillMode           = "RasterFill"         ; raster mode
   res@cnLinesOn            =  False               ; Turn off contour lines
   res@cnLineLabelsOn       =  False               ; Turn off contour line labels

   res@cnLevelSelectionMode = "ExplicitLevels"              
   res@cnLevels             = (/0.1, 0.5,1,2.5,5,10,15,20,25,50/) ; "mm/3hr" 
   res@cnFillPalette        = (/"Snow","PaleTurquoise","PaleGreen","SeaGreen3" ,"Yellow" \   ; contour colors
                               ,"Orange","magenta","Red","Violet", "Purple", "Brown"/)       ; one more color than contour levels

   res@mpCenterLonF         = 180.                  ; center on dateline
   res@mpFillOn             = False
 
   nt   = 0                                         ; 1st time step
   res@tiMainString         =  fili
   res@gsnCenterString      = "prcGlbAvg="+sprintf("%4.2f", prcGlbAvg)
   plot = gsn_csm_contour_map(wks,prc(nt,:,:), res)
