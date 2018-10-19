;*************************************************
; barb_1.ncl
;
; Concepts illustrated:
;   - Drawing wind barbs vectors over a cylindrical equidistant map
;   - Changing the length of the vectors
;   - Changing the size of the vectors
;   - Decreasing the number of vectors drawn
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
  a = addfile("83.nc","r")
;************************************************
; read in zonal [u] and meridional [v] winds 
;************************************************
  u = a->U(0,12,:,:) 
  v = a->V(0,12,:,:)   
;************************************************
; create plot
;************************************************
  wks = gsn_open_wks("png","barb")                 ; send graphics to PNG file

  res                         = True               ; plot mods desired

  res@vcRefMagnitudeF         = 10.                ; make vectors larger
  res@vcRefLengthF            = 0.050              ; ref vec length
  res@vcGlyphStyle            = "WindBarb"         ; select wind barbs 
  res@vcMinDistanceF          = 0.025              ; thin out windbarbs

  res@mpOutlineOn             = True               ; turn on map outline

  res@tiMainString            = "Default Wind Barbs" ; title 

  plot=gsn_csm_vector_map_ce(wks,u,v,res)          ; create plot

end
