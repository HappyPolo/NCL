load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
begin
;==============  1  =============================================================
    f = asciiread("/mnt/e/scripts/ncl/ncl/week14/air_59082_201101.txt", (/31,13/), "integer")
    tmin = f(:,9)
    tmin_avg = dim_avg(tmin(10:19))
    print(tmin)
;==============  2  =============================================================
        f2 =readAsciiTable("/mnt/e/scripts/ncl/ncl/week14/data_59287.txt", 12 , "float", (/0,1/))
        slp = f2(:,7)
        yyyy = f2(:,2)
        mm = f2(:,3)
        dd = f2(:,4)
        ; yyyymmdd = sprinti("%4i",toint(yyyy))+sprinti("0%2i",toint(mm))+sprinti("%02i",toint(dd))
            yyyymmdd = sprinti("%4i", toint(yyyy))+sprinti("%02i", toint(mm))+sprinti("%02i", toint(dd))
        time = ispan(20160201, 20160207, 1)
        print(time)
        id = get1Dindex(yyyymmdd, tostring(time))
        print(id)
        slp_avg = dim_avg(slp(id))
        print(slp_avg)

==============  3  =============================================================
    f3 = addfile("/mnt/e/scripts/ncl/ncl/week14/hgt.mon.mean.850hPa.nc", "r")
    hgt = f3->hgt

    printVarSummary(hgt)

    wks = gsn_open_wks("x11", "3")
    gsn_define_colormap(wks, "MPL_BrBG")
time = cd_calendar(hgt&time, -1)
id = get1Dindex(time,201101)
    res = True

    res@mpMaxLatF= 90
    res@mpMinLatF = 0
    res@mpMaxLonF = 0
    res@mpMinLonF = -120

    res@cnFillOn = True
    res@cnLinesOn = False

    res@tmXBLabelFontHeightF = 0.02
    res@tmYLLabelFontHeightF = 0.02
    res@pmLabelBarOrthogonalPosF = 0.1
    res@tiMainFontHeightF = 0.05
plot = gsn_csm_contour_map(wks, hgt(id,{850},:,:), res)

; ;==============  3  =============================================================
    f3 = addfile("/mnt/e/scripts/ncl/ncl/week14/hgt.mon.mean.850hPa.nc", "r")
    hgt = f3->hgt
time = cd_calendar(hgt&time, -1)
id = get1Dindex(time,201101)
    printVarSummary(hgt)

    wks = gsn_open_wks("x11", "3")
    gsn_define_colormap(wks, "MPL_BrBG")    

    res = True
    res@cnFillOn    = True
    res@gsnPolar    = "NH"  
    res@gsnPolarLabelFontHeightF    = 0.024
    res@lbLabelFontHeightF = 0.024
    res@mpCenterLonF = 120.
    res@mpMinLatF = 20.

    plot = gsn_csm_contour_map_polar(wks, hgt(id,{850},:,:), res)


    
end