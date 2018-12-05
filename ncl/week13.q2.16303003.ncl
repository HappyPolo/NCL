; Read the file from "hgt.850hPa.mon.mean.nc", 
    f = addfile("/mnt/e/data/ncl/hgt.850hPa.mon.mean.nc", "r")
    hgt = f->hgt

; Read the variable "time" from "hgt.850hPa.mon.mean.nc"
    time = cd_calendar(hgt&time,-1)



; Extract the indices corresponding to December to February from 1971/1972 to 2000/2001
    dec = ispan(197112, 200012, 100)
    jan = ispan(197201, 200101, 100)
    feb = ispan(197202, 200102, 100)
    exc = ndtooned(transpose((/dec, jan, feb/)))
    id = get1Dindex(time, exc)




; Calculate the long-term mean in December to February 1971/1972–2000/2001 over the globe. 
; ** Using function dim_avg_n_Wrap
    hgt_DJF = dim_avg_n_Wrap(hgt(id,0,:,:), 0)


; Output the data to the file "hgt.850hPa.DJF.clim.1971-2000.学号.nc"
    output="/mnt/e/data/ncl/"
    system("/bin/rm -f "+output+"hgt.850hPa.DJF.clim.1971-2000.16303003.nc")
    ncdf = addfile(output+"hgt.850hPa.DJF.clim.1971-2000.16303003.nc" ,"c")
    ncdf->hgt = hgt_DJF
