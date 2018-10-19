;----------------------------------------------------------------------------------

;begin
	a      = addfile("./slp.mon.mean.nc","r")
	time   = a->time		      ; time@units = "hours since 1-1-1 00:00:0.0" 
	printVarSummary(time)
	
	utc_d  = cd_calendar(time,0)	      ; utc_date(:,0)=years, utc_date(:,1)=months
					      ; utc_date(:,2)=days, utc_date(:,3)=hours
					      ; utc_date(:,4)=minutes, utc_date(:,5)=seconds
						
	ym    = cd_calendar(time,1)           ; YYYYMM  of type double
	ymd   = cd_calendar(time,-2)          ; YYYYMMDD of type integer
	ymdh  = cd_calendar(time,-3)          ; YYYYMMDDHH  of type integer
	yrfrac= cd_calendar(time,4)           ; YYYY.fraction_of_year; type double
	
;---------------------------------------------------------------------------------
;    Taking output from cd_calendar (utc_d array from above), convert from 
;    a UT-referenced date to a mixed Julian/Gregorian date. cd_inv_calendar
;    requires input of type integer for the year, month, day, hour, and minute.
;    cd_calendar outputs floats when the option is set to 0. Thus, these inputs 
;    will have to be converted from float to integer.
;---------------------------------------------------------------------------------	
        year   = tointeger(utc_d(:,0))        ; [*]
	month  = tointeger(utc_d(:,1))        ; [*]
	day    = tointeger(utc_d(:,2))        ; [*]
	hour   = tointeger(utc_d(:,3))        ; [*]
	minute = tointeger(utc_d(:,4))        ; [*]

	tunits = "days since 1801-1-1 00:00:0.0"   ; NEW reference time 

	time2  = cd_inv_calendar(year,month,day,hour,minute,utc_d(:,5),tunits,0)
	time2!0= "time2"
	time2&time2= time2
	printVarSummary(time2)

        print(time+"  "+ym+"  "+ymd+"  "+ymdh+"  "+sprintf("%9.4f", yrfrac)+"  "+time2)
;end
