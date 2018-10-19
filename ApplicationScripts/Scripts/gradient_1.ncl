;----------------------------------------------------------------------
; gradient_1.ncl
;
; Concepts illustrated:
;   - Reading and reordering variables
;   - Using spherical harmonic (SPH)  procedure to calculate the 
;     latitudinal and longitidinal gradients.
;   - Using 'grad_latlon_cfd'  centered finite differences (CFD) to calculate the
;     latitudinal and longitidinal gradients.
;   - Compute global means and differences between the SPH and CFS estimates  
;   - Plotting with symmetric contour bounds
;===========================================================
; Comment: 
;   - Using the 2-meter temperatures will maximize the differences
;     because there are large gradients and 2m-temps can be a bit noisy.
;===========================================================
;                  MAIN: requires NCL 6.4.0 onward
;===========================================================
; Read gaussian array
; ftp://ftp.cdc.noaa.gov/Datasets/ncep.reanalysis/surface_gauss/
;************************************************
  diri = "/Users/shea/Data/CDC/"
  fili = "air.2m.gauss.1979.nc"          ; 2m temp on gaussian grid
  f    = addfile(diri+fili,"r")

  TG   = f->air(0,:,:)                   ; (time,lat,lon) => (lat,lon); degK        
  TG   = TG(::-1,:)                      ; NCL spherical harmonics want S->N
  TG   = lonPivot(TG, 30)

  TG@long_name = "TG_2m"                 ; short name for plot labeling clarity
  printVarSummary(TG)                    ; (94,192) gaussian [S->N]
  printMinMax(TG,True)
  print("")
  
;************************************************
; Miscellaneous
;************************************************

  dimTG = dimsizes(TG)
  nlat  = dimTG(0)                       ; 94
  mlon  = dimTG(1)                       ; 192

  rad   = 4.*atan(1.)/180.
  lat   = TG&lat
  lon   = TG&lon

  re    = 6.37122e6                      ; spherical earth
  con   = re*rad                         ; one deg lat = 111198.8 meters
  scly  = 1e5                            ; scale => nicer plots
  sclx  = 1e5  
  
;************************************************
; SPHERICAL HARMONICS:
; Use "highly accurate" spherical harmonics procedure (gradsg)
; to compute zonal (X) and meridional (Y) gradients.
;************************************************
                                         ; pre-allocate space for return gradients
  TGX_gradsg = new( dimTG, typeof(TG), getFillValue(TG) )  ; lon=>X
  TGY_gradsg = new( dimTG, typeof(TG), getFillValue(TG) )  ; lat=>Y
  gradsg(TG, TGX_gradsg, TGY_gradsg)     ; procedure for gaussian grids

  copy_VarCoords(TG, TGX_gradsg)         ; add meta data
  copy_VarCoords(TG, TGY_gradsg) 
  TGX_gradsg@long_name = "TGX: gradsg"
  TGX_gradsg@units     = "K/s"
  TGY_gradsg@long_name = "TGY: gradsg"
  TGY_gradsg@units     = "K/s"

  print("")
  printMinMax(TGY_gradsg,True )          ; unscaled
  printMinMax(TGX_gradsg,False)
  print("")

;************************************************
; CENTERED FINITE DIFFERENCES:
; Use local function [grad_latlon_cfd]
; to compute zonal (X) and meridional (Y) gradients.
;************************************************

  gradLatLon = grad_latlon_cfd(TG, lat, lon, True, False)  
  TGY_cfd    = gradLatLon[0]
  TGX_cfd    = gradLatLon[1]

  TGY_cfd@long_name = "TGY: cfd"
  TGY_cfd@units     = "K/s"

  TGX_cfd@long_name = "TGX: cfd"
  TGX_cfd@units     = "K/s"

  printMinMax(TGY_cfd, True)             ; unscaled
  printMinMax(TGX_cfd,False)
  print("")

;************************************************
; DIFFERENCES between centered finite differences and spherical harmonics
;************************************************

  TGX_diff  = TGX_cfd - TGX_gradsg
  TGY_diff  = TGY_cfd - TGY_gradsg

  copy_VarCoords(TG, TGX_diff)
  copy_VarCoords(TG, TGY_diff) 

  TGX_diff@long_name = "TGX: (cfd-gradsg)"
  TGX_diff@units     = "K/s"

  TGY_diff@long_name = "TGY: (cfd-gradsg)"
  TGY_diff@units     = "K/s"

  printMinMax(TGY_diff, True)
  printMinMax(TGX_diff,False)
  print("")

