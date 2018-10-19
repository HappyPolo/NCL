;*****************************************************
; global_nogaps_con.ncl
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
load "./func_nogaps.ncl"
;*****************************************************
begin
;*****************************************************
; User's parameters
;*****************************************************
 date       = "2001121800" 
 period     = (/3/) 
			  ; keep (/.../) syntax even if only one period chosen
                          ; can be 0(analysis)3,6,9,12,15,18,21,24,27,30,33,
                          ; 36,39, 42, 45, 48, 51, 54, 57, 60, 63, 66, 69, 72 

 var_name   = "air_temp"
			 ; "pres","dwpt_dprs","vpr_pres"
                         ; "snsb_heat_flux", "snsb_ltnt_heat_flux"
                         ; "ir_flux","ttl_heat_flux","ir_flux"
                         ; "ttl_prcp","sol_rad" 
                         ; "grnd_sea_temp", "air_temp"

; -1 means let NCL determine range of data. Note fluxes have hardwired
; ranges to ensure colormap centered on zero.  
 mincn      =  -1        ; min contour
 maxcn      =  -1        ; max contour
 cnint      =  -1        ; contour interval
; 
 centerLon  = 36         ; choose any value
 linesOn    = False      ; turn on contour lines
 output     = "png"      ; can be "ps","eps","epsi","x11",or "ncgm"
;*****************************************************
; NO USERS CHANGES AFTER THIS POINT
;*****************************************************
; open file and read in data
;*****************************************************
 if(var_name .eq. "dwpt_dprs")then
   var_name="dwpt_dprs_surface"
 end if
 fname1 = "./nogaps_"+var_name+"."+date
;*****************************************************
; create coordinate variables (in nogaps_func.ncl)
;*****************************************************   
  lat     = nogaps_lat(-90,90)            
  lon     = nogaps_lon(0,359)
;*****************************************************
 npts  = dimsizes(period)
 nlat  = 181
 nlon  = 360
 do i = 0,npts-1
    j = period(i)/3
    var_x = fbindirread(fname1,j,(/nlat,nlon/),"float")
;*****************************************************
; assign coordinate variables and attributes to data.
; functions are located in nogaps_func.ncl
;***************************************************** 
    var_x = create_meta(var_name,var_x,lat,lon)
;**************************************
;   open workstation
;***************************************
   wks  = \
   gsn_open_wks(output,"global_nogaps_con")
;**************************************
;   intial resources
;***************************************
   res                             = True            ; plot mods desired

   res@cnFillOn                    = True            ; turn on color 
   res@cnLinesOn                   = linesOn         ; no contour lines

   res@mpFillOn                    = False           ; don't fill contours
   res@mpGeophysicalLineThicknessF = 2.0             ; line thickness
   res@mpGeophysicalLineColor      = "black"         ; boundaries color
   res@mpCenterLonF                = centerLon       ; center longitude

   res@lbLabelStride               = 2               ; label bar stride
   res@gsnMaximize                 = True            ; maximize plot size
   res@gsnLeftString               = var_x@long_name ; left string title
   res@gsnRightString              = var_x@units     ; right string title
   res@tiMainString                = "NOGAPS: "+date

   if( period(i).eq.0 ) then
     res@gsnCenterString           = "Analysis"
   else
     res@gsnCenterString           = "Forecast Period: "+period(i)+" hours"
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
;**************************************
;   assign colormap by variable, assign variable specific resources
;   and create final plot
;***************************************

   gsn_define_colormap(wks,"gui_default")         ; for press/temp fields

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

   plot = gsn_csm_contour_map(wks,var_x,res)

end do

end 



