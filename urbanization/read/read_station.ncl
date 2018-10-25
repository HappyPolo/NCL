load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
begin
    ;data1=asciiread("/mnt/f/data/ur/5sta.CSV", -1, "float")
    ;data2=asciiread("/mnt/f/data/ur/5wnd.CSV", -1, "float")
    dim_names=(/"time","stat"/)
    dim_sizes=(/20819,5/)
    dimUnlim =(/False,False/)
    ;system(cd /home/ys-ug/data/Station && rm *.nc)
    ncdf1       = addfile("/home/ys-ug/data/Station/5sta_daily_lc.nc","c")
    filedimdef(ncdf1,dim_names,dim_sizes,dimUnlim)
    ncdf2       = addfile("/home/ys-ug/data/Station/5sta_daily_tmax.nc","c")
    filedimdef(ncdf2,dim_names, dim_sizes, dimUnlim)
    ncdf3       = addfile("/home/ys-ug/data/Station/5sta_daily_tmin.nc","c")
    filedimdef(ncdf3,dim_names, dim_sizes, dimUnlim)
    ncdf4       = addfile("/home/ys-ug/data/Station/5sta_daily_wnd.nc","c")
    filedimdef(ncdf4,dim_names, dim_sizes, dimUnlim)
    delete([/dim_sizes/])
    dim_sizes=(/684,5/)
    ncdf5       = addfile("/home/ys-ug/data/Station/5sta_mon_lc.nc","c")
    filedimdef(ncdf1,dim_names,dim_sizes,dimUnlim)
    ncdf6       = addfile("/home/ys-ug/data/Station/5sta_mon_tmax.nc","c")
    filedimdef(ncdf2,dim_names, dim_sizes, dimUnlim)
    ncdf7       = addfile("/home/ys-ug/data/Station/5sta_mon_tmin.nc","c")
    filedimdef(ncdf3,dim_names, dim_sizes, dimUnlim)
    ncdf8       = addfile("/home/ys-ug/data/Station/5sta_mon_wnd.nc","c")
    filedimdef(ncdf4,dim_names, dim_sizes, dimUnlim)
    data1  = asciiread("/home/ys-ug/data/Station/station.TXT", -1, "float")
    data2  = asciiread("/home/ys-ug/data/Station/wnd.TXT", -1, "float")
    ncol   = 10
    mcol   = 10
    npts   = dimsizes(data1)/ncol
    mpts   = dimsizes(data2)/mcol
    data01 = onedtond(data1, (/npts,ncol/))
    data02 = onedtond(data2, (/mpts,mcol/))
    print(data1(0))
    printVarSummary(data1)
    ;f=(station,time,lc,tmax,tmin,wnd)
    f1 = new((/20819,5/), typeof(data01))
    f2 = new((/20819,5/), typeof(data01))
    f3 = new((/20819,5/), typeof(data01))
    f4 = new((/20819,5/), typeof(data02))
    f5 = new((/684,5/),typeof(data01))
    f6 = new((/684,5/),typeof(data01))
    f7 = new((/684,5/),typeof(data01))
    f8 = new((/684,5/),typeof(data01))
    f1@_FillValue = 99999
    f2@_FillValue = 99999
    f3@_FillValue = 99999
    f4@_FillValue = 99999

    i=0
    yrs=1961
    yre=2017
    do ms = 0,4
        t = 0
        do my = 0,56
            do mn = 0,11
            day=days_in_month(yrs+my,mn+1)
                do md = 0,day-1
                    f1(t,ms) = data01(i,5) ;lc
                    f2(t,ms) = data01(i,7) ;tmax 
                    f3(t,ms) = data01(i,8) ;tmin 
                    f4(t,ms) = data02(i,5) ;wnd
                    i = i + 1
                    t = t + 1
                end do 
            end do 
        end do 
    end do
    f1=where(f1.eq."nan", f1@_FillValue, f1)
    f2=where(f2.eq."nan", f2@_FillValue, f2)
    f3=where(f3.eq."nan", f3@_FillValue, f3)
    f4=where(f4.eq."nan", f4@_FillValue, f4)
    ;printVarSummary(f1)
    delete(mn)
    yyyy=toint(fspan(yrs, yre, 57))
    mm=toint(fspan(1,12,12))
    time=new((/20819/),"double")
    time2=new((/684/),"double")
    n=new((/1/), "integer")
    units="days after 0049-09-01 00:00:00"
    ;print(days_in_month(1960, 2))
    n=0
    do i=0,56
        do j=0,11
            d = days_in_month(yyyy(i), mm(j))
            do k = 0,d-1
                dd=toint(fspan(1,d,d))
                hh=dd
                mn=dd
                sc=dd
                hh=0
                mn=0
                sc=0
                time(n)=cd_inv_calendar(yyyy(i), mm(j), dd(k), hh(k), mn(k), sc(k), units, 0)
                delete([/dd,hh,mn,sc/])
                n=n+1
            end do 
            delete(d)
        end do   
    end do 
    printVarSummary(time)
    f1!1="stat"
    f1!0="time"
    f2!1="stat"
    f2!0="time"
    f3!1="stat"
    f3!0="time"
    f4!1="stat"
    f4!0="time"
    f5!1="stat"
    f5!0="time"
    f6!1="stat"
    f6!0="time"
    f7!1="stat"
    f7!0="time"
    f8!1="stat"
    f8!0="time"
    stat=(/59284,59285,59287,59294,59481/)
    stat@long_name="station_numeber"
    f1&stat=stat
    f2&stat=stat
    f3&stat=stat
    f4&stat=stat
    f1&time=time
    f2&time=time
    f3&time=time
    f4&time=time
    f5&stat=stat
    f6&stat=stat
    f7&stat=stat
    f8&stat=stat
    f5&time=time2
    f6&time=time2
    f7&time=time2
    f8&time=time2
    f1@long_name="low cloud"
    f2@long_name="daliy max temperature"
    f3@long_name="daily min temperature"
    f4@long_name="daily wind velocity"
    f1@units="0.1"
    f2@units="degC"
    f3@units="degC"
    f4@units="m/s"
    f5@long_name="monthly low cloud"
    f6@long_name="monthly max temperature"
    f7@long_name="monthly min temperature"
    f8@long_name="monthly wind velocity"
    f5@units="0.1"
    f6@units="degC"
    f7@units="degC"
    f8@units="m/s"
    ncdf1->f = f1
    ncdf2->f = f2
    ncdf3->f = f3
    ncdf4->f = f4
;====================== daily to month ======================================
    opt           = True
    opt@nval_crit = 12
    f5        = calculate_monthly_values(f1,"avg",0,opt)
    f6      = calculate_monthly_values(f2,"avg",0,opt)
    f7      = calculate_monthly_values(f3,"avg",0,opt)
    f8       = calculate_monthly_values(f4, "avg", 0, opt)
    delete(opt)

    ncdf5->f = f5
    ncdf6->f = f6
    ncdf7->f = f7
    ncdf8->f = f8


end 