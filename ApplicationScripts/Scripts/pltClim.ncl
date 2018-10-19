procedure pltClim(clim[12][*][*], froot, pltType, pltID, pltColor)
local dnam, pltName, wks, plot, res, resP, n
begin
  dnam     = getvardims(clim)


  pltName  = froot+"."+pltID
  wks  = gsn_open_wks(pltType,pltName)
  gsn_define_colormap(wks,pltColor)       ; choose colormap
  plot = new(12,graphic)             	  ; create graphic array
                                          ; only needed if paneling
; climatology
  res                      = True         
  res@gsnDraw              = False        ; don't draw yet
  res@gsnFrame             = False        ; don't advance frame yet

  res@gsnSpreadColors      = True         ; spread out color table
  res@gsnAddCyclic         = False        ; plotted data are not cyclic
 
  res@mpFillOn             = False        ; turn off map fill
  res@mpLimitMode          = "LatLon"
  
  res@mpMinLatF            = min(clim&$dnam(1)$) 
  res@mpMaxLatF            = max(clim&$dnam(1)$) 
  res@mpMinLonF            = min(clim&$dnam(2)$)
  res@mpMaxLonF            = max(clim&$dnam(2)$)
  res@mpCenterLonF	   = (res@mpMinLonF + res@mpMaxLonF)*0.5

  res@cnFillOn             = True         ; turn on color fill
  res@cnLinesOn            = False        ; True is default
  res@cnLineLabelsOn       = False        ; True is default
  res@lbLabelBarOn         = False        ; turn off individual lb's
                                          ; set symmetric plot min/max
;  symMinMaxPlt(clim, 16, False, res)      ; contributed.ncl

  resP                     = True         ; modify the panel plot
  resP@gsnMaximize         = True         ; large format
  resP@gsnPanelLabelBar    = True         ; add common colorbar
  resP@lbLabelAutoStride   = True         ; auto stride on labels

 ;yStrt                    = yyyymm(0)/100
 ;yLast                    = yyyymm(nyrs-1)/100
 ;resP@txString		   = varname+", "+yStrt+"-"+yLast
;*******************************************
; first plot
;*******************************************
  month = (/"J","F","M","A","M","J","J","A","S","O","N","D"/)
  do n=0,11
     res@gsnLeftString  = month(n)
     plot(n)=gsn_csm_contour_map_ce(wks,clim(n,:,:),res)
  end do
  gsn_panel(wks,plot,(/6,2/),resP)     ; now draw as one plot

end
