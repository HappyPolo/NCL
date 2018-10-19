;*************************************************
; NCL Graphics: polar_2.ncl
;
; Concepts illustrated:
;   - Drawing black-and-white contours over a polar stereographic map
;   - Drawing the northern hemisphere of a polar stereographic map
;
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
  a = addfile("$NCARG_ROOT/lib/ncarg/data/cdf/uv300.nc","r")
;************************************************
; read in zonal winds
;************************************************
  u = a->U(1,:,:)                                  ; read July zonal winds
;************************************************
; create plot
;************************************************
  wks = gsn_open_wks("png","polar")                ; send graphics to PNG file
  res = True                                       ; plot mods desired

  res@cnLevelSelectionMode = "ManualLevels"        ; set manual contour levels
  res@cnMinLevelValF       = -10.                  ; set min contour level
  res@cnMaxLevelValF       =  35.                  ; set max contour level
  res@cnLevelSpacingF      =   5.                  ; set contour spacing
  res@tiMainString         = "CCM2 T42 July"       ; plot title
  res@gsnCenterString      = "300 mb"              ; plot center string
  res@gsnFrame             = False                 ; Do not draw plot 
  res@gsnDraw              = False                 ; Do not advance frame


  plot=new(2,graphic)                              ; create graphic array

  res@gsnPolar   = "NH"                            ; select the N. Hem.
  plot(0) = gsn_csm_contour_map_polar(wks,u, res)  ; create plot zero

  delete(res@gsnPolar)                             ; delete previous option
  res@gsnPolarSH = True                            ; specify the hemisphere
  plot(1) = gsn_csm_contour_map_polar(wks,u, res)  ; create plot one
;***********************************************
; create panel plot
;***********************************************
  pres                            = True        ; panel plot mods desired
  pres@gsnPanelYWhiteSpacePercent = 5           ; increase white space around
                                                ; indiv. plots in panel
  pres@gsnMaximize                = True        ; fill the page

  gsn_panel(wks,plot,(/2,1/),pres)              ; create panel plot
  end
