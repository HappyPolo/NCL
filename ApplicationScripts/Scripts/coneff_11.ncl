;***********************
; coneff_11.ncl
;
; Concepts illustrated:
;   - Filling contours with multiple shaded patterns
;   - Filling contours with stippling (solid dots)
;   - Changing the size of the dot fill pattern in a contour plot
;   - Changing the density of contour shaded patterns
;
;***********************
;
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
;
; This file still has to be loaded manually
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl"
;===========================
begin
;*************************
; get data
;*************************
 f     = addfile("atmos.nc","r") 
 u     = f->V(0,0,:,:)       
;===========================
; plot parameters
;===========================
 wks   = gsn_open_wks ("png", "coneff" )     ; open workstation and send data to PNG file

 res                      = True             ; plot mods desired
 res@cnFillOn             = True             ; fill contour intervals

 res@cnLevelSelectionMode = "ManualLevels"   ; manually specify contour levels
 res@cnMinLevelValF       = -35.             ; min level
 res@cnMaxLevelValF       =  35.             ; max level
 res@cnLevelSpacingF      =  10              ; contour interval
 res@cnSpanFillPalette    = False            ; don't span the full color map
 res@cnFillPalette        = "default"        ; This colormap will be used for the dots
 
 res@cnMonoFillPattern    = False            ; want multiple patterns 
 res@cnFillPatterns       = (/3,3,3,3,-1,17,17,17,17/) ; the patterns
 res@cnMonoFillScale      = False            ; want different densities 
 res@cnFillScales         = (/.1,.2,.3,.4,1,1,1.5,2.0,2.5/) ; the densities

 res@tiMainString         = "Default dot size"
 plot = gsn_csm_contour(wks, u, res ) 
                    
; second plot. increase the size of the stippling dot pattern (#17). Note
; that you have to set it for the label bar as well.         
 res@cnFillDotSizeF       = 0.005            ; increase dot size of contours
 res@tiMainString         = "Increased to 0.005"
 plot = gsn_csm_contour(wks, u, res ) 
end
