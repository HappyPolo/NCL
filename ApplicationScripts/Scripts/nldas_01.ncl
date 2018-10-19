;*****************************************************
; nldas_1.ncl
;
; Concepts illustrated:
;   - Reading multiple variable directly from a GRIB file
;   - Manually adding attributes to a varible not in GRIB tables
;   - Plot data over USA
;*****************************************************
;
; These files are loaded by default in NCL V6.2.0 and newer 
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"   
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"    
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"    

begin
  in   = addfile("NLDAS_FORA0125_MC.ACLIM07.002.grb","r")

  PRC  = in->A_PCP_110_SFC_S51
  T    = in->TMP_110_HTGL_S51
  U    = in->U_GRD_110_HTGL_S51
  V    = in->V_GRD_110_HTGL_S51
  P    = in->PRES_110_SFC_S51
  H    = in->SPF_H_110_HTGL_S51
  CAPE = in->CAPE_110_SPDY_S51 
  DS   = in->DSWRF_110_SFC_S51
  DL   = in->DLWRF_110_SFC_S51
  PEV  = in->PEVAP_110_SFC_S51

  NCR  = in->NCRAIN_110_SFC_S51 

;************************************************
; create plots
;************************************************
  wks = gsn_open_wks("png" ,"nldas")             ; send graphics to PNG file
 ;gsn_define_colormap(wks,"BlAqGrYeOrRe")        ; choose colormap

  res                       = True     ; plot mods desired
  res@gsnDraw               = False
  res@gsnFrame              = False
  res@cnFillOn              = True     ; turn on color fill
;  res@cnFillPalette         = "BlAqGrYeOrRe" ; set color map
  res@cnLinesOn             = False    ; turn of contour lines
  res@cnLineLabelsOn        = False    ; turn of contour lines

 ;res@pmTickMarkDisplayMode = "Always"; use NCL default lat/lon labels

  res@gsnAddCyclic         = False    ; Regional data                
  res@mpMinLatF            =  min(T&lat_110)                    
  res@mpMaxLatF            =  max(T&lat_110)
  res@mpMinLonF            =  min(T&lon_110)
  res@mpMaxLonF            =  max(T&lon_110)

  res@lbOrientation       = "Vertical"

  resP                     = True                ; modify the panel plot
  resP@txString            = "NLDAS: July 1980-2009"

  plot = new( 2, "graphic")

  plot(0) = gsn_csm_contour_map(wks,PRC, res)
  plot(1) = gsn_csm_contour_map(wks,PEV, res)
  gsn_panel(wks,plot,(/2,1/),resP)               ; now draw as one plot

  plot(0) = gsn_csm_contour_map(wks,NCR, res)
  plot(1) = gsn_csm_contour_map(wks,CAPE, res)
  gsn_panel(wks,plot,(/2,1/),resP)               ; now draw as one plot

  plot(0) = gsn_csm_contour_map(wks,T, res)
  plot(1) = gsn_csm_contour_map(wks,H, res)
  gsn_panel(wks,plot,(/2,1/),resP)               ; now draw as one plot

  plot(0) = gsn_csm_contour_map(wks,U, res)
  plot(1) = gsn_csm_contour_map(wks,V, res)
  gsn_panel(wks,plot,(/2,1/),resP)               ; now draw as one plot

  plot(0) = gsn_csm_contour_map(wks,DS, res)
  plot(1) = gsn_csm_contour_map(wks,DL, res)
  gsn_panel(wks,plot,(/2,1/),resP)               ; now draw as one plot


  plot(0) = gsn_csm_contour_map(wks,P, res)
;  gsn_panel(wks,plot(0),(/1,1/),resP)               ; now draw as one plot

  spd = sqrt(U^2 + V^2)
  copy_VarCoords(U,spd)
  spd@long_name = "Speed"
  spd@units     = U@units

  vcres                       = True      ; plot mods desired
  vcres@gsnDraw               = False
  vcres@gsnFrame              = False
  vcres@vcRefMagnitudeF       = 3.0              ; make vectors larger
  vcres@vcRefLengthF          = 0.050            ; ref vec length
  vcres@vcGlyphStyle          = "CurlyVector"    ; turn on curly vectors
  vcres@vcMinDistanceF        = 0.017            ; thin out vectors
  vcres@gsnAddCyclic          = False    ; Regional data                
  vcres@mpMinLatF             =  min(T&lat_110)                    
  vcres@mpMaxLatF             =  max(T&lat_110)
  vcres@mpMinLonF             =  min(T&lon_110)
  vcres@mpMaxLonF             =  max(T&lon_110)
  vcres@mpFillOn              =  False
  vcres@vcLevelPalette        = "amwg"
  vcres@vcRefAnnoOrthogonalPosF = -.14
  vcres@vcLevelSelectionMode  = "ManualLevels"
  vcres@vcMinLevelValF        = 0.5                ; set min contour level
  vcres@vcMaxLevelValF        = 5.0 
  vcres@vcLevelSpacingF       = 0.5
  vcres@lbOrientation         = "Vertical"

  plot(1)=gsn_csm_vector_scalar_map(wks,U,V,spd,vcres)  ; create plot
  gsn_panel(wks,plot,(/2,1/),resP)                      ; now draw as one plot

end
