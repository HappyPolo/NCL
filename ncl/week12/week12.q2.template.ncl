; Create an array representing all months from Jan 1950 to Dec 2018 
; using the function “yyyymm_time”, i.e. 195001, 195002, 195003, ..., 
; 201810, 201811, 201812. 
begin

    time = yyyymm_time(1950, 2018, "integer")



; Then, define an array to extract indices corresponding to June, July and August 
; from 1971 to 2000 using the function “get1Dindex”, i.e. this array is assigned the index 
; corresponding to 197106, 197107, 197108, 197206, 197207, 197208, ..., 200006, 200007, 200008.
    jun = ispan(197106, 200006, 100)
    jul = ispan(197107, 200007, 100)
    aug = ispan(197108, 200008, 100)
    time_exc = new(90, float)
    time_exc =ndtooned(transpose((/jun,jul,aug/)))
    time@_FillValue = -999
    exc = get1Dindex_Exclude(time, (time_exc))


end 
