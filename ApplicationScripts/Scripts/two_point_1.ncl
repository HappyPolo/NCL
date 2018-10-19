load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl" 

begin

  diri = "./"
  fili = "wrfout_franco.nc"

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

  nt            = 0     
  x_in		= 0	; first node on the x direction
  x_fin		= 98	; last node on the x direction
  y_in          = 0     ; first node on the y direction
  y_fin         = 98    ; last node on the y direction
		        ; x and y dimensions of the subdomain must be the same

  k     	= 24	; z level to analize

  dx		= 50.	; cell size in x direction
  dy		= 50.	; cell size in y direction

  plot2d        = 1	; 1 to plot 2d autocorrelation coefficient, 
                        ; otherwise plot the 1d autocorrelation coefficient
  pltType       = "ps"
  pltName       = "two_point_cor"

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

  a   = addfile (diri+fili,"r")

  x   = a->W(nt, k:k+1, y_in:y_fin, x_in:x_fin)
  printVarSummary(x)
  dimx= dimsizes(x)              ; (2,99,99)
  print(dimx)

  nj  = y_fin - y_in -1          ; NCL is zero based
  ni  = x_fin - x_in -1
 ;print("nj="+nj+"   ni="+ni)

  w   = new((/nj,ni/),float)
  do j=0,nj-1
    do i=0,ni-1
       w(j,i) = avg(x(:,j,i))
    end do
  end do
  printVarSummary( w )      
  printMinMax( w, True )   

  periodog_2d    = (fft2df(w))^2
  f_corr_ncl_in  = fft2db(periodog_2d)

  dimcorr        = dimsizes(f_corr_ncl_in)
  njc            = dimcorr(0)
  nic            = dimcorr(1)
 ;print(dimcorr)

  f_corr_ncl_in  = f_corr_ncl_in/f_corr_ncl_in(1,1)    ; normalize
  f_corr_ncl     = f_corr_ncl_in(1:floattoint((njc-1)/2.),1:floattoint((nic-1)/2.))

  dimcorr2       = dimsizes(f_corr_ncl)
  njj            = dimcorr2(0)
  nii            = dimcorr2(1)
 ;print(dimcorr2)

;======================================================
; Create plot
;======================================================

  wks = gsn_open_wks(pltType,pltName)

  gsn_define_colormap(wks,"gsltod")
  colors = gsn_retrieve_colormap(wks)     ; retrieve color map for editing.
  colors(0,:) = (/ 1, 1, 1 /)
  colors(1,:) = (/ 0., 0., 0. /)
  gsn_define_colormap(wks,colors)

  res					= True               ; plot mods desired
  res@gsnMaximize			= True
 ;res@vpWidthF				= 0.6
 ;res@vpHeightF				= 0.6

if(plot2d.eq.1) then

  res2d=res

  res2d@gsnSpreadColors			= True             ; use full range of colormap
  res2d@cnFillMode			= "AreaFill"
  res2d@cnFillOn			= True
  res2d@cnLinesOn			= True
  res2d@cnLineLabelFormat		= "@1.4f"

  res2d@cnLevelSelectionMode		= "ManualLevels"
  res2d@cnMinLevelValF			= -.5
  res2d@cnMaxLevelValF			= 1.

  res2d@cnLineLabelDensityF		= .25
  res2d@cnLevelSpacingF			= .125
  res2d@cnLineLabelsOn			= False
  res2d@cnInfoLabelOn			= False
  res2d@lbLabelAutoStride               = True

  res2d@gsnDraw				= False
  res2d@gsnFrame			= False

  zres1=res2d

  zres1@gsnSpreadColors			= True             ; use full range of colormap
  zres1@cnFillMode			= "AreaFill"
  zres1@cnFillOn			= True
  zres1@cnLinesOn			= False
  zres1@cnLineLabelFormat		= "@1.4f"

  zres1@lbLabelBarOn			= False   ;  colour bar
  zres1@pmLabelBarDisplayMode		= "Always"
  zres1@pmLabelBarSide			= "Bottom"
  zres1@pmLabelBarHeightF		= 0.12
  zres1@pmLabelBarWidthF		= 0.9
  zres1@lbAutoManage			= False
  zres1@lbLabelJust			= "CenterCenter"
  zres1@lbLabelFontHeightF		= 0.03
  zres1@lbOrientation			= "Horizontal"
  zres1@lbPerimOn			= False

  plotz = gsn_csm_contour (wks,f_corr_ncl,zres1)

  zres2=res2d

