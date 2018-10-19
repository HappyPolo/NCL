;----------------------------------------------------------------------
; ESMF_regrid_25.ncl
;
; Concepts illustrated:
;   - Interpolating from one grid to another using ESMF_regrid
;   - Interpolating data from an unstructured SE grid to a finite volume grid
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
;---Specify remap method  
    remap_method = "bilinear"     ; "bilinear" , "patch", "conserve"

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
    SE_dir   = "./"
    SE_file  = "b.e11.B1850C5CN.ne30_g16.001.clm2.h0.0002-12.nc"
    sfile    = addfile(SE_dir + SE_file,"r")

;---Data file containing destination grid
    FV_dir   = "./"
    FV_file  = "b.e11.B1850CN.f19_g16.007.clm2.h0.0005-12.nc"
    dfile    = addfile(FV_dir+FV_file,"r")

;---Get any variable to regrid
;    var_name = "TSA"                  ; (time, lev, ncol) 
    var_name = "TSOI"                    ; TSOI(time, levgrnd, lndgrid)
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
    Opt@SrcInputFileName = SE_file 

    Opt@DstGridLat     = dfile->lat
    Opt@DstGridLon     = dfile->lon

    Opt@DstMask2D      = dfile->landmask 
    Opt@SrcMask2D      = sfile->landmask

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
;        LEV = var_in&lev(kl)
        LEV = var_in&levgrnd(kl)
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

    res@lbLabelBarOn         = False             ; Will turn on in panel later

    res@gsnLeftString        = var_name    ; long_name is too long!
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
    res@trGridType   = "TriangularMesh"  
    res@gsnAddCyclic = False

    res@mpFillOn             = True
    res@mpOceanFillColor     = "white"
    res@mpLandFillColor      = "transparent"
    res@mpFillDrawOrder      = "postdraw"

    res@tiMainString = "Original SE grid (" + dims_in(2) +" cells)"

    plot_orig = gsn_csm_contour_map(wks,var_in(nt,kl,:),res)  
;---Draw both plots in a panel
    pres                   = True
    pres@gsnMaximize       = True
    pres@gsnPanelLabelBar  = True

    gsn_panel(wks,(/plot_orig,plot_regrid/),(/2,1/),pres)
end
