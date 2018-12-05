; Assumption: You don't know which data are missing

begin

	; Step 1: Input data	
	; uA: zonal wind anomaly 
	; vA: meridional wind anomaly
	; Missing value is -999 

	uA =(/4.5, 2.0, -999., 1.2, 6.3, \
		7.8, -999., 1.5, 12.4, 2.8, \
		-999., -999., 10.2, 5.5, 3.2/)
	
	vA =(/1.3, -2.5, -999., 4.2, -0.3, \
		2.5, -999., 0.5, 4.4, -1.5, \
		-999., -999., -3.2, -1.1, 1.2/)
	
	nData = dimsizes(uA) ; Count the number of input data

	; Step 2: Identify if each data point has missing data  
	; True if either uA or vA is missing
	; False if both uA and vA are non-missing
	
	miss  = new(nData,logical)

	; do i = 0, nData-1
	; 	if (uA(i).eq.-999. .or. vA(i).eq.-999.) then
	; 		miss(i) = True
	; 	else
	; 		miss(i) = False
	; 	end if
	; end do

	miss = where(uA.eq.-999. .or. vA.eq.-999., True, False)
	
	; Step 3: Extract the data points without missing values
	
	; notMiss = ind(.not. miss)
	; nExist  = dimsizes(notMiss)		
	
	
	; Step 4: Calculate the averaged momentum flux over the points without missing values
	; if there are at least 10 non-missing data
	
	; if (nExist.ge.10) then
		
	; 	momentumFlux = new(nExist,typeof(uA))
		
	; 	do n = 0, nExist-1
	; 		momentumFlux(n) = uA(notMiss(n))*vA(notMiss(n))
	; 	end do
		
	; 	momentumFluxAvg = avg(momentumFlux)
	; else
	; 	momentumFluxAvg	= -999.
	; end if	

	uA@_FillValue = -999.
	vA@_FillValue = -999.
	uva = uA*vA
	notMiss = ind(.not.miss)
	nExist  = dimsizes(notMiss)
	momentumFlux = new(nExist,typeof(uA))
	momentumFlux = uva(notMiss)
	if (nExist.ge.10) then
		momentumFluxAvg = avg(momentumFlux)
	else 
		momentumFluxAvg = -999.
	end if 


print(momentumFluxAvg)

end 




; 	print(momentumFluxAvg)
	
; end