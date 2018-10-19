
begin

latstr = -10
latend = 70
lonstr = 10
lonend = 150
yrStrt = 1979
yrLast = 2016
Year   = ispan(yrStrt, yrLast, 1)
ny     = dimsizes(Year)

;===================================================
; read data
;===================================================
 diri1 = "~/data-observation/ERA-interim/monthly/"
 uname = "uwnd.mon.mean.nc"
 vname = "vwnd.mon.mean.nc"

 diri2 = "~/wuyt/data/ERAI/"
 tname = "T2m.mon.mean.7916.r1.nc"
 fu = addfile(diri1+uname, "r")
 fv = addfile(diri1+vname, "r")
 ft = addfile(diri2+tname, "r")

 TIME = fu->time
 YYYYMM = cd_calendar(TIME, -1)/100
 iYYYY  = ind(YYYYMM.ge.yrStrt .and. YYYYMM.le.yrLast)

 u1 = short2flt(fu->u(iYYYY,:,{latstr:latend},{lonstr:lonend}))
 v1 = short2flt(fv->v(iYYYY,:,{latstr:latend},{lonstr:lonend}))
 t1 = short2flt(ft->t2m(iYYYY,{latstr:latend},{lonstr:lonend}))
 u  = month_to_annual(u1, 1)
 v  = month_to_annual(v1, 1)
 t  = month_to_annual(t1, 1)
 u&year = Year
 v&year = Year
 t&year = Year
 printVarSummary(u)
 printVarSummary(v)
 printVarSummary(t)
 nlat = dimsizes(u1&latitude)
 nlon = dimsizes(u1&longitude)

;========================================================
; calc regression surfT on uv
;========================================================
 t_tp = dim_avg_n_Wrap(t(:,{25:40},{75:105}), (/1,2/))
 
 rcu850 = regCoef_n(t_tp, u(:,{850},:,:), 0, 0)  
 rcv850 = regCoef_n(t_tp, v(:,{850},:,:), 0, 0)  
 copy_VarMeta(u(0,0,:,:), rcu850)
 copy_VarMeta(u(0,0,:,:), rcv850)
 printVarSummary(rcu850)

 ; test
 ccu850 = escorc_n(t_tp, u(:,{850},:,:), 0, 0)   
 ccv850 = escorc_n(t_tp, v(:,{850},:,:), 0, 0)   
 probu  = ccu850
 probv  = ccv850
 probu  = rtest(ccu850, ny, 0)   ; ny = dimsizes(Year)
 probv  = rtest(ccv850, ny, 0)
 copy_VarMeta(rcu850, probu)
 copy_VarMeta(rcv850, probv)
 printVarSummary(probu)
 prob = probu
 do i = 0,nlat-1
    do j = 0,nlon-1
        if (abs(probu(i,j)).le.0.05 .or. abs(probv(i,j)).le.0.05) then
            prob(i,j) = 1.0
        else
            prob(i,j) = 2.0
        end if
    end do
 end do




;=============================================================
; plot
;=============================================================
 wks = gsn_open_wks("x11", "reg_ann_timeseries_surfT_uv850")
 gsn_define_colormap(wks, "MPL_autumn")

 nplot = 1
 plot = new(nplot, graphic)
 plot_prob = plot
 plot_topo = plot

;*****************************************************
; this is for outline of TP
;*****************************************************

 f0 = "~/wuyt/data/TOPO_1500.nc"
 topo_in = addfile(f0,"r")
 topo = topo_in ->TP

 mlat = topo_in->LATIXY(:,0)
 mlon = topo_in->LONGXY(0,:)
 topo!0 = "lsmlat"
 topo!1 = "lsmlon"
 topo&lsmlat = mlat
 topo&lsmlon = mlon

 ;----------------------
 res_topo            = True
 res_topo@cnFillOn   = False
 res_topo@cnLinesOn  = True
 res_topo@gsnFrame   = False
 res_topo@gsnDraw    = False
 res_topo@cnLineLabelsOn         = False
 res_topo@cnLineThicknessF       = 5
 res_topo@cnLineColor            = "black"
 res_topo@cnInfoLabelOn          = False
 res_topo@cnLevelSelectionMode   ="ExplicitLevels"
 res_topo@cnLevels               = (/1500/)
;**************************************************************

 ;vcres                     = True      ; plot mods desired
 ;vcres@lbLabelStride       = 2         ; plot every other colar bar label
 ;vcres@vcRefMagnitudeF         = 2.0              ; make vectors larger
 ;vcres@vcRefLengthF            = 0.050            ; ref vec length
 ;vcres@vcGlyphStyle            = "CurlyVector"    ; turn on curly vectors
 ;vcres@vcMinDistanceF          = 0.017            ; thin out vectors

 resv1                  = True            ; vector only resources
 resv1@gsnDraw          = False           ; don't draw
 resv1@gsnFrame         = False           ; don't advance frame
 resv1@gsnAddCyclic     = False
 resv1@vcGlyphStyle     = "LineArrow"   ; curly vectors"Fillarrow"
 resv1@vcRefMagnitudeF  = 0.5             ; define vector ref mag
 resv1@vcRefLengthF     = 0.04            ; define length of vec ref
 resv1@vcMinDistanceF   = 0.03
 resv1@vcLineArrowThicknessF = 2.5
 ;resv1@vcRefAnnoFontHeightF = 0.012
 resv1@tiXAxisString    = " "             ; turn off axis label
 resv1@vcRefAnnoOn      = True            ; draw the reference vector annotation.
 resv1@vcRefAnnoString2On =  False          ;display a string below or to the right
 resv1@vcRefAnnoOrientation = "horizontal"
 resv1@vcRefAnnoString1  = " 0.5 "
 resv1@vcRefAnnoString2  = " "
 resv1@vcRefAnnoOrthogonalPosF = -0.13    ; move ref vector into plot
 resv1@vcFillArrowsOn       = True
 resv1@vcLineArrowHeadMinSizeF = 0.01
 resv1@vcLineArrowHeadMaxSizeF = 0.018
 ;resv1@vcLineArrowColor = "green" 
 resv1@gsnLeftString  = "Annual"
 resv1@gsnRightString  = ""
 resv1@gsnSpreadColors     = True
 resv1@gsnSpreadColorEnd   = 18
 resv1@gsnSpreadColorStart = 1
 resv1@lbLabelBarOn        = False

 resv1@mpOutlineOn = True
 resv1@mpFillOn    = True
 resv1@mpMinLonF   = lonstr
 resv1@mpMaxLonF   = lonend
 resv1@mpMinLatF   = latstr
 resv1@mpMaxLatF   = latend
 
 plot(0) = gsn_csm_vector_scalar_map_ce(wks,rcu850,rcv850,prob,resv1)  ; create plot
 plot_topo(0) = gsn_csm_contour(wks, topo, res_topo)
 overlay(plot(0), plot_topo(0))

 draw(plot)
 frame(wks)
;pres = True
;pres@gsnMaximize = True
;gsn_panel(wks, plot, (/2,2/), pres)

end 