;;shading for negative values
  zres2@gsnContourNegLineDashPattern	= 1
  zres2@gsnContourPosLineDashPattern	= 0

  zres2@cnFillOn			= False
  zres2@cnLinesOn			= True
  zres2@lbLabelBarOn			= False   ;  colour bar
  zres2@pmLabelBarDisplayMode		= "Always"
  zres2@pmLabelBarSide			= "Bottom"
  zres2@pmLabelBarHeightF		= 0.12
  zres2@pmLabelBarWidthF		= 0.9
  zres2@lbAutoManage			= False
  zres2@lbLabelJust			= "CenterCenter"
  zres2@lbLabelFontHeightF		= 0.03
  zres2@lbOrientation			= "Horizontal"
  zres2@lbPerimOn			= False
  zres2@lbLabelStride			= 999
  zres2@cnLineLabelFormat		= "@1.4f"

  zres2@gsnCenterString                 = "2D-Autocorrelation" 
  plotz2=gsn_csm_contour (wks,f_corr_ncl,zres2)

  opt					= True
  opt@gsnShadeFillType			= "pattern"
  opt@gsnShadeLow			= 17         ; Use fill Pattern #17

;FOR T shading to highlight stability
  plotz2 = gsn_contour_shade(plotz2,0.,-999., opt)   ; Shade contours below 0.

  delete(opt@gsnShadeLow)

  overlay (plotz, plotz2)

  draw(plotz)
  frame(wks)

else

  f_corr_delta = new(floattoint((nii^2.+njj^2.)^.5)-1,float)
  v_del        = fspan(0,((nii*dx)^2.+(njj*dy)^2.)^.5,floattoint((nii^2.+njj^2.)^.5)-1)
  nidel        = new(floattoint((nii^2.+njj^2.)^.5)-1,integer)
  nidel        = 0
  f_corr_delta = 0.

  do j=0,njj-1
    do i=0,nii-1
      idel               = floattoint((i^2.+j^2.)^.5)
      f_corr_delta(idel) = f_corr_delta(idel)+f_corr_ncl(j,i)
      nidel(idel)        = nidel(idel)+1
    end do
  end do
  f_corr_delta = f_corr_delta/nidel
  
  xyres=res
  xyres@vpWidthF		= 1.4
  xyres@vpHeightF		= 1.

  xyres@xyLineThicknessF        = 2
  
  xyres@tiYAxisString	        = "~F8~r~F21~~B~w~N~"
  xyres@tiXAxisString     	= "~F8~D~F21~~"
  xyres@tmYLMode                = "Manual"
  xyres@trYMinF		        = -.2
  xyres@trYMaxF		        = 1.
  xyres@tmYLAutoPrecision	= False
  xyres@tmYLPrecision   	= 2
  xyres@tmYLTickSpacingF	= .2

  xyres@tmXBMode		= "Manual"
  xyres@trXMinF		        = 0.
  xyres@trXMaxF		        = 3500.
  xyres@tmXBTickSpacingF	= 500.
  xyres@tmXBMinorPerMajor	= 4
  
  xyres@gsnDraw		        = False
  xyres@gsnFrame		= False
  xyres@gsnCenterString         = "1D-Autocorrelation" 
  plotxy = gsn_csm_xy (wks,v_del,f_corr_delta,xyres)
  
  plres = True
  plres@gsLineThicknessF        = 2
  ply   = (/0,0/)
  plx   = (/0,v_del(floattoint((nii^2.+njj^2.)^.5)-2)/)
  dum_0 = gsn_add_polyline(wks, plotxy, plx, ply, plres)
  
  draw(plotxy)
  frame(wks)

end if

end
