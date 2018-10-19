load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
begin
    yrs=1961
    yre=2017
    yyyy=toint(fspan(yrs, yre, 57))
    yyyy@_FillValue=999999
    mm=toint(fspan(1,12,12))
    mm@_FillValue=999999
    time=new((/20819/),"double")
    time@_FillValue=999999
    n=new((/1/), "integer")
    n@_FillValue=999999
    time@_FillValue=999999
    units="days after 0049-09-01 00:00:00"
    ;print(days_in_month(1960, 2))
    n=0
    do i=0,56
        i@_FillValue=999999
        do j=0,11
            j@_FillValue=999999
            d = days_in_month(yyyy(i), mm(j))
            d@_FillValue=999999
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
    print(n)
    printVarSummary(time)

end 