;*****************************************************
; coamps_5.ncl
; 
; Concepts illustrated:
;   - Plotting COAMPS data
;   - Drawing curly vectors over a cylindrical equidistant map
;   - Using fbinrecread to read in fortran record data
;   - Setting the labelbar label stride in a panel plot
;   - Paneling multiple plots on a page
;   - Adding a common title to paneled plots
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
 period     = (/0,12,24/) 
                          ; some variables are every 3 hrs,
                          ; others every 6 hrs. This varies
                          ; by region.

 type       = "wind"      ; (/"curl","wind")
 region     = "w_atl"
                          ; "southwest_asia", " cen_amer", "e_pac",
                          ; "europe", "europe2","w_atl", "w_pac"

 output     = "png"       ; can be "ps","eps","epsi","x11",or "ncgm"

 if(type.eq."wind")then
   refvec     = 5.0         ; for wind
   thinvec    = 0.05        ; larger number = sparser vectors
 else
   refvec     = 0.1         ; for curl
   thinvec    = 0.012       ; larger number = sparser vectors
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
; check for number of plots desired
;*****************************************************
  if(dimsizes(period).gt.4)then
     print("For optimal presentation, please select only 4 periods:EXIT")
     exit
  end if

  if(dimsizes(period).eq.1)then
     print("This script is for panelling two or more plots: EXIT")
  end if
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
; plot results
;*****************************************************    
 wks  = gsn_open_wks(output,"coamps") 
 plot = new(dimsizes(period),graphic)               ; create plot array
                                             
 res                             = True
 res@vcRefMagnitudeF             = refvec           ; make vectors larger
 res@vcRefLengthF                = 0.050            ; ref vector length
 res@vcGlyphStyle                = "CurlyVector"    ; turn on curly vectors
 res@vcMinDistanceF              = thinvec          ; thin the vectors
 res@vcRefAnnoOrthogonalPosF     = -0.12            ; move ref vector

 res@gsnDraw                     = False            ; don't draw yet
 res@gsnFrame                    = False            ; don't advance frame
 res@gsnAddCyclic                = False                     ; regional data 
 res@mpMinLatF                   = min(lat)
 res@mpMaxLatF                   = max(lat)
 res@mpMinLonF                   = min(lon)
 res@mpMaxLonF                   = max(lon)
; add some titles

  res@tiMainString    = "COAMPS: "+date
  res@txFontHeightF   = 0.014                       ; shrink upper text

  if (type.eq."wind")then
    res@gsnLeftString   = "Wind (10 meter)"
    res@gsnRightString  = "m/s"
  end if
  if (type.eq."curl")then
    res@gsnLeftString   = "Wind Stress"
    res@gsnRightString  = "m/s"
  end if


  do i = 0,npts-1
    j    = period(i)/period_poss@div
    u    = fbinrecread(fname1,j,(/nlat,nlon/),"float")  ; read in variable
    v    = fbinrecread(fname2,j,(/nlat,nlon/),"float")   
    u     = create_meta("u",u,lat,lon)                  ; assign meta data
    v     = create_meta("v",v,lat,lon)                  
   
   if( period(i).eq.0 ) then
     res@gsnCenterString           = "Analysis"
   else
     res@gsnCenterString           = "Forecast Period: "+period(i)+" hours"
   end if

   plot(i)= gsn_csm_vector_map(wks,u,v,res)                ; create indiv plots
 end do

   pres             = True
   pres@gsnMaximize = True
   if(dimsizes(period).eq.2)then
     gsn_panel(wks,plot,(/2,1/),pres)                      ; panel plots
   end if
   if(dimsizes(period).eq.3)then
     gsn_panel(wks,plot,(/3,1/),pres)                      ; panel plots
   end if
   if(dimsizes(period).eq.4)then
     gsn_panel(wks,plot,(/2,2/),pres)                      ; panel plots
   end if
end


