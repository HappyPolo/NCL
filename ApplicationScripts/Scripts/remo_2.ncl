;*******************************************
; remo_2.ncl
;
; Concepts illustrated:
;   - Read a variable from a REMO GRIB formatted file 
;     for which a warning message was issued.
;   - Illustrate manually setting attributes after table lookup
;   - Plotting the variable
;********************************************************************

load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"   
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"   

begin
   diri  = "./"
   fili  = "REMO1_data.grb"

;********************************
; Read a variable for which a warning message was issued 
;      (see: 'ncl_filedump -itime' output)
; Force GRIB files with a single time step, to have an explicit 'time' dimension.
;********************************

   setfileoption("grb","SingleElementDimensions","Initial_time") 

   f     = addfile(diri+fili, "r")
   x     = f->VAR_130_GDS0_HYBY   ; ( initial_time0_hours, lv_HYBY3, g0_lat_4, g0_lon_5 )
   printVarSummary(x)

;********************************
; Must manually look at "REMO3_WRF_Vtable" to determine 
;      to what parameter 130 refers
;********************************
   x@long_name = "Temperature"
   x@units     = "degK"
   printVarSummary(x)

;********************************
; plot
;********************************
   wks = gsn_open_wks("ps","remo")       
 ;;gsn_define_colormap(wks,"default")       ; choose colormap

   res                 = True               
   res@gsnMaximize     = True
   res@cnFillOn        = True               ; color plot desired
   res@cnLinesOn       = False
   res@cnLineLabelsOn  = False              ; turn off contour lines
   res@gsnAddCyclic    = False              ; regional grid ... not global

   res@mpMinLatF       = min(x&g0_lat_4)   ; region to zoom in on
   res@mpMaxLatF       = max(x&g0_lat_4)
   res@mpMinLonF       = min(x&g0_lon_5)
   res@mpMaxLonF       = max(x&g0_lon_5)
   res@mpCenterLonF    = 0.5*(res@mpMinLonF + res@mpMaxLonF)
   res@mpFillOn        = False              ; don't prefill land with gray

   nt  = 0                                  ; time index
   lvl = 25                                 ; level index
   time_str = f->initial_time0(nt)
   
   res@tiMainString    = fili+": "+time_str 
   res@gsnCenterString = "lvl_index="+lvl

   map = gsn_csm_contour_map(wks,x(nt,lvl,:,:),res)   
end


