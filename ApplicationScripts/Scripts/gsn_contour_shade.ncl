;***********************************************************************;
; Function : gsn_contour_shade                                          ;
;                                                                       ;
; This function shades contour regions given low and/or high values     ;
; using colors or patterns.                                             ;
;                                                                       ;
; This function was written by Adam Phillips, 2006                      ;
;                                                                       ;
; This function was updated July 2013 to allow any combination of       ;
; gsnShadeLow, gsnShadeMid, and gsnShadeHigh to be set.                 ;
;                                                                       ;
; This function was updated July 2014 to allow RGB and RGBA values for  ;
; color. The following are now valid for colors:                        ;    
;                                                                       ;
;  Color index value:  opt@gsnShadeLow  = 5                             ;
;  Named color:        opt@gsnShadeHigh = "blue"                        ;
;  RGB color:          opt@gsnShadeHigh = (/1.,0.,0.5/)                 ;
;  RGBA color:         opt@gsnShadeHigh = (/1.,0.,0.5,0.5/)             ;
;***********************************************************************;
undef("gsn_contour_shade")
function gsn_contour_shade(plot:graphic,lowval:numeric,highval:numeric,\
                           opt:logical) 
local shaden_set, shadem_set, shadep_set, shaden, shadep, shadem, ovrly_ids, \
idstringcnlvls, colist, i, N, tmp_wks, \
def_fill_scale, def_dot_size, dot_size, fill_scale
begin
   if (.not.opt) then
     print("gsn_contour_shade: Options list must be used as one of the following option resources must be set: opt@gsnShadeLow, opt@gsnShadeHigh, opt@gsnShadeMid.")
     print("   Returning without making any changes to plot.")
     return(plot)
   end if

   shade_type = str_lower(get_res_value_keep(opt,"gsnShadeFillType","color"))   ; "pattern"

   if(.not.any(shade_type.eq.(/"color","pattern"/))) then
     print("gsn_contour_shade: gsnShadeFillType can only be 'pattern' or 'color'.")
     print("   Returning without making any changes to plot.")
     return(plot)
   end if

;---Get default values of fill pattern resources
   getvalues plot
      "cnFillScaleF"   : def_fill_scale
      "cnFillDotSizeF" : def_dot_size
   end getvalues

;---Check if user explicitly set these resources. If not, use defaults.
   dot_size   = get_res_value_keep(opt,"gsnShadeFillDotSizeF",def_dot_size)
   fill_scale = get_res_value_keep(opt,"gsnShadeFillScaleF",def_fill_scale)

;----------------------------------------------------------------------
; This section is used to retrieve the gsnShadeLow/Mid/High resources
; and make sure they are valid.
;
; If doing color fill, you can mix and match color types (index color,
; named color, rgb, rgba).
;
; If doing pattern fill, only pattern indexes can be used.
;----------------------------------------------------------------------
   tmp_wks = NhlGetParentWorkstation(plot)
   if (isatt(opt,"gsnShadeLow")) then
     shaden_set = True
     if(shade_type.eq."color") then
       shaden = rm_single_dims_no_meta(convert_color_to_rgba(tmp_wks,opt@gsnShadeLow))
     else
       shaden      = opt@gsnShadeLow
       shaden_type = typeof(shaden)
     end if
   else
     shaden_set = False
     if(shade_type.eq."color") then
       shaden      = (/0.,0.,0.,0./)  ; transparent
       shaden_type = "rgba"
     else
       shaden      = -1              ; no fill
       shaden_type = "integer"
     end if
   end if
   if (isatt(opt,"gsnShadeMid")) then
     shadem_set = True
     if(shade_type.eq."color") then
       shadem      = rm_single_dims_no_meta(convert_color_to_rgba(tmp_wks,opt@gsnShadeMid))
       shadem_type = "rgba"
     else
       shadem      = opt@gsnShadeMid
       shadem_type = typeof(shadem)
     end if
   else
     shadem_set = False
     if(shade_type.eq."color") then
       shadem      = (/0.,0.,0.,0./)  ; transparent
       shadem_type = "rgba"
     else
       shadem      = -1               ; no fill
       shadem_type = "integer"
     end if
   end if
   if (isatt(opt,"gsnShadeHigh")) then
     shadep_set = True
     if(shade_type.eq."color") then
       shadep      = rm_single_dims_no_meta(convert_color_to_rgba(tmp_wks,opt@gsnShadeHigh))
       shadep_type = "rgba"
     else
       shadep      = opt@gsnShadeHigh
       shadep_type = typeof(shadep)
     end if
   else
     shadep_set = False
     if(shade_type.eq."color") then
      shadep      = (/0.,0.,0.,0./)  ; transparent
      shadep_type = "rgba"
     else
       shadep      = -1              ; no fill
       shadep_type = "integer"
     end if
   end if