;************************************************
; GLOBAL MEANS 
;************************************************

  gwt   = latGauWgt(nlat, "lat", "gaussian weights", "")

  TGY_gradsg_mean = wgt_areaave(TGY_gradsg, gwt, 1.0, 1)     ; UNSCALED
  TGY_cfd_mean    = wgt_areaave(TGY_cfd   , gwt, 1.0, 1)
  TGY_diff_mean   = wgt_areaave(TGY_diff  , gwt, 1.0, 1)

  TGX_gradsg_mean = wgt_areaave(TGX_gradsg, gwt, 1.0, 1)
  TGX_cfd_mean    = wgt_areaave(TGX_cfd   , gwt, 1.0, 1)
  TGX_diff_mean   = wgt_areaave(TGX_diff  , gwt, 1.0, 1)

  TGX_cfd_mean    = TGX_cfd_mean*sclx                        ; SCALED
  TGY_cfd_mean    = TGY_cfd_mean*scly
  TGX_gradsg_mean = TGX_gradsg_mean*sclx
  TGY_gradsg_mean = TGY_gradsg_mean*scly
  TGX_diff_mean   = TGX_diff_mean*scly
  TGY_diff_mean   = TGY_diff_mean*scly

  print("-----")
  print("TGY_gradsg_mean="+sprintf("%9.3f",TGY_gradsg_mean)) ; SCALED values
  print("TGY_cfd_mean   ="+sprintf("%9.3f",TGY_cfd_mean   ))
  print("TGY_diff_mean  ="+sprintf("%9.3e",TGY_diff_mean  ))
  print("  ")
  print("TGX_gradsg_mean="+sprintf("%9.3e",TGX_gradsg_mean))
  print("TGX_cfd_mean   ="+sprintf("%9.3e",TGX_cfd_mean   ))
  print("TGX_diff_mean  ="+sprintf("%9.3e",TGX_diff_mean  ))
  print("  ")

;************************************************
; PLOTS:  SCALE gradients  for graphical esthetics
;************************************************

  TGY_gradsg = TGY_gradsg*scly
  TGY_cfd    = TGY_cfd*scly

  TGX_gradsg = TGX_gradsg*sclx
  TGX_cfd    = TGX_cfd*sclx

  TGX_diff   = TGX_diff*sclx
  TGY_diff   = TGY_diff*scly

  print("")
  print("=====> scaled values <=====")
  print("")
  printMinMax(TGY_gradsg, True)          ; scaled
  printMinMax(TGX_gradsg,False)
  print("")
  printMinMax(TGY_cfd, True)             ; scaled
  printMinMax(TGX_cfd,False)
  print("")
  printMinMax(TGY_diff, True)
  printMinMax(TGX_diff,False)
  print("")
  

;************************************************
  wks = gsn_open_wks("ps","gradient")           ; open a ps file
  plot = new(2,graphic)                         ; create a plot array
  
  res                 = True
  res@gsnMaximize     = True                     
  res@gsnPaperOrientation = "portrait"
  res@cnLineLabelsOn  = False
  res@cnLevelSpacingF =   5.0                   ; set contour spacing
                                              
  plot(0) = gsn_csm_contour_map_ce(wks,TG,res)  ; original data array 
  delete([/ res@gsnMaximize, res@gsnPaperOrientation, res@cnLevelSpacingF /])  ; not explicitly used below

;----

; panel plots

  res@gsnDraw         = False                    ; don't draw
  res@gsnFrame        = False                    ; don't advance frame
  res@lbLabelBarOn    = False                    ; turn off individual lb's
  res@cnFillOn        = True
  res@cnLinesOn       = False                    ; default is True
  res@cnFillPalette   = "ViBlGrWhYeOrRe"         ; specify colormap 
  res@mpFillOn        = False

  resP    = True
  resP@gsnMaximize         = True                ; make ps, pdf, eps ... large
  resP@gsnPanelLabelBar    = True                ; add common colorbar
  resP@pmLabelBarParallelPosF = 0.05                              

  symMinMaxPlt (TGY_gradsg,20,False,res)
  res@gsnCenterString = "avg="+sprintf("%9.4f", TGY_gradsg_mean) + "[*1e5]"
  plot(0) = gsn_csm_contour_map_ce(wks,TGY_gradsg,res) 

  res@gsnCenterString = "avg="+sprintf("%9.4f", TGY_cfd_mean) + "[*1e5]"
  plot(1) = gsn_csm_contour_map_ce(wks,TGY_cfd   ,res) 
  gsn_panel(wks,plot,(/2,1/),resP)

;----
  symMinMaxPlt (TGX_gradsg,20,False,res)
  res@gsnCenterString = "avg="+sprintf("%9.4f", TGX_gradsg_mean) + "[*1e5]"
  plot(0) = gsn_csm_contour_map_ce(wks,TGX_gradsg,res) 

  res@gsnCenterString = "avg="+sprintf("%9.4f", TGX_cfd_mean) + "[*1e5]"
  plot(1) = gsn_csm_contour_map_ce(wks,TGX_cfd   ,res) 
  gsn_panel(wks,plot,(/2,1/),resP)

;----

  symMinMaxPlt (TGX_diff,20,False,res)
  res@gsnCenterString = "avg="+sprintf("%9.4f", TGX_diff_mean) + "[*1e5]"
  plot(0) = gsn_csm_contour_map_ce(wks,TGX_diff  ,res) 

  symMinMaxPlt (TGY_diff,20,False,res)
  res@gsnCenterString = "avg="+sprintf("%9.4f", TGY_diff_mean) + "[*1e5]"
  plot(1) = gsn_csm_contour_map_ce(wks,TGY_diff  ,res) 
  gsn_panel(wks,plot,(/2,1/),resP)



