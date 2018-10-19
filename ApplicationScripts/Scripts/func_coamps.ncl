;******************************************
undef("coamps_lat")
function coamps_lat(region:string)
begin
    if(region.eq."southwest_asia")then
	latmin = 15.
	latmax = 40.
        nlat   = 127
    end if
    if(region.eq."e_pac")then
	latmin = 29.
	latmax = 60.
	nlat   = 156
    end if
    if(region.eq."cen_amer")then
	latmin = 0.
	latmax = 32.
	nlat   = 161
    end if
    if(region.eq."europe")then
	latmin = 29.
	latmax = 47.
        nlat   = 91
    end if
    if(region.eq."europe2")then
	latmin = 29.
	latmax = 59.
        nlat   = 151
    end if
    if(region.eq."w_atl")then
	latmin = 20.
	latmax = 55.
        nlat   = 176
    end if
    if(region.eq."w_pac")then
	latmin = 5.
	latmax = 45.
        nlat   = 201
    end if

    lat       = fspan(latmin,latmax,nlat)
    lat!0     = "lat"
    lat@units = "degrees_north"
    lat&lat   = lat
    return(lat)
end
;******************************************
undef("coamps_lon")
function coamps_lon(region:string)
begin

    if(region.eq."southwest_asia")then
	lonmin = 30.
	lonmax = 60.
        nlon   = 151
    end if
    if(region.eq."e_pac")then
	lonmax = -114.0
	lonmin = -160.0
 	nlon   = 231
    end if
    if(region.eq."cen_amer")then
	lonmin = -120.
	lonmax = -60.
 	nlon   = 301
    end if
    if(region.eq."europe")then
	lonmin = -12.
	lonmax = 40.0
        nlon   = 261
    end if
    if(region.eq."europe2")then
	lonmin = -15.
	lonmax = 40.0
        nlon   = 276
    end if
    if(region.eq."w_atl")then
	lonmax = -55.0
	lonmin = -93.0
        nlon   = 191
    end if
    if(region.eq."w_pac")then
	lonmin = 100.0
	lonmax = 165.0
        nlon   = 326
    end if

  lon       = fspan(lonmin,lonmax,nlon)
  lon!0     = "lon"
  lon@units = "degrees_east"
  lon&lon   = lon
  return(lon)
end
;******************************************
undef("create_meta")
function create_meta(var_name:string,x[*][*]:numeric,lat[*]:float,lon[*]:float)
begin
   x@_FillValue = -999.                    ; assign fill value
   if(var_name.eq."pres" .or. var_name.eq."air_temp")then
	x = mask(x,x.lt.0.000001,False)
   end if

   if(var_name .eq. "pres")then
      x = x/100.                           ; convert to mb from Pa
   end if

   x!0   = "lat"                           ; name dimensions
   x!1   = "lon"

   x&lat = lat                             ; assign cv's
   x&lon = lon 

; check for bad data values
   error = new(3,string)
   error = (/"pres","air_temp","grnd_sea_temp"/)
   if any(var_name .eq. error)then
       x = mask(x, x .eq. 0.0, False)
   end if
;*****************************************************
; assign attributes
;***************************************************** 
   if(var_name.eq."air_temp")then
     x@long_name  = "Temperature"
     x@units      = "deg K"
   end if
  if(var_name.eq."grnd_sea_temp")then
     x@long_name  ="Ground or SST"
     x@units      = "deg K"
   end if
   if(var_name.eq."dwpt_dprs_surface")then
     x@long_name  = "Dew Pt Depression"
     x@units      = "deg K"
   end if
   if(var_name.eq."pres")then
     x@long_name  = "Surface Pressure"
     x@units      = "mb"
   end if
  if(var_name.eq."vpr_pres")then
     x@long_name  = "Vapor Pressure"
     x@units      = "Pa"
   end if
 if(var_name.eq."ttl_prcp")then
     x@long_name  = "Total Precipitation"
     x@units      = "kg/m/m"
   end if
;***************
; fluxes
;***************
   if(var_name.eq."sol_rad")then
     x@long_name  = "Solar_Radiation"
     x@units      = "W/m**2"
   end if
   if(var_name.eq."ttl_heat_flux")then
     x@long_name  = "Total Heat Flux"
     x@units      = "W/m**2"
   end if
   if(var_name.eq."snsb_heat_flux")then
     x@long_name  = "Sensible Heat Flux"
     x@units      = "W/m**2"
   end if
   if(var_name.eq."snsb_ltnt_heat_flux")then
     x@long_name  = "Sensible Latent Heat Flux"
     x@units      = "W/m**2"
   end if
   if(var_name.eq."ir_flux")then
     x@long_name  = "IR Flux"
     x@units      = "W/m**2"
   end if
   return(x)
