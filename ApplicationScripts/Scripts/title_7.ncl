;----------------------------------------------------------------------
; title_7.ncl
;
; Concepts illustrated:
;   - Moving the X and Y axis strings to a different side
;   - Changing the angle of the X axis string
;----------------------------------------------------------------------
;
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"

begin
;---Read in netCDF file
  a = addfile("$NCARG_ROOT/lib/ncarg/data/cdf/uv300.nc","r")
  u = a->U(0,:,7)

  wks = gsn_open_wks("png","title")   

  res                 = True              ; plot mods desired
  res@gsnDraw = False                     ; don't draw the plots, gsn_panel will draw them
  res@gsnFrame = False                    ; don't advance the frame, gsn_panel will
  res@gsnStringFontHeightF = 0.03		  ; set the gsnLeft/Center/RightString font height

  plot = new(2,graphic)                   ; preallocate graphics array for two panel plots

  res@tiYAxisOn = False	
  res@gsnLeftString   = "Wind Speed"      ; add the gsn titles
  res@gsnCenterString = "June"
  res@gsnRightString  = "mm/day"
  plot(0)=gsn_csm_xy(wks,u&lat,u,res)             ; create xy plot
  
;  For the plot drawn above, gsnCenterString is not level vertically with  
;  the other strings, due to the letters p and y "raising" the center of the Left/Right
;  strings. You can manually raise the CenterString to be on the same plane by setting
;  gsnCenterStringOrthogonalPosF appropriately
  
  res@gsnCenterStringOrthogonalPosF = .020		; raise the CenterString slightly

  plot(1)=gsn_csm_xy(wks,u&lat,u,res)             ; create xy plot
  
  panres = True                                   ; panel resource list
  panres@gsnMaximize = True
  panres@gsnPanelYWhiteSpacePercent = 5.0         ; set spacing vertically between 2 panels
   gsn_panel(wks,plot,(/1,2/),panres)  
end

