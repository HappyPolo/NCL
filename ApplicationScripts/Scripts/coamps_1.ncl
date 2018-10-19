;*****************************************************
; coamps_1.ncl
; 
; Concepts illustrated:
;   - Plotting COAMPS data
;   - Drawing color-filled contours over a cylindrical equidistant map
;   - Using fbinrecread to read in fortran record data
;   - Drawing raster contours
;   - Turning off the addition of a longitude cyclic point
;   - Setting contour levels using a min/max contour level and a spacing
;   - Creating a color map using RGB triplets
;   - Zooming in on a particular area on a cylindrical equidistant map
;   - Changing the thickness of map outlines
;   - Drawing subtitles at the top of a plot
;   - Changing the stride of the labelbar labels
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
 date       = "2002030900"
 period     = (/12/) 
                         ; some variables are every 3 hrs,
                         ; others every 6 hrs. This varies
                         ; by region.

 var_name   = "pres"
                         ; "pres","dwpt_dprs","vpr_pres"
                         ; "snsb_heat_flux", "snsb_ltnt_heat_flux"
                         ; "ir_flux","ttl_heat_flux","ir_flux"
                         ; "ttl_prcp","sol_rad" 
                         ; "grnd_sea_temp", "air_temp"

 region      = "europe2"
                         ; "southwest_asia", " cen_amer", "e_pac",
                         ; "europe", "europe2","w_atl", "w_pac"

; -1 means let NCL determine range of data. Note fluxes have hardwired
; ranges to ensure colormap centered on zero.  
 mincn      =  -1        ; min contour
 maxcn      =  -1        ; max contour
 cnint      =  -1        ; contour interval
; 
 linesOn    = True       ; turn on contour lines
 output     = "png"      ; can be "ps","eps","epsi","x11",or "ncgm"
;*****************************************************
; NO USERS CHANGES AFTER THIS POINT
;*****************************************************
; each region varies by variable and output periods.
; check to see if the period requested exists for that
; variable in that subregion.
;*****************************************************
  period_poss = create_period(var_name,region)
  do i=0,dimsizes(period)-1
     if (any(period_poss.eq.period(i)).eq.False)then
        print("period "+period(i)+" does not exist for variable "+var_name)
	print("acceptable periods are "+ period_poss)
        exit
     end if
  end do
;*****************************************************
; open file and read in data
;*****************************************************
 if(var_name .eq. "dwpt_dprs")then
   var_name="dwpt_dprs_surface"
 end if
 tmp  = stringtochar(date)                            ; get year from date
 yyyy = chartostring(tmp(0:3))


; if(region .eq. "europe2")then
;    fname1 = "/u/NOGAPS/COAMPSg/"+region+"/"+yyyy+"/europe_"+var_name+"."+date
; else
;    fname1 = "/u/NOGAPS/COAMPSg/"+region+"/"+yyyy+"/"+region+"_"+var_name+"."+date
; end if

  if(region .eq. "europe2")then
     fname1 = region+"/"+yyyy+"/europe_"+var_name+"."+date
  else
     fname1 = region+"/"+yyyy+"/"+region+"_"+var_name+"."+date
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
    j = period(i)/period_poss@div
    var_x = fbinrecread(fname1,j,(/nlat,nlon/),"float")
;*****************************************************
; assign coordinate variables and attributes to data.
; functions are located in coamps_func.ncl
;***************************************************** 
    var_x = create_meta(var_name,var_x,lat,lon)
;**************************************
;   open workstation
;***************************************
   wks  = \
   gsn_open_wks(output,\
   "coamps_"+region+"_"+var_name+"_cn_"+date+"_"+sprinti( "%0.2i", period(i)))
;**************************************
;   intial resources
;***************************************
   res                             = True            ; plot mods desired

   res@cnFillOn                    = True            ; turn on color 
   res@cnFillMode                  = "RasterFill"
   res@cnLinesOn                   = linesOn         ; no contour lines

   res@mpFillOn                    = False           ; don't fill contours
   res@mpGeophysicalLineThicknessF = 2.0             ; line thickness
   res@mpGeophysicalLineColor      = "black"         ; boundaries color
   res@gsnAddCyclic                = False           ; regional data

   res@gsnMaximize                 = True            ; maximize plot size
   res@gsnLeftString               = var_x@long_name ; left string title
   res@gsnRightString              = var_x@units     ; right string title
   res@tiMainString                = "COAMPS: "+date 
   res@txFontHeightF               = 0.014           ; shrink upper text

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
       res@cnFillPalette          = "BlWhRe"      ; set color map
       res@cnMinLevelValF         = -1100         ; set min contour level
       res@cnMaxLevelValF         =  1100         ; set max contour level
       res@cnLevelSpacingF        =   100         ; contour interval
   end if 

   if(var_name .eq. "snsb_heat_flux")then
       res@cnFillPalette          = "BlWhRe"      ; set color map
       res@cnMinLevelValF         = -500          ; set min contour level
       res@cnMaxLevelValF         =  500          ; set max contour level
       res@cnLevelSpacingF        =  50           ; contour interval
   end if

  if(var_name .eq. "snsb_ltnt_heat_flux")then
       res@cnFillPalette          = "BlWhRe"      ; set color map
       res@cnMinLevelValF         = -1000         ; set min contour level
       res@cnMaxLevelValF         =  1000         ; set max contour level
       res@cnLevelSpacingF        =  100          ; contour interval
   end if

   if(var_name .eq. "ir_flux")then
       res@cnFillPalette          = "BlWhRe"      ; set color map
       res@cnMinLevelValF         = -400          ; set min contour level
       res@cnMaxLevelValF         =  400          ; set max contour level
       res@cnLevelSpacingF        =  50           ; contour interval
   end if

   if(var_name .eq. "ttl_prcp")then
      colors = (/ (/255,255,255/),(/0,0,0/),(/255,255,255/), (/244,255,244/), \
               (/217,255,217/), (/163,255,163/), (/106,255,106/), \
               (/43,255,106/), (/0,224,0/), (/0,134,0/),(/255,255,0/),\
               (/255,127,0/) /) * 1.0 ; we multiply by 1 to make colors float
       colors = colors/255.               ; normalize (required by NCL)
       res@cnFillPalette        = colors
       res@cnLevelSelectionMode = "ExplicitLevels"   
       res@cnLevels             = (/0.1,0.2,0.4,0.8,1.6,3.2,6.4,12.8,25.6/)
   end if 

   plot = gsn_csm_contour_map (wks,var_x,res)

end do

end 

