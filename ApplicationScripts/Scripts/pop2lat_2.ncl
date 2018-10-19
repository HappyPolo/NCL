;************************************************
; pop2lat_2.ncl
;************************************************
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"   
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"    
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/popRemap.ncl"  
;************************************************
begin
  in = addfile("iceh_mavg.0014-02.nc","r")
  u = in->uvel
  v = in->vvel
;************************************************
; convert pop to a 1x1 degree grid
;************************************************
  remap   = PopLatLonV(u,v,"gx1v3","1x1d","bilin","da","010808")
  u_remap = remap(0,:,:,:)
  v_remap = remap(1,:,:,:)
;************************************************
; create plots
;************************************************
  wks = gsn_open_wks("ps","pop2lat")            ; open ps file
  gsn_define_colormap(wks,"WhBlGrYeRe")         ; choose colormap
;
; This will not be necessary in V6.1.0 and later. Named colors can
; be used without having to first add them to the color map.
;
  i = NhlNewColor(wks,0.7,0.7,0.7)              ; add gray to colormap
  
  res                      = True
  res@gsnPolar             = "NH"               ; choose hemisphere
  
  res@mpLandFillColor      = "grey"             ; color of land
  res@mpMinLatF            = 50                 ; adjust map limit
  
  res@vcRefMagnitudeF       = 5.0               ; vec magnitude
  res@vcRefLengthF          = 0.050             ; size of ref vector
  res@vcMonoLineArrowColor  = False
  res@vcMinDistanceF        = 0.007              ; thins arrows near pole 
  res@vcGlyphStyle            = "CurlyVector"   ; turn on curley vectors
  
  
  res@gsnSpreadColors     = True                ; use full colormap
  res@gsnSpreadColorStart = 2 
  res@gsnSpreadColorEnd   = 97
  
  res@tiMainString        = "gx1v2 to 1x1d"
  
; because this is ice data, which has a gap in the tropics, we need to
; explicitly pass the range of the data to plot.  Since we are coloring 
; the vectors, this range should also match the MinLatF above, since the
; range for the colors is chosen over the full data passed, and not the
; map limits.

   plot = gsn_csm_vector_map_polar(wks,u_remap(0,{50:90},:), \
				       v_remap(0,{50:90},:),res)
end
