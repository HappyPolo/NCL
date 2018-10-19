;*************************************************
; zonal_3.ncl
;
; Concepts illustrated:
;   - Attaching a zonal means plot to a cylindrical equidistant contour plot
;************************************************
;
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
;************************************************
begin
;************************************************
; variable and file handling
;************************************************
  in  = addfile("83.nc","r") 
  ts = in->TS                                   ; select variable to ave
;************************************************
; plotting
;************************************************
  wks  = gsn_open_wks("png","zonal")            ; send graphics to PNG file
  
  res                 = True		        ; make plot mods
  res@tiMainString    = "Zonal Average"         ; Title for the plot
  res@gsnZonalMean    = True                    ; put zonal on side
  res@gsnZonalMeanXMinF = 240.			; set minimum X-axis value for zonal mean plot  
  res@gsnZonalMeanXMaxF = 315.			; set maximum X-axis value for zonal mean plot  
  res@gsnZonalMeanYRefLine = 273.15		; set reference line X-axis value
  
  plot=gsn_csm_contour_map(wks,ts(0,:,:),res)   ; plot temp contours 
;***********************************************
end


