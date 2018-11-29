begin
; Read the variable uwnd from uwnd.850hPa.2010.nc (type of uwnd: short)
    fu = addfile("/mnt/f/data/ncl/uwnd.850hPa.2010.nc", "r")
    uwnd = short2flt(fu->uwnd)
    ; printVarSummary(uwnd)
; Read the variable vwnd from vwnd.850hPa.2010.nc (type of vwnd: short)
    fv = addfile("/mnt/f/data/ncl/vwnd.850hPa.2010.nc", "r")
    vwnd = short2flt(fv->vwnd)



; Read the variable time from uwnd.850hPa.2010.nc 
    time = cd_calendar(uwnd&time, -2)


; Extract the indices corresponding to the date from 16 Jan to 15 Feb 
    ext0 = yyyymmdd_time(2010, 2010, "integer")
    ext = ext0({20100116:20100215})
    id = get1Dindex(time, ext)

; Calculate daily vorticity at 850 hPa from 16 Jan to 15 Feb 
; over the region 30°–45°N and 120°–150°E. 
    ; ua = dim_avg_n_Wrap(uwnd(id,{850},{30:40},{120:150}),(/1,2/))
    ; va = dim_avg_n_Wrap(vwnd(id,{850},{30:40},{120:150}),(/1,2/))
    lat = fspan(30, 40, 5)
    lon = fspan(120, 150, 13)
    
    vorticity = uv2vr_cfd(uwnd(id,{850},{30:40},{120:150}), \
                vwnd(id,{850},{30:40},{120:150}), lat, lon, 0)
    copy_VarCoords(uwnd(id,{850},{30:40},{120:150}), vorticity)
    



; Output daily vorticity to the file vorticity.850hPa.2010.学号.nc.
    output="/mnt/f/data/ncl/"
    system("/bin/rm -f "+output+"vorticity.850hPa.2010.16303003.nc")
    ncdf = addfile(output+"vorticity.850hPa.2010.16303003.nc" ,"c")
    ncdf->v = vorticity
end