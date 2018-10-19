;--------------------------------------------------
; mapgrid_5.ncl
;--------------------------------------------------
; Concepts illustrated:
;   - Attaching polylines to a map plot
;   - Drawing a lat/lon grid
;--------------------------------------------------
;
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"  
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"  

begin
;---Read netCDF file
  in   = addfile("$NCARG_ROOT/lib/ncarg/data/cdf/uv300.nc","r")
  u    = in->U

;---Start the graphics.
  wks = gsn_open_wks("png","mapgrid")             ; send graphics to PNG file

  res               = True                        ; plot mods desired

  res@gsnMaximize   = True                        ; maximize plot size
  res@gsnDraw       = False                       ; don't draw yet
  res@gsnFrame      = False                       ; don't advance frame
  res@tiMainString  = "Grid of two dimensional data"

  res@pmTickMarkDisplayMode = "Always"            ; nice tickmark labels

;---Create map (don't draw it yet)
  map = gsn_csm_map_ce(wks,res)

;---Call function to attach lat/lon lines. Only use every third line.
  pres                   = True
  pres@gsnCoordsAsLines  = True        ; Default is points
  gsn_coordinates(wks,map,u(0,::3,::3),pres)
end
