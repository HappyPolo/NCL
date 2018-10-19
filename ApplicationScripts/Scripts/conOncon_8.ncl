;***************************************************
; conOncon_8.ncl
;
; Concepts illustrated:
;   - Drawing a color significance plot
;   - Creating a color map using named colors
;   - Overlaying two sets of contours on a map
;   - Using "transparent" as a contour fill color
;   - Overlaying line contours on filled contours
;***************************************************
;
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
;***************************************************                          
begin
  f    = addfile ("slpDiffProb.nc", "r")         ; open the netCDF file
  diff = f->DIFF                                 ; (lat,lon,time)
  prob = f->PROB
  prob = 1.-prob                                    
;***************************************************
; plot
;***************************************************
  wks   = gsn_open_wks ("png", "conOncon" )                   ; send graphics to PNG file
;background,foreground,stippling,for continents
  colors = (/"white","black","magenta","LightGray"/)          ; create colormap using named colors
  gsn_define_colormap(wks, colors)
;****************************************************
; create first plot of probabiliites
;****************************************************
  res1                      = True                            ; res1 probability plots

  res1@lbLabelBarOn        = False                            ; turn off label bar
  res1@cnFillOn            = True                             ; turn on color
  res1@cnLinesOn           = False                            ; no contour lines
  res1@cnLineLabelsOn      = False                            ; do not draw contour labels
; we have to add transparent here, b/c even though we have one contour level, a color table always consists
; of the contoured colors, and all values outside of this range. w/o the transparent, the entire contour
; plot would be magenta.
  res1@cnFillColors        = (/"transparent","magenta"/)      ; choose one color for our single cn level

  res1@gsnDraw             = False                            ; do not draw plot yet
  res1@gsnFrame            = False                            ; do not advance frame yet

  res1@gsnLeftString       = diff@long_name                   ; add some titles
  res1@gsnRightString      = diff@units
  res1@gsnCenterString     = "prob>90%"
  res1@tiMainString        = "SLP Difference: 9099-7079"      ; title

  res1@cnLevelSelectionMode= "ExplicitLevels"                 ; set explicit contour levels
  res1@cnLevels            = 0.95                             ; only set one level

  plot1   = gsn_csm_contour_map_ce(wks,prob(:,:,0), res1) 

;***********************************************************
; second plot
;***********************************************************
  res2                     = True             ; plot mods desired

  res2@cnLevelSelectionMode = "ManualLevels"  ; set manual contour levels
  res2@cnMinLevelValF       = -6.             ; set min contour level
  res2@cnMaxLevelValF       =  6.             ; set max contour level
  res2@cnLevelSpacingF      =   1.            ; set contour spacing

  res2@cnInfoLabelOrthogonalPosF = 0.15       ; move label down out of 1st plt

  res2@gsnDraw              = False           ; Do not draw plot
  res2@gsnFrame             = False           ; Do not advance frome

  res2@gsnLeftString       = ""
  res2@gsnRightString      = ""
  res2@gsnCenterString     = ""

  plot2 = gsn_csm_contour(wks,gsn_add_cyclic_point(diff(:,:,0)), res2)  

  overlay (plot1, plot2)
  draw (plot1)
  frame(wks)

end

