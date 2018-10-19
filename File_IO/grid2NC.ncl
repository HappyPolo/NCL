 load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
;----------------------------------------------------------------------  
; grid2NC.ncl  
; convert China daily air temperature 0.5 бу б┴ 0.5 бу grid data sets to NC file
; grid data sets can download from http://cdc.cma.gov.cn/
; By het,igsnrr.ac.cn 2014-9-14  
;---------------------------------------------------------------------- 
 ;system("/bin/rm -rf T01.nc")
 ncdf 		= addfile("/mnt/f/data/For_Fortran/nc/1961_2010_temp_mean.nc","c")
 filedimdef(ncdf,"time",-1,True)
 ncols		= 128
 nrows		= 72
 xllcorner	= 72.0  ;lon
 yllcorner	= 18.0  ;lat
 lat  		= fspan (yllcorner,yllcorner+(nrows-1)*0.5,nrows)
 lon 		= fspan (xllcorner,xllcorner+(ncols-1)*0.5,ncols)
 lat@units      = "degrees_north"
 lon@units      = "degrees-east"

 T = readAsciiTable("/mnt/f/data/For_Fortran/temp_annual.txt",ncols,"float",6)
 T2= T(::-1,:)                       
 T2@_FillValue	= -9999
 T2!0    	= "lat"                      
 T2!1   	= "lon"
 T2&lat  	= lat                    
 T2&lon  	= lon
 T2@long_name	= "PRC"
 T2@units    	= "mm/day"
 ncdf->T2  	= T2

                                 
                                 
                                 
                                 

