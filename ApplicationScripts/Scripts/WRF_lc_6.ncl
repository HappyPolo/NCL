;----------------------------------------------------------------------
; WRF_lc_6.ncl
;
; Concepts illustrated:
;   - Plotting WRF data that's on a Lambert Conformal map projection
;   - Using gsn_csm_contour_map to plot WRF-ARW data in its native projection
;   - Creating a color map using named colors
;   - Drawing raster contours
;----------------------------------------------------------------------
; WRF: PRECIPITATION: Total, Cumulus and non-cumulus prc
;----------------------------------------------------------------------
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"   
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"   
; load "$NCARG_ROOT/lib/ncarg/nclscripts/wrf/WRFUserARW.ncl"

begin
;
; open file 
; Read Cumulus (rinc) and Non-cumulus (rainnc) prc
;
  f       = addfile ("wrfout_d01_000000_25time.nc","r")
  rainc   = f->RAINC                 ; (Time, south_north, west_east)
  rainnc  = f->RAINNC     
                                    
  times   = wrf_user_getvar(f,"times",-1)
  ntim    = dimsizes(times)         ; # time steps
;
; Use NCL operator > to make sure all values >=0.0
; Sum components and assign attributes
;
  rainc   = rainc  > 0.0         
  rainnc  = rainnc > 0.0
  rainTot = rainc + rainnc          
  rainTot@description = "Total Precipitation"
  rainTot@units       =  rainc@units

;
; Create plots: create colormap using named colors
;               unequal contour levels
;
  wks = gsn_open_wks("png" ,"WRF_lc")
  colors = (/"white","azure"          \ 
            ,"green","palegreen","yellowgreen", "greenyellow" \
            ,"yellow","goldenrod","orange","orangered"        \
            ,"red","deeppinK", "violet","darkviolet"          \
            ,"blueviolet","blue"                              /)
  
  res                       = True             ; plot mods desired
  res@gsnMaximize           = True             ; maximize plot size
  res@cnFillOn              = True             ; color plot desired
  res@cnFillMode            = "RasterFill"     ; raster contours
  res@cnFillPalette         = colors           ; Define colors for contour plot
  res@cnLinesOn             = False            ; turn off contour lines
  res@cnLineLabelsOn        = False            ; turn off contour labels
  
  res@cnLevelSelectionMode  = "ExplicitLevels" ; explicit [unequal] cn levels
  res@cnLevels              = (/0,0.1,1,2.5,5,7.5,10,15,20,25,37.5,50,75,100,125,150/)
  res@lbOrientation         = "Vertical"       ; default is horizontal

  res@gsnStringFontHeightF  = 0.015            ; decrease size of left/right titles

  res = wrf_map_resources(f,res)
  res@gsnAddCyclic          = False            ; regional data: not cyclic 
  res@tfDoNDCOverlay        = True             ; set True for native projections

;---Allocate array for plots
  plts = new (3 , "graphic")                   ; 1d array to hold plots

  res@gsnDraw               = False            ; (a) do not draw 
  res@gsnFrame              = False            ; (b) do not advance 'frame'
  res@lbLabelBarOn          = False            ; (c) turn off individual lb's 

;---Create panel: panel plots have their own set of resources
  resP                      = True             ; modify the panel plot
  resP@gsnMaximize          = True             ; maximize panel area
  resP@gsnPanelRowSpec      = True             ; specify 1 top, 2 lower level  
  resP@gsnPanelLabelBar     = True             ; add common colorbar
  resP@pmLabelBarWidthF     = 0.85             ; make label wider 
  resP@lbLabelFontHeightF   = 0.015            ; default 0.02 [demo make smaller]

  nt = 12                                      ; demo only one time 
;;do nt=0,ntim-1                               ; uncomment to loop over all times
     plts(0) = gsn_csm_contour_map(wks,rainTot(nt,:,:),res)
     plts(1) = gsn_csm_contour_map(wks,rainnc(nt,:,:),res)
     plts(2) = gsn_csm_contour_map(wks,rainc(nt,:,:),res)

     resP@gsnPanelMainString = f@TITLE+": "+times(nt)      
     gsn_panel(wks,plts,(/1,2/),resP)               ; now draw as one plot
;;end do
end
