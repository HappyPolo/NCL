;************************************************
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"  
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"  
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"  
;************************************************

begin
;************************************************
; Specify input directories & plot directories
;************************************************
  diri   = "./"
  fili   = "ana_yest.800x800_complex.grb"    ; "ana_yest.grb"

  pltDir = "./"
  pltType= "ps"
  pltName= "cmplxgrb"
;************************************************
; open file ... force time dimension
;************************************************
  setfileoption("grb","SingleElementDimensions","Initial_time") 

  in     = addfile(diri+fili,"r")
 ;names  = getfilevarnames(in) ; Get all variable names on file 
 ;print(names)

  time   = in->initial_time0_hours ; all times
  ntim   = dimsizes(time)

  date   = cd_calendar(time, -3)   ; yyyymmddhh

  lev    = in->lv_ISBL1            ; 500, 700, 850, 1000
  klev   = dimsizes(lev)
  print(lev)

;************************************************
; High resolution grid is (800,1600)
;************************************************

  lat  = in->g4_lat_5
  lon  = in->g4_lon_6
  nlat = dimsizes(lat)
  mlon = dimsizes(lon)

;************************************************
; loop over times & levels
; .  use NCL synthesis functions to create grids 
;************************************************
  T = new((/ntim,klev,nlat,mlon/), "float", 1e20)

  do nt=0,ntim-1
   do kl=0,klev-1
     TC = in->T_GDS50_ISBL(nt,kl,:,:,:)          ; complex ( 2, 800, 800) 
     if (nt.eq.0 .and. kl.eq.0) then
         printVarSummary(TC)
     end if
     T(nt,kl,:,:) = shsgC(TC, mlon ) 
   end do           ; kl
  end do            ; nt

  printVarSummary(T)                             ; raw array
  printMinMax(T,0)

;************************************************
; add meta data
;************************************************

  T!0 = "time"
  T!1 = "lev"
  T!2 = "lat"
  T!3 = "lon"
  T&time = time
  T&lev  = lev
  T&lat  = lat
  T&lon  = lon
  T@long_name = TC@long_name
  T@units     = TC@units

  printVarSummary(T)                             ; meta array
  printMinMax(T,0)

;************************************************
; compute a vertical average
;************************************************

  ptop = lev(0)                                  ; or, say, 450
  pbot = lev(klev-1)                             ; or, say, 1010
  dp   = dpres_plevel(lev, pbot, ptop, 0)        ; weights
 ;print(dp)                                      ; layer thickness

  Tdp = dim_sum_wgt_n_Wrap(T,dp,0,1)             ; T*dp 
  printVarSummary(Tdp)

  Tavg = Tdp/sum(dp)                             ; vertical average 

  copy_VarMeta(Tdp, Tavg)
  Tavg@long_name = "Vertical Avg: T"             ; add new attribute
  printVarSummary(Tavg)
  printMinMax(Tavg,0)

;************************************************
; open workstation
;************************************************
  pltPath = pltDir+pltName
  wks = gsn_open_wks(pltType  , pltPath)
  gsn_define_colormap(wks,"BlAqGrYeOrRe")        

  res                       = True               ; plot mods desired

;---This resource not needed in NCL V6.1.0
  res@gsnSpreadColors       = True               ; use full range of color map

  res@gsnMaximize           = True               ; make as large as possible
  res@gsnPaperOrientation   = "portrait"         ; force portrait         
  res@cnFillOn              = True               ; turn on color fill
  res@cnLinesOn             = False              ; turn off contour lines
  res@lbLabelAutoStride     = True

  res@gsnCenterString       = ""

  do nt=0,0    ; ntim-1
     res@gsnCenterString    = date(nt)
     plot = gsn_csm_contour_map_ce(wks,Tavg(nt,:,:),res)     

   do kl=0,0   ; klev-1
     res@gsnCenterString    = lev(kl)+"hPa: "+date(nt)
     plot = gsn_csm_contour_map_ce(wks,T(nt,kl,:,:),res)     
   end do          ; kl
  end do           ; nt

end
