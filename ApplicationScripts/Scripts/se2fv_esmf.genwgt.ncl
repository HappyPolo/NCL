;----------------------------------------------------------------------
; This example uses ESMF regridding software to regrid from an
; unstructured SE grid to a CAM finite volume grid (96 x 144).
;----------------------------------------------------------------------
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/esmf/ESMF_regridding.ncl"

begin
;---Specify remap method  
    remap_method = "conserve"  ; "bilinear" , "patch", "conserve"

;---Specify source SE grid resolution
    SE_res       = "ne30"

;---Specify name of destination grid
    DstGridName  = "FV_96x144"

;---Specify name of weight file to be generated; name of destination grid; dst directory
    WgtFileDir   = "./"
    WgtFileName  = "SE_"+str_upper(SE_res)+"_to_"+DstGridName+"."+remap_method+".nc"

;---Sample plot options
    pltDir   = "./"
    pltType  = "png"
    pltName  = "SE_"+str_upper(SE_res)+"_to_"+DstGridName

;---Data file containing source grid (sample)
    SE_dir   = "/ptmp/shea/SE_REGRID/ORIG_FILES/"
    SE_file  = "b.e11.B1850C5CN.ne30_g16.tuning.004.cam.h0.0013-01.nc"
    sfile    = addfile(SE_dir + SE_file,"r")

;---Data file containing destination grid
    FV_dir   = "/ptmp/shea/SE_REGRID/ORIG_FILES/"
    FV_file  = "CAM_TEST_b30.081_climo.nc"
    dfile    = addfile(FV_dir+FV_file,"r")

;---Get any variable to regrid
    var_name = "T"                  ; (time, lev, ncol) 
    var_in   = sfile->$var_name$
    src_lat  = sfile->lat
    src_lon  = sfile->lon

;+++
; End user input
;+++

;---Set up regridding options
    Opt                = True
    Opt@InterpMethod   = remap_method

    Opt@WgtFileName    = WgtFileDir+WgtFileName
    Opt@SrcGridLat     = src_lat
    Opt@SrcGridLon     = src_lon

    Opt@DstGridLat     = dfile->lat
    Opt@DstGridLon     = dfile->lon

  ;;if (remap_method.eq."conserve") then
  ;;    Opt@DstLLCorner      = (/-90.00d,   0.00d /)
  ;;    Opt@DstURCorner      = (/ 90.00d, 357.50d /) 
  ;;end if

    Opt@ForceOverwrite = True
    Opt@Debug          = True
    Opt@PrintTimings   = True

;---Call the regridding function
    var_regrid = ESMF_regrid(var_in,Opt)
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
        LEV = var_in&lev(kl)
    end if

    pltName = pltName+"."+remap_method
    pltPath = pltDir+pltName
    wks = gsn_open_wks(pltType,pltPath)

;---Resources to share between both plots
    res                      = True              ; Plot modes desired.

    res@gsnDraw              = False
    res@gsnFrame             = False

    res@gsnMaximize          = True              ; Maximize plot

    res@cnFillOn             = True              ; color plot desired
    res@cnLinesOn            = False             ; turn off contour lines
    res@cnLineLabelsOn       = False             ; turn off contour labels
    res@cnFillMode           = "RasterFill"      ; turn raster on      

    res@lbLabelBarOn         = False      ; Will turn on in panel later

    res@mpFillOn             = False

   ;res@gsnLeftString        = var_name    ; long_name is too long!
    res@gsnLeftString        = var_in@long_name
    res@gsnCenterString      = "lev="+LEV
 
;---Resources for plotting regridded data
    res@gsnAddCyclic  = True

    dims = tostring(dimsizes(var_regrid))
    rank = dimsizes(dims)
    res@tiMainString  = "Data regridded to FV grid (" + \
                        str_join(dims(rank-2:)," x ") + ") using '" + \
                        Opt@InterpMethod + "' method"

    plot_regrid = gsn_csm_contour_map(wks,var_regrid(nt,kl,:,:),res)

;---Resources for contouring the above grid; apply to next grid

    res@cnLevelSelectionMode = "ManualLevels"
    getvalues plot_regrid@contour
      "cnMinLevelValF"       : res@cnMinLevelValF   
      "cnMaxLevelValF"       : res@cnMaxLevelValF 
      "cnMaxLevelValF"       : res@cnMaxLevelValF 
      "cnLevelSpacingF"      : res@cnLevelSpacingF
    end getvalues

;---Resources for plotting original (source) data
    res@sfXArray     = src_lon
    res@sfYArray     = src_lat
    res@gsnAddCyclic = False

    res@tiMainString = "Original SE grid (" + dims_in(2) + \
                       " cells)"

    plot_orig = gsn_csm_contour_map(wks,var_in(nt,kl,:),res)  

;---Draw both plots in a panel
    pres                   = True
    pres@gsnMaximize       = True
    pres@gsnPanelLabelBar  = True

    gsn_panel(wks,(/plot_orig,plot_regrid/),(/2,1/),pres)
end
