;*******************************************************
; conOncon_5.ncl
;
; Concepts illustrated:
;   - Overlaying individual contour lines on a polar stereographic map
;   - Drawing a spaghetti contour plot
;   - Increasing the thickness of contour lines
;   - Explicitly setting contour levels
;   - Changing the color of a contour line
;*******************************************************
;
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
;*******************************************************
begin
  f    = addfile("HGT500_MON_1958-1997.nc","r")
  x    = f->HGT                         
;*******************************************************
; create plot
;*******************************************************
  wks    = gsn_open_wks("png","conOncon")            ; send graphics to PNG file
  plots  = new(20,graphic)                           ; create graphical array
  colors = (/ "red", "green", "blue", "yellow", "cyan", "hotpink", \
  "red4", "skyblue", "navyblue", "lightyellow", "mediumorchid4", "orange", \
  "slateblue3", "palegreen", "magenta", "springgreen", "pink", \
  "forestgreen", "violet" /)

  res                      = True        ; plot mods desired
  res@gsnMaximize          = True        ; make as large as possible
  res@gsnDraw              = False       ; do not draw until the end
  res@gsnFrame             = False       ; do not automatically advance 'frame'
  res@gsnPolar             = "NH"        ; choose which hemisphere

  res@cnLevelSelectionMode = "ExplicitLevels" ; explicit contour levels
  res@cnLevels             = 5500             ; which level(s) to plot
  res@cnInfoLabelOn        = False            ; no info label
  res@cnLineLabelsOn       = False            ; no line labels

; 1st plot generates the map + 1st contour

  res@cnLineThicknessF     = 3                ; thickness of contour lines
  res@tiMainString         = "Spaghetti Plot" ; title 

  plot_base = gsn_csm_contour_map_polar(wks,x(0,:,:),res)

  delete (res@gsnPolar)        ; avoid annoying warning messages
;*******************************************
; loop over other fields but only do contour
; note the color index is changing. here we are selecting a new
; color from the default color map.
;******************************************

  res@gsnLeftString    = ""  ; suppress automatic labels
  res@gsnRightString   = ""
  res@cnLineThicknessF = 1
  
  do i=0,18                    ; loop over the number of plots
    res@cnLineColor      = colors(i)     ; change line color 
    plots(i) = gsn_csm_contour(wks,x(12*i+1,:,:),res)
    overlay(plot_base,plots(i))
  end do

  draw(plot_base)
  frame(wks)
end
