;----------------------------------------------------------------------
; WRF_lc_8.ncl
;
; Concepts illustrated:
;   - Plotting WRF data that's on a Lambert Conformal map projection
;   - Using gsn_csm_vector_scalar_map to plot WRF-ARW data
;   - Drawing wind barbs over filled contours
;   - Creating a color map using named colors
;   - Drawing raster contours
;----------------------------------------------------------------------
; WRF: near surface winds and total precipitation
;----------------------------------------------------------------------
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"   
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"   
; load "$NCARG_ROOT/lib/ncarg/nclscripts/wrf/WRFUserARW.ncl"

begin
;
; Open file 
; Read U10 and V10, Cumulus (rinc) and Non-cumulus (rainnc) prc
;
  f       = addfile ("wrfout_d01_000000_25time.nc","r")
  rainc   = f->RAINC                 ; (Time, south_north, west_east)
  rainnc  = f->RAINNC     
  u10     = f->U10                   ; (Time, south_north, west_east)
  v10     = f->V10                    

  times   = wrf_user_getvar(f,"times",-1)
  ntim    = dimsizes(times)          ; # time steps

;
; Use NCL operator > to make sure all values >=0.0
; Sum components and assign attributes
;
  rainc   = rainc  > 0.0         
  rainnc  = rainnc > 0.0
  rainTot = rainc + rainnc          
  rainTot@description = "Total Precipitation"
  rainTot@units       =  rainc@units

  wks = gsn_open_wks("png","WRF_lc")

  colors = (/"white","azure"          \ 
            ,"green","palegreen","yellowgreen", "greenyellow" \
            ,"yellow","goldenrod","orange","orangered"        \
            ,"red","deeppinK", "violet","darkviolet"          \
            ,"blueviolet","blue"                              /)
  
  res                       = True             ; plot mods desired
  res@gsnMaximize           = True             ; maximize size
  res@gsnScalarContour      = True               ; contours desired
  res@gsnLeftString         = "Wind Vectors (m/s)"
  res@gsnRightString        = "Total Precipitation (mm)"

  res@cnFillOn              = True             ; color plot desired
  res@cnFillPalette         = colors           ; define colors for contour plot
  res@cnLinesOn             = False            ; turn off contour lines
  res@cnLineLabelsOn        = False            ; turn off contour labels
  res@cnFillMode            = "RasterFill"     ; raster
  res@cnLevelSelectionMode  = "ExplicitLevels" ; explicit [unequal] cn levels
  res@cnLevels              = (/0,0.1,1,2.5,5,7.5,10,15,20,25,37.5,50,75,100,125,150/)

  res@vcGlyphStyle          = "WindBarb"
  res@vcRefLengthF          = 0.025            ; ref vec length
  res@vcMinDistanceF        = 0.025            ; larger means sparser
  res@vcWindBarbTickLengthF = 0.4              ; default 0.3
  res@vcRefAnnoOn           = False
  
  res = wrf_map_resources(f,res)
  res@gsnAddCyclic          = False            ; regional data: not cyclic 
  res@tfDoNDCOverlay        = True             ; set True for native projections

  res@mpFillOn                    = False
  res@mpGeophysicalLineColor      = "black"    ; wrf_map_resources uses "gray"
  res@mpUSStateLineColor          = "black"
  res@mpGeophysicalLineThicknessF = 2.0        ; wrf_map_resources uses 0.5
  res@mpUSStateLineThicknessF     = 2.0
;
; Plot one time and level for demo
; .  create u and v on a common grid for visualization: nothing fancy
;
  nt = 12
;;do nt=0,ntim-1                               ; uncomment to loop
     res@tiMainString             = times(nt)
     plot = gsn_csm_vector_scalar_map(wks,u10(nt,:,:),v10(nt,:,:),rainTot(nt,:,:),res)
;;end do

end
