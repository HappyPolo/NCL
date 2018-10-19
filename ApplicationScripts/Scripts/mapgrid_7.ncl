;--------------------------------------------------
; mapgrid_7.ncl
;--------------------------------------------------
; Concepts illustrated:
;   - Drawing a WRF lat/lon grid using gsn_coordinates
;--------------------------------------------------
;
;
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/wrf/WRFUserARW.ncl"

begin
  a = addfile("wrfout_d01_2003-07-15_00:00:00.nc","r")

  wks = gsn_open_wks("png","mapgrid") ; send graphics to PNG file

  res              = True
  res@gsnMaximize  = True
  res@gsnDraw      = False
  res@gsnFrame     = False

  res@tiMainString = "Drawing WRF grid as lines"

;---Set some resources for correctly drawing WRF map.
  res = wrf_map_resources(a,res)    ; This will produce some warnings
                                    ; which you can ignore

;---Create plot, but don't draw it yet.
  plot = gsn_csm_map(wks,res)

;
; The hgt variable is arbitrary. Just need something to hold the
; lat/lon arrays.
;
  hgt       = wrf_user_getvar(a,"HGT",0)
  hgt@lat2d = wrf_user_getvar(a,"XLAT",0)
  hgt@lon2d = wrf_user_getvar(a,"XLONG",0)
 
;---Call function to attach lat/lon lines.
  pres                   = True
  pres@gsnCoordsAsLines  = True        ; Default is points
  gsn_coordinates(wks,plot,hgt,pres)
end
