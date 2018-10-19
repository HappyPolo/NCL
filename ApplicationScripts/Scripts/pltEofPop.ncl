undef("pltEofPop")
procedure pltEofPop (xts[*][*]:numeric,xpat[*][*][*]:numeric,yrfrac[*]:numeric \
                    ,filName[1]:string ,pltType[1]:string, pltID[1]:string     \
                    ,pltColor[1]:string)

; Utility to isolate code used to plot the EOF and/or POP patterns and time series

local dim_xpat, dim_xts, n, nMode, pltName, wks, gary, plot, res, rts, resP
begin
  dim_xpat = dimsizes(xpat)
  dim_xts  = dimsizes(xts )
  nMode    = dim_xts(0)
  
  pltName  = filName+"."+pltID
  wks      = gsn_open_wks(pltType,pltName)
  gsn_define_colormap(wks,pltColor  )     ; choose colormap
  gray     = NhlNewColor(wks,0.7,0.7,0.7)  ; add gray to color table

  plot = new(nMode,graphic)               ; create graphic array
  res                      = True         
  res@gsnDraw              = False        ; don't draw yet
  res@gsnFrame             = False        ; don't advance frame yet
  res@gsnSpreadColors      = True         ; spread out color table
  res@gsnSpreadColorEnd    = -2           ; don't use added gray
  res@gsnAddCyclic         = False        ; data not cyclic
 
  res@mpCenterLonF         = 180.         ; defailt is 0 [GM]
  res@mpMinLatF            = min(xpat&lat)
  res@mpMaxLatF            = max(xpat&lat)
  res@mpMinLonF            = min(xpat&lon)
  res@mpMaxLonF            = max(xpat&lon)
  res@mpFillDrawOrder      = "PostDraw"

  res@cnFillOn             = True         ; turn on color fill
  res@cnLinesOn            = False        ; True is default
  res@cnLinesLabelsOn      = False        ; True is default
  res@lbLabelBarOn         = False        ; turn off individual lb's
                                          ; set symmetric plot min/max
  symMinMaxPlt(xpat, 16, False, res); contributed.ncl

; panel plot only resources
  resP                     = True         ; modify the panel plot
  resP@gsnMaximize         = True         ; large format
  resP@gsnPanelLabelBar    = True         ; add common colorbar
  resP@lbLabelAutoStride   = True         ; auto stride on labels

  resP@txString            = filName               
  do n=0,nMode-1
     res@gsnLeftString  = pltID+" "+(n+1)
     if (pltID.eq."EOF") then
         res@gsnRightString = sprintf("%5.1f", xpat@pcvar(n)) +"%"
     end if
     plot(n) = gsn_csm_contour_map_ce(wks,xpat(n,:,:),res)
  end do
  if (nMode.gt.3) then
      gsn_panel(wks,plot,(/nMode,2/),resP) 
  else
      gsn_panel(wks,plot,(/nMode,1/),resP) 
  end if

;*******************************************
; time series (principal component) plot
;*******************************************
  xts@long_name = "Amplitude"

  rts           = True
  rts@gsnDraw   = False       ; don't draw yet
  rts@gsnFrame  = False       ; don't advance frame yet
 ;rts@gsnScale  = True        ; force text scaling               

  rts@vpHeightF = 0.40        ; Changes the aspect ratio
  rts@vpWidthF  = 0.85
  rts@vpXF      = 0.10        ; change start locations
  rts@vpYF      = 0.75        ; the plot

  rts@gsnYRefLine           = 0.              ; reference line   
  rts@gsnAboveYRefLineColor = "red"           ; above ref line fill red
  rts@gsnBelowYRefLineColor = "blue"          ; below ref line fill blue

; panel plot only resources
  rtsP                     = True             ; modify the panel plot
  rtsP@gsnMaximize         = True             ; large format
      
  resP@txString            = filName
  do n=0,nMode-1
     rts@gsnLeftString  = pltID+" "+(n+1)
     if (pltID.eq."EOF") then
         res@gsnRightString = sprintf("%5.1f", xpat@pcvar(n)) +"%"
     end if
     plot(n) = gsn_csm_xy (wks,yrfrac,xts(n,:),rts)
  end do

  if (nMode.gt.3) then
      gsn_panel(wks,plot,(/nMode/2,2/),resP) 
  else
      gsn_panel(wks,plot,(/nMode  ,1/),resP) 
  end if

end 
