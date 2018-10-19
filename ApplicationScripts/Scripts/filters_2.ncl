; ***********************************************
; filters_2.ncl
; ***********************************************
;
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
; ***********************************************
begin


  f     = addfile ("./SOI.nc" , "r") 
  dsoi  = f->SOI_DARWIN        

  ihp   = 0                             ; low_pass
  sigma = 1.0                           ; Lanczos sigma

  nWgt  = 49                            ; loose 24 months each end                            
  fca   = 1./24.                        ; 2 years
  wgtq  = filwgts_lanczos (nWgt, ihp, fca, -999., sigma )

  nWgt  = 121                           ; loose 60 months each end
  fca   = 1./24.                        ; 2 years
  wgtr  = filwgts_lanczos (nWgt, ihp, fca, -999., sigma )

  nWgt  = 121                           ; loose 60 months each end
  fca   = 1./120.                       ; decadal
  wgts  = filwgts_lanczos (nWgt, ihp, fca, -999., sigma )

  nWgt  = 241                           ; loose 120 months each end
  fca   = 1./120.                       ; decadal
  wgtt  = filwgts_lanczos (nWgt, ihp, fca, -999., sigma )

  ntim  = dimsizes( dsoi )
  yPlot = new ( (/4,ntim/) , typeof(dsoi), getFillValue(dsoi) )

  yPlot(0,:) = wgt_runave ( dsoi, wgtq, 0 )   ; 2 year
  yPlot(1,:) = wgt_runave ( dsoi, wgtr, 0 )   ; 2 year
  yPlot(2,:) = wgt_runave ( dsoi, wgts, 0 )   ; 10 year
  yPlot(3,:) = wgt_runave ( dsoi, wgtt, 0 )   ; 10 year

; ***********************************************
; create new date array for use on the plot
; ***********************************************
  pltType = "png"                   ; send graphics to PNG file
  pltName = "filters"

  date    = f->time                 ; yyyymm
  ntim    = dimsizes(date)
  yrfrac  = yyyymm_to_yyyyfrac (date, 0)

  delete(yrfrac@long_name)
  delete(dsoi@long_name)

  plot             = new ( 2, "graphic") 
  wks              = gsn_open_wks (pltType,pltName)

  res              = True            ; plot mods desired
  res@gsnDraw      = False           ; don't draw 
  res@gsnFrame     = False           ; don't advance frame yet      

  res@vpHeightF    = 0.4             ; change aspect ratio of plot
  res@vpWidthF     = 0.8                  
  
  res@trYMinF      = -3.0            ; min value on y-axis
  res@trYMaxF      =  3.0            ; max value on y-axis
  res@trXMinF      = 1860            ; min value on x-axis
  res@trXMaxF      = 2016            ; max value on x-axis

  res@vpXF         = 0.1             ; start plot at x ndc coord 
  res@gsnYRefLine  = 0.0             ; create a reference line   
  
  res@gsnCenterString = "Darwin Southern Oscillation Index" 
  plot(0)          = gsn_csm_xy (wks,yrfrac,dsoi,res)      
  
  res@xyMonoDashPattern= True
  res@xyLineThicknessF = 2
  res@xyLineColors     = (/ "blue", "red", "green", "black" /)
  res@gsnCenterString  = "Low Pass Filtered: 2-year and 10-year"     
  plot(1) = gsn_csm_xy (wks,yrfrac,yPlot,res)     
  
  resP                 = True    
  resP@gsnMaximize     = True
  gsn_panel(wks,plot,(/2,1/),resP) 

end

