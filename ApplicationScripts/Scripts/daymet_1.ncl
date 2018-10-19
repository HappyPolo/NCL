;----------------------------------------------------------------------
; daymet_1.ncl
;
; Concepts illustrated:
;   - Reading a Daymet netCDF file containg one 2x2 tile with 1km x 1km data
;   - Exploring the tile's data values using min, max and stat_dispersion
;   - Plot on the Lambert Conformal projection
;
; Assumes v6.1.0
;----------------------------------------------------------------------
; The file used was obtained via:
; wget http://thredds.daac.ornl.gov/thredds/fileServer/ornldaac/1328/tiles/2010/12296_2010/prcp.nc
;----------------------------------------------------------------------
;
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"   
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"   
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"   

;************************************************
; open file and read in data and map info
;************************************************
  vname = "prcp"                               ; Daymet variable name 
  year  =  2010                                ; year
  tile  =  12296                               ; tile number

  diri  = "./"                                 ; input directory
  fili  = vname+"."+year+"_"+tile+".nc"
;  fili  = vname+".nc"
  f     = addfile (diri+fili, "r")
  var   = f->$vname$                           ; (time, y, x)=>(365,232,221)
  printVarSummary(var)

  lc    = f->lambert_conformal_conic           ; variable with map info
  lat2d = f->lat
  lon2d = f->lon

;************************************************
; dimension info
;************************************************
  dimvar= dimsizes(var)                        ; dimension sizes
  ntim  = dimvar(0)                            ; number of time steps
  nlat  = dimvar(1)
  mlon  = dimvar(2)

;************************************************
; Data exploration
;************************************************
  printVarSummary(var)
  print(vname+":  min="+min(var)+"   max="+max(var))

  opt = True
  opt@PrintStat = True
  stat_var = stat_dispersion(var, opt )        ; can be SLOW for large arrays

;************************************************
; create plots  
;************************************************
  pltType = "png"                              ; ps,pdf,png,x11,ncgm,eps
  pltDir  = "./"
  pltName = "daymet"                           ; vname+"."+year+"_"+tile
  pltPath = pltDir+pltName

  wks = gsn_open_wks(pltType, pltPath)         ; ps,pdf,x11,ncgm,eps

  res                       = True             ; plot mods desired
  res@gsnMaximize           = True             ; uncomment to maximize size
  res@gsnAddCyclic          = False            ; regional data: not global 

  res@cnFillOn              = True             ; color plot desired
  res@cnFillPalette         = "BlAqGrYeOrReVi200"  ; set color map
  res@cnLinesOn             = False            ; turn off contour lines
  res@cnLineLabelsOn        = False            ; turn off contour labels

;************************************************
; Set map resources
;************************************************

  res@mpProjection          = "LambertConformal"
  res@mpLambertParallel1F   = lc@standard_parallel(0)
  res@mpLambertParallel2F   = lc@standard_parallel(1)
  res@mpLambertMeridianF    = lc@longitude_of_central_meridian
  res@mpLimitMode           = "Corners"  
  res@mpLeftCornerLatF      = lat2d(0,0)
  res@mpLeftCornerLonF      = lon2d(0,0)
  res@mpRightCornerLatF     = lat2d(nlat-1,mlon-1)
  res@mpRightCornerLonF     = lon2d(nlat-1,mlon-1)
  res@mpOutlineBoundarySets = "GeophysicalAndUSStates" ; state boundaries

  res@mpFillOn              = True  

;************************************************
; Turn on lat / lon labeling
;************************************************
  res@pmTickMarkDisplayMode = "Always"         ; turn on tickmarks
 ;res@tmXTOn = False                           ; turn off top   labels 
 ;res@tmYROn = False                           ; turn off right labels

;************************************************
; Loop over all times and levels ( uncomment )
; Demo: one arbitrarily closen time and level  
;************************************************
  res@cnLevelSelectionMode = "ManualLevels"
  res@cnMinLevelValF       =  1.0
  res@cnMaxLevelValF       = 10.0
  res@cnLevelSpacingF      =  1.0

  var@lat2d = lat2d                               ; direct assignment
  var@lon2d = lon2d           

  nt    = ntim/2                               ; arbitrary time
  res@tiMainString = fili+": day "+f->yearday(nt) +": tile="+tile            
;;do nt=0,ntim-1                               ; uncomment for loop
     plot      = gsn_csm_contour_map(wks,var(nt,:,:),res)
;;end do
