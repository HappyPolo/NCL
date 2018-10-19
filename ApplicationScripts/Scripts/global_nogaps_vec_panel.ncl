;*****************************************************
; global_nogaps_vec_panel.ncl
; 
; Sylvia Murphy NCAR Feb 2002
;*****************************************************
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"   
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"    
load "./func_nogaps.ncl"
;*****************************************************
begin
;*****************************************************
; USER INPUT
;*****************************************************
 date       = "2001121800" 
 period     = (/18,63,72/) 
			  ; keep (/.../) syntax even if only one period chosen
                          ; can be 0(analysis)3,6,9,12,15,18,21,24,27,30,33,
                          ; 36,39, 42, 45, 48, 51, 54, 57, 60, 63, 66, 69, 72
 type       = "wind"      ; (/"curl","wind")
refvec     = 10.         ; for wind
; refvec     = 0.1         ; for curl
 centerLon  = 0         ; choose any value
 output     = "ps"        ; can be "ps","eps","epsi","x11",or "ncgm"
;*****************************************************
; END USER INPUT
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
;*****************************************************
; plot results
;*****************************************************    
 wks  = gsn_open_wks(output,"global_nogaps_vec_"+date+"_panel") 
 plot = new(dimsizes(period),graphic)               ; create plot array
                                             
 res                             = True
 res@vcRefMagnitudeF             = refvec           ; make vectors larger
 res@vcRefLengthF                = 0.050            ; ref vector length
 res@vcGlyphStyle                = "CurlyVector"    ; turn on curly vectors
 res@vcMinDistanceF              = 0.018            ; thin the vectors
 res@vcRefAnnoOrthogonalPosF     = -0.12            ; move ref vector
 res@mpCenterLonF                = centerLon       ; center longitude


 res@gsnDraw                     = False            ; don't draw yet
 res@gsnFrame                    = False            ; don't advance frame

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


  do i = 0,npts-1
    j    = period(i)/3
    u    = fbindirread(fname1,j,(/nlat,nlon/),"float")  ; read in variable
    v    = fbindirread(fname2,j,(/nlat,nlon/),"float")   
    u     = create_meta("u",u,lat,lon)                  ; assign meta data
    v     = create_meta("v",v,lat,lon)                  
   
   if( period(i).eq.0 ) then
     res@gsnCenterString           = "Analysis"
   else
     res@gsnCenterString           = "Forecast Period: "+period(i)+" hours"
   end if

   plot(i)= gsn_csm_vector_map_ce(wks,u,v,res)           ; create indiv plots
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


