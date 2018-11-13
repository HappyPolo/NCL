; NCL week 11 
; Class exercise
; Question 1

; a) 	Write a script to define variables time, lat, and air with the named dimensions, coordinates and attributes.
; Hints: First, using ispan and fspan to define variables time and lat, respectively. 
; The coordinates of time and lat are evenly spaced. Second, using “new” to 
; create the two-dimensional variable air, where its named dimensions are time and lat. 
    time = ispan(1, 365, 1)
    lat = fspan(-90, 90, 73)
    air = new((/365,73/), double)
    air!0 = "time"
    air!1 = "lat"
    air&time = time 
    air&lat = lat 


; b)	Extract the following values from the variable lat using syntax characters {:}
; i.	all values from -90 to -80
    lat := ind (lat .gt. -90 .and. lat .lt. -80)

; ii.	10 to 60 with an interval of 10
    lat :=ispan(10, 60, 10)

; iii.	15 to -15 with an interval of 5
    lat :=ispan(15, -15, -5)

; c)	Correct the following errors
; i.	lat-at-0 = lat({60})		; extract latitude = 60°N
    lat_at_0 = lat({60})

; ii.	air0 = air(time|10,{0}) 	; extract the 11-th time step at latitude = 60°N
    air0 = air(10,{60})

; iii.	air60 = lat({60}) 			; compute the product of lat and air 
;       air60 = air60*air(time|10,{60})
    air60 = todouble(lat({60}))
    air60 = air60*air(10,{60})
