 a = (/1,2,3,4,-999.000,6/)
 a@_FillValue = -999.000
 print(ind(a.eq.a@_FillValue))
 print(ind(ismissing(a)))      
