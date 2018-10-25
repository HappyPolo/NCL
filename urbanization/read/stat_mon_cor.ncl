
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
begin
;====================== read ===============================================
    f1            = addfile("/home/ys-ug/data/Station/5sta_daily_lc.nc","r")
    f2            = addfile("/home/ys-ug/data/Station/5sta_daily_tmin.nc","r")
    f3            = addfile("/home/ys-ug/data/Station/5sta_daily_tmax.nc","r")
    f4            = addfile("/home/ys-ug/data/Station/5sta_daily_wnd.nc","r")
    lc            = f1->f
    tmin          = f2->f
    tmax          = f3->f
    wnd           = f4->f

;====================== daily to month ======================================
    opt           = True
    opt@nval_crit = 12
    lc_mon        = calculate_monthly_values(lc,"avg",0,opt)
    tmin_mon      = calculate_monthly_values(tmin,"avg",0,opt)
    tmax_mon      = calculate_monthly_values(tmax,"avg",0,opt)
    wnd_mon       = calculate_monthly_values(wnd, "avg", 0, opt)
    printVarSummary(wnd_mon)
    delete(opt)

;====================== month to annual ======================================
    opt      = 1
    lc_ann   = month_to_annual(lc_mon, opt)
    tmin_ann = month_to_annual(tmin_mon,opt)
    tmax_ann = month_to_annual(tmax_mon,opt)
    wnd_ann  = month_to_annual(wnd_mon, opt)

;====================== month to season ======================================
    ;lc_MAM=month_to_season(lc_mon, "MAM")
    lc_JJA=month_to_season(lc_mon, "JJA")
    lc_SON=month_to_season(lc_mon, "son")
    tmin_MAM=month_to_season(tmin_mon, "MAM")
    tmin_JJA=month_to_season(tmin_mon, "JJA")
    tmin_SON=month_to_season(tmin_mon, "son")
    tmax_MAM=month_to_season(tmax_mon, "MAM")
    tmax_JJA=month_to_season(tmax_mon, "JJA")
    tmax_SON=month_to_season(tmax_mon, "son")
    wnd_MAM=month_to_season(wnd_mon, "MAM")
    wnd_JJA=month_to_season(wnd_mon, "JJA")
    wnd_SON=month_to_season(wnd_mon, "son")
    lc_DJF=new((/57,5/), typeof(lc_mon))
    tmin_DJF=new((/57,5/), typeof(lc_mon))
    tmax_DJF=new((/57,5/), typeof(lc_mon))
    wnd_DJF=new((/57,5/), typeof(lc_mon))  
    do sta=0,4
        mm =0
        do yr =0 ,56
            mm               = yr*12+11
            lc_DJF(yr,sta)   = (lc_mon(mm)+lc_mon(mm+1)+lc_mon(mm+2))/3
            tmin_DJF(yr,sta) = (tmin_mon(mm)+tmin_mon(mm+1)+tmin_mon(mm+2))/3
            tmax_DJF(yr,sta) = (tmax_mon(mm)+tmax_mon(mm+1)+tmax_mon(mm+2))/3
            wnd_DJF(yr,sta)  = (wnd_mon(mm)+wnd_mon(mm+1)+wnd_mon(mm+2))/3
        end do 
    end do 
    copy_VarCoords(lc_mam, lc_DJF)
    copy_VarCoords(lc_mam, tmin_DJF)
    copy_VarCoords(lc_mam, tmax_DJF)
    copy_VarCoords(lc_mam, wnd_DJF)
end 
