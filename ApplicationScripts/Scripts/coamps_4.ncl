;*****************************************************
; coamps_4.ncl
;
; Concepts illustrated:
;   - Plotting COAMPS data
;   - Using a blue-white-red color map
;   - Using fbinrecread to read in fortran record data
;   - Paneling multiple plots on a page with a common labelbar
;   - Drawing raster contours
;   - Setting the labelbar label stride in a panel plot
;   - Adding a common title to paneled plots
;
; Sylvia Murphy NCAR Feb 2002
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
 period     = (/6,12/) 
                         ; some variables are every 3 hrs,
                         ; others every 6 hrs. This varies
                         ; by region.

 var_name   = "air_temp"
			 ; "pres","dwpt_dprs","vpr_pres"
                         ; "snsb_heat_flux", "snsb_ltnt_heat_flux"
                         ; "ir_flux","ttl_heat_flux"
                         ; "ttl_prcp","sol_rad" 
                         ; "grnd_sea_temp", "air_temp"

 region      = "w_pac"
                         ; "southwest_asia", " cen_amer", "e_pac",
                         ; "europe", "europe2","w_atl", "w_pac"

; -1 means let NCL determine range of data. Note fluxes have hardwired
; ranges to ensure colormap centered on zero. You will not be able to
; override these.  
 manual     = False
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
  period_poss = create_period(var_name,region)
  do i=0,dimsizes(period)-1
     if (any(period_poss.eq.period(i)).eq.False)then
        print("period "+period(i)+" does not exist for variable "+var_name)
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
 if(var_name .eq. "dwpt_dprs")then
   var_name="dwpt_dprs_surface"
 end if
 tmp = stringtochar(date)
 yyyy=chartostring(tmp(0:3))
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
;**************************************
;   plot results
;***************************************
   wks = gsn_open_wks(output,"coamps")
   plot = new(dimsizes(period),graphic)              ; create plot array

   res                             = True            ; plot mods desired

   res@cnFillOn                    = True            ; turn on color
   res@cnFillMode                  = "RasterFill"    ; turn on raster mode
   res@cnLinesOn                   = linesOn         ; no contour lines

   res@lbLabelBarOn                = False           ; turn off individual cb's
   res@txFontHeightF               = 0.014           ; shrink upper text


   res@mpFillOn                    = False           ; don't fill contours
   res@mpGeophysicalLineThicknessF = 2.0             ; line thickness
   res@mpGeophysicalLineColor      = "black"         ; boundaries color

   res@gsnAddCyclic                = False           ; regional data

   res@gsnDraw                     = False           ; don't draw yet
   res@gsnFrame                    = False           ; don't advance frame yet

   res@cnLevelSelectionMode        = "ManualLevels"  ; set manual cn levels

   res@mpMinLatF                   = min(lat)
   res@mpMaxLatF                   = max(lat)
   res@mpMinLonF                   = min(lon)
   res@mpMaxLonF                   = max(lon)
;*************************************
; create large array of all data values
;*************************************
   big        = new( (/dimsizes(period),nlat,nlon/),"float")
   do i = 0,npts-1
     j          = period(i)/period_poss@div
     var_x      = fbinrecread(fname1,j,(/nlat,nlon/),"float") 
     var_x      = create_meta(var_name,var_x,lat,lon)
     big(i,:,:) = var_x
   end do 
;**************************************
;   assign colormap by variable, assign variable specific resources
;   and create final plot
;***************************************
   re@cnFillPalette                = "gui_default"   ; for press/temp fields

   if(manual.eq.True)then 
      res@cnMinLevelValF           = mincn           ; set min contour level
      res@cnMaxLevelValF           = maxcn           ; set max contour level
      res@cnLevelSpacingF          = cnint           ; contour interval
      if(mincn.eq.-1.or.maxcn.eq.-1.or.cnint.eq.-1)then
        print("You must specify all range values: min,max,contour interval")
	exit
      end if
   else
      mnmxint               = nice_mnmxintvl(min(big), max(big), 24, False)
      res@cnMinLevelValF    = mnmxint(0) 
      res@cnMaxLevelValF    = mnmxint(1) 
      res@cnLevelSpacingF   = mnmxint(2) 
   end if

   if(var_name .eq. "ttl_heat_flux")then
       res@cnFillPalette          = "BlWhRe"      ; choose color map
       res@cnMinLevelValF         = -1100         ; set min contour level
       res@cnMaxLevelValF         =  1100         ; set max contour level
       res@cnLevelSpacingF        =   100         ; contour interval
   end if 

   if(var_name .eq. "snsb_heat_flux")then
       res@cnFillPalette          = "BlWhRe"      ; choose color map
       res@cnMinLevelValF         = -500          ; set min contour level
       res@cnMaxLevelValF         =  500          ; set max contour level
       res@cnLevelSpacingF        =  50           ; contour interval
   end if

  if(var_name .eq. "snsb_ltnt_heat_flux")then
       res@cnFillPalette          = "BlWhRe"      ; choose color map
       res@cnMinLevelValF         = -1000         ; set min contour level
       res@cnMaxLevelValF         =  1000         ; set max contour level
       res@cnLevelSpacingF        =  100          ; contour interval
   end if

   if(var_name .eq. "ir_flux")then
       res@cnFillPalette          = "BlWhRe"      ; choose color map
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
       res@cnFillPalette        = colors  ; generate new color map
       res@cnLevelSelectionMode = "ExplicitLevels"   
       res@cnLevels             = (/0.1,0.2,0.4,0.8,1.6,3.2,6.4,12.8,25.6/)
   end if 
  
   do i = 0,npts-1
     res@gsnLeftString               = var_x@long_name ; left string title
     res@gsnRightString              = var_x@units     ; right string title

     if( period(i).eq.0 ) then
       res@gsnCenterString           = "Analysis"
     else
       res@gsnCenterString           = "Forecast Period: "+period(i)+" hours"
     end if

     plot(i)= gsn_csm_contour_map(wks,big(i,:,:),res)  ; create indiv plots
   end do

   pres                  = True
   pres@gsnMaximize      = True                          ; blow up plots
   pres@txString         = "COAMPS: "+date               ; common title
   pres@lbLabelStride    = 2                             ; label bar stride
   pres@gsnPanelLabelBar = True                          ; common label bar

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




