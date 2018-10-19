;----------------------------------------------------------------------
; h_lat_7.ncl
;----------------------------------------------------------------------
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"   
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"   
;----------------------------------------------------------------------
begin

;---Read in variables
  fi   = addfile("atmos.nc","r")
  T    = fi->T             ; temperature (K)
  V    = fi->V             ; meridional wind (m/s)
  Z    = fi->Z3            ; geopotl. height in m
  omega= fi->OMEGA         ; vert. pres. vel.(mb/day)
  lev  = T&lev             ; pressure levels (millibars)
  q = fi->Q                ; spec. humidity (g/kg)
  q = 1.e-3*q              ; change units to kg/kg
  lev = 100*lev            ; change units to Pa

;---Calculate moist static energy (h)
  g   = 9.81        
  L   = 2.5e6  
  Cp  = 1004.

  h = T                               ; trick to keep cv's
  h = Cp*T + g*Z + L*q  
  h = 1.e-3*h                         ; Convert to kJ/kg
  h@units = "kJ/kg"
  h@long_name = "Moist Static Energy"

;---Convert h and omega to pressure levels
  hyam =   fi->hyam         
  hybm =   fi->hybm
  P0mb =   fi->P0*0.01
  ps   =   fi->PS           
  lat  =   fi->lat                              
  lev_p           = (/300,400,500,600,700,800,900,1000/)
  lev_p@units     = "hPa"                        ; required for vinth2p

  hp   = vinth2p (h, hyam,hybm, lev_p ,ps, 2, P0mb, 1, False )
  hp@units = "kJ/kg"
  hp@long_name = "Moist Static Energy"

  op   = vinth2p (omega, hyam,hybm, lev_p ,ps, 2, P0mb, 1, False )
  vp   = vinth2p (V, hyam,hybm, lev_p ,ps, 2, P0mb, 1, False )
;*************************************
; Set v equal to zero so that we plot
; only the vertical component.
;*************************************
  vp = 0.

;Note: the vector components, omega (mb/day) and v (m/s)
;      which represent the vertical and meridional components 
;      have different units. No scaling is used in this example
;      but the user may wish do do so.
;***************************************
; PLOT
;**************************************
  wks   = gsn_open_wks ("png", "h_lat" )          ; send graphics to PNG file
  
  cmap = read_colormap_file("wh-bl-gr-ye-re")
  nc   = dimsizes(cmap(:,0))
  res                      = True
  res@tiMainString         = "Pressure/Height Vector Example"
  res@cnFillPalette        = cmap(10:nc-3,:)
  res@cnFillOn             = True                ; color on
  res@cnLevelSelectionMode = "ManualLevels"      ; manual contouring
  res@cnMinLevelValF       = 300.0               ; set min contour level
  res@cnMaxLevelValF       = 335.0               ; set max contour level
  res@cnLevelSpacingF      = 2                   ; set contour spacing
  res@lbLabelStride        = 2                   ; every other label bar label

  res@vcRefAnnoOrthogonalPosF  = -0.165          ; move reference vec up
  res@pmLabelBarOrthogonalPosF = -0.05           ; move color label bar up
  res@vcRefMagnitudeF           = 0.04           ; define vector ref mag
  res@vcRefLengthF              = 0.045          ; define length of vec ref
  res@vcMapDirection           = False

  plot  = gsn_csm_pres_hgt_vector(wks, hp(0,{1000:300},{-30:30},{210}) \
                                     , vp(0,{1000:300},{-30:30},{210}) \
                                     , op(0,{1000:300},{-30:30},{210})\
                                     , res )
end
