;*************************************************
; grid_fill_4.ncl
;*************************************************
;
; Concepts illustrated:
;   - Using vinth2p to interpolate to constant pressure levels
;   - Setting parameters for "poisson_grid_fill"
;   - Using "poisson_grid_fill" to fill grid locations
;
;*************************************************
;
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
;************************************************
begin
   Ntime  = 4
   PLOT   = True 
                        ; only used if PLOT=True
   pltType= "png"       ; x11, pdf, ps 
   pltName= "grid_fill" 

;************************************************
; Read variables 
;************************************************
   dir  = "./"
   fnam = "cam.sample_vinth2p.nc"
   f    = addfile(dir+fnam , "r")
   hyam = f->hyam     
   hybm = f->hybm 
   Z3   = f->Z3
   PS   = f->PS                               
   TS   = f->TS                                
   PHIS = f->PHIS                                ; m2/s2                              
  

;************************************************
; define arguments required by vinth2p
;************************************************
   P0mb   = 1000.
   interp = 2       ; type of interpolation: 1 = linear, 2 = log, 3 = loglog

   pnew   = (/1000,950,900,850,800,750,700,650,600,550,500,450,400,350,300,250,200,150,100/)
   pnew!0 = "pnew"
   pnew@units = "hPa"
   
   Z_atts = True    ; convenience
   Z_atts@long_name = "Geopotential Height"
   Z_atts@units     = "m"

;************************************************
; calculate Z3 on pressure levels
;************************************************
   extrap = False
   Z3PF   = vinth2p_ecmwf(Z3,hyam,hybm,pnew,PS,interp,P0mb,1,extrap,-1,TS,PHIS)
   copy_VarAtts(Z_atts, Z3PF)
   printVarSummary(Z3PF)

   extrap = True
   Z3PT   = vinth2p_ecmwf(Z3,hyam,hybm,pnew,PS,interp,P0mb,1,extrap,-1,TS,PHIS)
   copy_VarAtts(Z_atts, Z3PT)
   printVarSummary(Z3PT)

;************************************************
; Set the poisson_grid_fill input variables
; Global grid: Fill in over land
;************************************************
   nscan = 2000             ; usually *much* fewer
   eps   = 0.001            ; variable depended
   gtype = True             ; Cyclic in longitude [global]
   guess = 0                ; use zonal means
   relc  = 0.6              ; standard relaxation coef
   opt   = 0

   Z3POIS = Z3PF
   poisson_grid_fill( Z3POIS, gtype, guess, nscan, eps, relc, opt)

;*********************************************************************
; Plot
;*********************************************************************
if (PLOT)
  LEV   = (/600,700,800,900,950,1000/) ; arbitrary level for demo
  nLEV  = dimsizes(LEV)
  
  wks   = gsn_open_wks(pltType, pltName)  
  plot  = new((/nLEV,3/),graphic)     

  res                      = True
  res@gsnDraw              = False  
  res@gsnFrame             = False  

  res@cnInfoLabelOn        = False           ; turn off cn info label
  res@cnFillOn             = True            ; turn on color
  res@cnFillPalette        = "amwg"          ; set color map

  res@lbOrientation        = "vertical"
  res@mpFillOn             = False
  res@gsnAddCyclic         = False           ; data regional ... not periodic

  res@mpMinLatF            = min( Z3&lat )                  
  res@mpMaxLatF            = max( Z3&lat )
  res@mpMinLonF            = min( Z3&lon )
  res@mpMaxLonF            = max( Z3&lon )

  resP    = True
  resP@gsnMaximize         = True                ; make large

; Geopotential

 do n=0,nLEV-1
  res@gsnLeftString  = LEV(n) +" hPa"
  print("res@gsnLeftString= "+res@gsnLeftString)

  res@gsnRightString = "vinth2p: no extrapolation"
  plot(n,0) = gsn_csm_contour_map_ce(wks,Z3PF(Ntime,{LEV(n)},:,:),res)           

  res@gsnRightString = "poisson_grid_fill"
  plot(n,1) = gsn_csm_contour_map_ce(wks,Z3POIS(Ntime,{LEV(n)},:,:),res)     

  res@gsnRightString = "vinth2p: extrapolation"
  plot(n,2) = gsn_csm_contour_map_ce(wks,Z3PT(Ntime,{LEV(n)},:,:),res)     

  if (n%2.eq.1)
      n1  = n-1
      plt = ndtooned( plot(n1:n,:) )
      gsn_panel(wks,plt,(/2,3/),resP)
  end if
 end do

end if    ; PLOT

end
