;----------------------------------------------------------------------
; ESMF_regrid_28.ncl
;
; Concepts illustrated:
;   - Interpolating from a rectilinear to a POP grid using ESMF_regrid
;   - The variable on the source (rectilinear) grid is type 'short'
;     This must be unpacked prior to usage.
;     Further only the first time step is read. No need for multiple times.
;   - Using mask for the destination (POP) grid
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

;---Specify name of rectilinear (RL) grid
    RL_res       = "T62"          ; arbitrary

;---Specify name of destination POP grid
    DstGridName  = "gx1v3"
    POP_res      = DstGridName

;---Specify name of weight file to be generated; name of destination grid; dst directory
    WgtFileDir   = "./"
    WgtFileName  = "wgt.RL_"+RL_res+"_to_"+DstGridName+"."+remap_method+".nc"

;---Sample plot options
    pltDir   = "./"
    pltType  = "png"                  ; send graphics to PNG file
   ;pltName  = "RL_"+RL_res+"_to_"+DstGridName
    pltName  = "ESMF_regrid"

;---Data file containing source grid lat and lon
    RL_dir   = "./"
    RL_file  = "air.2m.gauss.t5.nc"
    sfile    = addfile(RL_dir + RL_file,"r")

;---Data file containing destination POP grid information
    POP_dir  = "./"
    POP_file = "TEMP.nc"                      ; this is a 'one variable' POP file
    dfile    = addfile(POP_dir+POP_file,"r")

;---Get variable to regrid from source file (rectilinear) 
    var_name = "air"                                  ; type short must convert to float or double                  
    var_in   = short2flt( sfile->$var_name$(0,:,:) )  ; only need lat/lon (ie: spatial information)
    src_lat  = sfile->lat
    src_lon  = sfile->lon

;---Set up regridding options
    Opt                = True
    Opt@InterpMethod   = remap_method

    Opt@WgtFileName    = WgtFileName                      
    Opt@SrcGridLat     = src_lat
    Opt@SrcGridLon     = src_lon

    Opt@DstGridLat     = dfile->TLAT                   ; scalar grid locations
    Opt@DstGridLon     = dfile->TLONG
    Opt@DstGridType    = "curvilinear"

    POP_var            = dfile->TEMP(0,0,:,:)          ; read POP variable to create mask
                                                       ; first time and 'near' sfc level
    Opt@DstMask2D      = where(ismissing(POP_var),0,1)

    Opt@ForceOverwrite = True
    Opt@Debug          = True
    Opt@PrintTimings   = True

;---Call the regridding function; Generate weight file
    var_regrid = ESMF_regrid(var_in,Opt)
    printVarSummary(var_regrid)
    
    dims_regrid = dimsizes(var_regrid)
    rank_regrid = dimsizes(dims_regrid)
    var_regrid!(rank_regrid-1) = "ncol"

    delete(var_regrid@lon1d)
    delete(var_regrid@lat1d)
    printVarSummary(var_regrid)

;----------------------------------------------------------------------
; Plotting section
;
; This section creates filled contour plots of both the original
; data and the regridded data, and panels them.
;----------------------------------------------------------------------
    dims_in = dimsizes(var_in)
    rank_in = dimsizes(dims_in)

    wks = gsn_open_wks(pltType,pltDir+pltName)

;---Resources to share between both plots
    res                      = True              ; Plot modes desired.

    res@gsnDraw              = False
    res@gsnFrame             = False

    res@gsnMaximize          = True              ; Maximize plot

    res@cnFillOn             = True              ; color plot desired
    res@cnLinesOn            = False             ; turn off contour lines
    res@cnLineLabelsOn       = False             ; turn off contour labels
    res@cnFillMode           = "RasterFill"      ; turn raster on      

    res@lbLabelBarOn         = False       ; Will turn on in panel later

    res@mpFillOn             = False

   ;res@gsnLeftString        = var_name    ; long_name is too long!
    res@gsnLeftString        = var_in@long_name
 
;---Resources for plotting regridded data
    res@gsnAddCyclic  = True               ; default is True

    dims = tostring(dimsizes(var_in))
    rank = dimsizes(dims)
    res@tiMainString = "Original rectilinear grid: " + str_join(dims(rank-2:)," x ")

    plot_orig = gsn_csm_contour_map(wks,var_in,res)

;---Resources for contouring the above grid; apply to next grid

    res@cnLevelSelectionMode = "ManualLevels"
    getvalues plot_orig@contour
      "cnMinLevelValF"       : res@cnMinLevelValF   
      "cnMaxLevelValF"       : res@cnMaxLevelValF 
      "cnMaxLevelValF"       : res@cnMaxLevelValF 
      "cnLevelSpacingF"      : res@cnLevelSpacingF
    end getvalues

;---Resources for plotting destination (POP) data

    var_regrid@lat2d = dfile->TLAT
    var_regrid@lon2d = dfile->TLONG
    res@gsnAddCyclic = True                 ; default is True

    res@tiMainString  = "Rectilinear to POP grid using "+Opt@InterpMethod + " method"

    plot_regrid = gsn_csm_contour_map(wks,var_regrid,res)  

;---Draw both plots in a panel
    pres                   = True
    pres@gsnMaximize       = True
    pres@gsnPanelLabelBar  = True

    gsn_panel(wks,(/plot_orig,plot_regrid/),(/2,1/),pres)
end
