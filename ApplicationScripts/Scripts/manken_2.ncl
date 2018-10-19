;*************************************************
; manken_2.ncl
;
; Concepts illustrated:
;   - Read tabular values from an ascii file
;   - Extract desired period using NCL array syntax and using 'ind'
;   - Calculate the seasonal average values
;   - Calculate linear regression coef and Theil-Sen slope
;   - Plot
;*************************************************
; http://climate.rutgers.edu/snowcover/table_area.php?ui_set=1
; NOTE: Missing months added and filled with -99.
;       I recommend using 1972 onward ... better 1979 onward
; columns
;  0      1        2      3         4      5         6
; Row    Year    Month   NHem    Eurasia NAmerica  NAmerica
;                                                (no Greenland)
;*************************************************

;-----------------------------------------------------
; Specify the desired region; also,  start and end year
;-----------------------------------------------------
   diri   = "./"
   fili   = "rutgers.snow_cover_extent.time_series.txt"

   region = 3                                        ; column w desired data
   regstr = "NHem"

   yyStrt = 1979
   yyLast = 2014
   lensea = 5                                        ; # monthly values for season

;-----------------------------------------------------
; Read ascii (text) file; time is in reverse order
;-----------------------------------------------------
   pthi   = diri+fili

   ncol   = 7 
   nskp   = 5 
   data   = readAsciiTable(pthi, ncol, "float", nskp)
   data@_FillValue = -99.0

   data(:,1) = data(::-1,1)           ; make chronological
   data(:,2) = data(::-1,2)
   data(:,region) = data(::-1,region)

   YYYY   = toint( data(:,1) )
   MM     = toint( data(:,2) )
   YYYYMM = YYYY*100 + MM
                                      ; 'extra' year for runave bound
   nt     = ind(YYYY.ge.(yyStrt-1) .and. YYYY.le.(yyLast+1))

   SNE    = data(nt, region)
   SNE@long_name = "snow extent: "+regstr
   SNE@units     = "km^2"
   SNE!0  = "yyyymm"
   SNE&yyyymm = YYYYMM(nt)
   printVarSummary( SNE )

   delete( [/nt, YYYY, MM, YYYYMM /] )

;-----------------------------------------------------
; Calculate seasonal means by performing a running average
;-----------------------------------------------------
   sea_mean = runave_n_Wrap(SNE, lensea, 0, 0)
   printVarSummary(sea_mean)                                ; &yyyymm

;-----------------------------------------------------
; Extract desired seasonal means
;-----------------------------------------------------
   ymStrt = yyStrt*100 +  1
   ymLast = yyLast*100 +  1
   sea_winter = sea_mean({ymStrt:ymLast:12})                 ; winter: January center month   
   print(sea_winter&yyyymm+"  sea_winter="+sea_winter)

   ymStrt = yyStrt*100 +  7
   ymLast = yyLast*100 +  7
   sea_summer = sea_mean({ymStrt:ymLast:12})                 ; summer: July    center month
   print(sea_summer&yyyymm+"  sea_summer="+sea_summer)

;-----------------------------------------------------
; Calculate regression and Mann-Kendall trend for each season
;-----------------------------------------------------
   yyyy  = (sea_winter&yyyymm)/100
   nyrs  = dimsizes(yyyy)
  
   rc_winter = regline(yyyy, sea_winter)
   p_winter  = trend_manken(sea_winter, False, 0)

   rc_summer = regline(yyyy, sea_summer)
   p_summer  = trend_manken(sea_summer, False, 0)

;-----------------------------------------------------
; Store for plotting
;-----------------------------------------------------

   dplt_winter      = new ( (/3,nyrs/), typeof(sea_winter), sea_winter@_FillValue)
   dplt_winter(0,:) = sea_winter
   dplt_winter(1,:) = rc_winter*(yyyy-rc_winter@xave)   + rc_winter@yave
   dplt_winter(2,:) = p_winter(1)*(yyyy-rc_winter@xave) + rc_winter@yave
   delete(dplt_winter@long_name)                              ; not wanted

   dplt_summer      = new ( (/3,nyrs/), typeof(sea_summer), sea_summer@_FillValue)
   dplt_summer(0,:) = sea_summer
   dplt_summer(1,:) = rc_summer*(yyyy-rc_summer@xave)   + rc_summer@yave
   dplt_summer(2,:) = p_summer(1)*(yyyy-rc_summer@xave) + rc_summer@yave
   delete(dplt_summer@long_name)                              ; not wanted

;-----------------------------------------------------
; plot resources
;-----------------------------------------------------
  plot = new ( 2, "graphic")

  wks  = gsn_open_wks("png","manken")              ; send graphics to PNG file
 
  res                     = True                   ; plot mods desired
  res@gsnDraw             = False                  ; don't draw yet      
  res@gsnFrame            = False                  ; don't advance frame yet      

  res@xyDashPatterns      = 0                      ; solid line 
  res@xyLineColors        = (/"black", "red", "blue"/) 
  res@xyLineThicknesses   = (/1,3,1/)                

  res@vpHeightF           = 0.4                    ; change aspect ratio of plot
  res@vpWidthF            = 0.8                  
  res@vpXF                = 0.1                    ; start plot at x ndc coord 

  res@trXMinF             = yyStrt   
  res@trXMaxF             = yyLast
 ;res@trYMinF             = -0.6      
 ;res@trYMaxF             =  0.6
 ;res@gsnYRefLine         =  0.0

  txres                   =  True
  txres@txFontHeightF     =  0.02
  txres@txJust            = "CenterLeft"
  txres@txFontThicknessF  =  2.0      ; default=1.00
  txres@txFontHeightF     =  0.025    ; default=0.05

  res@gsnCenterString     = "Winter: NDJFM"
  plot(0) = gsn_csm_xy (wks,yyyy,dplt_winter,res)           ; create plot
  text    = "p="+sprintf("%5.3f",p_winter(0))+"  trend="+sprintf("%5.3f",p_winter(1))+" km^2/year"
  txt_winter = gsn_add_text(wks,plot(0),text, 1985, 44.3,txres)

  res@gsnCenterString     = "Summer: MJJAS"
  plot(1) = gsn_csm_xy (wks,yyyy,dplt_summer,res)           ; create plot
  text    = "p="+sprintf("%5.3f",p_summer(0))+"  trend="+sprintf("%5.3f",p_summer(1))+" km^2/year"
  txt_summer = gsn_add_text(wks,plot(1),text, 1990, 10.0,txres)

;************************************************
; create panel
;************************************************
  resP = True
  resP@gsnMaximize = True
  resP@txString    = regstr+": Snow Cover Extent (km^2): Rutgers Snow Lab"
  gsn_panel(wks,plot,(/2,1/),resP)               ; now draw as one plot

