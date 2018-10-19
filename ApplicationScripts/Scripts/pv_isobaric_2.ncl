;=================================================================================
; pv_isobaric_2.ncl
;
; Concepts illustrated:
;   - Using a TEST mode
;   - Calculating potential vorticity on isobaric surfaces
;   - Extracting elements (variables) from a return variable of type list
;
;=================================================================================

load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"  
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"  
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"  
;=================================================================================
;                       MAIN
;=================================================================================
     TEST     = True
     gridType = 0       ; gaussian grid
     optPV    = 1       ; return variable of type list
     plev     = (/ 300 /)
     
     diri     = "./"
     fu       = addfile (diri+"e4moda.an.pl.t85.u.2000.nc", "r")
     fv       = addfile (diri+"e4moda.an.pl.t85.v.2000.nc", "r")
     ft       = addfile (diri+"e4moda.an.pl.t85.t.2000.nc", "r")
     
     if (TEST) then
         ntStrt = 0
         ntLast = 0
         u   = fu->U(ntStrt:ntLast,:,:,:)    ; (time,lev,lat,lon) 
         v   = fv->V(ntStrt:ntLast,:,:,:)
         t   = ft->T(ntStrt:ntLast,:,:,:)    ; K
     else
         u   = fu->U                         ; (time,lev,lat,lon) 
         v   = fv->V                     
         t   = ft->T                         ; K
     end if

    ;printVarSummary(u)
    ;printVarSummary(v)
    ;printVarSummary(t)

     lev = ft->lev  ; hPa
     lev = lev*100  ; convert units
     lev@units = "Pa"

     PV  = pot_vort_isobaric(lev,u,v,t,t&lat, gridType, optPV )
     printVarSummary(PV)

     pv    = PV[0]          ; extract PV
     s     = PV[1]          ; extract static stability
     theta = PV[2]          ; extract potential temperature

     printVarSummary(pv)
     printMinMax(pv,0)
     printVarSummary(s)
     printMinMax(s,0)
     printVarSummary(theta)
     printMinMax(theta,0)

;************************************************
; create plots
;************************************************
     dims = dimsizes(t)
     ntim = dims(0)
     klev = dims(1)
     nlat = dims(2)
     mlon = dims(3)

     if (.not.TEST) then
         ntStrt = 0
         ntLast = ntim-1
     end if

     wks = gsn_open_wks("ps","pv_isobaric") 
   ;;gsn_define_colormap(wks,"gui_default")
     plot = new(3,graphic)                      ; create a plot array
     
     res                      = True
     res@gsnDraw              = False
     res@gsnFrame             = False
   ;;res@gsnSpreadColors      = True            ; spread out color table
     res@cnFillOn             = True            ; turn on color
     res@cnLinesOn            = False
     res@cnLineLabelsOn       = False
     res@cnLevelSelectionMode = "ManualLevels"   
     res@lbOrientation        = "Vertical"   

     resP                     = True                ; modify the panel plot
     resP@gsnMaximize         = True  

     do nt=ntStrt,ntLast
       do pl=0,dimsizes(plev)-1
          res@gsnCenterString     = plev(pl)+"hPa"

          symMinMaxPlt( pv(nt,{plev(pl)},:,:), 16, True, res)
          res@cnLevelSpacingF = 0.5*res@cnLevelSpacingF

          res@gsnLeftString = "PV: NCL derived"
          plot(0) = gsn_csm_contour_map_ce(wks,   pv(nt,{plev(pl)},:,:),res) 
          delete( [/res@gsnLeftString, res@cnLevelSelectionMode \
                   ,res@cnMinLevelValF, res@cnMaxLevelValF, res@cnLevelSpacingF/] )

          plot(1) = gsn_csm_contour_map_ce(wks,    s(nt,{plev(pl)},:,:),res) 
          plot(2) = gsn_csm_contour_map_ce(wks,theta(nt,{plev(pl)},:,:),res) 

          gsn_panel(wks,plot   ,(/3,1/),resP)            ; now draw as one plot
       end do
     end do

