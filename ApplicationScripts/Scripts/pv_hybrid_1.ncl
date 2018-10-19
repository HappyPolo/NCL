;=================================================================================
; pv_hybrid_1.ncl
;
; Concepts illustrated:
;   - Using a TEST mode
;   - Calculating potential vorticity on hybrid surfaces
;=================================================================================
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"  
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"  
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
;=================================================================================
     TEST       = True
     gridType   = 0                         ; gaussian grid
     plev       = (/ 500, 300, 100 /)       ; nominal
     
     diri       = "./"
     fu  = addfile (diri+"e4moda.an.ml.t85.u.2000.nc", "r")
     fv  = addfile (diri+"e4moda.an.ml.t85.v.2000.nc", "r")
     ft  = addfile (diri+"e4moda.an.ml.t85.t.2000.nc", "r")
     fps = addfile (diri+"e4moda.an.ml.t85.psfc.2000.nc", "r")

     if (TEST) then
         ntStrt = 0
         ntLast = 0

         u   = fu->U(ntStrt:ntLast,:,:,:)    ; (time,lev,lat,lon) 
         v   = fv->V(ntStrt:ntLast,:,:,:)
         t   = ft->T(ntStrt:ntLast,:,:,:)    ; K
         ps  = fps->PSFC(ntStrt:ntLast,:,:)  ; Pa; Logarithm of surface pressure
     else
         u   = fu->U                         ; (time,lev,lat,lon) 
         v   = fv->V                     
         t   = ft->T                         ; K
         ps  = fps->PSFC   ; Pa; Logarithm of surface pressure
     end if

    ;printVarSummary(u)
    ;printVarSummary(v)
    ;printVarSummary(t)

     hyam = ft->hyam
     hybm = ft->hybm
     p0   = ft->P0    ; p0=100000
     ps   = exp(ps)
     ps@long_name = "surface pressure"

    ;printVarSummary(ps)
    ;printMinMax(ps,0)
  
     p    = pres_hybrid_ccm (ps,p0,hyam,hybm)  ; Pa [kg/(m s2)]
     copy_VarCoords(t, p)
     p@units = ps@units
     p@long_name = "hybrid pressure levels"

    ;printVarSummary(p)
    ;printMinMax(p,0)

     PV  = pot_vort_hybrid(p,u,v,t,t&lat, gridType, 0 )
     printVarSummary(PV)
     printMinMax(PV,0)

;************************************************
; create plots
;************************************************
     dims = dimsizes(t)
     ntim = dims(0)
     klev = dims(1)
     nlat = dims(2)
     mlon = dims(3)

     lev  = ft->lev           ; hPa

     if (.not.TEST) then
         ntStrt = 0
         ntLast = ntim-1
     end if

     wks = gsn_open_wks("ps","pv_hybrid") 
   ;;gsn_define_colormap(wks,"gui_default")
     
     res                      = True
     res@gsnMaximize          = True

   ;;res@gsnSpreadColors      = True            ; spread out color table
     res@cnFillOn             = True            ; turn on color
     res@cnLinesOn            = False
     res@cnLineLabelsOn       = False
     res@cnLevelSelectionMode = "ManualLevels"   

     do nt=ntStrt,ntLast
       do pl=0,dimsizes(plev)-1
          levDiff = abs(lev-plev(pl))
          iplvl   = ind(levDiff.eq.min(levDiff))
          res@gsnCenterString     = lev(iplvl(0))+" hPa (Nominal)"

          symMinMaxPlt( PV(nt,{plev(pl)},:,:), 16, True, res)
          res@cnLevelSpacingF = 0.5*res@cnLevelSpacingF

          res@gsnLeftString = "PV: NCL derived"
          plot = gsn_csm_contour_map(wks,PV(nt,{plev(pl)},:,:),res) 
       end do
     end do

