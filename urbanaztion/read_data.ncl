load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
begin

system("rm /mnt/f/data/ur/dataset/*.nc")
    data01=asciiread("/mnt/f/data/ur/dataset/Tm_adj_final.txt", -1, "float")
    data02=asciiread("/mnt/f/data/ur/dataset/Tmin_adj_final.txt", -1, "float")
    data03=asciiread("/mnt/f/data/ur/dataset/Tmax_adj_final.txt", -1, "float")
    data04=asciiread("/mnt/f/data/ur/dataset/station_information.txt", -1, "float")

    ncdf  = addfile("/mnt/f/data/ur/dataset/Tmin_adj_final.nc","c")
    npts = 20820
    ncol = dimsizes(data01)/npts
    data1 = onedtond(data01, (/npts,ncol/)) ;762个站点，每个点20820个数据
    data2 = onedtond(data02, (/npts,ncol/))
    data3 = onedtond(data03, (/npts,ncol/))
    data4 = onedtond(data04, (/762,5/)) ; "No" "station" "No." "Lat." "Long."
    Tmin = new((/20820,762,762/), typeof(data01))
    ;Tmin =new((/20820,762/),float)
    i=0
    yrs=1960
    yre=2016
    do ms = 0,761
        t = 0
        do my = 0,56
            do mn = 0,11
            day=days_in_month(yrs+my,mn+1)
                do md = 0,day-1
                    Tmin(t,ms,ms,ms) = data1(t,ms) ;lc
                    i = i + 1
                    t = t + 1
                end do 
            end do 
        end do 
    end do
    delete([/ms,t,my,mn,day,md/])
    yyyy=toint(fspan(yrs, yre, 57))
    mm=toint(fspan(1,12,12))
    time=new((/20820/),"double")
    n=new((/1/), "integer")
    units="days after 0049-09-01 00:00:00"
    print(days_in_month(1960, 2))
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
    Tmin!0="time"
    ;Tmin!1="stat"
    Tmin!1="lat"
    Tmin!2="lon"
    ;stat=new((/762/), integer)
    lat=new((/762/), float)
    lon=new((/762/), float)
    do i = 0, 761
        ;stat(i)=toint(data4(i,1))  
        lat(i)=data4(i,3)
        lon(i)=data4(i,4)
    end do 
    lat@units      = "degrees_north"
    lon@units      = "degrees-east"
    Tmin&time=time
    ;Tmin&stat=stat
    Tmin&lat=lat
    Tmin&lon=lon

    ncdf->Tmin =Tmin


end
