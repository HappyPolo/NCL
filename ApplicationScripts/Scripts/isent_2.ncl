;************************************************
; isent_2.ncl
;************************************************
;
; This file is loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/wrf/WRFUserARW.ncl"

;************************************************
; file path
;************************************************

  diri = "./"
  fili = "wrfout_d01_000000.nc"
  pthi = diri+fili

  a    = addfile(pthi,"r")
  time = -1                                      ; all times

  times= tostring(a->Times)            
  theta= wrf_user_getvar(a,"theta",time)         ; get theta
  printVarSummary(theta)                         ; print informations
  printMinMax(theta, 0)

  x    = wrf_user_getvar(a,"tc" ,time)           ; variable to be interpolated
  printVarSummary(x)
  printMinMax(x, 0)

  lvl  = (/ 320, 350, 400/)                      ; user specified inentropic levels
  lvl@description = "isentropic level"           ; add meta data
  lvl@units       = theta@units
  lvl!0           = "lvl"
  lvl&lvl         =  lvl

  xlvl = int2p_n_Wrap (theta, x, lvl, 0, 1)      ; vertically interpolate
  printVarSummary(xlvl)
  printMinMax(xlvl, 0)

;************************************************
; create plots  
;************************************************

  xlvl@lat2d = a->XLAT(0,:,:)                  ; direct assignment
  xlvl@lon2d = a->XLONG(0,:,:)

  wks = gsn_open_wks("png" ,"isent")           ; ps,pdf,x11,ncgm,eps,svg

  res                       = True             ; plot mods desired
;************************************************
; Use WRF procedure to set map resources
;************************************************
  res = wrf_map_resources (a, res)
  print(res)
  
;************************************************
; Set other desired resources
;************************************************
  res@cnFillOn              = True     ; turn on color fill
  res@cnFillPalette         = "BlAqGrYeOrReVi200"  ; set color map
  res@cnLinesOn             = False    ; turn of contour lines
  res@cnLineLabelsOn        = False    ; turn of contour line labels
  res@cnLevelSpacingF       = 1.0      ; contour spacing
;************************************************
; Loop over all times and levels ( uncomment )
; Demo: one arbitrarily closen time and level  
;************************************************
  dimx  = dimsizes(xlvl)                       ; dimensions of x
  ntim  = dimx(0)                              ; number of time steps
  klev  = dimx(1)                              ; number of "bottom_top" levels

  nt    = ntim/2                               ; arbitrary time
;;kl    =  2                                   ;     "     level
;;do nt=0,ntim-1                               ; uncomment for loop
    do kl=0,klev-1
     ;;res@tiMainString     = "Isentropic level"
       res@tiMainString     = fili+"   t="+times(nt)
       res@gsnCenterString  = "isen_lvl="+lvl(kl)
      ;res@gsnLeftString    = xlvl@description+"  isen lvl="+lvl(kl)
       plot                 = gsn_csm_contour_map(wks,xlvl(nt,{lvl(kl)},:,:),res)
    end do
;;end do
