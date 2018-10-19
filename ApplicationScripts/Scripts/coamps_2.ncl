;*****************************************************
; coamps_2.ncl
;
; Concepts illustrated:
;   - Plotting COAMPS data
;   - Drawing curly vectors over a cylindrical equidistant map
;   - Changing the length of the vectors
;   - Changing the magnitude of the vectors
;   - Using fbinrecread to read in fortran record data
;   - Turning off the addition of a longitude cyclic point
;   - Zooming in on a particular area on a cylindrical equidistant map
;   - Drawing subtitles at the top of a plot
;   - Decreasing the number of vectors drawn
;   - Moving the vector reference annotation into the plot
;   - Thinning vectors using a minimum distance resource
;
; Sylvia Murphy NCAR Apr 2002
;*****************************************************
;
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"   
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"  
;
; This file still has to be loaded manually  
load "./func_coamps.ncl"
;*****************************************************
begin
;*****************************************************
; USER INPUT
;*****************************************************
 date       = "2002030800"
 period     = (/0/) 
                          ; some variables are every 3 hrs,
                          ; others every 6 hrs. This varies
                          ; by region.

 type       = "wind"      ; "wind" or "curl"

 region     = "e_pac"
                          ; "southwest_asia", " cen_amer", "e_pac",
                          ; "europe", "europe2","w_atl", "w_pac"

 output     = "png"       ; can be "ps","eps","epsi","x11",or "ncgm"

 if(type.eq."wind")then
   refvec     = 5.         ; for wind
 else
   refvec     = 0.1        ; for curl
 end if
;*****************************************************
; END USER INPUT
;*****************************************************
; each region varies by variable and output periods.
; check to see if the period requested exists for that
; variable in that subregion.
;*****************************************************
  period_poss = create_period(type,region)
  do i=0,dimsizes(period)-1
     if (any(period_poss.eq.period(i)).eq.False)then
        print("period "+period(i)+" does not exist for variable "+type)
	print("acceptable periods are "+ period_poss)
        exit
     end if
  end do
;*****************************************************
; open file and read in data
;*****************************************************
 tmp = stringtochar(date)
 yyyy=chartostring(tmp(0:3))


 if(type.eq."wind")then
;   if(region .eq. "europe2")then
;     fname1 = "/u/NOGAPS/COAMPSg/"+region+"/"+yyyy+"/europe_wnd_ucmp."+date
;     fname2 = "/u/NOGAPS/COAMPSg/"+region+"/"+yyyy+"/europe_wnd_vcmp."+date
;   else
;     fname1 = "/u/NOGAPS/COAMPSg/"+region+"/"+yyyy+"/"+region+"_wnd_ucmp."+date
;     fname2 = "/u/NOGAPS/COAMPSg/"+region+"/"+yyyy+"/"+region+"_wnd_vcmp."+date
;  end if
   if(region .eq. "europe2")then
      fname1 = region+"/"+yyyy+"/europe_wnd_ucmp."+date
      fname2 = region+"/"+yyyy+"/europe_wnd_vcmp."+date
   else
      fname1 = region+"/"+yyyy+"/"+region+"_wnd_ucmp."+date
      fname2 = region+"/"+yyyy+"/"+region+"_wnd_vcmp."+date
   end if
 end if


 if(type.eq."curl")then
;   if(region .eq. "europe2")then
;     fname1 = "/u/NOGAPS/COAMPSg/"+region+"/"+yyyy+"/europe_wnd_strs_ucmp."+date
;     fname2 = "/u/NOGAPS/COAMPSg/"+region+"/"+yyyy+"/europe_wnd_strs_vcmp."+date
;   else
;     fname1 = "/u/NOGAPS/COAMPSg/"+region+"/"+yyyy+"/"+region+"_wnd_strs_ucmp."+date
;     fname2 = "/u/NOGAPS/COAMPSg/"+region+"/"+yyyy+"/"+region+"_wnd_strs_vcmp."+date
;  end if
   if(region .eq. "europe2")then
      fname1 = region+"/"+yyyy+"/europe_wnd_strs_ucmp."+date
      fname2 = region+"/"+yyyy+"/europe_wnd_strs_vcmp."+date
   else
      fname1 = region+"/"+yyyy+"/"+region+"_wnd_strs_ucmp."+date
      fname2 = region+"/"+yyyy+"/"+region+"_wnd_strs_vcmp."+date
   end if
 end if
;*****************************************************
; create coordinate variables (in coamps_func.ncl)
;*****************************************************   
 lat  = coamps_lat(region)
 lon  = coamps_lon(region)
 npts = dimsizes(period)
 nlat = dimsizes(lat)
 nlon = dimsizes(lon)
;*****************************************************
; each coamps region produces different variables. 
; check to see if the variable requested exists.
;*****************************************************
 check_date_exist(region,yyyy,date)

 if(type.eq."curl")then
   name="wnd_strs_ucmp"
   check_file_exist(region,yyyy,date,name)
 end if
 if(type.eq."wind")then
   name="wnd_ucmp"
   check_file_exist(region,yyyy,date,name)
 end if
;*****************************************************
; begin plot
;*****************************************************
 do i = 0,npts-1
    j    = period(i)/period_poss@div
    u    = fbinrecread(fname1,j,(/nlat,nlon/),"float")
    v    = fbinrecread(fname2,j,(/nlat,nlon/),"float")
;*****************************************************
; assign coordinate variables to data
;*****************************************************
    u     = create_meta("u",u,lat,lon)
    v     = create_meta("v",v,lat,lon)
;*****************************************************
; plot results
;*****************************************************    
    wks  = gsn_open_wks(output,"coamps_"+region+"_"+type+"_"+date+"_"+period(i)) 
                                             
    res                             = True
    res@vcRefMagnitudeF             = refvec           ; make vectors larger
    res@vcRefLengthF                = 0.050            ; ref vector length
    res@vcGlyphStyle                = "CurlyVector"    ; turn on curly vectors
    res@vcMinDistanceF              = 0.018            ; thin the vectors
    res@vcRefAnnoOrthogonalPosF     = -0.125           ; move ref vector

; add some titles

    res@tiMainString    = "COAMPS: "+date

    if (type.eq."wind")then
       res@gsnLeftString   = "Wind (10 meter)"
       res@gsnRightString  = "m/s"
    end if
    if (type.eq."curl")then
       res@gsnLeftString   = "Wind Stress"
       res@gsnRightString  = "m/s"
    end if

    if( period(i).eq.0 ) then
     res@gsnCenterString   = "Analysis"
   else
     res@gsnCenterString   = "Fcst: "+period(i)+" hrs"
   end if

   res@txFontHeightF       = 0.014                     ; shrink upper text
   res@gsnMaximize         = True                      ; largest plot possible
   res@gsnAddCyclic        = False                     ; regional data 
   res@mpMinLatF           = min(lat)
   res@mpMaxLatF           = max(lat)
   res@mpMinLonF           = min(lon)
   res@mpMaxLonF           = max(lon)

  plot= gsn_csm_vector_map(wks,u,v,res)
end do
end


