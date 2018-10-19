;*******************************************
; remo_1.ncl
;
; Concepts illustrated:
;   - Read a variable from a GRIB formatted REMO file
;   - Plotting a REMO variable
;********************************************************************
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"   
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"   

begin
   diri  = "./"
   fili  = "REMO1_data.grb"

;********************************
; Read a variable (see: 'ncl_filedump -itime' output)
; This is a simple rectilinear grid
; Force GRIB files with a single time step, to have an explicit 'time' dimension.
;********************************

   setfileoption("grb","SingleElementDimensions","Initial_time") 

   f     = addfile(diri+fili, "r")
   pw    = f->P_WAT_GDS0_SFC               ; ( initial_time0_hours, g0_lat_1, g0_lon_2 )
   printVarSummary(pw)
;********************************
; plot
;********************************
   wks = gsn_open_wks("ps","remo")          ; open a workstation
   gsn_define_colormap(wks,"BlAqGrYeOrReVi200")   ; choose colormap

   res                 = True               
   res@gsnMaximize     = True 
   res@cnFillOn        = True               ; color plot desired
   res@cnLinesOn       = False
   res@cnLineLabelsOn  = False              ; turn off contour lines
   res@gsnAddCyclic    = False              ; regional grid ... not global

   res@mpMinLatF       = min(pw&g0_lat_1)   ; region to zoom in on
   res@mpMaxLatF       = max(pw&g0_lat_1)
   res@mpMinLonF       = min(pw&g0_lon_2)
   res@mpMaxLonF       = max(pw&g0_lon_2)
   res@mpCenterLonF    = 0.5*(res@mpMinLonF + res@mpMaxLonF)
   res@mpFillOn        = False              ; don't prefill land with gray

   res@tiMainString    = fili

   map = gsn_csm_contour_map(wks,pw(0,:,:),res)    ; Draw contours over a map.
end


