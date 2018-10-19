;*****************************************************
; global_nogaps_vec.ncl
;
; Sylvia Murphy NCAR Feb 2002
;*****************************************************
;
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"   
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"  
;
; This file still has to be loaded manually  
load "./func_nogaps.ncl"
;*****************************************************
begin
;*****************************************************
; USER INPUT
;*****************************************************
 date       = "2001121800" 
 period     = (/0/) 
			  ; keep (/.../) syntax even if only one period chosen
                          ; can be 0(analysis)3,6,9,12,15,18,21,24,27,30,33,
                          ; 36,39, 42, 45, 48, 51, 54, 57, 60, 63, 66, 69, 72
 type       = "curl"      ; "wind" or "curl"
; refvec     = 10.         ; for wind
 refvec     = 0.1         ; for curl
 centerLon  = 0           ; choose any value
 output     = "png"       ; can be "ps","eps","epsi","x11",or "ncgm"
;*****************************************************
; END USER INPUT
;*****************************************************
; open file and read in data
;*****************************************************
 if(type.eq."wind")then
   fname1 = "./nogaps_wnd_ucmp."+date
   fname2 = "./nogaps_wnd_vcmp."+date
 end if
 if(type.eq."curl")then
   fname1 = "./nogaps_wnd_strs_ucmp."+date
   fname2 = "./nogaps_wnd_strs_vcmp."+date
 end if
;*****************************************************
; create coordinate variables (in nogaps_func.ncl)
;*****************************************************   
 lat     = nogaps_lat(-90,90)
 lon     = nogaps_lon(0,359)
;*****************************************************   
 npts = dimsizes(period)
 nlat = 181
 nlon = 360
 do i = 0,npts-1
    j    = period(i)/3
    u    = fbindirread(fname1,j,(/nlat,nlon/),"float")
    v    = fbindirread(fname2,j,(/nlat,nlon/),"float")
;*****************************************************
; assign coordinate variables to data
;*****************************************************
    u     = create_meta("u",u,lat,lon)
    v     = create_meta("v",v,lat,lon)
;*****************************************************
; plot results
;*****************************************************    
    wks  = gsn_open_wks(output,"global_nogaps_vec") 
                                             
    res                             = True
    res@vcRefMagnitudeF             = refvec           ; make vectors larger
    res@vcRefLengthF                = 0.050            ; ref vector length
    res@vcGlyphStyle                = "CurlyVector"    ; turn on curly vectors
    res@vcMinDistanceF              = 0.018            ; thin the vectors
    res@vcRefAnnoOrthogonalPosF     = -0.12            ; move ref vector

; add some titles

    res@tiMainString    = "NOGAPS: "+date

    if (type.eq."wind")then
       res@gsnLeftString   = "Wind (10 meter)"
       res@gsnRightString  = "m/s"
    end if
    if (type.eq."curl")then
       res@gsnLeftString   = "Wind Stress"
       res@gsnRightString  = "m/s"
    end if

    if( period(i).eq.0 ) then
     res@gsnCenterString           = "Analysis"
   else
     res@gsnCenterString           = "Forecast Period: "+period(i)+" hours"
   end if

    res@gsnMaximize     = True                  ; largest plot possible
    res@mpCenterLonF    = centerLon             ; center longitude



  plot= gsn_csm_vector_map(wks,u,v,res)
end do
end


