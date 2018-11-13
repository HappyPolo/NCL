;external Rnd "./read_t90.so"
;***********************************************************
; Concepts illustrated:
;   - Reading a CSV file using two different methods
;   - Using asciiread to read an ASCII file with delimiters
;   - Using str_split_csv to read an ASCII file with delimiters
;   - Reshaping a one-dimensional array
;   - Using Fortran procedure from ncl
;===============================================================
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
begin

;---Read the values in as 1D array of strings to get rows and columns.

    data1    =asciiread("/home/ys-ug/data/Station/tmean.csv", -1, "string")
    delim    = ","
    
    ncols    = dimsizes(str_split(data1(0),","))
    nrows    = dimsizes(data1)
    print("This file has " + nrows + " rows and " + ncols + " columns.")
    
    
    ;---Reread values as integers and reshape at the same time.
    ;data_2d = onedtond(data1, (/nrows,ncols/)) 
    ;rint(data_2d(:,2))
    id_in   = toint(str_get_field(data1,1,delim))
    lon_in  = tofloat(str_get_field(data1,2,delim))
    lat_in  = tofloat(str_get_field(data1,3,delim))
    h_in    = tofloat(str_get_field(data1,4,delim))
    t_in    = tofloat(str_get_field(data1,5,delim))
    time_in = str_get_field(data1,6,delim)
    yyyy_in = toint(str_get_field(time_in, 1, "/")) ; 这里从1开始计数)
    mm_in   = toint(str_get_field(time_in, 2, "/"))
    dd_in   = toint(str_get_field(time_in, 3, "/"))
    ;id_in  =new((/884962/), integer)
    stat_in =new((/338/), integer)
    ;t_in   =new((/884962/), float)
    ;h_in   =new((/884962/), float)
    ;Rnd::read_t(id_in,h_in,t_in)


;============================================================
;        time 
;============================================================
    hh      =dd_in
    mn      =dd_in
    sc      =dd_in
    hh      =0
    mn      =0
    sc      =0
    units   ="days after 0049-09-01 00:00:00"
    time    = cd_inv_calendar(yyyy_in, mm_in, dd_in, hh, mn, sc, units, 0)   
    time_st =new((/4748/), typeof(time))
    print(typeof(time))
    yyyy_st =toint(ispan(2005, 2017, 1))
    
    mm_st   = toint(ispan(1, 12, 1))
    ;n=new((/1/), "integer")
    n=0
    do i = 0, 12
        do j = 0, 11
            d_st = days_in_month(yyyy_st(i), mm_st(j))
            do k = 0, d_st-1
                dd_st      =toint(fspan(1,d_st,d_st))
                hh_st      =dd_st
                mn_st      =dd_st
                sc_st      =dd_st
                hh_st      =0
                mn_st      =0
                sc_st      =0
                time_st(n) =cd_inv_calendar(yyyy_st(i), mm_st(j), dd_st(k), hh_st(k), mn_st(k), sc_st(k), units, 0)
                delete([/dd_st,hh_st,mn_st,sc_st/])
                n          =n+1
            end do 
            delete(d_st)
        end do   
    end do 
    delete([/i,j,n/])

;============================================================
;             1d to 2d 
;============================================================
    sta = 0
    do i = 0,884960
        if (id_in(i) .ne. id_in(i+1)) then
            stat_in(sta) = id_in(i)
            sta          =sta+1
        end if
    end do 
    print(sta)
    stat_in(337) = id_in(884960)

    delete([/sta,i/])

    ns           = 0
    j            = 0
    t_2d       = new((/338,4748/), float)
    time_2d      = new((/338,4748/), double)
    h_2d         = new((/338,4748/), float)
    lon_2d       = new((/338,4748/), float)
    lat_2d       = new((/338,4748/), float)
    t_2d       = 9999
    time_2d      = 9999
    h_2d         = 9999
    lon_2d       = 9999
    lat_2d       = 9999
    t_out       = new((/338,4748/), float)
    h_out         = new((/338,4748/), float)
    lon_out       = new((/338,4748/), float)
    lat_out       = new((/338,4748/), float)
    t_out       = getFillValue(t_out)
    h_out         = getFillValue(t_out)
    lon_out       = getFillValue(t_out)
    lat_out       = getFillValue(t_out)
    ;do ns = 0, 285
    do i = 0, 884960
        if (id_in(i) .eq. id_in(i+1)) then
            t_2d(ns,j)  = t_in(i)
            time_2d(ns,j) = time(i)
            h_2d(ns,j)    = h_in(i)
            lat_2d(ns,j)  = lat_in(i)
            lon_2d(ns,j)  = lon_in(i)
            ns            = ns
            j             = j+1
        else 
            t_2d(ns,j) = t_in(i)
            ns           = ns + 1
            j            =0      
        end if     
    end do 
    delete([/i,ns,j/])
    ;print(t_in(0:10)+"    "+t_2d(0,0:10))
    do ns = 0, 337
        i = 0
        do nt =0, 4747
            if (time_st(nt) .eq. time_2d(ns,i)) then
                t_out(ns,nt) = t_2d(ns,i)
                h_out(ns,nt)   = h_2d(ns,i)
                lat_out(ns,nt) = lat_2d(ns,i)
                lon_out(ns,nt) = lon_2d(ns,i)
                i                = i + 1
            else 
                i = i
            end if
            ;if (time_2d(ns,i) .eq. )
        end do 
    end do 

;============================================================
;        wirte to netcdf 
;===========================================================
    t_out@_FillValue = 9999
    h_out@_FillValue = 9999
    lat_out@_FillValue = 9999
    lon_out@_FillValue = 9999
    t_out!0 = "station"
    t_out!1 = "time"
    time_out = time_st
    t_out&time = time_out
    t_out&station = stat_in
    stat_out = stat_in
    stat_out!0 = "station"
    stat_out&station =stat_in
    h_out!0 = "station"
    h_out&station = stat_in
    lat_out!0 = "station"
    lat_out&station = stat_in
    lon_out!0 = "station"
    lon_out&station = stat_in

    

    output="~/data/Station/"
    system("/bin/rm -f "+output+"t.daily.2005_2017.nc")
    ncdf = addfile(output+"t.daily.2005_2017.nc" ,"c")
    ncdf->t=t_out
    ncdf->sta=stat_out
    ncdf->lat=lat_out
    ncdf->lon=lon_out
;print("Lon "+lon_in(0:10)+"  "+"Lat "+lat_in(0:10)+"Station "+stat_in(0:10)\
;      +"h "+h_in(0:10)+"t "+t_in(0:10)+"yyyy "+yyyy_in(0:10))
print("=========================================")
print("===============  All Down  ==============")
print("=========================================")
print(num(ismissing(stat_in)))
end 
