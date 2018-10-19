;*****************************************************
; global_nogaps_vec_con_panel.ncl
;
; Sylvia Murphy NCAR Mar 2002
;*****************************************************
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl"
load "./func_nogaps.ncl"
;*****************************************************
begin
;*****************************************************
; User's parameters
;*****************************************************
 date       = "2001121800" 
 period     = (/18,27/) 
			  ; keep (/.../) syntax even if only one period chosen
                          ; can be 0(analysis)3,6,9,12,15,18,21,24,27,30,33,
                          ; 36,39, 42, 45, 48, 51, 54, 57, 60, 63, 66, 69, 72 

 refvec     = 10.         ; value of reference vector

 var_name   = "vpr_pres"
			 ; "pres","dwpt_dprs","vpr_pres"
                         ; "snsb_heat_flux", "snsb_ltnt_heat_flux"
                         ; "ir_flux","ttl_heat_flux"
                         ; "ttl_prcp","sol_rad" 
                         ; "grnd_sea_temp", "air_temp"

; -1 means let NCL determine range of data. Note fluxes have hardwired
; ranges to ensure colormap centered on zero.You will not be able to
; override these.    
 manual     = False
 mincn      =  -1        ; min contour
 maxcn      =  -1        ; max contour
 cnint      =  -1        ; contour interval
; 
 linesOn    = False      ; turn on contour lines
 centerLon  = 89         ; choose any value
 output     = "ps"      ; can be "ps","eps","epsi","x11",or "ncgm"
;*****************************************************
; NO USERS CHANGES AFTER THIS POINT
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
 fname1 = "./nogaps_wnd_ucmp."+date
 fname2 = "./nogaps_wnd_vcmp."+date
 fname3 = "./nogaps_"+var_name+"."+date
;*****************************************************
; create coordinate variables (in nogaps_func.ncl)
;*****************************************************   
  lat     = nogaps_lat(-90,90)            
  lon     = nogaps_lon(0,359)
;*****************************************************
 npts  = dimsizes(period)
 nlat  = 181
 nlon  = 360
;**************************************
;   plot results
;***************************************
   wks = gsn_open_wks(output,"global_nogaps_"+var_name+\
                             "_vec_con_"+date+"_panel")
   plot = new(dimsizes(period),graphic)              ; create plot array

   res                             = True            ; plot mods desired

   res@cnFillOn                    = True            ; turn on color 
   res@cnLinesOn                   = linesOn         ; no contour lines

;---This resource not needed in V6.1.0
   res@gsnSpreadColors             = True            ; use full color map

   res@lbLabelBarOn                = False           ; turn off individual cb's

   res@mpFillOn                    = False           ; don't fill contours
   res@mpGeophysicalLineThicknessF = 2.0             ; line thickness
   res@mpGeophysicalLineColor      = "black"         ; boundaries color
   res@mpCenterLonF                = centerLon       ; center longitude

   res@vcGlyphStyle                = "CurlyVector"   ; turn on curley vectors
   res@vcRefMagnitudeF             = refvec          ; define vector ref mag
   res@vcRefLengthF                = 0.045           ; define length of vec ref
   res@vcRefAnnoOrthogonalPosF     = -0.17           ; move ref vector
   res@vcMinDistanceF              = 0.019           ; thin vectors
   res@vcRefAnnoString2            = "m/s"           ; unit string
   res@vcRefAnnoString2On          = True            ; turn on second string
   res@gsnScalarContour            = True            ; vectors on contours

   res@cnLevelSelectionMode        = "ManualLevels"  ; set manual cn levels
   res@gsnMaximize                 = True            ; maximize plot size

   res@gsnDraw                     = False           ; don't draw yet
   res@gsnFrame                    = False           ; don't advance frame yet
;*************************************
; create large array of all data values
;*************************************
   big        = new( (/dimsizes(period),nlat,nlon/),"float")
   big_u        = new( (/dimsizes(period),nlat,nlon/),"float")
   big_v        = new( (/dimsizes(period),nlat,nlon/),"float")
   do i = 0,npts-1
     j          = period(i)/3
     u     = fbinrecread(fname1,j,(/nlat,nlon/),"float")
     v     = fbinrecread(fname2,j,(/nlat,nlon/),"float")
     var_x = fbinrecread(fname3,j,(/nlat,nlon/),"float")
     var_x = create_meta(var_name,var_x,lat,lon)
     u     = create_meta("u",u,lat,lon)
     v     = create_meta("v",v,lat,lon)
     big(i,:,:) = var_x
     big_u(i,:,:) = u
     big_v(i,:,:) = v
   end do 
;**************************************
;   assign colormap by variable, assign variable specific resources
;   and create final plot
;***************************************
   gsn_define_colormap(wks,"gui_default")         ; for press/temp fields

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
       gsn_define_colormap(wks,"BlWhRe")          ; choose color map
       res@cnMinLevelValF         = -1100         ; set min contour level
       res@cnMaxLevelValF         =  1100         ; set max contour level
       res@cnLevelSpacingF        =   100         ; contour interval
   end if 

   if(var_name .eq. "snsb_heat_flux")then
       gsn_define_colormap(wks,"BlWhRe")          ; choose color map
       res@cnMinLevelValF         = -500          ; set min contour level
       res@cnMaxLevelValF         =  500          ; set max contour level
       res@cnLevelSpacingF        =  50           ; contour interval
   end if

  if(var_name .eq. "snsb_ltnt_heat_flux")then
       gsn_define_colormap(wks,"BlWhRe")          ; choose color map
       res@cnMinLevelValF         = -1000         ; set min contour level
       res@cnMaxLevelValF         =  1000         ; set max contour level
       res@cnLevelSpacingF        =  100          ; contour interval
   end if

   if(var_name .eq. "ir_flux")then
       gsn_define_colormap(wks,"BlWhRe")          ; choose color map
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
       gsn_define_colormap(wks, colors)   ; generate new color map
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

     plot(i)= gsn_csm_vector_scalar_map_ce(wks,big_u(i,:,:),big_v(i,:,:),\
					   big(i,:,:),res)  
							; create indiv plots
   end do

   pres                  = True
   pres@gsnMaximize      = True                          ; blow up plots
   pres@txString         = "NOGAPS: "+date               ; common title
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