;---Error checking on the gsnShadeLow/Mid/High resources
   if(.not.any((/shaden_set,shadem_set,shadep_set/))) then
     print("gsn_contour_shade: one of the following resources must be set: opt@gsnShadeLow, opt@gsnShadeHigh, opt@gsnShadeMid.")
     print("   Returning without making any changes to plot.")
     return(plot)
   end if

;---Error checking if we have pattern fill.
   if(shade_type.eq."pattern".and.\
      any((/shaden_type,shadem_type,shadep_type/).ne."integer")) then
     print("gsn_contour_shade: You must use integer values when doing pattern fill.")
     print("   Returning without making any changes to plot.")
     return(plot)
   end if

   if(shade_type.eq."color".and.any((/all(ismissing(shaden)),\
         all(ismissing(shadem)),all(ismissing(shadep))/))) then
     print("gsn_contour_shade: One of your gsnShadeLow/Mid/High resources is set to an invalid color.")
     print("   Returning without making any changes to plot.")
     return(plot)
   end if

   getvalues plot
      "pmOverlaySequenceIds" : ovrly_ids
      "cnFillScaleF" : scale    
   end getvalues
   if (.not.any(ismissing(ovrly_ids))) then
     do i=0,dimsizes(ovrly_ids)-1
         if (NhlClassName(ovrly_ids(i)).eq."contourPlotClass")
            idstring = ovrly_ids(i)
	    end if
      end do
   end if 
   getvalues idstring
     "cnLevels"  : cnlvls
   end getvalues

   if ((isatt(opt,"printcnlevels"))) then
      if (opt@printcnlevels) then
	    print(cnlvls)
	 end if
   end if

;---Make sure we have contour levels
   N = dimsizes(cnlvls)
   if (ismissing(N) .or. N.le.0) then
       print ("gsn_contour_shade: dimsizes(cnlvls)="+N+" return (non-fatal)")
       return (plot)
   end if

;---Create array for fill, set all to transparent or white
   if(shade_type.eq."color") then
     colist      = new((/N+1,4/),double)
     colist      = 1.d     ; initialize to all white so no missing values are used
     colist(:,3) = 0.      ; now set all colors to transparent.
   else
     colist = new(N+1,integer)
     colist = -1
   end if

;---Start filling colist
   if (shaden_set.and.any(cnlvls.le.lowval)) then
     ii := ind(cnlvls.le.lowval)
     ii_dims = dimsizes(ii)
     if(shade_type.eq."pattern") then
       colist(ii) = shaden
     elseif(ii_dims.eq.1) then
       colist(ii,:) = shaden
     else
       colist(ii,:) = conform(colist(ii,:),shaden,1)
     end if
   end if

   if (shadep_set.and.any(cnlvls.ge.highval)) then     
     ii := ind(cnlvls.ge.highval)+1
     ii_dims = dimsizes(ii)
     if(shade_type.eq."pattern") then
       colist(ii) = shadep
     elseif(ii_dims.eq.1) then
       colist(ii,:) = shadep
     else
       colist(ii,:) = conform(colist(ii,:),shadep,1)
     end if
   end if

   if (shadem_set.and.any(cnlvls.ge.lowval.and.cnlvls.le.highval)) then
     ii := ind(cnlvls.ge.lowval.and.cnlvls.le.highval)
     ii_dims = dimsizes(ii)
     if(shade_type.eq."pattern") then
       colist(ii) = shadem
     elseif (ii_dims.ge.2) then
       colist(ii(1:),:) = conform(colist(ii(1:),:),shadem,1)
     else
       print("gsn_contour_shade: 1 contour level or less found between "+lowval+" and "+highval+", not color filling")
     end if
   end if

   if (shade_type.eq."color") then
	 setvalues idstring               
	    "cnFillOn"          : True
            "cnMonoFillPattern" : True
            "cnMonoFillColor"   : False
            "cnFillColors"      : colist			   
	 end setvalues
   else
	 setvalues idstring               
	    "cnFillOn"          : True
            "cnMonoFillColor"   : True
            "cnMonoFillPattern" : False
            "cnFillPatterns"    : colist	   
            "cnFillDotSizeF"    : dot_size
            "cnFillScaleF"      : fill_scale
	 end setvalues
   end if
   return (plot)
end
