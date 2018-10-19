;***********************************************************************
; Merge all total precipitation into one netCDF file
;***********************************************************************
; header has 10 records         
; each time step has 11 records
;--------------------------------------------------
; first file of each run has header with 10 records 
; first file of each run has 41 time steps:
;            xtime  = 0, 6,12,18,24,.....234,240           
; starting record # =10,21,32,43,54,.....439,450    
;--------------------------------------------------
; following file of each run has  40 time steps 
;                            has 440 records    
; starting record # = 0,11,22,33,44,.....418,429    
;***********************************************************************
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"   
;-----------------------------------------------------------------------
begin
  MssPath = "/JEFF/regcm2/82nmc03/"
  END = "end.nc"
  OUT = "out.nc"
 
  month_length = (/31,28,31,30,31,30,31,31,30,31,30,31/)
  nlat =78
  nlon =121
  nlvl =14  
 
; process all 10 history (OUT) files
  do nfile= 1,10          
;-------------------------------------------------------------------------
;*** get file from mss                                                   -
     if (nfile.ne.10) then
        IN = "OUT.19821100"+nfile*10
     else                  
        IN = "OUT.1982110100"
     end if
        print(IN)
 
     system("msread "+IN+" "+MssPath+IN)
;-------------------------------------------------------------------------
     if (nfile.eq.1) then
;-------------------------------------------------------------------------
;****** get the lat and lon arrays from the first data file.
;-------and reorder into (lat,lon) instead of (lon,lat)     

        tmp = craybinrecread(IN,6,(/nlon,nlat/),"float")
        tmp!0 ="lon" 
        tmp!1 ="lat"
        lat2d =tmp(lat|0:nlat-1,lon|0:nlon-1)   
        delete(tmp)

        tmp = craybinrecread(IN,7,(/nlon,nlat/),"float")
        tmp!0 ="lon"
        tmp!1 ="lat"
        lon2d = tmp(lat|0:nlat-1,lon|0:nlon-1)
 
        lat2d!0         = "lat"
        lat2d!1         = "lon"
        lat2d@long_name = "2d-latitude"
        lat2d@info      = "non-traditional 2d-latitude"
 
        lon2d!0         = "lat"
        lon2d!1         = "lon"
        lon2d@long_name = "2d-longitude"
        lon2d@info      = "non-traditional 2d-longitude"
;-------------------------------------------------------------------------
;****** get initial date from the first data file.
        header1= craybinrecread(IN,0,(/24/),"integer")
 
        yyyymmdd = header1(0)/100
        yyyymm   = header1(0)/10000
        yyyy     = header1(0)/1000000
        mm       = yyyymm - yyyy*100  
        dd       = yyyymmdd - yyyymm*100
 
        if (mm.eq.11) then
           month_change1 = month_length(mm-1)
           month_change2 = month_change1     +month_length(mm)
           month_change3 = month_change2     +month_length(0)
           month_change4 = month_change3     +month_length(1)
        else                 
           month_change1 = month_length(mm-1)
           month_change2 = month_change1     +month_length(mm)
           month_change3 = month_change2     +month_length(mm+1)
           month_change4 = month_change3     +month_length(mm+2)
        end if
;-------------------------------------------------------------------------
;****** the first file has 41 time steps and a header with 10 records
        nstep = 41
        nrecord_header = 10
     else
;****** the other file has 40 time steps and no header 
        nstep = 40
        nrecord_header =  0
     end if
 
     do n = 1,nstep
;-------------------------------------------------------------------------
        b = addfile(OUT,"c")
        filedimdef(b,"time",-1,True)
;-------------------------------------------------------------------------
;****** get time step info from the correct record number
;-------the "11" means 11 records for each time step     
        nrecord_time = (n-1)*11 + nrecord_header
 
        header2= craybinrecread(IN,nrecord_time,(/4/),"float")
 
        hour_run = floattointeger(header2(0)+0.1)
;-------------------------------------------------------------------------
;****** quick and dirty way to get the right "date" for each time step   -------------------------
;-------specifically for data starting Nov21 00hour and May20 00hour
;-------             for data totaling 100 days each                 
 
        day_run  = hour_run/24
        hour = hour_run - day_run*24
        day_tmp = dd + day_run
 
        if (day_tmp.gt.month_change4)  then
           day   = day_tmp - month_change4
           if (mm.eq.11) then
              month = 3
              year  = yyyy + 1
           else                
              month = 9
              year  = yyyy     
           end if
        end if
 
    if (day_tmp.gt.month_change3 .and. day_tmp.le.month_change4)  then
       day   = day_tmp - month_change3
       if (mm.eq.11) then
          month = 2
          year  = yyyy + 1
       else                
          month = 8
          year  = yyyy     
       end if
    end if
 
    if (day_tmp.gt.month_change2 .and. day_tmp.le.month_change3)  then
       day   = day_tmp - month_change2
       if (mm.eq.11) then
          month = 1
          year  = yyyy + 1
       else                
          month = 7
          year  = yyyy     
       end if
    end if
 
    if (day_tmp.gt.month_change1 .and. day_tmp.le.month_change2)  then
       day   = day_tmp - month_change1
       if (mm.eq.11) then
          month = 12
          year  = yyyy    
       else                
          month = 6
          year  = yyyy     
       end if
    end if
 
    if (day_tmp.le.month_change1) then
       day = day_tmp
       month = mm 
       year  = yyyy 
    end if            
 
    date = new((/1/),integer)
    date!0         = "time"
    date(0) = year*1000000 + month*10000 + day*100 + hour
       print (date)
;-------------------------------------------------------------------------
;***** get the record number of the field wanted
;------counting from the record with the time step info
;------         0: time step info                       
;------         1: u                                    
;------         2: v                                    
;------         3: t                                    
;------         4: px,ht                                
;------         5: tg                                   
;------         6: q                                    
;------         7: rc,rt                                
;------         8: qca                                  
;------         9: qra                                  
;------        10: td,swt,hfx,qfx,veg                   
 
;***** to get total precipitation, need to add rc and rt
;------and reorder into (lat,lon) instead of (lon,lat)     
       nrecord_rcrt = nrecord_time + 7
       rcrt = craybinrecread(IN,nrecord_rcrt,(/2,nlon,nlat/),"float")
       rcrt!0 = "field"
       rcrt!1 = "lon"
       rcrt!2 = "lat"
;----- unit:cm                          
 
       x = new((/1,nlat,nlon/),float)
       x!0         = "time"
       x!1         = "lat"
       x!2         = "lon"
       x(0,:,:)=rcrt(field|0,lat|:,lon|:) + rcrt(field|1,lat|:,lon|:)
 
       x@long_name = "precipitation"
       x@units     = "cm"
       x@info      = "total precipitation"
;-------------------------------------------------------------------------
;***** write data to new file                                            - 
 
       b->date = date        
       b->time = date        
       b->prc  = x              
       b->lat2d= lat2d       
       b->lon2d= lon2d       
 
;***** merge new file with previous file                                 - 
       if (nfile.eq.1 .and. n.eq.1) then
          system("/usr/bin/cp "+OUT+" "+END)
       else
          system("/contrib/bin/ncrcat "+"-O "+END+" "+OUT+" "+END)
       end if
 
       system("/usr/bin/rm "+OUT)
     end do
 
    system("/usr/bin/rm "+IN)
 end do
end
