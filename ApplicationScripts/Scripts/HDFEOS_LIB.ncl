;========================================================
;    Collection of HIR* Statistics and Graphical Functions
;========================================================

; 
;*******************************************************
; Plot 1 time series with grid outline
;*******************************************************
undef("TimeSeries_y1")
function TimeSeries_y1(wks[1]:graphic \
                      ,time[*]:numeric,  yL[*]:numeric, resLeft[1]:logical )
local resL
begin

; left (L) variable 
  resL           = True 

  resL@vpXF                 = 0.10 
  resL@vpWidthF             = 0.65            ; Set width and height of plot.
  resL@vpHeightF            = 0.35

  resL@xyLineColor          = "Foreground"   ; To distinguish the lines
  resL@xyLineThicknesses    = 2.      ; thicker line

; tickmarks:
  resL@tmXTOn               = False   ; Turn off top tickmarks

  resL@tmYLMinorOn          = False   ; Turn off left minor tickmarks

  resL@tmXBLabelFontHeightF = 0.01

  resL@tmXMajorGrid                = True
  resL@tmYMajorGrid                = True
  resL@tmXMajorGridThicknessF      = 1.0
  resL@tmYMajorGridThicknessF      = 1.0
  resL@tmXMajorGridLineDashPattern = 2
  resL@tmYMajorGridLineDashPattern = 2

  if (isatt(yL,"long_name")) then
      resL@tiYAxisString  = yL@long_name
  else
      if (isatt(yL,"hdfeos5_name")) then
          resL@tiYAxisString  = yL@hdfeos5_name
      end if
  end if

  mnmxint  = nice_mnmxintvl( min(time), max(time), 20, False)
  resL@trXMinF  = mnmxint(0)
  resL@trXMaxF  = mnmxint(1)
                                          ; user over-ride
  resL@tiYAxisFontColor         = resL@xyLineColor
  resL@tiYAxisFontHeightF       = 0.015

  if (resLeft) then
      copy_VarAtts(resLeft, resL)
  end if

; Create the plot with the three variables and three different axes.

  plot = gsn_csm_xy(wks,time,yL,resL)
  return(plot)
end

;****************************************************
; Plot three time series on the same plot
;****************************************************

undef("TimeSeries_y3")
function TimeSeries_y3(wks[1]:graphic \
                      ,time[*]:numeric,  yL[*]:numeric \
                      ,  yR[*]:numeric, yR2[*]:numeric \
                      , resLeft[1]:logical \
                      , resRight[1]:logical, resRight2[1]:logical)
local resL, resR, resR2
begin

; left (L) variable 
  resL           = True 

  resL@vpXF                 = 0.10 
  resL@vpWidthF             = 0.65            ; Set width and height of plot.
  resL@vpHeightF            = 0.35

  resL@xyLineColor          = "Foreground"   ; To distinguish the lines
  resL@xyLineThicknesses    = 2.      ; thicker line

; tickmarks:
  resL@tmXTOn               = False   ; Turn off top tickmarks

  resL@tmYLMinorOn          = False   ; Turn off left minor tickmarks

  resL@tmXBLabelFontHeightF = 0.01

  resL@tmXMajorGrid                = True
  resL@tmYMajorGrid                = True
  resL@tmXMajorGridThicknessF      = 1.0
  resL@tmYMajorGridThicknessF      = 1.0
  resL@tmXMajorGridLineDashPattern = 2
  resL@tmYMajorGridLineDashPattern = 2

  if (isatt(yL,"long_name")) then
      resL@tiYAxisString  = yL@long_name
  else
      if (isatt(yL,"hdfeos5_name")) then
          resL@tiYAxisString  = yL@hdfeos5_name
      end if
  end if

  mnmxint  = nice_mnmxintvl( min(time), max(time), 20, False)
  resL@trXMinF  = mnmxint(0)
  resL@trXMaxF  = mnmxint(1)
                                          ; user over-ride
  resL@tiYAxisFontColor         = resL@xyLineColor
  resL@tiYAxisFontHeightF       = 0.015

; right variable (yR)
  resR                          = True                      
  resR@xyLineColor              = "Blue"
  resR@xyDashPatterns           = 0                   ; solid/ dashed line for 2nd
  resR@xyLineThicknesses        = 1   

  resR@trXMinF                  = resL@trXMinF
  resR@trXMaxF                  = resL@trXMaxF

  resR@tiYAxisFontColor = resR@xyLineColor
  if (isatt(yR,"long_name")) then
      resR@tiYAxisString = yR@long_name
  else
      if (isatt(yR,"hdfeos5_name")) then
          resR@tiYAxisString   = yR@hdfeos5_name
      end if
  end if
  resR@tiYAxisFontColor        = resR@xyLineColor
  resL@tiYAxisFontHeightF      = resL@tiYAxisFontHeightF

  resR@tmYRMinorOn             = False   ; Turn off right minor tickmarks

