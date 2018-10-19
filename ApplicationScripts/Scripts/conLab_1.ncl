;************************************************
; conLab_1.ncl
;
; Concepts illustrated:
;   - Drawing black-and-white contours over a cylindrical equidistant map
;   - Setting contour labels using three different methods
;   - Setting contour labels using the "randomized" method (default)
;   - Setting contour labels using the "constant" method
;   - Setting contour labels using the "computed" method
;   - Zooming in on a particular area on a cylindrical equidistant map
;
;************************************************
;
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"  
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"  
;************************************************
begin
;************************************************
; read in netCDF file
;************************************************
  a = addfile("$NCARG_ROOT/lib/ncarg/data/cdf/uv300.nc","r")
;************************************************
; read in zonal winds
;************************************************
  u = a->U(1,:,:)                                ; read July zonal winds
;************************************************
; create default plot
;************************************************
  wks  = gsn_open_wks("png","conLab")                 ; open a png file
  
  res  = True

  res@mpMinLatF                = -30            ; specify region to be plotted
  res@mpMaxLatF                =  30
  res@mpMinLonF                = 0
  res@mpMaxLonF                = 70


  res@tiMainString             = "Randomized: Default"
  plot = gsn_csm_contour_map_ce(wks,u,res)       ; create a default plot

  res@cnLineLabelPlacementMode = "constant"
  res@tiMainString             = "Constant"
  plot = gsn_csm_contour_map_ce(wks,u,res)       ; create a default plot


  delete(res@cnLineLabelPlacementMode)
  res@tiMainString             = "Computed"
  res@cnLineLabelPlacementMode = "computed"
  plot = gsn_csm_contour_map_ce(wks,u,res)       ; creates a cylindrical equidistant map
end



