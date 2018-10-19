;***********************************************
; unique_13.ncl
;***********************************************
;
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
;***********************************************
; Original File: ser_int_fgco2_ind_model.ncl
;
; Author: Hongmei Li, Max-Planck-Institute for Meteorology
;
; Date: 12 October 2012
;
;************************************************
begin
;************************************************
; read in data
;************************************************
 f2  = addfile ("ser_int_fgco2_CanESM2_his_rcp85.nc","r")
 f3  = addfile ("ser_int_fgco2_GFDL-ESM2G_his_rcp85.nc","r")
 f4  = addfile ("ser_int_fgco2_GFDL-ESM2M_his_rcp85.nc","r")
 f5  = addfile ("ser_int_fgco2_HadGEM2-ES_his_rcp85.nc","r")
 f6  = addfile ("ser_int_fgco2_IPSL-CM5A-LR_his_rcp85.nc","r")
 f7  = addfile ("ser_int_fgco2_MIROC-ESM_his_rcp85.nc","r")
 f8  = addfile ("ser_int_fgco2_MPI-ESM-LR_his_rcp85.nc","r")
 f9  = addfile ("ser_int_fgco2_NorESM1-ME_his_rcp85.nc","r")

 f22  = addfile ("ser_int_fgco2_CanESM2_esmhis_esmrcp85.nc","r")
 f33  = addfile ("ser_int_fgco2_GFDL-ESM2G_esmhis_esmrcp85.nc","r")
 f44  = addfile ("ser_int_fgco2_GFDL-ESM2M_esmhis_esmrcp85.nc","r")
 f55  = addfile ("ser_int_fgco2_HadGEM2-ES_esmhis_esmrcp85.nc","r")
 f66  = addfile ("ser_int_fgco2_IPSL-CM5A-LR_esmhis_esmrcp85.nc","r")
 f77  = addfile ("ser_int_fgco2_MIROC-ESM_esmhis_esmrcp85.nc","r")
 f88  = addfile ("ser_int_fgco2_MPI-ESM-LR_esmhis_esmrcp85.nc","r")
 f99  = addfile ("ser_int_fgco2_NorESM1-ME_esmhis_esmrcp85.nc","r")
;************************************************
; to plot multiple lines, you must put them into
; a mulidimensional array
;************************************************
 data1  = new((/9,251/),float)
 data2  = new((/9,251/),float)
 data1  = 1.e+20
 data2  = 1.e+20

 data1(0,:) = f2->fgco2(:,0,0)*12./44.
 data1(1,11:) = f3->fgco2(:,0,0)
 data1(2,11:) = f4->fgco2(:,0,0)
 data1(3,11:249) = f5->fgco2(2:240,0,0)
 data1(4,:) = f6->fgco2(0:250,0,0)
 data1(5,:) = f7->fgco2(:,0,0)
 data1(6,:) = f8->fgco2(0:250,0,0)
 data1(7,:) = f9->fgco2(0:250,0,0)
 data1(8,:) = dim_avg_n(data1(0:7,:),0)

 data1!0 = "var"
 data1!1 = "time"
 data1&time = ispan(1850,2100,1)
 data1@_FillValue = 1.e+20

 data2(0,:) = f22->fgco2(:,0,0)*12./44.
 data2(1,11:) = f33->fgco2(:,0,0)
 data2(2,11:) = f44->fgco2(:,0,0)
 data2(3,11:249) = f55->fgco2(2:240,0,0)
 data2(4,:) = f66->fgco2(:,0,0)
 data2(5,:) = f77->fgco2(:,0,0)
 data2(6,:) = f88->fgco2(:,0,0)
 data2(7,:) = f99->fgco2(:,0,0)
 data2(8,:) = dim_avg_n(data2(0:7,:),0)

 data2!0 = "var"
 data2!1 = "time"
 data2&time = ispan(1850,2100,1)
 data2@_FillValue = 1.e+20

;************************************************
; plotting parameters
;************************************************
 wks   = gsn_open_wks ("png","unique")         ; send graphics to PNG file
 colors = (/"white","black","White","RoyalBlue","LightSkyBlue",\
             "PowderBlue","lightseagreen","PaleGreen","Wheat","Brown",\
             "Pink","darkgreen","darkorange","red","grey"/)
 gsn_define_colormap(wks, colors) 

 res                   = True                  ; plot mods desired
 res@gsnDraw           = False
 res@gsnFrame          = False
 res@gsnMaximize       = True
 res@trXMinF           = 1850
 res@trXMaxF           = 2100
 res@trYMinF           = -1.0
 res@trYMaxF           = 6.8

