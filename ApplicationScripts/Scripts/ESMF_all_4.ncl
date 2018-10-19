;======================================================================
; ESMF_all_4.ncl
;
; Concepts illustrated:
;   - Interpolating from one grid to another using ESMF software
;   - Interpolating data from a subset of a high-res topo grid to a low-res 0.5 grid
;======================================================================
; This example is identical to ESMF_regrid_4.ncl, except it does the
; regridding in separate steps.  See ESMF_wgts_4.ncl for a faster 
; example of regridding using an existing weights file.
;======================================================================
; This is based on regrid_13.ncl, which regrids from a high-resolution
; regular grid to a lower resolution 0.5 degree grid.
;
; This example uses the ESMF application "ESMF_RegridWeightGen" to 
; generate the weights.
;
; For more information about ESMF:
;
;        http://www.earthsystemmodeling.org/
;
; This script uses built-in functions that are only available in 
; NCL V6.1.0 and later.
;======================================================================
;
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
;
; This file still has to be loaded manually
load "$NCARG_ROOT/lib/ncarg/nclscripts/esmf/ESMF_regridding.ncl"

begin
;---Output (and input) files
    srcGridName = "src_SCRIP.nc"
    dstGridName = "dst_SCRIP.nc"
    wgtFile     = "Rect_2_1deg.nc"

    latS  = 25    ; rough box that encloses the Tibet Plateau
    latN  = 42    ; this is larger than the 'final' Tibet region
    lonW  = 72    ; common TIBET region: 28N-40N and 75-104E
    lonE  = 108

;---Set to True if you want to skip any of these steps
    SKIP_SRC_SCRIP_GEN = False
    SKIP_DST_SCRIP_GEN = False
    SKIP_WGT_GEN       = False

;----------------------------------------------------------------------
; Step 1, part 1
;     Convert original NetCDF file to an SCRIP convention file.
;----------------------------------------------------------------------
    src_file = addfile("ETOPO2_GLOBAL_2_ELEVATION.nc","r")
    zcrit    = 1500  ; user specifed elevation boundary for Tibet 
    topo     = short2flt(src_file->ELEV({latS:latN},{lonW:lonE}))
    topo     = where(topo .lt.zcrit, topo@_FillValue , topo )

    if(.not.SKIP_SRC_SCRIP_GEN) then
      Opt                = True
      Opt@ForceOverwrite = True
      Opt@PrintTimings   = True
      Opt@Title          = "TOPO Grid"
      Opt@Mask2D         = where(.not.ismissing(topo),1,0) 
     

      rectilinear_to_SCRIP(srcGridName,topo&LAT,topo&LON,Opt)

;---Clean up
      delete(Opt)
   end if

;----------------------------------------------------------------------
; Step 1, part 2
;     Convert destination grid to SCRIP convention file.
;----------------------------------------------------------------------
    if(.not.SKIP_DST_SCRIP_GEN) then
      Opt                = True
      Opt@LLCorner       = (/ latS, lonW /)
      Opt@URCorner       = (/ latN, lonE /)
      Opt@ForceOverwrite = True
      Opt@PrintTimings   = True
      Opt@Title          = "Global 0.5 degree resolution"

      latlon_to_SCRIP(dstGridName,"0.5deg",Opt)

      delete(Opt)
    end if

;----------------------------------------------------------------------
; Step 2
;     Generate the weights that take you from the TOPO grid to a
;     1 degree grid.
;----------------------------------------------------------------------
    if(.not.SKIP_WGT_GEN) then
      Opt                = True
      Opt@ForceOverwrite = True
      Opt@InterpMethod   = "conserve"
      Opt@SrcRegional    = True
      Opt@DstRegional    = True
      Opt@PrintTimings   = True
      ESMF_regrid_gen_weights(srcGridName,dstGridName,wgtFile,Opt)

      delete(Opt)
    end if

;----------------------------------------------------------------------
; Step 3
;     Apply the weights to a given variable on the NCEP file.
;----------------------------------------------------------------------
    Opt                = True
    Opt@PrintTimings   = True
    Opt@Debug          = True

    topo_regrid = ESMF_regrid_with_weights(topo,wgtFile,Opt)
    printVarSummary(topo_regrid)

;----------------------------------------------------------------------
; Plotting section
;----------------------------------------------------------------------
    wks = gsn_open_wks("png","ESMF_all")        ; send graphics to PNG file

    res                     = True              ; Plot modes desired.
    res@gsnDraw             = False
    res@gsnFrame            = False

    res@gsnMaximize         = True              ; Maximize plot
    
    res@mpFillOn            = False
    res@mpMinLatF           = latS 
    res@mpMaxLatF           = latN
    res@mpMinLonF           = lonW
    res@mpMaxLonF           = lonE
    res@mpCenterLonF        = (lonW+lonE)*0.5

    res@cnFillOn            = True              ; color plot desired
    res@cnFillPalette       = "BlAqGrYeOrReVi200"  ; set color map
    res@cnFillMode          = "RasterFill"      
    res@cnLinesOn           = False             ; turn off contour lines
    res@cnLineLabelsOn      = False             ; turn off contour lines

    res@cnLevelSelectionMode =  "ManualLevels"   ; manual levels
    res@cnMinLevelValF       = zcrit              ; set min contour level
    res@cnMaxLevelValF       = 5750               ; set max contour level
    res@cnLevelSpacingF      =  250 

    res@lbLabelBarOn        = False

    res@gsnAddCyclic        = False

    res@tiMainString = "TOPO: Original data " + \
                       str_join(tostring(dimsizes(topo))," x ")

    plot_orig = gsn_csm_contour_map(wks,topo,res) 

    res@gsnAddCyclic        = False
    res@tiMainString = "TOPO: Regridded to 0.5 degree " + \
                       str_join(tostring(dimsizes(topo_regrid))," x ") + \
                       " (conserve)"

    plot_regrid = gsn_csm_contour_map(wks,topo_regrid,res)     

;---Resources for paneling
    pres                  = True
    pres@gsnMaximize      = True
    pres@gsnPanelLabelBar = True

    gsn_panel(wks,(/plot_orig,plot_regrid/),(/2,1/),pres)
end
