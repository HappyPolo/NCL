;***********************************************
; precip_1.ncl
;***********************************************
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"

begin
;************************************************
; Read the file
;************************************************
  a    = addfile("xieArkin-T42.nc","r")
  prc  = a->prc                                 ; (time,lat,lon)
  time = a->time                                ; (time) ==> YYMM
  ntim = dimsizes(time)

  months = (/"January", "February", "March", "April" \
            ,"May", "June", "July", "Auguat"         \
            ,"September", "October", "November"      \
            ,"December" /)
;************************************************
; Compute the climatology using a function in contributed.ncl
;************************************************
  prcClm = clmMonTLL (prc)            ; monthly climatology
  prcStd = stdMonTLL (prc)            ; monthly interannual variability
;************************************************
; create colors
;*************************************************
  wks = gsn_open_wks("ps","precip")             ; open a workstation

  colors = (/"white","black"             \      ; back/fore ground
            ,"azure1","beige","lavender" \
            ,"PaleGreen","SeaGreen3","LightYellow" \
            ,"Yellow","HotPink","Red"/)         ; choose colors for color map
  gsn_define_colormap(wks, colors)              ; generate new color map
;************************************************
; create panel plots
;*************************************************
  plot   = new (4 , graphic)                    ; create graphical array

  res                      = True               ; plot options desired

  res@cnFillOn             = True               ; turn on color fill
  res@cnInfoLabelOn        = False              ; turn off contour info label
  res@cnLinesOn            = False              ; turn off contour lines
  res@cnLineLabelsOn       = False              ; turn off line labels
  res@cnLevelSelectionMode = "ExplicitLevels"   ; set explicit contour levels
  res@cnLevels             = (/ 0.5, 1.0, 2.0 \ ; set unequal contour levels
                              , 3.0, 4.0, 5.0 \
                              , 7.5,10.0 /)

  res@mpFillOn             = False              ; turn off gray continents
  res@mpCenterLonF         = 180                ; Centers the plot at 180 
 
  res@lbLabelBarOn         = False              ; No single label bar

  res@gsnDraw              = False
  res@gsnFrame             = False

  resP                     = True               ; panel options
  resP@txString            = "CPC Merged Prc: Climatology"   ; common title
  resP@gsnMaximize         = True               ; maximize image
  resP@gsnPanelLabelBar    = True               ; Add common label bar 

  i = -1                                        ; Climatologies
  do nmo=0,11,3                                 ; loop over the months
     i = i+1
     res@gsnCenterString   = months(nmo)+":"+time(0)/100 +"-"+ time(ntim-1)/100
     plot(i) = gsn_csm_contour_map_ce(wks,prcClm(nmo,:,:), res)  ; create plot
  end do

  gsn_panel(wks,plot,(/2,2/),resP)
;************************************************
; create second panel plot
;*************************************************
  i = -1                                        ; Std Deviations
  do nmo=0,11,3                                 ; loop over the months
     i = i+1
     res@gsnCenterString   = months(nmo)+":"+time(0)/100 +"-"+ time(ntim-1)/100
     plot(i) = gsn_csm_contour_map_ce(wks,prcStd(nmo,:,:), res)  ; create plot
  end do

  gsn_panel(wks,plot,(/2,2/),resP)

end