end
;******************************************
undef("create_period")
function create_period(varname:string,region:string)
begin
    if(region.eq."southwest_asia")then
       list1 = (/"curl","pres","ttl_heat_flux","sol_rad","vpr_pres"/)
       if(any(varname.eq.list1))then
	 period_poss=(/0,3,6,9,12,15,18,21,24,27,30,33,36,39,42,45,48/)
	 period_poss@div = 3
       else
   	 period_poss=(/0,3,6,9,12,15,18,21,24,30,36,42,48/)           ;weird one
	 period_poss@div = 6
       end if
	
    end if
    if(region.eq."e_pac")then
	list1 = (/"wind","curl"/)
        if(any(varname.eq.list1))then
            period_poss=(/0,3,6,9,12,15,18,21,24,27,30,33,36,39,42,45,48/)
	    period_poss@div = 3
        else
	    period_poss=(/0,6,12,18,24,30,36,42,48/)
	    period_poss@div = 6
        end if
    end if
    if(region.eq."cen_amer")then
        period_poss=(/0,3,6,9,12,15,18,21,24,27,30,33,36,39,42,45,48/)
	period_poss@div = 3
    end if
    if(region.eq."europe")then
        list1 = (/"curl","pres"/)
        if(any(varname.eq.list1))then
            period_poss=(/0,3,6,9,12,15,18,21,24,27,30,33,36,39,42,45,48/)
	    period_poss@div = 3
        else
	    period_poss=(/0,6,12,18,24,30,36,42,48/)
 	    period_poss@div = 6
        end if
    end if
    if(region.eq."europe2")then
        list1 = (/"curl","pres"/)
        if(any(varname.eq.list1))then
            period_poss=(/0,3,6,9,12,15,18,21,24,27,30,33,36,39,42,45,48/)
	    period_poss@div = 3
        else
	    period_poss=(/0,6,12,18,24,30,36,42,48/)
 	    period_poss@div = 6
        end if
    end if
    if(region.eq."w_atl")then
        list1 = (/"curl"/)
        if(any(varname.eq.list1))then
            period_poss=(/0,3,6,9,12,15,18,21,24,27,30,33,36,39,42,45,48/)
	    period_poss@div = 3
        else
	    period_poss=(/0,6,12,18,24,30,36,42,48/)
	    period_poss@div = 6
        end if
    end if
    if(region.eq."w_pac")then
        list1 = (/"curl","wind"/)
        if(any(varname.eq.list1))then
            period_poss=(/0,3,6,9,12,15,18,21,24,27,30,33,36,39,42,45,48/)
	    period_poss@div = 3
        else
	    period_poss=(/0,6,12,18,24,30,36,42,48/)
	    period_poss@div = 6
        end if
    end if
    return(period_poss)
end
;******************************************
undef("check_file_exist")
procedure check_file_exist(region:string,yyyy:string,date:string,var_name:string)
begin
    list_var  = systemfunc("ls "+region+"/"+yyyy+"/")
;    list_var  = systemfunc("ls /u/NOGAPS/COAMPSg/"+region+"/"+yyyy+"/")
    file_test = region+"_"+var_name+"."+date
 if .not.(any(list_var.eq.file_test))then
   print("that variable does not exist for this region")
   exit
 end if 
end
;******************************************* 
undef("check_date_exist")
procedure check_date_exist(region:string,yyyy:string,date:string)
begin
   list_var  = systemfunc("ls "+region+"/"+yyyy+"/*")
;    list_var  = systemfunc("ls /u/NOGAPS/COAMPSg/"+region+"/"+yyyy+"/")

; the following assumes that the date will always be the last string in the 
; filename, and that the date string will be 10 characters long.

 date_exist = new(dimsizes(list_var),"string")
 do i=0,dimsizes(list_var)-1
    x             = stringtochar(list_var(i))
    date_exist(i) = chartostring(x(dimsizes(x)-11:dimsizes(x)-1))
    if(date.eq.date_exist(i))
       return
    end if
    delete(x)
 end do

 print("date "+date+" does not exist")
 print("available dates are: "+date_exist)
 exit
end
;******************************************* 
undef("compare_periods")
; this function goes through the periods selected by the user
; and compares them to available periods for the vector and
; scalar variables. It will return only those periods that 
; both fields have in common.

function compare_periods(period[*],period_poss[*],period_poss_U[*])
begin  
  if(dimsizes(period_poss).ne.dimsizes(period_poss_U))then
     k=0
     new_period = new(dimsizes(period),typeof(period))
     do i=0,dimsizes(period)-1                           
        if(any(period_poss.eq.period(i)).eq.True)then    
           if(any(period_poss_U.eq.period(i)))then
              new_period(k)=period(i)
	      k = k+1
           end if
        end if
     end do
  else
     new_period = period                                ; they are the same
     print("All the periods you have chosen exist in both the scalar and vector variables")
     return(new_period)
     exit
  end if

; notify user if some chosen periods can not be plotted.

  if(dimsizes(new_period).eq.-999.)then
     print("The periods you have chosen do not exist in both the scalar and vector variables")
     print("Available periods for the scalar field are "+period_poss)
     print("Available periods for the wind field are "+period_poss_U)   
     exit
  else 
     print("The following periods you have chosen existed in both the wind and scalar files and will therefore be plotted:" +new_period)
     return(new_period)
  end if
end
;********************************************************
