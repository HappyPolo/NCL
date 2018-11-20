load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
begin

    lon = fspan(-180, 180, 145)
    lon1 = ind(lon.gt.120.and.lon.lt.150)
    lon2 = ind(lon.lt.-150.and.lon.gt.150)
    lon3 = get1Dindex_Exclude(lon, (/0,90,180/))

    year = ispan(1950, 2018, 1)
    yearWant = (/1982,1997,2016/)
    exc = get1Dindex_Exclude(year, yearWant)

    time = yyyymm_time(2001, 2018, "integer")
    t1 = ind(time.le.200508.and.time.ge.200506)
    t2 = get1Dindex_Exclude(time, (/200401,200802,201212/))

    time = yyyymm_time(2001, 2009, "integer")
    lat = latGlobeF(181, "lat", "latitude", "degreess_north")
    lon = lonGlobeF(360, "lon", "longitude", "degreess_east")
    slp = new((/dimsizes(time),dimsizes(lat),dimsizes(lon)/), float)
    slp!0 = getVarDimNames(time)
    slp!1 = getVarDimNames(lat)
    slp!2 = getVarDimNames(lon)
    slp&time = time
    slp&lat = lat
    slp&lon = lon 
    slp@units = "Pa"

    year = ispan(2001, 2009, 1)
    month = ispan(1, 12, 1)
    slp2 = reshape(slp, (/dimsizes(year),dimsizes(month),dimsizes(lat),dimsizes(lon)/))
    slp2!0 = year
    slp2!1 = month 
    slp2&year = year
    slp2&month = month

    weight = new((/dimsizes(lat),dimsizes(lon)/), float)
    weight2 =conform_dims(dimsizes(slp), weight, (/1,2/))
    slpW = slp*weight2
    copy_VarCoords(slp, slpW)

    wind = (/45, 65, 80, 90, 115, 100, 80, 100, 120, 150, 165, 180, 195, 120, 70, 55, 65, 90/)
    intensity = new(18, string)
    n = num(wind..lt.149.and.wind.gt.118)


    rainfall = (/2.5, 3.4, 0.4, 1.5, 0.1, -999., 1.2, -999., -999., 1.8, 13.5, 50., 70., 5., 0.5/)
    rainfall@_FillValue = -999.
    nData = dimsizes(rainfall)
    do i = 0, nData
        if (rainfall.lt.1.) then
            rainfall(i) = rainfall@_FillValue
        end if
    end do
    
    rainfall = where(crainfall.lt.1., rainfall@_FillValue, rainfall)







end