; third variable (Right2)
  resR2                        = True
  if (isatt(yR2,"long_name")) then
      resR2@tiYAxisString = yR2@long_name
  else
      if (isatt(yR2,"hdfeos5_name")) then
          resR2@tiYAxisString  = yR2@hdfeos5_name
      end if
  end if

  resR2@trXMinF                = resL@trXMinF
  resR2@trXMaxF                = resL@trXMaxF

  resR2@xyDashPatterns         = 0
  resR2@xyLineThicknesses      = 1  
  resR2@xyLineColor            = "Green"

  resR2@tiYAxisFontColor       = resR2@xyLineColor
  resR2@tmYRMinorOn            = False   ; Turn off right minor tickmarks
  resR2@amOrthogonalPosF       = 0.65    ; Move "l" axis to right a little

  if (resLeft) then
      copy_VarAtts(resLeft, resL)
  end if
  if (resRight) then
      copy_VarAtts(resRight, resR)
  end if
  if (resRight2) then
      copy_VarAtts(resRight2, resR2)
  end if

; Create the plot with the three variables and three different axes.
;
  plot = gsn_csm_xy3(wks,time,yL,yR,yR2,resL,resR,resR2)
  return(plot)
end
;***********************************************************
; Plot "Q" as a function of "time" and a 2-D vertical coordinate 
; The input is expected to be (level,time).
; This may require that the data be reordered
; EG 
; plt = HIR_contour_2D2D(wks, telapse \
;                       ,A(nLevels_HIRDLS|:,nTimes_HIRDLS|:) \
;                       ,T(nLevels_HIRDLS|:,nTimes_HIRDLS|:) \
;                       ,res_cn)
;***********************************************************
function HIR_contour_2D2D (wks, time[*]:numeric \
                          ,ALT[*][*]:numeric, Q[*][*]:numeric, res[1]:logical)
local resLocal, plot
begin
      resLocal                  = True
      resLocal@sfXArray         = conform(Q, time, 1)
      resLocal@sfYArray         = ALT  

      resLocal@trGridType       = "TriangularMesh"  
      resLocal@cnFillMode       = "RasterFill"       ; Raster Mode
      resLocal@cnRasterSmoothingOn = True

      resLocal@cnFillOn         = True
      resLocal@cnLinesOn        = False
      resLocal@cnLineLabelsOn   = False
      resLocal@gsnSpreadColors  = True
      resLocal@lbLabelAutoStride= True

      if (.not.isatt(Q,"long_name") .and. isatt(Q,"hdfeos5_name")) then
          resLocal@gsnLeftString = Q@hdfeos5_name
      end if

      if (res) then
          copy_VarAtts(res, resLocal)
          if (isatt(res,"tiXAxisString")) then
              resLocal@pmLabelBarHeightF= 0.10       ; slightly smaller than default
              resLocal@pmLabelBarOrthogonalPosF =  0.075
      ;        resLocal@tiXAxisOffsetYF  = 0.15 
          end if
      end if

      plot  = gsn_csm_contour (wks, Q, resLocal) 
      return(plot)
end

;****************************************************
; Contour Difference
;****************************************************
; EG
; HIR_contour_diff(wks, telapse1, T1, fil1 \
;                     , telapse2, T2, fil2,  res, resDiff)
;****************************************************

undef("HIR_contour_diff")
procedure HIR_contour_diff(wks, time1[*]:numeric, Q1[*][*]:numeric, fil1[1]:string
                            , time2[*]:numeric, Q2[*][*]:numeric, fil2[1]:string
                            , resQ[1]:logical, resDiff[1]:logical)
; create a 3 panel plot
local plot, diffQ, optStat, Q_stat, dNam, resLoc, presLoc1, presLoc2, plt2
begin
    plot  = new (2, "graphic")

    diffQ = Q1
    diffQ = Q1-Q2
    diffQ = smth9(diffQ, 0.50, 0.25, False) ; local smoother
    diffQ@long_name = "Difference"
   ;printVarSummary(diffQ)
   ;printMinMax(diffQ, True)
   ;print(Q1+"   "+Q2+"   "+diffQ)

    if (resQ .and. isatt(resQ,"PrintStat") .and. resQ@PrintStat) then
       optStat = True
       optStat@PrintStat = True
       Q_stat = dispersion_stat(diffQ, optStat)
       print("==============")
    end if

    dNam = getvardims(Q1)      ; get dimension names

