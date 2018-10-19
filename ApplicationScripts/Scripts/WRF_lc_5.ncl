;----------------------------------------------------------------------
; WRF_lc_5.ncl
;
; Concepts illustrated:
;   - Plotting WRF data that's on a Lambert Conformal map projection
;   - Using gsn_csm_contour_map to plot WRF-ARW data in its native projection
;   - Paneling plots on a page
;   - Selecting a different color map for each contour plot
;   - Drawing raster contours
;----------------------------------------------------------------------
; WRF: plot data with "missing_values"
;----------------------------------------------------------------------
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"   
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"   
; load "$NCARG_ROOT/lib/ncarg/nclscripts/wrf/WRFUserARW.ncl"

begin
;
; open file 
; (1) Read SST and SMOIS at specified time/level
; (2) Read character variable Times; Convert to string for plots
;
  nt      = 12   ; time index to plot
  f       = addfile ("wrfout_d01_000000_25time.nc","r")
  sm      = f->SMOIS(nt,0,:,:)      ; (Time, soil_layers_stag, south_north, west_east )
  sm@_FillValue = 1.0               ; manually set _FillValue 
  sst     = f->SST(nt,:,:)          ; (Time, south_north, west_east )
  sst@_FillValue = 0.0              ; manually set _FillValue

  times   = wrf_user_getvar(f,"times",-1)
  ntim    = dimsizes(times)         ; # time steps

;---Create plots  
  wks = gsn_open_wks("png","WRF_lc")

  res                       = True             ; plot mods desired
  res@gsnMaximize           = True                 ; maximize plot size
  res@cnFillOn              = True                 ; color plot desired
  res@cnLinesOn             = False            ; turn off contour lines
  res@cnLineLabelsOn        = False            ; turn off contour labels

  res@lbOrientation         = "Vertical"       ; default is horizontal 

  res = wrf_map_resources(f,res)
  res@gsnAddCyclic          = False            ; regional data: not cyclic 
  res@tfDoNDCOverlay        = True             ; set True for native projections

  res@mpFillOn              = False            ; turn off map fill
  res@mpOutlineOn           = True             ; turn oon map outlines

; print(res)      ; Uncomment to see what wrf_map_resources is setting.

;
; wrf_map_resources sets some resources for the map outlines that
; can make it hard to see. After calling wrf_map_resources, you
; can change some of the settings to whatever you like.
; 
  res@mpGeophysicalLineColor      = "black"    ; wrf_map_resources uses "gray"
  res@mpGeophysicalLineThicknessF = 2.0        ; wrf_map_resources uses 0.5

;---For individual plots 
  res@gsnDraw               = False            ; do not draw 
  res@gsnFrame              = False            ; do not advance 'frame'

;---Allocate array to store plots: specify time step
  plts = new (2, "graphic")                   ; 1d array to hold plots

;---NCL contouring does not like _FillValue=0.0
  sst@_FillValue = -999.                       ; change to -999

;---For demo: use raster fill for soil moisture 
  res@cnFillMode     = "RasterFill"              ; turn raster on         
  res@cnFillPalette  = "MPL_winter"              ; select color map
  plts(0) = gsn_csm_contour_map(wks,sm,res)

  delete(res@cnFillMode)                         ; delete raster mode; smooth contours
  res@cnFillPalette = "BlAqGrYeOrReVi200"        ; select color map
  plts(1) = gsn_csm_contour_map(wks,sst,res)

;---Create panel: panel plots have their own set of resources
  resP                    = True                   ; modify the panel plot
  resP@gsnMaximize        = True                   ; maximize panel area
  resP@gsnPanelMainString = times(nt)      
  gsn_panel(wks,plts,(/2,1/),resP)               ; now draw as one plot
end

