;================================================
;  lb_2.ncl
;================================================
;
; Concepts illustrated:
;   - Making the labelbar be vertical
;   - Changing the labelbar labels
;   - Setting color maps using the new standard
;
;================================================
;
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl" 
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"   
;************************************************
begin
;************************************************
; open netCDF file and read in data
;************************************************
  in = addfile("atmos.nc","r")
  v  = in->V
;************************************************
; create plot
;************************************************
  wks = gsn_open_wks("png","lb")            ; send graphics to PNG file

  res               =   True
  res@cnFillOn      =   True                ; turn on color 
  res@cnFillPalette =   "wgne15"            ; set color map
  res@lbOrientation =   "vertical"          ; vertical label bar
  res@lbLabelStrings =  (/"-70","-50","-30","-10","10","30","50","70",\
	"90","110","130","150"/) 
  contour = gsn_csm_contour_map_ce(wks,v(0,3,:,:),res)  ; create the plot
end
