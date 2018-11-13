load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
begin
;============= 1 ============================
    yr = ispan(1800, 2016, 4)
;============= 2 ============================
    per = fspan(0, 100, 30)
;============= 3 ============================
    lat = fspan(0, 90, 37)
;============= 4 ============================
    a = new((/300/), float)
    b = new((/600/), integer)
    c = new((/900/), string)
;============= 5 ============================
    y = 60.d
    pi = get_pi(1.d)
    y = cos(y*pi/180)
;============= 6 ============================
    yy = tostring(yr)+"0229"
;============= 7 ============================
    year = (/2000, 2001, 2005, 2009, 2011/)
    month = (/1, 11, 2, 3, 12/)
    day = (/3, 7, 6, 10, 20/)
    yyyymmdd = sprinti("%4i", year)+sprinti("%02i", month)+sprinti("%02i", day)
    print(yyyymmdd)
;============= 8 ============================
    delete(lat)
    lat = fspan(30, 60, 13)
    lat!0 = "latitude"
    lat@units = "degrees_north"
;============= 9 ============================
    lon = ispan(70, 150, 10)
    lon!0 = "longitude"
    lon@units = "degrees_east"
    printVarSummary(lon)
;============= 10 ============================
    pressure = (/1000, 925, 850, 700, 600, 500, 400, 300, 200, 100/)
    pressure!0 = "level" 
    pressure@units = "hPa" 



end 