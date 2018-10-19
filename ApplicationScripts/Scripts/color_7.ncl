;*************************************************
; color_7.ncl
;
; Concepts illustrated:
;   - Paneling three plots vertically on a page
;   - Making the labelbar be vertical
;   - Selecting a different color map
;   - Drawing zonal average plots
;   - Adding attributes to a variable
;   - Changing the center longitude for a cylindrical equidistant projection
;   - Turning off the addition of a longitude cyclic point
;   - Explicitly setting the fill colors for contours
;************************************************
; Note that the reassignment operator, ":-" is
; used in this script. You must have NCL version
; 6.2.0 or later for this to work. Otherwise,
; you need to call "delete(res@cnFillColors)".
;************************************************
;
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl" 
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
;************************************************
begin
;************************************************
; read in netCDF file
;************************************************
  a = addfile("ANN_MEAN.nc","r")
  OLR = a->OLR
  ABS = a->ABS
  NET = a->NET
;************************************************
; The variables had no attributes. Manually specify.
;************************************************
  OLR@long_name = "Outgoing Longwave Radiation"
  ABS@long_name = "Absorbed Solar Radiation"
  NET@long_name = "Net (R)"
  OLR@units     = "(W/m2)"
  ABS@units     = "(W/m2)"
  NET@units     = "(W/m2)"
;************************************************
; create plot
;************************************************
  wks = gsn_open_wks("png","color")         ; send graphics to PNG file
  gsn_define_colormap(wks,"uniform")        ; define color map
  plot = new(3,graphic)                     ; create graphic array

  res                 = True                ; Use plot options

  res@cnFillOn        = True                ; Fill contours
  res@lbOrientation   = "Vertical"          ; Label bar to side 

  res@mpFillOn        = False               ; turn off map fill
  res@mpCenterLonF    = 180                 ; Centers the plot at 180
 
  res@cnLevelSelectionMode = "ManualLevels" ; set manual contour levels

  res@gsnDraw         = False               ; Do not draw plot
  res@gsnFrame        = False               ; Do not advance frame

  res@gsnZonalMean    = True                ; Draw a Zonal mean
  res@gsnAddCyclic    = False               ; Data already has cyclic point
	
  res@gsnCenterString = "T63"               ; Specify resolution
;******************************************
; plot 1
;******************************************
  res@cnMinLevelValF  = 60.                 ; set min contour level
  res@cnMaxLevelValF  = 340.                ; set max contour level
  res@cnFillColors    = (/1,20,10,8,79,74,73,72,106,71,141,51,66,67,68,1/)
  plot(0) = gsn_csm_contour_map(wks,ABS, res)  
;******************************************
; plot 2
;******************************************
  res@cnMinLevelValF  = 140.                ; set min contour level
  res@cnMaxLevelValF  = 280.                ; set max contour level

  res@cnFillColors    := (/79,74,73,72,106,71,141,51,66/)
  plot(1) = gsn_csm_contour_map(wks,OLR, res) 
;******************************************
; plot 3
;******************************************
  res@cnMinLevelValF  = -120.               ; set min contour level
  res@cnMaxLevelValF  =  80.                ; set max contour level

  res@cnFillColors    := (/20,10,8,79,74,73,72,106,71,141,51,66/)
  plot(2) = gsn_csm_contour_map(wks,NET, res) 
;******************************************
; panel plot
;******************************************
  pres             = True                    ; panel mods desired
  pres@gsnMaximize = True                    ; fill the page
  gsn_panel(wks,plot,(/3,1/),pres)           ; draw: 2-across, 2-down

end
