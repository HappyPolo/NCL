;************************************************
; e20c_1.ncl
;
; Concepts illustrated:
;   - Reading GRIB data
;   - Compute monthly mean cloud cover at 00Z, 12Z and all time
;   - Use assorted NCL functions: cd_calendar, ind, dim_avg_n_Wrap
;   - Plotting plot results on a panel
;
;*************************************************
;
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"  
;************************************************
begin
;************************************************
; create pointer to file and read in data
;************************************************
  in     = addfile("e20c.oper.an.pl.3hr.128_248_cc.regn80sc.1909110100_1909113021.grb","r")
  cc     = in->CC_GDS4_ISBL

  ymdhms = cd_calendar(cc&initial_time0_hours, -5)
  yyyymm = cd_calendar(cc&initial_time0_hours, -1)
;************************************************
; create plot resources
;************************************************
  wks = gsn_open_wks("png","e20c")               ; send graphics to PNG file

  res                       = True               ; plot mods desired
  res@gsnDraw               = False              ; don't draw
  res@gsnFrame              = False              ; don't advance frame

  res@cnFillOn              = True               ; turn on color fill
  res@cnFillPalette         = "prcp_1"           ; set color map
  res@cnLinesOn             = False              ; turn off contour lines
  res@cnLineLabelsOn        = False              ; turn off contour line labels
  res@cnFillMode            = "RasterFill"
  res@cnLevelSelectionMode  =  "ManualLevels"   
  res@cnMinLevelValF        = 0.10
  res@cnMaxLevelValF        = 0.90
  res@cnLevelSpacingF       = 0.10 
  res@mpCenterLonF          = 180

  res@lbLabelBarOn          = False  

;************************************************
; create panel resources
;************************************************
  resP                     = True                ; modify the panel plot
  resP@gsnPanelLabelBar    = True                ; add common colorbar

;************************************************
; Compute specified hourly means over the month at a specified level
;************************************************
  plev = 750
  hr   = (/ 0, 12 /)                             ; compute means at these hours
  nhr  = dimsizes(hr)
  plot = new (nhr,"graphic")

  do n=0,nhr-1 
     nt := ind(ymdhms(:,3).eq.hr(n))
     cc_mean = dim_avg_n_Wrap(cc(nt,{plev},:,:), 0)
     res@gsnCenterString = "hr="+sprinti("%0.2i", hr(n))+"Z" 
     plot(n) = gsn_csm_contour_map(wks,cc_mean,res)     
  end do

  resP@txString   = "E20C: Monthly Mean: "+yyyymm(0)+" p="+plev+"hPa"
  gsn_panel(wks,plot,(/2,1/),resP)               ; now draw as one plot

;************************************************
; Overal all mean at a different level
;************************************************
  plev = 500
  cc_mean = dim_avg_n_Wrap(cc(:,{plev},:,:), 0)

  resP@txString  = "E20C: Monthly Mean: "+yyyymm(0)+" p="+plev+"hPa"
  res@gsnCenterString = "All times" 
  plt = gsn_csm_contour_map(wks,cc_mean,res)     
  gsn_panel(wks,plt,(/1,1/),resP)               ; now draw as one plot
end


