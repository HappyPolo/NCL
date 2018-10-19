;----------------------------------------------------------------------
; coneff_7.ncl
;
; Concepts illustrated:
;   - Drawing pressure/height contours
;   - Selectively shading between contour levels
;   - Paneling four plots on a page
;----------------------------------------------------------------------
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
;----------------------------------------------------------------------

begin

;---Get data
 f     = addfile("atmos.nc","r") 
 u     = f->U(0,:,:,:)       

;---Convert to pressure levels
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
 
  uzon=u_int(:,:,0)
  uzon=dim_avg(u_int)
 
;---Plot parameters
 wks   = gsn_open_wks ("png", "coneff" )          ; open workstation and send to PNG file

 res                 = True                       ; plot mods desired
 res@gsnDraw         = False                      ; do not draw  
 res@gsnFrame        = False                      ; do not advance frame
 res@cnLevelSpacingF = 4.0                        ; contour level spacing
 res@cnInfoLabelOn   = False                      ; turn off contour label

 plot                = new(4,graphic)             ; create a graphical array

;---Create first plot
 res@gsnCenterString = "< 4 shaded"
 plot(0) = gsn_csm_pres_hgt(wks, uzon, res )

;---Add shading to first plot
 opt                  = True
 opt@gsnShadeFillType = "pattern"
 opt@gsnShadeLow      = 3 
 plot(0) = gsn_contour_shade(plot(0), 4.1, 25., opt)
 delete(opt)

;---Create second plot
  res@gsnCenterString = "> 16 shaded"
  plot(1) = gsn_csm_pres_hgt(wks, uzon, res ) 

;---Add shading to second plot
  opt                  = True
  opt@gsnShadeFillType = "pattern"
  opt@gsnShadeHigh     = 1
  plot(1) = gsn_contour_shade(plot(1), 0, 15.5, opt)
  delete(opt)

;---Create third plot
  res@gsnCenterString = "< 0 shaded AND > 24 shaded"
  plot(2) = gsn_csm_pres_hgt(wks, uzon, res ) 

;---Add shading to third plot
  opt                  = True
  opt@gsnShadeFillType = "pattern"
  opt@gsnShadeLow      = 7
  opt@gsnShadeHigh     = 8
  plot(2) = gsn_contour_shade(plot(2),0.1,22.5,opt)
  delete(opt)

;---Create fourth plot
  res@gsnCenterString = "Between 0 and 8 shaded"
  plot(3) = gsn_csm_pres_hgt(wks, uzon, res ) 

;---Add shading to fourth plot
  opt                  = True
  opt@gsnShadeFillType = "pattern"
  opt@gsnShadeMid      = 10
  plot(3) = gsn_contour_shade(plot(3),1.,10.,opt)

;---Panel all four plots
  resP             = True                            ; panel mods desired
  resP@gsnMaximize = True                            ; fill up the page
  gsn_panel(wks,plot,(/2,2/),resP)                     
end
