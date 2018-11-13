load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
begin
    ;time = ispan(1, 365, 1)
    ;lat = fspan(-90, 90, 73)
    ;lat!0 = "latitude"
    ;lat&latitude = lat
    ;air = new((/365,73/), double)
    ;air!0 = "time"
    ;air!1 = "lat"
    ;air&time = time 
    ;air&lat = lat 
    ;lat := ind (lat .gt. -90 .and. lat .lt. -80)
    ;lat :=ispan(10, 60, 10)
    ;lat :=ispan(15, -15, 5)
    ;print(lat)
    ;lat_at_0 = lat({60})
    ;air0 = air(10,{60})
    ;air60 = todouble(lat({60}))
    ;air60 = air60*air(10,{60})


    str = "E" + ispan(1,5,1)

    year = (/2000,2001,2003,2005,2007/)
    mon = (/1,2,3,2,1/)
    day = (/3,10,21,7,5/)
    
    air = (/5.2,6.7,10,8.5,6.3/)
;
    ; add line(s) below 

    strOut = str+" "+sprinti("%4i", year)+sprinti("%02i", mon`)\
    +sprinti("%02i", day)+" "+sprintf("%5.2f", air)
    print(strOut);
    

end