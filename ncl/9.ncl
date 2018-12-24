#! ~/.ncl/bin/ ncl
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
begin

    fu =addfile("/mnt/e/data/ncl/uwnd.week15.nc", "r")
    fv =addfile("/mnt/e/data/ncl/vwnd.week15.nc", "r")
    u0 = short2flt(fu->uwnd(:,{850},:,:))
    v0 = short2flt(fv->vwnd(:,{850},:,:))

    time = cd_calendar(u0&time, -5)
    ID = ind(time(:,0).ge.1980.and.time(:,0).le.2009)
    ID2 = ind(time(:,0).ge.1980.and.time(:,0).le.2010)
    ; u1 = u0(ID,:,:)
    ; v1 = v0(ID,:,:)

    u2 = u0(ID2,:,:)
    v2 = v0(ID2,:,:)

    ; u_JJA = dim_avg_n_Wrap(month_to_season(u1, "JJA"),0)
    ; v_JJA = dim_avg_n_Wrap(month_to_season(v1, "JJA"),0)

    time := cd_calendar(u2&time,-5)
    ID_DJF = ind(time(:,1).eq.12.or.time(:,1).eq.1.and.time(:,1).eq.2)
    u_DJF = dim_avg_n_Wrap(u2(ID_DJF,:,:),0)
    v_DJF = dim_avg_n_Wrap(v2(ID_DJF,:,:),0)

    res = True 
    res@gsnDraw =False
    res@gsnFrame =False

    res@wkOrientation ="landscape"
    res@gsnMaximize = True

    res@mpMaxLatF = 75
    res@mpMinLatF = 0
    res@mpMinLonF = 0
    res@mpMaxLonF = 240
    res@mpCenterLonF = 120

    res@cnLevelSelectionMode = "ManualLevels"
    res@cnMaxLevelValF = 14
    res@cnMinLevelValF = -14
    res@cnLevelCount = 2

    res@cnLinesOn = False
    res@cnFillOn = True
    res@cnInfoLabelOn = False
    res@gsnLeftString ="DJF:Monthly mean wind "

    resv = True
    resv@gsnDraw = False
    resv@gsnFrame =False

    resv@vcGlyphStyle = "CurlyVector"
    resv@vcLineArrowThicknessF     =1.5


    resv@gsnLeftString =""
    resv@gsnRightString = ""

    resv@vcLineArrowColor          ="black"
    ; resv@vcRefAnnoPerimOn 
    resv@vcRefAnnoOn               =True
    resv@vcRefAnnoBackgroundColor  ="white"
    resv@vcRefAnnoFontHeightF      =0.005
    resv@vcRefAnnoOrthogonalPosF   =-0.46
    resv@vcRefAnnoParallelPosF     =1.
    resv@vcRefAnnoPerimOn          =True
    resv@vcRefAnnoArrowUseVecColor = False
    resv@vcRefAnnoArrowLineColor   ="Black"
    resv@vcRefAnnoSide             ="Bottom"
    resv@vcRefAnnoString1On        =False ;参考箭头上方字符
    resv@vcRefAnnoString2On        =True ;参考箭头下方字符

    ; resv@gsnRightString =""
    

    resv@vcRefMagnitudeF = 10
    resv@vcRefLengthF = 0.04
    resv@vcMinDistanceF = 0.016


    resv@vcRefAnnoString2          ="10 m/s"


    wks = gsn_open_wks("x11", "name")
    gsn_define_colormap(wks, "cmp_b2r")
    base = gsn_csm_contour_map_ce(wks, u_DJF, res)
    plot = gsn_csm_vector(wks, u_DJF, v_DJF, resv)
    overlay(base, plot)
    draw(base)
    frame(wks)


end 
