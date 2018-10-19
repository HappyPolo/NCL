;************************************************
; pop2lat_1.ncl
;************************************************
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"   
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"    
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"  
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/popRemap.ncl"  
;************************************************
begin
  in  = addfile("iceh_mavg.0014-02.nc","r")
  ice = in->hi 
;************************************************
; convert pop to a 1x1 degree grid
;************************************************
  remap = PopLatLon(ice,"gx1v3","1x1d","bilin","da","010808")
;************************************************
; create plots
;************************************************
  wks = gsn_open_wks("ps","pop2lat")             ; open ps file
  gsn_define_colormap(wks,"WhBlGrYeRe")         ; choose colormap
;
; This will not be necessary in V6.1.0 and later. Named colors can
; be used without having to first add them to the color map.
;
  i = NhlNewColor(wks,0.7,0.7,0.7)              ; add gray to colormap
  
  res                      = True
  res@gsnPolar             = "NH"               ; choose hemisphere
  
  res@cnFillOn             = True               ; turn on color
  res@cnLinesOn            = False              ; no contour lines
  
  res@mpLandFillColor      = "grey"             ; color of land
  res@mpMinLatF            = 50                 ; adjust map limit
  
  
  res@cnLevelSelectionMode = "ManualLevels"     ; set manual contour levels
  res@cnMinLevelValF       =  0.                ; set min contour level
  res@cnMaxLevelValF       =  5.                ; set max contour level
  res@cnLevelSpacingF      =  0.5               ; set contour spacing
  
  res@gsnSpreadColors     = True                ; use full colormap
  res@gsnSpreadColorStart = 2 
  res@gsnSpreadColorEnd   = 97
  
  res@tiMainString        = "gx1v3 to 1x1d"
  
; because this is ice data, which has a gap in the tropics, we need to
; explicitly pass the range of the data to plot.  Since we are coloring 
; the vectors, this range should also match the MinLatF above, since the
; range for the colors is chosen over the full data passed, and not the
; map limits.

  plot = gsn_csm_contour_map_polar(wks,remap(0,{50:90},:),res)
  
end
