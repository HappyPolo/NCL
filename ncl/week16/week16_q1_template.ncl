begin

	fu 		= addfile("uwnd.week15.nc","r")
	fv 		= addfile("vwnd.week15.nc","r")
	
	timeARR = cd_calendar(fu->time,-5)
	yrARR 	= timeARR(:,0)
	monARR 	= timeARR(:,1)

	timeIND = ind(yrARR.ge.1980 .and. yrARR.le.2009 .and. (monARR.ge.12 .or. monARR.le.2))

	uClim  	= dim_avg_n_Wrap(fu->uwnd(timeIND,{250},:,:),0)
	vClim  	= dim_avg_n_Wrap(fv->vwnd(timeIND,{250},:,:),0)
	
	; ====================================================
	; draw graph
	
end