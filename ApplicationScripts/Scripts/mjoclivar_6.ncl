load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"   
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"    
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"    
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/diagnostics_cam.ncl"    
;******************** MAIN **********************************
begin

                         ; time window : include enough buffer
  twStrt = 19950101      ; 4 years: winter 96-97 MJO gold standard
  twLast = 19981231

  thStrt = 19960101      ; Hov start time
  thLast = 19971231      ; Hov last  time

  spd    = 1
  bpf    = (/20,100,201/)

  diri    = "/Users/shea/Data/AMWG/"
 ;vName   = "olr"           ; name of variable on the file
 ;fili    = "olr.day.mean.nc"
 ;vName   = "U_anom"        ; name of variable on the file
 ;fili    = "uwnd.day.850.anomalies.1980-2005.nc"

  vName   = "OLR_anom"      ; name of variable on the file
  fili    = "olr.day.anomalies.1980-2005.nc"

  f       = addfile(diri+fili, "r")

  latS    = -30.            ; arbitrary
  latN    =  30.
  lonL    =  60.
  lonR    = 280.

  pltDir  = "./"                     ; plot dorectory
  pltType = "x11"                    ; x11, ps, eps, pdf, png
  pltName = "mjo"

;************************************************************
; time indices corresponding to the desired time window
;************************************************************

  date  = cd_calendar(f->time, -2)   ; *entire* file
  iStrt = ind(date.eq.twStrt)        ; user specified dates
  iLast = ind(date.eq.twLast)
  delete(date)

;************************************************************
; Read user specified period
;************************************************************

  if (getfilevartypes(f,vName) .eq. "short") then
      X = short2flt( f->$vName$(iStrt:iLast,:,:) )
  else
      X = f->$vName$(iStrt:iLast,:,:)
  end if
 ;printVarSummary( X )
 ;printMinMax(X, True)

  x       = X(:,{latS:latN},{lonL:lonR})   ; region

 ;printVarSummary( x )
 ;printMinMax(x, True)

 ;wgty    = latRegWgt(x&lat, "double", 0)

  dimx    = dimsizes( x )
  ntim    = dimx(0)

  date    = cd_calendar(x&time, -2)   ; selected period
  hStrt   = ind(date.eq.thStrt)       ; plot times
  hLast   = ind(date.eq.thLast)
  ntimp   = (hLast-hStrt) + 1

;************************************************
; Extract filtered series at each grid point
;************************************************

  optLatLon  = False
  mjo_latlon = band_pass_latlon_time (x, spd, bpf, optLatLon)

  printVarSummary(mjo_latlon)
  printMinMax(mjo_latlon, True)

;************************************************
; Plots using output from latlon_time
;************************************************

  wks  = gsn_open_wks(pltType ,pltName)
  gsn_merge_colormaps(wks,"amwg_blueyellowred","BlAqGrYeOrReVi200")
 
;************************************************
; create spatial plot at one time
;************************************************
  plot = new ( 2, "graphic")

  res                       = True     ; plot mods desired
  res@gsnDraw               = False    ; don't draw
  res@gsnFrame              = False    ; don't advance frame

  res@cnFillOn              = True     ; turn on color fill
  res@cnLinesOn             = False    ; turn of contour lines
  res@cnLineLabelsOn        = False    ; turn of contour line labels
  res@gsnSpreadColors       = True     ; use full range of color map
 ;res@lbLabelBarOn          = False    ; turn off individual cb's
  res@lbLabelAutoStride     = True     ; let NCL figure spacing
  res@lbOrientation         = "vertical" ; vertical label bar

  res@mpMinLatF             = latS     ; range to zoom in on
  res@mpMaxLatF             = latN
  res@mpMinLonF             = lonL
  res@mpMaxLonF             = lonR
  res@mpCenterLonF          = 180      ; DL is middle
 ;res@pmTickMarkDisplayMode = "Always" ; use default lat/lon labels

  res@mpShapeMode           = "FreeAspect"
  res@vpWidthF              = 0.8
  res@vpHeightF             = 0.3
                                       ; nice symmetric min&max for region
  rSym    = True
  symMinMaxPlt (mjo_latlon,20,False,rSym)
 ;print(rSym)
  mnmxint = nice_mnmxintvl( min(x) , max(x), 16, False)

  rOrig   = True
  rOrig@cnLevelSelectionMode = "ManualLevels"
  rOrig@cnMinLevelValF       = mnmxint(0)
  rOrig@cnMaxLevelValF       = mnmxint(1)
  rOrig@cnLevelSpacingF      = mnmxint(2)

  resP                       = True           ; modify the panel plot
  resP@gsnMaximize           = True
  resP@gsnPaperOrientation   = "portrait"
 ;resP@lbOrientation         = "vertical"     ; vertical label bar
 ;resP@gsnPanelLabelBar      = True           ; add common colorbar
 ;resP@gsnPanelBottom        = 0.05

  res@gsnAddCyclic           = False          ; {lonL:lonR}

  nnn = (hLast+hStrt)/2                       ; demo
  do nt=nnn,nnn                               ; just one time
;;do nt=hStrt,hLast                           ; all times
     res@gsnSpreadColorStart  = 18
     res@gsnSpreadColorEnd    = -1
     res                      = rOrig
     plot(0) = gsn_csm_contour_map_ce(wks,x(nt,:,:), res)

     res@gsnSpreadColorStart  =  2
     res@gsnSpreadColorEnd    = 17
     res                      = rSym
     plot(1) = gsn_csm_contour_map_ce(wks,mjo_latlon(nt,:,:), res)

     resP@txString            = date(nt)
     gsn_panel(wks,plot,(/2,1/),resP)
  end do

end
