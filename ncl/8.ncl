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
    u1 = u0(ID,:,:)
    v1 = v0(ID,:,:)

    u2 = u0(ID2,:,:)
    v2 = v0(ID2,:,:)

    u_JJA = dim_avg_n_Wrap(month_to_season(u1, "JJA"),0)
    v_JJA = dim_avg_n_Wrap(month_to_season(v1, "JJA"),0)

    time := cd_calendar(u2&time,-5)
    ID_DJF = ind(time(:,1).eq.12.or.time(:,1).eq.1.and.time(:,1).eq.2)
    u_DJF = dim_avg_n_Wrap(u2(ID_DJF,:,:),0)
    v_DJF = dim_avg_n_Wrap(v2(ID_DJF,:,:),0)

    res = True

    res@vcGlyphStyle = "CurlyVector"


    res@mpMaxLatF = 75
    res@mpMinLatF = -15
    res@mpMaxLonF = 180
    res@mpMinLonF = 45

    res@vcLineArrowColor          ="blue"
    ; res@vcRefAnnoPerimOn 
    res@vcRefAnnoOn               =True
    res@vcRefAnnoBackgroundColor  ="white"
    res@vcRefAnnoFontHeightF      =0.015
    res@vcRefAnnoOrthogonalPosF   =-0.14
    res@vcRefAnnoParallelPosF     =1.
    res@vcRefAnnoPerimOn          =True
    res@vcRefAnnoArrowUseVecColor = False
    res@vcRefAnnoArrowLineColor   ="Black"
    res@vcRefAnnoSide             ="Bottom"
    res@vcRefAnnoString1On        =False ;参考箭头上方字符
    res@vcRefAnnoString2On        =True ;参考箭头下方字符

    ; res@gsnRightString =""
    
    res2 = res
    res@gsnLeftString ="JJA:Monthly mean wind "
    res2@gsnLeftString ="DJF:Monthly mean wind "
    res@vcRefMagnitudeF = 10
    res@vcRefLengthF = 0.05
    res@vcMinDistanceF = 0.025

    res2@vcRefMagnitudeF = 10
    res2@vcRefLengthF = 0.05
    res2@vcMinDistanceF = 0.025
    res@vcRefAnnoString2          ="10 m/s"
    res2@vcRefAnnoString2          ="10 m/s"

    wks=gsn_open_wks("x11", "name")
    plot=gsn_csm_vector_map(wks, u_JJA, v_JJA, res)
    plot2=gsn_csm_vector_map(wks, u_DJF, v_DJF, res2)





end