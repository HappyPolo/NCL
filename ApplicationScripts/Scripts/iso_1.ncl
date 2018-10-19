;*************************************************
; NCL Graphics: iso_1.ncl
;
; Concepts illustrated: 
;   - Using "int2p_n_Wrap" to interpolate to user specified levels
;   - Drawing contour plot over a map
;************************************************
;
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"

begin
;************************************************
; read POP netCDF file
;************************************************
 b = addfile("gx1v3.210.pop.h.0001-01.nc","r")
 ;b = addfile("gx1v3.TEMP.nc","r")

;************************************************
; oceanic data to plot
;************************************************
  x     = b->TEMP         ; (time,z_t,nlat,nlon) [deg C]
  z_t   = b->z_t

;************************************************
; Interpolate to specific [constant] depths
; The returned vertical coordinate is Z_T
;************************************************
  zlev = (/ 735, 12580/)    ; cm
  zlev@units = z_t@units
  zlev!0 = "zlev"
  isox = int2p_n_Wrap(z_t,x, zlev, 0, 1)

  printVarSummary(isox) ; [time | 1] x [zlev | 2] x [nlat | 384] x [nlon | 320]  
  printMinMax(isox, True) 
 
;************************************************
; Interpolate to specific [constant] TEMP levels
; The default returned vertical coordinate is Z_T but change to 'tlev'
;************************************************
  tlev    = (/ 13.5 , 18/)    ; same units [here, C] as TEMP
  tlev@units = x@units
  tlev!0     = "tlev"

  depth   = conform(x, z_t, 1)
  copy_VarCoords(x, depth)
  printVarSummary(depth)
  
  isot    = int2p_n_Wrap(x,depth, tlev, 0, 1)

 ;printVarSummary(isot) ; [time | 1] x [tlev | 2] x [nlat | 384] x [nlon | 320]  
 ;printMinMax(isot, True) 

;************************************************ 
; create plot
;************************************************
  plot = new( 2, "graphic")

  wks = gsn_open_wks("png","iso")                 ; send graphics to PNG file

  res                      = True                 ; plot mods desired
  res@gsnDraw              = False
  res@gsnFrame             = False
  res@cnFillOn             = True                 ; turn on color fill
  res@cnFillPalette        = "BlAqGrYeOrReVi200"  ; set color map
  res@cnLinesOn            = False                ; turn off contour lines
  res@mpCenterLonF         = 210                  ; center map at 210
  res@lbLabelAutoStride    = True  
  res@lbOrientation        = "vertical"
  res@gsnAddCyclic         = True                 

  resP = True
  resP@gsnMaximize         = True                 ; make as large as possible   
  resP@gsnPaperOrientation = "portrait"           ; force portrait

  isox@lat2d = b->TLAT         ; used in graphics
  isox@lon2d = b->TLONG

  do kl=0,dimsizes(zlev)-1
     res@gsnCenterString   = "lev="+zlev(kl)+" cm"
     plot(kl) = gsn_csm_contour_map_ce(wks,isox(0,kl,:,:),res)  
  end do
  resP@txString            = "TEMP at User Specified Depths "
  gsn_panel(wks, plot, (/2,1/), resP)
  delete(isox)

  isot@lat2d = b->TLAT         ; used in graphics
  isot@lon2d = b->TLONG

  do kt=0,dimsizes(tlev)-1
     res@gsnCenterString   = "tlev="+tlev(kt)+" C"
     plot(kt) = gsn_csm_contour_map_ce(wks,isot(0,kt,:,:),res)   
  end do
  resP@txString            = "DEPTH of Specified TEMP Levels"
  gsn_panel(wks, plot, (/2,1/), resP)
end

