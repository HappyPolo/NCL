;*************************************************
; zonal_7.ncl
;
; Concepts illustrated:
;   - Attaching a zonal means plot to a cylindrical equidistant contour plot
;   - Customzing the look of a zonal means plot
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
  ts = in->TS(0,:,:)
;************************************************
; plotting
;************************************************
  wks  = gsn_open_wks("png","zonal")            ; send graphics to PNG file
  
  res                 = True		        ; make plot mods
  res@tiMainString    = "Zonal Average"         ; Title for the plot
  
  res@gsnDraw         = False
  res@gsnFrame        = False

  plot = gsn_csm_contour_map(wks,ts,res)        ; plot temp contours 

  zres                      = True

; Set some resources for the zonal means plot
  zres@trXMinF              = 240.      ; Could also use gsnZonalMeanXMinF
  zres@trXMaxF              = 315.      ; Could also use gsnZonalMeanXMaxF
  zres@trYMinF              = -90
  zres@trYMaxF              =  90

  zres@gsnZonalMeanYRefLine = 273.15

; Indicate where we want tickmarks.
  zres@tmXBMode             = "Explicit"
  zres@tmXBValues           = (/240,273.15,315/)
  zres@tmXBLabels           = zres@tmXBValues + ""   ; Make it a string
  zres@tmXBLabelFontHeightF = 0.01                   ; Make slightly smaller.
  zres@tmXBLabelFontColor   = "Blue" 

  zres@vpWidthF             = 0.1
  zonal_id = gsn_csm_attach_zonal_means(wks,plot,ts,zres)

  draw(plot)
  frame(wks)

end


