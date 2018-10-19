;*****************************************************
; coamps_3.ncl
;
; Concepts illustrated:
;   - Plotting COAMPS data
;   - Using a blue-white-red color map
;   - Using fbinrecread to read in fortran record data
;   - Drawing contours and vectors on the same map
;   - Setting contour levels using a min/max contour level and a spacing
;   - Drawing raster contours
;   - Explicitly setting contour levels to uneven levels
;   - Spanning part of a color map for contour fill
;   - Drawing curly vectors
;   - Turning off the addition of a longitude cyclic point
;   - Zooming in on a particular area on a cylindrical equidistant map
;   - Drawing subtitles at the top of a plot
;   - Moving the vector reference annotation into the plot
;   - Changing the length of the vectors
;   - Changing the magnitude of the vectors
;   - Decreasing the number of vectors drawn
;   - Creating a color map using RGB triplets
;   - Thinning vectors using a minimum distance resource
;
; Sylvia Murphy NCAR Apr 2002
;*****************************************************
;
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
;
; These files still have to be loaded manually
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl"
load "./func_coamps.ncl"
;*****************************************************
begin
;*****************************************************
; User's parameters
;*****************************************************
 date       = "2002030800"
 period     = (/6/) 
                         ; some variables are every 3 hrs,
                         ; others every 6 hrs. This varies
                         ; by region. Your scalar and vector
                         ; variables must have the same periods

 refvec     = 10.        ; value of reference vector
                         

 var_name   = "ttl_heat_flux"
			 ; "pres","dwpt_dprs","vpr_pres"
                         ; "snsb_heat_flux", "snsb_ltnt_heat_flux"
                         ; "ir_flux","ttl_heat_flux"
                         ; "ttl_prcp","sol_rad" 
                         ; "grnd_sea_temp", "air_temp"

 region      = "southwest_asia"
                         ; "southwest_asia", " cen_amer", "e_pac",
                         ; "europe", "europe2","w_atl", "w_pac"

; -1 means let NCL determine range of data. Note fluxes have hardwired
; ranges to ensure colormap centered on zero.   
 mincn      =  -1        ; min contour
 maxcn      =  -1        ; max contour
 cnint      =  -1        ; contour interval
; 
 linesOn    = False      ; turn on contour lines
 output     = "png"      ; can be "ps","eps","epsi","x11",or "ncgm"
;*****************************************************
; NO USERS CHANGES AFTER THIS POINT
;*****************************************************
; each region varies by variable and output periods.
; check to see if the period requested exists for that
; variable in that subregion.
;*****************************************************
  period_poss   = create_period(var_name,region)
  period_poss_U = create_period("wind",region)
  tmp           = compare_periods(period,period_poss,period_poss_U)
  delete(period)
  period = tmp
  delete(tmp)
;*****************************************************
; open file and read in data
;*****************************************************
 if(var_name .eq. "dwpt_dprs")then
   var_name="dwpt_dprs_surface"
 end if
 tmp  = stringtochar(date)
 yyyy = chartostring(tmp(0:3))
;*****************************************************
; vector data
;*****************************************************
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
;*****************************************************
; scalar data file
;*****************************************************
; if(region .eq. "europe2")then
;    fname3 = "/u/NOGAPS/COAMPSg/"+region+"/"+yyyy+"/europe_"+var_name+"."+date
; else
;    fname3 = "/u/NOGAPS/COAMPSg/"+region+"/"+yyyy+"/"+region+"_"+var_name+"."+date
; end if

  if(region .eq. "europe2")then
     fname3 = region+"/"+yyyy+"/europe_"+var_name+"."+date
  else
     fname3 = region+"/"+yyyy+"/"+region+"_"+var_name+"."+date
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
  check_file_exist(region,yyyy,date,var_name)
;*****************************************************
; begin plot
;*****************************************************
 do i = 0,npts-1
    j_vec = period(i)/period_poss_U@div
    j_scal= period(i)/period_poss@div
    u     = fbinrecread(fname1,j_vec,(/nlat,nlon/),"float")
    v     = fbinrecread(fname2,j_vec,(/nlat,nlon/),"float")
    var_x = fbinrecread(fname3,j_scal,(/nlat,nlon/),"float")
;*****************************************************
; assign coordinate variables and attributes to data.
; functions are located in coamps_func.ncl
;***************************************************** 
    u     = create_meta("u",u,lat,lon)
    v     = create_meta("v",v,lat,lon)
    var_x = create_meta(var_name,var_x,lat,lon)
;**************************************
;   Create plot
;***************************************
   wks  = \
   gsn_open_wks(output,\
   "coamps_vc_"+var_name+"_"+date+"_"+sprinti( "%0.2i", period(i)))
