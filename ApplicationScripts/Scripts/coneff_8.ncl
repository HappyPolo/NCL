;***********************
; coneff_8.ncl
;
; Concepts illustrated:
;   - Drawing pressure/height contours
;   - Selectively coloring between contour levels (using an old method)
;
;***********************
;
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
;===========================
begin
;*************************
; get data
;*************************
 f     = addfile("atmos.nc","r") 
 u     = f->U(0,:,:,:)       
;*************************
; convert to pressure levels
;*************************
  hyam   = f->hyam
  hybm   = f->hybm
  ps     = f->PS 
  p0     = 1000.
  pres3d      = (/1000,950,800,700,600,500,400,300,200/)
  pres3d@units= "mb"

  u_int=(/vinth2p(u,hyam,hybm,pres3d,ps(0,:,:),2,\
              p0,2,False)/)
  u_int!0    = "plev"
  u_int&plev = pres3d
  u_int!1    = "lat"
  u_int&lat  = u&lat
  u_int!2    = "lon"
  u_int&lon  = u&lon
  u_int@long_name = "Zonal Wind"
 
  uzon=u_int(:,:,0)
  uzon=dim_avg(u_int)
 
;===========================
; plot parameters
;===========================
 wks   = gsn_open_wks ("png", "coneff" )          ; open workstation and send data to PNG file
 res   = True                                     ; plot mods desired
 res@gsnDraw         = False                      ; do not draw  
 res@gsnFrame        = False                      ; do not advance frame
 res@cnLevelSpacingF = 4.0                        ; contour level spacing
 res@cnInfoLabelOn   = False                      ; turn off contour label
 
 plot = gsn_csm_pres_hgt(wks, uzon, res ) 
 opt = True
 opt@gsnShadeLow = "salmon"
 opt@gsnShadeHigh = "cyan"
 plot = gsn_contour_shade(plot,10.,20.,opt)

 draw(plot)
 frame(wks)

end
