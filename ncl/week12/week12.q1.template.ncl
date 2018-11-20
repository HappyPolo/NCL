; This script provides daily mean temperatures recorded at a weather station 
; in January 2011. 
begin

	air = (/14.9,15.1,14.0,13.4,15.7, \
			14.2,10.9,12.8,14.5,13.1, \
			11.2,8.8,12.9,16.3,13.7, \
			11.2,11.8,14.3,15.3,16.1, \
			13.7,13.2,15.0,14.1,14.3, \
			15.0,15.9,15.1,12.9,12.2, \
			13.1/)
			
; Complete the script as follows:
; 	a.	Calculate the time-averaged temperature in the following days
; 		i.	1-10 Jan
    t1 = dim_avg(air(0:9))

; 		ii.	11-20 Jan
    t2 = dim_avg(air(10:19))

; 		iii.21-31 Jan
    t3 = dim_avg(air(20:30))

; 	b.	Obtain the daily temperature change (变温) from 2 January to 30 January 2011 WITHOUT do loops (e.g. the daily temperature change on 2 January = temperature on 2 January minus temperature on 1 January)
    t_change = air(1:30)-air(0:29)



; 	c.	Find the number of days that temperature was below 12.0 degree Celsius (using NCL function(s))
    n = num(air.lt.12.)
    ;========================   or       ========================================
    iscold = where(air.lt.12, 1, 0)
    count = dim_sum(iscold)
    print(count)

end