; note a similar resource is xyLineThicknessF, which will affect all
; the lines in the array.
 res@xyLineThicknesses = (/1.0,1.0,1.0,1.0,1.0,1.0,1.0,1.0,3.0/)               ; make 2nd lines thicker
 res@xyDashPatterns    = (/1.,1.,1.,1.,1.,1.,1.,1.,1./)
 res@xyLineColors      = (/"grey","pink","blue","red","darkgreen","darkorange","brown","PowderBlue","black"/)    ; change line color
 res@tiYAxisString     = "CO~B~2~N~ flux into ocean [Pg C yr~S~-1~N~]"
 res@tiXAxisString     = "Year"
 res@tmXBLabelFontHeightF = 0.018
 res@tmYLLabelFontHeightF = 0.018

 res@pmLegendDisplayMode    = "Always"              ; turn on legend
 
 res@pmLegendSide           = "Top"                 ; Change location of 
 res@pmLegendParallelPosF   = 0.15                    ; move units right
 res@pmLegendOrthogonalPosF = -0.27                  ; more neg = down
 
 res@pmLegendWidthF         = 0.09                  ; Change width and
 res@pmLegendHeightF        = 0.15                  ; height of legend.
 res@lgLabelFontHeightF     = .011                  ; change font height
 res@lgPerimOn              = False                 ; no box around

; labels for the legend
 res@xyExplicitLegendLabels = (/"CanESM2","GFDL-ESM2G","GFDL-ESM2M","HadGEM2-ES","IPSL-CM5A-LR","MIROC-ESM","MPI-ESM-LR","NorESM1-ME","MME"/)
 plot_L = gsn_csm_xy (wks,data1&time,data1(:,:),res) ; create plot
 res@xyDashPatterns    = (/0.,0.,0.,0.,0.,0.,0.,0.,0./)
 plot0 = gsn_csm_xy (wks,data1&time,data2(:,:),res) ; create plot
 overlay(plot_L,plot0)

 res@gsnMaximize   = False
 res@pmLegendDisplayMode    = "Never"              ; turn off legend

 res@vpWidthF          = 0.15       ; Make plots quite a bit smaller.
 res@vpHeightF         = 0.33
 res@trYMinF           = -0.5
 res@trYMaxF           = 0.6
 res@trXMinF           = 1860
 res@trXMaxF           = 1870
 res@tmXBMode          = "Manual"
 res@tmXBTickSpacingF  = 5
 res@tiYAxisString     = ""
 res@tiXAxisString     = ""
 res@tmXBLabelFontHeightF = 0.016
 res@tmYLLabelFontHeightF = 0.016

 res@xyDashPatterns    = (/1.,1.,1.,1.,1.,1.,1.,1.,1./)
 plot_S1 = gsn_csm_xy (wks,data1&time,data1(:,:),res) ; create plot
 res@xyDashPatterns    = (/0.,0.,0.,0.,0.,0.,0.,0.,0./)
 plot1 = gsn_csm_xy (wks,data1&time,data2(:,:),res) ; create plot
 overlay(plot_S1,plot1)

 res@trYMinF           = 0.0
 res@trYMaxF           = 1.3
 res@trXMinF           = 1935
 res@trXMaxF           = 1945
 res@xyDashPatterns    = (/1.,1.,1.,1.,1.,1.,1.,1.,1./)
 plot_S2 = gsn_csm_xy (wks,data1&time,data1(:,:),res) ; create plot
 res@xyDashPatterns    = (/0.,0.,0.,0.,0.,0.,0.,0.,0./)
 plot2 = gsn_csm_xy (wks,data1&time,data2(:,:),res) ; create plot
 overlay(plot_S2,plot2)

 res@trYMinF           = 3.9
 res@trYMaxF           = 6.5
 res@trXMinF           = 2090
 res@trXMaxF           = 2100
 res@tmXBTickSpacingF  = 5
 res@xyDashPatterns    = (/1.,1.,1.,1.,1.,1.,1.,1.,1./)
 plot_S3 = gsn_csm_xy (wks,data1&time,data1(:,:),res) ; create plot
 res@xyDashPatterns    = (/0.,0.,0.,0.,0.,0.,0.,0.,0./)
 plot3 = gsn_csm_xy (wks,data1&time,data2(:,:),res) ; create plot
 overlay(plot_S3,plot3)

;
; Set up a resource list to add smaller plots as
; annotations of bigger plots.
;
  amres                  = True
  amres@amJust           = "BottomLeft"  ; Corner of plot for positioning

  amres@amOrthogonalPosF =  0.18   ;  0.5 is the bottom edge of the plot.
                                   ; Need to leave room for tickmarks.
  amres@amParallelPosF   = -0.40   ; -0.5 is the left edge of the plot.
  anno1 = gsn_add_annotation(plot_L, plot_S1, amres)  ; Attach first plot

  amres@amOrthogonalPosF =  -0.06   ;  0.5 is the bottom edge of the plot.
  amres@amParallelPosF  = -0.09
  anno2 = gsn_add_annotation(plot_L, plot_S2, amres)  ; Attach first plot

  amres@amOrthogonalPosF =  0.44   ;  0.5 is the bottom edge of the plot.
  amres@amParallelPosF  =  0.27
  anno3 = gsn_add_annotation(plot_L, plot_S3, amres)  ; Attach first plot

;---Drawing the "base" plot will draw all four plots.
  draw(plot_L)
  frame(wks)

end

