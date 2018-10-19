;*************************************************
 ; example program for Box-Percentile-Plots
 ;
 ; based on: Esty WW, Banfield J: The box-percentile plot. J Statistical Software 8 No. 17, 2003.
 ;
 ;************************************************
;
;  These files are loaded by default in NCL V6.2.0 and newer
;  load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
;  load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl" 
;  load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
;
;  These files still have to be loaded manually
 load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl"
 load "./box_percentile_plot.ncl"
 ;************************************************
 begin ; program
 ;************************************************
 ;************************************************
 ; create plot
  wtype                          = "png"
  wtype@wkWidth                  =   1200              ; Set the pixel size of image.
  wtype@wkHeight                 =   1000              ; Set the pixel size of image.
  wks                            = gsn_open_wks(wtype,"box")
  res                          = True
  res@tmXBLabels               = (/"RCP2.6","RCP4.5","RCP8.5","","RCP2.6","RCP4.5","RCP8.5","","RCP2.6","RCP4.5","RCP8.5"/)
  res@tmXBLabelFontHeightF     = 0.02 
  res@tmXBLabelAngleF          = 90
  res@tmXBLabelJust            = "CenterCenter"
  res@tmYMajorGrid                = True          ; implement y grid
  res@tmYMajorGridLineDashPattern = 2             ; select short dash lines
  res@trYMinF                  = 0 ;-90
  res@trYMaxF                  = 8.1 ; 90
  res@tiMainFontHeightF        = 0.023
  res@tiMainString             = "Example Box-Percentile-Plot"
  res@tmXTBorderOn             = True
  res@tmYRBorderOn             = True 
  res@tmYUseLeft              = True
  res@vpXF                     = 0.15
  res@vpYF                     = 0.9
  res@vpWidthF                 = 0.85
  res@vpHeightF                = 0.65 
  res@tiYAxisString            =   ""
  res@tiXAxisString            =   "2021-2050        2041-2070       2071-2100"
  res@tiXAxisFontHeightF      = 0.03
  boxOpts                      = True
  boxOpts@boxWidth             = 0.3  ; with DNA == True 0.3 / without 0.4
  lineRes                      = True
  lineRes@gsLineThicknessF     = 0.9
  lineRes@txFontHeightF            = 5  
  lineRes@tmXBLabelFontHeightF     = 9
  markerRes                    = True 
  markerRes@gsMarkerIndex      = 1
  markerRes@gsMarkerSizeF      = 0.05
  markerRes@gsMarkerThicknessF = 1
  markerRes@gsMarkerColor      = "black"; (/"red","blue"/) ;"blue"
  PerRes                       = True
  PerRes@gsLineColor           = "black"; (/"blue","red"/) ;"blue"
  PerRes@gsLineThicknessF      = 5  
  PerRes@gsFillColor           = (/"(/0.74, 0.84, 0.91/)","(/0.19, 0.51, 0.74/)","(/0.03, 0.32, 0.61/)","(/1.00, 1.00, 1.00/)", \ ; blau
                                    "(/0.80, 0.80, 0.80/)","(/0.60, 0.60, 0.60/)","(/0.40, 0.40, 0.40/)","(/1.00, 1.00, 1.00/)", \ ; grau
                                    "(/0.99, 0.68, 0.57/)","(/0.87, 0.18, 0.15/)","(/0.65, 0.06, 0.08/)"/) ; rot
  PerRes@FillBox               = True ;(/True,False/)
  PerRes@MarkPer               = True ;(/True,False/)
  PerRes@Avg                   = True ;(/True,False/)
  DNA                          = True ;True
  DNA@gsLineColor           = (/ "green","green","green","green","green","green","green","green","green","green","green","green","green","green","black","black","black","black","black","black","black","black","black","black","black","black","black","green"/)
  DNA@gsLineThicknessF     = 6.0
  NoMember                     = True ; False ;True
  NoMember@txFontHeightF       = 0.015 
  NoMember@txJust              = "BottomLeft"
  data                           = new((/11,028/),float)
  data@_FillValue                = -999.
  data(0,:)                      = (/  -999.0, -999.0, -999.0,    0.9, -999.0,    1.4,    1.6,    1.1,    0.9, -999.0, -999.0, -999.0,    0.9,    0.8, -999.0, -999.0, -999.0, -999.0, -999.0, -999.0, -999.0, -999.0,    1.1, -999.0, -999.0, -999.0, -999.0, -999.0/)
  data(1,:)                      = (/     1.6,    0.9,    1.5,    1.2,    1.3,    1.4,    1.6,    1.0, -999.0, -999.0,    1.3,    0.7, -999.0, -999.0,    0.7,    1.1,    2.0,    0.7,    1.2,    1.2,    1.4,    0.9,    1.3,    1.7,    1.4,    1.0,    1.3, -999.0/)
  data(2,:)                      = (/     1.6,    0.9,    1.8,    1.5,    1.3,    1.6,    1.9,    0.9, -999.0, -999.0,    1.1,    0.8, -999.0, -999.0,    0.8,    1.3,    2.2,    0.8,    1.4,    1.4,    1.4,    1.0,    1.6,    1.9,    1.4,    1.0,    1.0,    1.8/)
  data(3,:)                      = (/  -999.0, -999.0, -999.0, -999.0, -999.0, -999.0, -999.0, -999.0, -999.0, -999.0, -999.0, -999.0, -999.0, -999.0, -999.0, -999.0, -999.0, -999.0, -999.0, -999.0, -999.0, -999.0, -999.0, -999.0, -999.0, -999.0, -999.0, -999.0/)
  data(4,:)                      = (/  -999.0, -999.0, -999.0,    1.2, -999.0,    1.6,    1.5,    1.1,    1.1, -999.0, -999.0, -999.0,    1.0,    1.0, -999.0, -999.0, -999.0, -999.0, -999.0, -999.0, -999.0, -999.0,    1.3, -999.0, -999.0, -999.0, -999.0, -999.0/)
  data(5,:)                      = (/     2.0,    1.4,    2.4,    1.7,    1.8,    1.6,    2.3,    1.1, -999.0, -999.0,    1.7,    0.9, -999.0, -999.0,    1.3,    1.7,    2.9,    0.9,    1.8,    1.6,    1.3,    1.4,    1.9,    2.3,    1.8,    1.2,    1.7, -999.0/)
  data(6,:)                      = (/     2.6,    1.8,    2.9,    2.4,    2.6,    2.4,    2.8,    1.8, -999.0, -999.0,    2.1,    1.7, -999.0, -999.0,    1.6,    2.1,    3.2,    1.6,    2.2,    2.0,    1.9,    1.9,    2.5,    2.8,    2.7,    2.0,    2.0,    2.8/)
  data(7,:)                      = (/  -999.0, -999.0, -999.0, -999.0, -999.0, -999.0, -999.0, -999.0, -999.0, -999.0, -999.0, -999.0, -999.0, -999.0, -999.0, -999.0, -999.0, -999.0, -999.0, -999.0, -999.0, -999.0, -999.0, -999.0, -999.0, -999.0, -999.0, -999.0/)
  data(8,:)                      = (/  -999.0, -999.0, -999.0,    1.1, -999.0,    1.2,    1.6,    1.0,    1.0, -999.0, -999.0, -999.0,    1.0,    0.9, -999.0, -999.0, -999.0, -999.0, -999.0, -999.0, -999.0, -999.0,    1.2, -999.0, -999.0, -999.0, -999.0, -999.0/)
  data(9,:)                      = (/     2.5,    1.8,    2.3,    2.1,    2.4,    2.0,    2.8,    1.7, -999.0, -999.0,    2.2,    1.5, -999.0, -999.0,    1.8,    2.0,    3.2,    1.4,    2.3,    1.8,    2.1,    1.9,    2.3,    2.8,    2.5,    1.8,    2.1, -999.0/)
  data(10,:)                      = (/     4.7,    3.3,    4.7,    3.8,    4.2,    4.3,    4.7,    3.4, -999.0, -999.0,    3.6,    2.9, -999.0, -999.0,    3.1,    3.6,    5.4,    3.0,    4.0,    3.4,    3.7,    3.5,    4.1,    4.8,    4.2,    3.5,    3.5,    4.6/)
  box   = box_percentile_plot( wks,data, res,boxOpts,lineRes,PerRes,markerRes,DNA,NoMember)
  txres = True
  gsres = True
  txres@txFontHeightF = 0.015 
  txres@txJust = "CenterCenter"
  Auml    = "A~H-15V6F35~H~FV-6H3~"
  ;gsn_text_ndc(wks,Auml+"nderung zu ",0.1,0.170,txres)
  txres@txJust = "CenterCenter"
  txres@txFontHeightF = 0.025 
  gsn_text_ndc(wks,"[~S~o~N~C]",0.1,0.200,txres) 
 ;************************************************
 ; Drawing plot
   draw(box)
   frame(wks)
 ;************************************************
 end ; program
;************************************************   

