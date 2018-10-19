;=================================================================================
; pv_isobaric_1.ncl
;
; Concepts illustrated:
;   - Using a TEST mode
;   - Calculating potential vorticity on isobaric surfaces
;   - Reading and plotting a verification field
;
;=================================================================================
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"  
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"  
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
;=================================================================================
     TEST       = True
     gridType   = 0       ; gaussian grid
     plev       = (/ 500, 300, 100 /)
     
     diri= "./"
     fu  = addfile (diri+"e4moda.an.pl.t85.u.2000.nc", "r")
     fv  = addfile (diri+"e4moda.an.pl.t85.v.2000.nc", "r")
     ft  = addfile (diri+"e4moda.an.pl.t85.t.2000.nc", "r")
     
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

     PV  = pot_vort_isobaric(lev,u,v,t,t&lat, gridType, 0 )
     printVarSummary(PV)
     printMinMax(PV,0)

; Read ERA40  verification

     fpv = addfile (diri+"e4moda.an.pl.t85.pv.2000.nc", "r")
     if (TEST) then
         pv = fpv->PV(ntStrt:ntLast,:,:,:)    ; (time,lev,lat,lon) 
     else
         pv = fpv->PV                         ; (time,lev,lat,lon) 
     end if
     printVarSummary(pv)
     printMinMax(pv,0)

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
     plot = new(2,graphic)                          ; create a plot array
     
     res                      = True
     res@gsnDraw              = False           ; don't draw
     res@gsnFrame             = False           ; don't advance frame
   ;;res@gsnSpreadColors      = True            ; spread out color table
     res@cnFillOn             = True            ; turn on color
     res@cnLinesOn            = False
     res@cnLineLabelsOn       = False
     res@cnLevelSelectionMode = "ManualLevels"   
     res@lbLabelBarOn         = False           ; turn off individual cb's

     resP                     = True                ; modify the panel plot
     resP@gsnMaximize         = True  
     resP@gsnPanelLabelBar    = True                ; add common colorbar

     do nt=ntStrt,ntLast
       do pl=0,dimsizes(plev)-1
          res@gsnCenterString     = plev(pl)+"hPa"

          pvmin    = min( (/min(PV(nt,{plev(pl)},:,:)), min(pv(nt,{plev(pl)},:,:)) /) )
          pvmax    = max( (/max(PV(nt,{plev(pl)},:,:)), max(pv(nt,{plev(pl)},:,:)) /) )
          symMinMaxPlt( (/pvmin, pvmax/), 16, True, res)
          res@cnLevelSpacingF = 0.5*res@cnLevelSpacingF

          res@gsnLeftString = "PV: NCL derived"
          plot(0) = gsn_csm_contour_map_ce(wks,PV(nt,{plev(pl)},:,:),res) 
          res@gsnLeftString = "PV: ERA40"
          plot(1) = gsn_csm_contour_map_ce(wks,pv(nt,{plev(pl)},:,:),res) 

          gsn_panel(wks,plot   ,(/2,1/),resP)            ; now draw as one plot
       end do
     end do