;****************************************************
; Plot 3 time series plots on one frame. 
; The 3rd plot will be the difference plot
;****************************************************
    resLoc                  = True          
    resLoc@gsnDraw          = False            ; don't draw yet
    resLoc@gsnFrame         = False            ; don't advance frame yet
  
    resLoc@cnFillOn         = True
    resLoc@cnLinesOn        = False
    resLoc@cnLineLabelsOn   = False

    resLoc@cnFillMode       = "RasterFill"     ; faster
    resLoc@cnRasterSmoothingOn  = True
    resLoc@cnInfoLabelOn    = False            ; turn off cn info label

    resLoc@gsnSpreadColors  = True
    resLoc@lbLabelBarOn     = False         ; turn off individual label bars

    resLoc@gsnLeftString    = fil1
    resLoc@tiYAxisString    = "Level Index"     
    resLoc@tiXAxisString    = time1@long_name

    copy_VarAtts(resQ, resLoc)

    plot(0)  = gsn_csm_contour (wks, Q1($dNam(1)$|:,$dNam(0)$|:), resLoc)
  ;;plot(0)  = gsn_csm_contour (wks, Q1(nLevels_HIRDLS|:,nTimes_HIRDLS|:), resLoc)

    resLoc@gsnLeftString    = fil2
    resLoc@tiXAxisString    = time2@long_name
    plot(1)  = gsn_csm_contour (wks, Q2($dNam(1)$|:,$dNam(0)$|:), resLoc)
  ;;plot(1)  = gsn_csm_contour (wks, Q2(nLevels_HIRDLS|:,nTimes_HIRDLS|:), resLoc) 

    delete(resLoc@gsnLeftString)   ; no longer needed

;***************************************
; panel first two plots
; Use PanelBottom to tell the plot to only draw in the top part of the page.
; Since there are two plots here, and we have limited the plot to the upper
; 0.6 of the page, each plot will have a size 0.3.
;***************************************
    presLoc1                     = True
    presLoc1@txString            = Q1@long_name
    presLoc1@gsnPanelLabelBar    = True       ; common label bar
    presLoc1@gsnFrame            = False      ; don't advance frame yet
    presLoc1@lbOrientation       = "vertical" ; vertical label bar
    presLoc1@lbLabelAutoStride   = True       ; nice label bar labels
    presLoc1@gsnPanelBottom      = 0.5        ; move bottom up from 0.0 to 0.4
    gsn_panel(wks,plot,(/1,2/),presLoc1)

;***************************************
; Create third plot [difference]
; If present, delete the ManualLevel stuff
; Not appropriate for "Qdiff"
;***************************************
                    ; if present, remove limits from full contour
    if (isatt(resLoc,"cnLevelSelectionMode")) then
        delete(resLoc@cnLevelSelectionMode)
    end if
    if (isatt(resLoc,"cnMinLevelValF")) then
        delete(resLoc@cnMinLevelValF)
    end if
    if (isatt(resLoc,"cnMaxLevelValF")) then
        delete(resLoc@cnMaxLevelValF)
    end if
    if (isatt(resLoc,"cnLevelSpacingF")) then
        delete(resLoc@cnLevelSpacingF)
    end if
                    ; add new limits for Qdiff, if present
    if (resDiff .and. isatt(resDiff,"cnLevelSelectionMode")) then
        resLoc@cnLevelSelectionMode = resDiff@cnLevelSelectionMode

        if (isatt(resDiff,"cnMinLevelValF")) then
            resLoc@cnMinLevelValF = resDiff@cnMinLevelValF 
        end if
        if (isatt(resDiff,"cnMaxLevelValF")) then
            resLoc@cnMaxLevelValF = resDiff@cnMaxLevelValF 
        end if
    end if
    if (resDiff .and. isatt(resDiff,"cnLevelSpacingF")) then
            resLoc@cnLevelSpacingF  = resDiff@cnLevelSpacingF  
    end if

    plt2 = gsn_csm_contour(wks,diffQ($dNam(1)$|:,$dNam(0)$|:),resLoc)
  ;;plt2 = gsn_csm_contour(wks,diffQ(nLevels_HIRDLS|:,nTimes_HIRDLS|:),resLoc)

;***************************************
; create panel of just third plot to keep aspect ratio
; the same as the panel above
;***************************************
    presLoc2                     = True
    presLoc2@gsnPanelLabelBar    = True       ; common label bar
    presLoc2@gsnPanelTop         = 0.5        ; draw up to bdry of upper plot
    presLoc2@gsnFrame            = False      ; don't advance frame yet
    presLoc2@lbOrientation       = "vertical" ; vertical label bar
    presLoc2@lbLabelAutoStride   = True       ; nice label bar labels
    gsn_panel(wks,plt2,(/1,1/),presLoc2)
    frame(wks)
end
