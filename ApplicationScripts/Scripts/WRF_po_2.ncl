;*************************************************
; WRF: color over map with lat/lon labels 
;************************************************
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"   
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"   
load "$NCARG_ROOT/lib/ncarg/nclscripts/wrf/WRFUserARW.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/wrf/WRF_contributed.ncl"
begin
;************************************************
; open file and read in data
;************************************************
  f     = addfile ("wrfout_d01_2003-09-28_00:00:00.nc", "r")
;************************************************
; Read character variable Times; Convert to string for plots
; Read vertical coordinate for plot labels
;************************************************
  times = chartostring(f->Times)               ; built-in function
  znu   = f->ZNU(0,:)                          ; (Time, bottom_top)
;************************************************
; Read perturbation geopotential at all times and levels
;************************************************
  x     = f->T                                 ; (Time, bottom_top, south_north, west_east)
;************************************************
; create plots  
;************************************************
  wks = gsn_open_wks("ps" ,"WRF_po")           ; ps,pdf,x11,ncgm,eps
  gsn_define_colormap(wks,"BlAqGrYeOrReVi200") ; select color map

  res                       = True             ; plot mods desired
  res@gsnMaximize           = True             ; uncomment to maximize size
  res@gsnSpreadColors       = True             ; use full range of colormap
  res@cnFillOn              = True             ; color plot desired
  res@cnLinesOn             = False            ; turn off contour lines
  res@cnLineLabelsOn        = False            ; turn off contour labels

;************************************************
; Use WRF_contributed procedure to set map resources
;************************************************
;   WRF_map_c (f, res, 0)                       
  res = wrf_map_resources(f,res)
;************************************************
; set True for native projection (faster)
;************************************************
  res@tfDoNDCOverlay       = True      

;************************************************
; Turn on lat / lon labeling
;************************************************
  res@pmTickMarkDisplayMode = "Always"         ; turn on tickmarks

;************************************************
; Loop over all times and levels ( uncomment )
; Demo: one arbitrarily closen time and level  
;************************************************
  dimx  = dimsizes(x)                          ; dimensions of x
  ntim  = dimx(0)                              ; number of time steps
  klev  = dimx(1)                              ; number of "bottom_top" levels

  nt    = ntim/2                               ; arbitrary time
  kl    =  6                                   ;     "     level
;;do nt=0,ntim-1                               ; uncomment for loop
;;  do ll=0,klev-1
       res@tiMainString     = times(nt)
       res@gsnLeftString    = x@description+"  z="+znu(kl)
       plot                 = gsn_csm_contour_map(wks,x(nt,kl,:,:),res)
;;  end do
;;end do
end

