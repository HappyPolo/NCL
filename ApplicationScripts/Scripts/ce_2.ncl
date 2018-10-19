;*************************************************
; ce_2.ncl         
;
; Concepts illustrated:
;   - Drawing black-and-white contours over a cylindrical equidistant map
;   - Setting contour levels using a min/max contour level and a spacing
;   - Moving the contour informational label into the plot
;   - Creating a main title
;   - Creating a center subtitle
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
  u = a->U(1,:,:)                                ; read July zonal winds
;************************************************
; create plot
;************************************************
  wks = gsn_open_wks("png","ce")                ; send graphics to PNG file
  res = True                                    ; plot mods desired

  res@cnLevelSelectionMode = "ManualLevels"     ; set manual contour levels
  res@cnMinLevelValF       = -10.               ; set min contour level
  res@cnMaxLevelValF       =  35.               ; set max contour level
  res@cnLevelSpacingF      =   5.               ; set contour spacing

  res@tiMainString         = "CCM2 T42 July"    ; plot title
  res@gsnCenterString      = "300 mb"           ; plot center string

  res@cnInfoLabelOrthogonalPosF = -0.07         ; move the label inside the plot

  plot = gsn_csm_contour_map(wks,u, res)  ; create plot
end
