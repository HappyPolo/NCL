;======================================================================
; ESMF_all_3.ncl
;
; Concepts illustrated:
;   - Interpolating from one grid to another using ESMF software
;   - Interpolating data from a fixed high-res grid to T42 and T85 grids
;======================================================================
; This example is identical to ESMF_regrid_3.ncl, except it does the
; regridding in separate steps.  See ESMF_wgts_3.ncl for a faster 
; example of regridding using an existing weights file.
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
;---Input file
    srcFileName     = "TEST.TRMM_3B43V6_CLM.1998-2005.nc"

;---Output (and input) files
    srcGridName     = "src_SCRIP.nc"
    dstGridName_T85 = "dst_SCRIP_T85.nc"
    dstGridName_T42 = "dst_SCRIP_T42.nc"
    wgtFile_T85_pfx = "Rect_2_T85"
    wgtFile_T42_pfx = "Rect_2_T42"

;---Interpolation methods to use
    methods  = (/"bilinear","patch","conserve"/)
    nmethods = dimsizes(methods)

;---Set to True if you want to skip any of these steps
    SKIP_SRC_SCRIP_GEN     = False
    SKIP_DST_SCRIP_GEN_T85 = False
    SKIP_DST_SCRIP_GEN_T42 = False
    SKIP_WGT_GEN_T85       = False
    SKIP_WGT_GEN_T42       = False

;----------------------------------------------------------------------
; Step 1, part 1
;     Convert original NetCDF file to a SCRIP convention file.
;----------------------------------------------------------------------
    sfile = addfile(srcFileName,"r")
    prc   = sfile->TRMM_PRC           ; (time,lat,lon) => (1,480,1440)
    prc   = prc/3                     ; Not sure why doing this

    dimx  = dimsizes( prc )
    ntim  = dimx( 0 )
    nlat  = dimx( 1 )                 ; 400   [0.25 x 0.25 ]
    mlon  = dimx( 2 )                 ; 1440

    latS  = prc&lat(0)                  ; south extent of input grid
    latN  = prc&lat(nlat-1)             ; north extent

    if(.not.SKIP_SRC_SCRIP_GEN) then
      Opt                = True
      Opt@PrintTimings   = True
      Opt@ForceOverwrite = True
      Opt@Title          = "TRMM Grid"

      rectilinear_to_SCRIP(srcGridName,prc&lat,prc&lon,Opt)

;---Clean up
      delete(Opt)
   end if

;----------------------------------------------------------------------
; Step 1, part 2a
;     Convert T85 destination grid to SCRIP convention file.
;----------------------------------------------------------------------
   NLATT85 = 128                               ; RES   = "T85"    
   MLONT85 = 256                              
   LATT85  = latGau    (NLATT85, "LATT85", "latitude" , "degrees_north")  
   LONT85  = lonGlobeFo(MLONT85, "LONT85", "longitude", "degrees_east" ) 
   LAT_REGT85 = LATT85({latS:latN})

   if(.not.SKIP_DST_SCRIP_GEN_T85) then
      Opt                = True
      Opt@ForceOverwrite = True
      Opt@PrintTimings   = True
      Opt@Title          = "T85"

      rectilinear_to_SCRIP(dstGridName_T85,LAT_REGT85,LONT85,Opt)

;---Clean up
      delete(Opt)
    end if

;----------------------------------------------------------------------
; Step 1, part 2b
;     Convert T42 destination grid to SCRIP convention file.
;----------------------------------------------------------------------
    NLATT42 =  64                               ; RES   = "T42"    
    MLONT42 = 128                              
    LATT42  = latGau    (NLATT42, "LATT42", "latitude" , "degrees_north")  
    LONT42  = lonGlobeFo(MLONT42, "LONT42", "longitude", "degrees_east" )  
    LAT_REGT42 = LATT42({latS:latN})

    if(.not.SKIP_DST_SCRIP_GEN_T42) then
      Opt                = True
      Opt@ForceOverwrite = True
      Opt@PrintTimings   = True
      Opt@Title          = "T42"

      rectilinear_to_SCRIP(dstGridName_T42,LAT_REGT42,LONT42,Opt)

;---Clean up
      delete(Opt)
    end if

;----------------------------------------------------------------------
; Graphics setup before we start looping across each
; interpolation method.
;----------------------------------------------------------------------
    wks = gsn_open_wks("png","ESMF_all")           ; send graphics to PNG file

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
; Loop across each method and generate the weights for a T42 and T85 grid,
; apply the weights for the interpolation, and plot.
;----------------------------------------------------------------------
    do i=0,nmethods-1
      print("Method = " + methods(i))
;----------------------------------------------------------------------
; Step 2, part 2a
;     Generate the weights that take you from the 0.25 x 0.25 grid to
;     a T85 grid.
;----------------------------------------------------------------------
      if(.not.SKIP_WGT_GEN_T85) then
        wgtFile = wgtFile_T85_pfx + "_" + methods(i) + ".nc"

        Opt                      = True
        Opt@SrcRegional          = True
        Opt@DstRegional          = True
        Opt@ForceOverwrite       = True
        Opt@InterpMethod         = methods(i)
;       Opt@Debug                = True
        Opt@PrintTimings         = True

        ESMF_regrid_gen_weights(srcGridName,dstGridName_T85,wgtFile,Opt)

;---Clean up
        delete(Opt)
      end if

;----------------------------------------------------------------------
; Step 2, part 2b
;     Generate the weights that take you from the 0.25 x 0.25 grid to
;     a T42 grid.
;----------------------------------------------------------------------
      if(.not.SKIP_WGT_GEN_T42) then
        wgtFile = wgtFile_T42_pfx + "_" + methods(i) + ".nc"

        Opt                      = True
        Opt@SrcRegional          = True
        Opt@DstRegional          = True
        Opt@ForceOverwrite       = True
        Opt@InterpMethod         = methods(i)
;       Opt@Debug                = True
        Opt@PrintTimings         = True

        ESMF_regrid_gen_weights(srcGridName,dstGridName_T42,wgtFile,Opt)

;---Clean up
        delete(Opt)
      end if

;----------------------------------------------------------------------
; Step 3
;     Apply the weights to a given variable on the TRMM file.
;----------------------------------------------------------------------
      Opt                = True
;     Opt@Debug          = True
      Opt@PrintTimings   = True

;---T85
      wgtFile = wgtFile_T85_pfx + "_" + methods(i) + ".nc"
      prc_regrid_T85 = ESMF_regrid_with_weights(prc,wgtFile,Opt)
      printVarSummary(prc_regrid_T85)

;---T42
      wgtFile = wgtFile_T42_pfx + "_" + methods(i) + ".nc"
      prc_regrid_T42 = ESMF_regrid_with_weights(prc,wgtFile,Opt)
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
