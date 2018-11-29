; NCL week 11 
; Class exercise
; Question 2

begin
    str = "E" + ispan(1,5,1)

    year = (/2000,2001,2003,2005,2007/)
    mon = (/1,2,3,2,1/)
    day = (/3,10,21,7,5/)
	
    air = (/5.2,6.7,10,8.5,6.3/)

    ; add line(s) below 
    strOut = str+" "+sprinti("%4i", year)+sprinti("%02i", month)\
    +sprinti("%02i", day)+" "+sprintf("%5.2f", air)
    print(strOut)

end
