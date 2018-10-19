;--------------------------------------------------
; datagrid_1.ncl
;--------------------------------------------------
; Concepts illustrated:
;   - Drawing a rectilinear lat/lon grid using gsn_coordinates
;--------------------------------------------------
;
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"  
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"  

begin
;---Read netCDF file
  in   = addfile("$NCARG_ROOT/lib/ncarg/data/cdf/uv300.nc","r")
  u    = in->U(0,:,:)

;---Start the graphics.
  wks = gsn_open_wks("png","datagrid")             ; send graphics to PNG file

  res               = True                        ; plot mods desired

  res@gsnMaximize   = True                        ; maximize plot size
  res@gsnDraw       = False                       ; don't draw yet
  res@gsnFrame      = False                       ; don't advance frame

;---Create three maps to work with
  res@tiMainString  = "Rectilinear grid (lat/lon grid plotted as points)"
  map1 = gsn_csm_map(wks,res)

  res@tiMainString  = "Rectilinear grid (lat/lon grid plotted as lines)"
  map2 = gsn_csm_map(wks,res)

  res@tiMainString  = "Rectilinear grid (every 3rd lat/lon line plotted)"
  map3 = gsn_csm_map(wks,res)

;
; gsn_coordinates will examine "u" to see if it has lat/lon coordinate
; arrays (which it does in this case). These will be used to
; draw the lat/lon lines.
  pres                   = True
  pres@gsMarkerSizeF     = 5
  gsn_coordinates(wks,map1,u,pres)

  pres@gsnCoordsAsLines  = True
  gsn_coordinates(wks,map2,u,pres)

  gsn_coordinates(wks,map3,u(::3,::3),pres)

end
