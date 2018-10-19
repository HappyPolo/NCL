;*************************************************
; lcmask_2.ncl
;
; Concepts illustrated:
;   - Drawing filled contours over a masked Lambert Conformal map
;   - Turning off the border of a masked Lambert Conformal plot
;   - Maximizing the size of the plot

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
  a = addfile("atmos.nc","r")
  t = a->V
;************************************************
; create plot
;************************************************
  wks = gsn_open_wks("png","lcmask")            ; send graphics to PNG file

  res                       = True              ; plot mods desired
  res@mpProjection          = "LambertConformal"; choose projection
  res@mpFillOn              = False             ; turn off map fill

  res@cnFillOn              = True              ; turn on color
  res@cnLinesOn             = False             ; turn off contour lines
  res@cnFillPalette         = "BlWhRe"          ; set color map

  res@cnLevelSelectionMode  = "ManualLevels"    ; set manual contour levels
  res@cnMinLevelValF        =  -40              ; set min contour level
  res@cnMaxLevelValF        =   40              ; set max contour level
  res@cnLevelSpacingF       =   4               ; set contour spacing

  res@gsnAddCyclic          = False             ; regional plot
  res@gsnMaximize           = True              ; enlarge plot

  res@mpMinLatF             = 20                ; min lat to mask
  res@mpMaxLatF             = 80                ; max lat to mask
 
  res@mpMinLonF             = -90               ; min lon to mask
  res@mpMaxLonF             = 40                ; max lon to mask

  res@gsnMaskLambertConformal = True            ; turn on lc masking
  res@gsnMaskLambertConformalOutlineOn  = False ; turns off outline

  t&lon = t&lon-180                             ; make lon go -180 to 180 
; subset data going into the plot template so that the colorbar reflects only
; the data viewed vice the entire data set
  plot  = gsn_csm_contour_map(wks,t(0,0,{20:80},{-90:40}),res); create plot
end
