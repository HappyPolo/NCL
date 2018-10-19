;----------------------------------------------------------------------
; ESMF_wgts_25.ncl
;
; Concepts illustrated:
;   - Interpolating from one grid to another using ESMF_regrid_with_weights
;   - Interpolating data from an unstructured SE grid to a finite volume grid
;----------------------------------------------------------------------
; This example is identical to ESMF_regrid_25.ncl, except it assumes
; the weights file already exists, and does regridding using 
; "ESMF_regrid_with_weights".  This is the best method to use if you 
; already have the weights.
;----------------------------------------------------------------------
; This example uses ESMF regridding software to regrid from an
; unstructured SE grid to a CAM finite volume grid (96 x 144).
;----------------------------------------------------------------------
; NOTE
; The CLM sets all ocean node *locations and values* to _FillValue. 
; This is not consistent with the ocean model (POP) which provides
; valid lat/lon ocean locations and sets the corresponding value 
; to _FillValue. 
;----------------------------------------------------------------------
;
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
;
; This file still has to be loaded manually
load "$NCARG_ROOT/lib/ncarg/nclscripts/esmf/ESMF_regridding.ncl"

begin
;    WgtFileName  = "SE_NE30_to_FV_96x144.bilinear.nc"
  sfile = addfile("SE_NE30_to_FV_96x144.bilinear.nc","r")

;---Get any variable to regrid
;    var_name = "TSA"                  ; (time, lev, ncol) 
    var_name = "TSOI"                    ; TSOI(time, levgrnd, lndgrid)
    var_in   = sfile->$var_name$
    src_lat  = sfile->lat
    src_lon  = sfile->lon
;    var_in   = WgtFileName->$var_name$
;    src_lat  = WgtFileName->lat
;    src_lon  = WgtFileName->lon


;---Set up regridding options
    Opt                = True
    Opt@Debug          = True
    Opt@PrintTimings   = True

;---Do the regridding using the weights file
    var_regrid = ESMF_regrid_with_weights(var_in,WgtFileName,Opt)
    printVarSummary(var_regrid)

;----------------------------------------------------------------------
; Plotting section
;
; This section creates filled contour plots of both the original
; data and the regridded data, and panels them.
;----------------------------------------------------------------------
    dims_in = dimsizes(var_in)
    rank_in = dimsizes(dims_in)
    ntim    = dims_in(0)
    if (rank_in.ge.3) then
        klev = dims_in(1)
        nt  = 0
        kl  = klev/2
;        LEV = var_in&lev(kl)
        LEV = var_in&levgrnd(kl)
    end if

    wks = gsn_open_wks("png","ESMF_wgts")        ; send graphics to PNG file

;---Resources to share between both plots
    res                      = True              ; Plot mods desired.

    res@gsnMaximize          = True              ; Maximize plot

    res@cnFillOn             = True              ; color plot desired
    res@cnLinesOn            = False             ; turn off contour lines
    res@cnLineLabelsOn       = False             ; turn off contour labels
    res@cnFillMode           = "RasterFill"      ; turn raster on      

    res@gsnLeftString        = var_name    ; long_name is too long!
    res@gsnLeftString        = var_in@long_name
    res@gsnCenterString      = "lev="+LEV
 
    res@gsnAddCyclic  = True

    dims = tostring(dimsizes(var_regrid))
    rank = dimsizes(dims)
    res@tiMainString  = "Data regridded to FV grid (" + \
                        str_join(dims(rank-2:)," x ") + \
                        ") using 'bilinear method"

    plot_regrid = gsn_csm_contour_map(wks,var_regrid(nt,kl,:,:),res)
end
