;
; sol_2.ncl
;
; this code was based on the one contributed by joel norris from gfdl.
; sjm added some paneling and data processing as an example.
;
; he found a bug in NCL that causes the font sizes of the
; cylindrical equidistant plot to be too small when a global 
; plot of the tropics is drawn. 

; 8/29/00
; we have modified joel's original script with some new resources
; that make the code these bulky.
;**************************************************
;
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl" 
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
;
; This file still has to be loaded manually
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl"
;************************************************
begin
;************************************************
; read in netCDF file
;************************************************
  a = addfile("$NCARG_ROOT/lib/ncarg/data/cdf/uv300.nc","r")
;************************************************
; read in zonal winds
;************************************************
  u = a->U(1,:,:)                                ; read July zonal winds
  v = a->V(1,:,:)
;************************************************
; create plot
;************************************************
  wks = gsn_open_wks("png","sol")          ; send graphics to PNG file
  
  res               = True                 ; plot mods desired
  res@gsnDraw       = False                ; don't draw
  res@gsnFrame      = False                ; don't advance frame
  res@cnInfoLabelOn = False                ; turn off contour info label
  res@mpMinLatF     = -30.0		 ; only plot 30S to 30N
  res@mpMaxLatF     = 30.0
  res@tiMainString  = " "
  
; note: the plot manager chooses the font sizes and tickmark sizes of the 
; plot based on the aspect ratio chosen.  For this subregion, the default
; sizes are far too small, so they must be enlarged.  If a smaller longitude
; extent were chosen, this would probably not be an issue.
  
  res@tmXBMajorLengthF = 0.014	        ; resize tickmark lengths
  res@tmXBMinorLengthF = 0.007
  res@tmYLMajorLengthF = 0.014
  res@tmYLMinorLengthF = 0.007
  
  res@tmXBLabelFontHeightF = 0.014	; resize tick labels
  res@tmYLLabelFontHeightF = 0.014
  
; as a personal preference, limit the labeling of the y-axis
  
  res@gsnMajorLatSpacing = 30
  res@gsnMinorLatSpacing = 10
  
  res@txFontHeightF    = 0.017            ; resize the text
  res@amOrthogonalPosF = 0.15             ; move text up
  
  plot=new(4,graphic)
;*****************************************
; create the plot1
;*****************************************
  plot(0) = gsn_csm_contour_map(wks,u,res)	
  plot(0) = ZeroNegDashLineContour(plot(0)) 	
  
  plot(1) = gsn_csm_contour_map(wks,v,res)	
  plot(1) = ZeroNegDashLineContour(plot(1)) 	
  
  psi = u                                   ; trick to keep attributes
  chi = u
  uv2sfvpg(u,v,psi,chi)                     ; calculate psi and chi
  psi@long_name = "stream function"
  chi@long_name = "velocity potential"
  
  psi=(/ psi/1.e06 /)
  chi=(/ chi/1.e06 /)
  
  plot(2) = gsn_csm_contour_map(wks,psi,res)	
  plot(2) = ZeroNegDashLineContour(plot(2)) 	
  
  plot(3) = gsn_csm_contour_map(wks,chi,res)	
  plot(3) = ZeroNegDashLineContour(plot(3)) 	
;*****************************************
; create panel plot
;*****************************************
  gsn_panel(wks,plot,(/4,1/),False) 
end
