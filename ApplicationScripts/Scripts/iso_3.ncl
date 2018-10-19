;*************************************************
; NCL Graphics: iso_3.ncl
;
; Concepts illustrated: 
;   - Calculate THETA and THETA_E
;   - Using "vinth2p" to interpolate to user specified pressure levels
;   - Using "int2p_n_Wrap" to interpolate to user specified temperature levels
;   - Drawing contour plot over a map
;************************************************
;
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"

begin
;************************************************
; read netCDF file with hybrid levels
;************************************************
  diri = "./"
  fili = "ccsm35.h0.0021-01.nc"
  f = addfile(diri+fili,"r")

;************************************************
; Read T, Q, PS, hybrid coeffients
;************************************************
  t    = f->T    ; K (time,lev,lat,lon)
  q    = f->Q    ; kg/kg
  ps   = f->PS   ; surface pressure [Pa]
  hyam = f->hyam ; mid-layer coef
  hybm = f->hybm 
  p0   = 100000. ; since ps is in Pa or [ f->P0]

;************************************************
; Calculate Potential Temperature 
;************************************************
; Technically, this is a nonlinear computation and it should have
;    been done at each time step and, then, averaged. But ...
;************************************************
  pm    = pres_hybrid_ccm(ps,p0,hyam,hybm)  
 ;copy_VarCoords(t, pm)
 ;pm@long_name = "pressure at mid-layers"
 ;pm@units     = ps@units
 ;printVarSummary(pm)
 ;printMinMax(pm, True)

  theta = t*(p0/pm)^0.286
  copy_VarCoords(t, theta)
  theta@long_name = "potential temperature"
  theta@units     = "K"
  printVarSummary(theta)
  printMinMax(theta, True)

;************************************************
; Calculate Equivalent Potential Temperature 
;************************************************
; Technically, this is a nonlinear computation and it should have
;    been done at each time step and, then, averaged. But ...
;************************************************
; https://en.wikipedia.org/wiki/Equivalent_potential_temperature
;************************************************

  Lv   = 2.51e6  ; latent heat of vaporization at the triple point [J/kg]; Bluestein, p203        
;;cpd  = 1005.7  ; specific heat at constant pressure for air [Bolton (1980): MWR]
  cpd  = 1004.64 ; specific heat at constant pressure for air 
  R    = 287.04  ; specific gas constant for air [J/(Kg-K)]
  kap  = R/cpd   ; 0.285 

  q    = q/(1-q) ; convert spc humidity to mixing ratio
  q@long_name = "mixing ratio" 

                               ; wikipedia approx
  t_e  = t+(Lv/cpd)*q          ;                 Lv     cpd         q
                               ; Units check: ([J/kg]/[J/(kg-K)])[kg/kg]  => K
  
  theta_e = t_e*(p0/pm)^kap    ; p0 and pm must be same units

;************************************************
; [A] untested
;    An alternative approach to computing theta_e:
;    Wallace and Hobbs (1977): Atmospheric Science: A Survey
;************************************************
;;rh      = relhum(t, q, pm)/100   ; [K]; q[kg/kg], pm[Pa]  => [%]/100 => frac
;;qs      = q/rh                   ; rh = (q/qs) ==> qs=(q/rh)
;;theta   = t*(p0/pm)^kap
;;theta_e = theta*exp((Lv*qs)/(cpd*t))   ; Wallace & Hobbs:  eqn (2.76); page 79

;************************************************
; [B] untested
;     An alternative approach to computing theta_e:
;     Bolton (1980) Mon. Wea. Rev., Vol. 108, pp.1046-1053.x: eqns (22) and (43)
;************************************************
;         **untested**
;************************************************
;;rh      = relhum(t, q, pm)/100   ; [K]; q[kg/kg], pm[Pa]  => [%]/100 => frac
;;tlcl    = 1.0/((1.0/(t-55))-(log(rh)/2840)) + 55.0
;;theta   = t*(p0/pm)^(kap*(1-q*0.28e-3))                       ; eqn 22
;;theta_e = theta*exp(((3.376/tlcl)-0.00254)*q*(1+q*0.81e-3))   ; eqn 43

