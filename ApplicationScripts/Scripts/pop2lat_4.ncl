;************************************
; POP_Graphics: Interpolate to lat/lon grid at depth (not at surface) and
; normalize the regridding to reduce errors along the coast.
;************************************
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/popRemap.ncl"
;************************************
begin
  lev = 17        ; what level to plot

  a      = addfile("/fs/cgd/data0/asphilli/CibmT31_gx3v4.pop.h.0001-06.nc","r")
  Tpop   = a->TEMP(0,lev,:,:)                     ; grab 1st timestep and specified level              
  
  remap  = PopLatLon(Tpop,"gx3v4","1x1d","bilin","da","020604")

  tgrid  = where(.not.ismissing(Tpop),1.,0.)   
  remap2 = PopLatLon(tgrid,"gx3v4","1x1d","bilin","da","020604")
  delete(tgrid)
  
  remap2 = where(remap2.eq.0,remap2@_FillValue,remap2) ; set points = 0 to @_FillValue
	
  remap3 = remap                  ; done for metadata
  remap3 = (/ remap/remap2 /)     ; normalize the original regridded field by using remap2
  delete(remap2)		    
  
  Tpop@lat2d = a->TLAT            ; assign 2D lats/lons as attributes to original POP grid
  Tpop@lon2d = a->TLONG
  z_t        = a->z_t
   
  wks = gsn_open_wks("ps","pop2lat")             ; open ps file
  gsn_define_colormap(wks,"WhBlGrYeRe")         ; choose colormap
  nc = NhlNewColor(wks,0.30,0.30,0.30)   ; add gray30 to colormap
  nc2 = NhlNewColor(wks,0.80,0.80,0.80)  ; add gray70 to colormap
  
  res = True
  res@mpProjection = "WinkelTripel"      ; use a Winkel Tripel projection
  res@mpFillOn     = True                ; turn map fill on
  res@mpLandFillColor = "gray80"         ; fill the land with gray80
  res@mpFillDrawOrder = "PostDraw"       ; color fill the land last
  res@mpGeophysicalLineColor = "gray30"  ; set the geophysical line color to gray30
  res@mpPerimOn         = False          ; turn the perimeter off 
  res@mpGridLatSpacingF =  90            ; change latitude  line spacing
  res@mpGridLonSpacingF = 180.           ; change longitude line spacing
  res@mpGridLineColor   = "transparent"  ; trick ncl into drawing perimeter
  res@mpGridAndLimbOn   = True           ; turn on lat/lon lines	

  res@mpDataSetName = "Earth..4"         ; use the newest earth dataset
  res@gsnFrame      =  False             ; don't advance the frame as we are paneling
  res@gsnDraw       = False              ; don't draw the plots as we are paneling
  
  res@cnFillOn          = True           ; use color fill
  res@cnLinesOn         = False          ; turn the contour lines off
  res@cnLineLabelsOn    = False          ; turn the line labels off
  res@gsnSpreadColors   = True           ; use gsnSpreadColors
  res@gsnSpreadColorEnd = 101            ;    up to color index 101
  res@gsnSpreadColorStart  = 4           ;    and start at color index 4
  res@cnFillMode        = "RasterFill"   ; use raster fill
  res@cnLevelSelectionMode = "ExplicitLevels"  ; explicitly set the contour levels
  res@cnLevels          = fspan(-1.2,4.4,15)   ; set the contour levels
  res@lbLabelBarOn      = False          ; turn the label bar off
  
  res@gsnCenterStringOrthogonalPosF = 0.025  ; nudge the center string positioning up slightly
  
  plot = new(3,graphic)
  
  res@gsnLeftString = "Original Grid"
  res@gsnCenterString = z_t(lev)/100+"m"
  res@gsnRightString = "Potential Temp. (~S~o~N~C)"
  res@gsnAddCyclic = True      ; needed for 2d lat/lon arrays if data is global. Default is true for 1d lat/lon arrays
  plot(0) = gsn_csm_contour_map(wks,Tpop,res)
  
  res@gsnLeftString = "Regridded"
  plot(1) = gsn_csm_contour_map(wks,remap,res)
  
  res@gsnLeftString = "Regridded (normalized)"
  plot(2) = gsn_csm_contour_map(wks,remap3,res)
  
  panres = True
  panres@gsnPanelLabelBar = True             ; turn the panel label bar on
  panres@lbOrientation    = "vertical"       ; draw it vertically
  panres@pmLabelBarHeightF = 0.5             ; set the label bar width
  panres@pmLabelBarWidthF = 0.06             ; set the label bar height
  gsn_panel(wks,plot,(/3,1/),panres)         ; draw the first panel
  
  res@mpLimitMode = "LatLon"                 ; zoom in on the North Atlantic
  res@mpMinLatF   = 20.                      ; set the minimum latitude  
  res@mpMaxLatF   = 70.                      ; set the maximum latitude  
  res@mpMinLonF   = -80.                     ; set the minimum longitude  
  res@mpMaxLonF   = 20.                      ; set the maximum longitude  
  res@mpPerimOn   = True                     ; draw the map perimeter
  res@mpPerimDrawOrder = "PostDraw"          ;    and draw it last
  
  plot2 = new(3,graphic)
  
  res@gsnLeftString = "Original Grid"
  plot2(0) = gsn_csm_contour_map(wks,Tpop,res)
  
  res@gsnLeftString = "Regridded"
  plot2(1) = gsn_csm_contour_map(wks,remap,res)
  
  res@gsnLeftString = "Regridded (normalized)"
  plot2(2) = gsn_csm_contour_map(wks,remap3,res)
  gsn_panel(wks,plot2,(/3,1/),panres)          ; draw the second panel
end
