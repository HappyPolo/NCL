;======================================================================
; ESMF_regrid_3.ncl
;
; Concepts illustrated:
;   - Interpolating from one grid to another using ESMF_regrid
;   - Interpolating data from a fixed high-res grid to T42 and T85 grids
;======================================================================
; This example is identical to ESMF_all_3.ncl, except it does the
; regridding in one call to "ESMF_regrid".  See ESMF_wgts_3.ncl
; for a faster example of regridding using an existing weights file.
;======================================================================
; This is based on regrid_11.ncl, which regrids from a high-resolution
; fixed grid with limited latitudinal extent to lower resolution
; gaussian grids (T42 and T85) with approximately the same 
; latitudinal extent.
;
; This example uses the ESMF application "ESMF_RegridWeightGen" to 
; generate the weights. Three different interpolation methods are
; compared: bilinear, patch, and conservative.
;
; For more information about ESMF:
;
;        http://www.earthsystemmodeling.org/
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
;---File containing source grid
    srcFileName    = "TEST.TRMM_3B43V6_CLM.1998-2005.nc"

;---Filenames for source, destination, and weight files
    srcGridName     = "src_SCRIP.nc"
    dstGridName_T85 = "dst_SCRIP_T85.nc"
    dstGridName_T42 = "dst_SCRIP_T42.nc"
    wgtFile_T85_pfx = "Rect_2_T85"
    wgtFile_T42_pfx = "Rect_2_T42"

;---Interpolation methods to use
    methods  = (/"bilinear","patch","conserve"/)
    nmethods = dimsizes(methods)

;---Read variable to regrid
    sfile = addfile(srcFileName,"r")
    prc   = sfile->TRMM_PRC           ; (time,lat,lon) => (1,480,1440)
    prc   = prc/3                     ; Not sure why doing this

    dimx  = dimsizes( prc )
    ntim  = dimx( 0 )
    nlat  = dimx( 1 )                 ; 400   [0.25 x 0.25 ]
    mlon  = dimx( 2 )                 ; 1440

    latS  = prc&lat(0)                  ; south extent of input grid
    latN  = prc&lat(nlat-1)             ; north extent

;---Set common resources
    Opt                  = True
    Opt@SrcFileName      = srcGridName    ; name of output source file
    Opt@ForceOverwrite   = True

    Opt@SrcInputFileName = srcFileName    ; optional, but good idea
    Opt@SrcTitle         = "TRMM Grid"

    Opt@SrcRegional      = True
    Opt@DstRegional      = True

    ;;Opt@PrintTimings   = True

;---We'll be regridding to two different destination grids
    OptT85 = Opt
    OptT42 = Opt

;---Generate lat/lons for T85 grid
    NLATT85    = 128
    MLONT85    = 256                              
    LATT85     = latGau    (NLATT85, "LATT85", "latitude" , "degrees_north")  
    LONT85     = lonGlobeFo(MLONT85, "LONT85", "longitude", "degrees_east" ) 
    LAT_REGT85 = LATT85({latS:latN})

;---Destination grid
    OptT85@DstGridLat = LAT_REGT85
    OptT85@DstGridLon = LONT85

;---Generate lat/lons for T42 grid
    NLATT42    =  64
    MLONT42    = 128                              
    LATT42     = latGau    (NLATT42, "LATT42", "latitude" , "degrees_north")  
    LONT42     = lonGlobeFo(MLONT42, "LONT42", "longitude", "degrees_east" )  
    LAT_REGT42 = LATT42({latS:latN})

;---Destination grid
    OptT42@DstGridLat = LAT_REGT42
    OptT42@DstGridLon = LONT42