;************************************************
; add meta data
;************************************************

  theta_e@long_name = "equivalent potential temperature"
  theta_e@units     = "K"
  copy_VarCoords(t,theta_e) ; assign coordinates
  printMinMax(theta_e, True)

;************************************************
; Interpolate to pressure levels
; vinth2p requires the lev_p to be expressed in mb [hPa]
;************************************************

  lev_p           = (/  10, 20, 30, 50, 70,100,150,200,250 \
                     , 300,400,500,600,700,750,850,925,1000 /)                
  lev_p!0         = "lev_p"                  ; variable/dim name 
  lev_p&lev_p     =  lev_p                   ; create coordinate variable
  lev_p@long_name = "pressure"               ; attach some attributes
  lev_p@units     = "hPa"
  lev_p@positive  = "down"

  P0mb  = 1000.                              ; reference pressure [mb]
  intyp = 1                                  ; 1 = linear, 2 = log, 3 = log log 

  tp    = vinth2p(theta  , hyam, hybm, lev_p, ps, intyp, P0mb, 1, False )
  tp_e  = vinth2p(theta_e, hyam, hybm, lev_p, ps, intyp, P0mb, 1, False )
 
;************************************************
; Interpolate to specified [constant] Potential Temperature levels
; The default returned vertical coordinate is Z_T but change to 'tlev'
;************************************************
  tlev       = (/ 300.0 , 325.25/)    ; same units [here, K as t]
  tlev@units = t@units
  tlev!0     = "tlev"

  pm         = pm*0.01                ; convert .. make smaller numbers
  pm@units   = "hPa"
  
  isot    = int2p_n_Wrap(theta,pm, tlev, 0, 1)
  copy_VarCoords(theta(0,0,:,:), isot(0,0,:,:))   ; trick

  printVarSummary(isot) 
  printMinMax(isot, True) 

;************************************************ 
; create plot
;************************************************
  plot = new( 2, "graphic")

  wks = gsn_open_wks("png","iso")                 ; send graphics to PNG file
 ;gsn_define_colormap(wks,"BlAqGrYeOrReVi200")    ; choose a colormap     

  res                      = True                 ; plot mods desired
  res@gsnDraw              = False
  res@gsnFrame             = False
  res@cnFillOn             = True                 ; turn on color fill
  res@cnFillPalette        = "amwg"               ; set color map
  res@cnLinesOn            = False                ; turn off contour lines
  res@mpCenterLonF         = 180                  
  res@mpFillOn             = False
  res@lbLabelAutoStride    = True  
  res@lbOrientation        = "vertical"
  res@gsnAddCyclic         = True                 

  resP = True
  resP@gsnMaximize         = True                 ; make as large as possible   
  resP@gsnPaperOrientation = "portrait"           ; force portrait

  nt = 0
  do kl=10,10              ; 0,dimsizes(plev)-1
     res@gsnCenterString   = "lev="+lev_p(kl)+" hPa"
     plot(0) = gsn_csm_contour_map_ce(wks,theta(nt,kl,:,:),res)  
     plot(1) = gsn_csm_contour_map_ce(wks,theta_e(nt,kl,:,:),res)  
  end do
  resP@txString            = "Potential Temperature at Pressure Levels"
  gsn_panel(wks, plot, (/2,1/), resP)

  do kt=0,dimsizes(tlev)-1
     res@gsnCenterString   = "tlev="+tlev(kt)+" K"
     plot(kt) = gsn_csm_contour_map_ce(wks,isot(0,kt,:,:),res)   
  end do
  resP@txString            = "Pressure Levels of Specified  Potential Temperature"
  gsn_panel(wks, plot, (/2,1/), resP)
end