;**************************************
;   intial resources
;***************************************
   res                             = True            ; plot mods desired

   res@cnFillOn                    = True            ; turn on color
   res@cnFillMode                  = "RasterFill"    ; turn on raster mode 
   res@cnLinesOn                   = linesOn         ; no contour lines
   res@pmLabelBarOrthogonalPosF    = 0.1             ; move label bar down
   res@txFontHeightF               = 0.014           ; shrink upper text

   res@mpFillOn                    = False           ; don't fill contours
   res@mpGeophysicalLineThicknessF = 2.0             ; line thickness
   res@mpGeophysicalLineColor      = "gray"          ; continental boundaries

   res@gsnMaximize                 = True            ; maximize plot size
   res@gsnLeftString               = var_x@long_name ; left string title
   res@gsnRightString              = var_x@units     ; right string title
   res@tiMainString                = "COAMPS: "+date ; title

   res@vcGlyphStyle                = "CurlyVector"   ; turn on curley vectors
   res@vcRefMagnitudeF             = refvec          ; define vector ref mag
   res@vcRefLengthF                = 0.045           ; define length of vec ref
   res@vcRefAnnoOrthogonalPosF     = -0.17           ; move ref vector
   res@vcMinDistanceF              = 0.019           ; thin vectors
   res@vcRefAnnoString2            = "m/s"           ; unit string
   res@vcRefAnnoString2On          = True            ; turn on second string
   res@gsnScalarContour            = True            ; vectors on contours

   if( period(i).eq.0 ) then
     res@gsnCenterString           = "Analysis"
   else
     res@gsnCenterString           = "Fcst Per: "+period(i)+" hrs"
   end if

   res@cnLevelSelectionMode        = "ManualLevels"   ; set manual cn levels
   if(mincn.ne.-1)then 
     res@cnMinLevelValF            = mincn            ; set min contour level
   end if
   if(maxcn.ne.-1)then
      res@cnMaxLevelValF           = maxcn            ; set max contour level
   end if
   if(cnint.ne.-1)then
     res@cnLevelSpacingF           = cnint            ; contour interval
   end if
   res@gsnAddCyclic                = False            ; regional data 
   res@mpMinLatF                   = min(lat)
   res@mpMaxLatF                   = max(lat)
   res@mpMinLonF                   = min(lon)
   res@mpMaxLonF                   = max(lon)
;**************************************
;   assign colormap by variable, assign variable specific resources
;   and create final plot
;***************************************
   res@cnFillPalette = "gui_default"              ; for press/temp fields

   if(var_name .eq. "ttl_heat_flux")then
       res@cnFillPalette          = "BlWhRe"      ; choose color map 
       res@cnMinLevelValF         = -1100         ; set min contour level
       res@cnMaxLevelValF         =  1100         ; set max contour level
       res@cnLevelSpacingF        =   100         ; contour interval
       res@mpGeophysicalLineColor = "black"       ; continental boundaries
   end if 

   if(var_name .eq. "snsb_heat_flux")then
       res@cnFillPalette          = "BlWhRe"      ; choose color map 
       res@cnMinLevelValF         = -500          ; set min contour level
       res@cnMaxLevelValF         =  500          ; set max contour level
       res@cnLevelSpacingF        =  50           ; contour interval
       res@mpGeophysicalLineColor = "black"       ; continental boundaries
   end if

  if(var_name .eq. "snsb_ltnt_heat_flux")then
       res@cnFillPalette          = "BlWhRe"      ; choose color map 
       res@cnMinLevelValF         = -1000         ; set min contour level
       res@cnMaxLevelValF         =  1000         ; set max contour level
       res@cnLevelSpacingF        =  100          ; contour interval
       res@mpGeophysicalLineColor = "black"       ; continental boundaries
   end if

   if(var_name .eq. "ir_flux")then
       res@cnFillPalette          = "BlWhRe"      ; choose color map
       res@cnMinLevelValF         = -400          ; set min contour level
       res@cnMaxLevelValF         =  400          ; set max contour level
       res@cnLevelSpacingF        =  50           ; contour interval
       res@mpGeophysicalLineColor = "black"       ; continental boundaries
   end if

   if(var_name .eq. "ttl_prcp")then
      colors = (/ (/255,255,255/),(/0,0,0/),(/255,255,255/), (/244,255,244/), \
               (/217,255,217/), (/163,255,163/), (/106,255,106/), \
               (/43,255,106/), (/0,224,0/), (/0,134,0/),(/255,255,0/),\
               (/255,127,0/) /) * 1.0 ; we multiply by 1 to make colors float
       colors = colors/255.               ; normalize (required by NCL)
       res@cnFillPalette = colors         ; generate new color map
       res@cnLevelSelectionMode = "ExplicitLevels"   
       res@cnLevels             = (/0.1,0.2,0.4,0.8,1.6,3.2,6.4,12.8,25.6/)
   end if 

   plot = gsn_csm_vector_scalar_map (wks, u,v,var_x,res)

end do

end 