;----------------------------------------------------------------------
; Graphics setup before we start looping across each
; interpolation method.
;----------------------------------------------------------------------
    wks = gsn_open_wks("png","ESMF_regrid")        ; send graphics to PNG file

    colors = (/"Snow","PaleTurquoise","PaleGreen","SeaGreen3" ,"Yellow",  \
               "Orange","HotPink","Red","Violet", "Purple", "Brown"/)
 
    plot = new (3, "graphic")
     
    res                      = True     ; plot mods desired
    res@gsnDraw              = False    ; don't draw
    res@gsnFrame             = False    ; don't advance frame
     
    res@cnFillOn             = True     ; turn on color fill
    res@cnFillPalette        = colors   ; set color map
    res@cnLinesOn            = False    ; turn of contour lines
    res@cnFillMode           = "RasterFill"         ; Raster Mode
    res@cnLinesOn            =  False       ; Turn off contour lines
    res@cnLineLabelsOn       =  False       ; Turn off contour lines
    res@cnLevelSelectionMode = "ExplicitLevels"              
    res@cnLevels             = (/0.1,1,2.5,5.0,7.5,10,15,20,25,50/)

    res@cnMissingValFillPattern = 0         ; make 'missing' black
    res@cnMissingValFillColor   = "black"

    res@lbLabelBarOn         = False    ; turn off individual cb's
     
    res@mpCenterLonF         = 210.
    res@mpFillOn             = False
    res@mpMinLatF            = latS     ; range to zoom in on
    res@mpMaxLatF            = latN
   
    nt = 0    ; First time step

;---Resources for paneling
    resP                     = True
    resP@gsnMaximize         = True
    resP@gsnPanelLabelBar    = True                ; add common colorbar
    resP@lbLabelFontHeightF  = 0.0175              ; change font size

;----------------------------------------------------------------------
; Loop across each method and generate the weights for a T42 and
; T85 grid, apply the weights for the interpolation, and plot.
;----------------------------------------------------------------------
    do i=0,nmethods-1
      print("Method = " + methods(i))

;---Regrid to T85 grid
      OptT85@WgtFileName   = wgtFile_T85_pfx + "_" + methods(i) + ".nc"
      OptT85@InterpMethod  = methods(i)
      prc_regrid_T85       = ESMF_regrid(prc,OptT85)

      printVarSummary(prc_regrid_T85)
;
; The source grid description file will be the same for
; all seceding calls to ESMF_grid, so no need to keep
; regenerating it.
;
      OptT85@SkipSrcGrid   = True
      OptT42@SkipSrcGrid   = True

;---Regrid to T42 grid
      OptT42@WgtFileName   = wgtFile_T42_pfx + "_" + methods(i) + ".nc"
      OptT42@InterpMethod  = methods(i)
      prc_regrid_T42       = ESMF_regrid(prc,OptT42)

      printVarSummary(prc_regrid_T42)
;----------------------------------------------------------------------
; Plotting section
;----------------------------------------------------------------------
      sdims = tostring(dimsizes(prc(0,:,:)))
      res@gsnLeftString   = "Original 0.25 degree grid (" + \
                            str_join(sdims," x ") + ")"

      plot(0) = gsn_csm_contour_map_ce(wks,prc(nt,:,:), res)

      sdims = tostring(dimsizes(prc_regrid_T85(0,:,:)))
      res@gsnLeftString   = "T85 (" + str_join(sdims," x ") + ")"

      plot(1) = gsn_csm_contour_map_ce(wks,prc_regrid_T85(nt,:,:), res)

      sdims = tostring(dimsizes(prc_regrid_T42(0,:,:)))
      res@gsnLeftString   = "T42 (" + str_join(sdims," x ") + ")"

      plot(2) = gsn_csm_contour_map_ce(wks,prc_regrid_T42(nt,:,:), res)

;---Panel three plots on page
      resP@txString = "Fixed-to-Gaussian (Region) using '" + \
                      methods(i) + "' regridding"

      gsn_panel(wks,plot,(/3,1/),resP)               ; now draw as one plot

;---Clean up before next time through loop
      delete(prc_regrid_T85)
      delete(prc_regrid_T42)
    end do    ; end methods
end
