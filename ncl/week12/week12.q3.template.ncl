begin

	; events
	eventYear = (/1979, 1981, 1982, 1983, 1985, 1987, 1987, 1987, 1988, 1989, \
				  1990, 1991, 1991, 1993, 1995, 1995, 1996, 1997, 1998, 1998, \
				  1999, 2000, 2002, 2005, 2006, 2013, 2015, 2015, 2016, 2016/)
    eventYear@_FillValue = -999
	
	; Define an array extracting indices corresponding 
	; to the events occurring in 1982, 1987, 1991, 1997 and 2015. 
	
	; exc = get1Dindex(eventYear, (/1982,1987,1991,1997,2015/))
    exc = get1Dindex_Exclude(eventYear, (/1982,1987,1991,1997,2015/))
    nevent = eventYear(exc)
    id = get1Dindex_Exclude(eventYear,nevent)
    print(id)
    
end
