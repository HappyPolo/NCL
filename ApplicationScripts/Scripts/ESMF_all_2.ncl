;======================================================================
; ESMF_all_2.ncl
;
; Concepts illustrated:
;   - Interpolating from one grid to another using ESMF software
;   - Interpolating data from a fixed high-res grid to fixed offset 2x3 and 5x5 degree grids
;   - Writing data to a NetCDF file using the easy but inefficient method
;======================================================================
; This example is identical to ESMF_regrid_1.ncl, except it does the
; regridding in separate steps.  See ESMF_wgts_1.ncl for a faster 
; example of regridding using an existing weights file.
;======================================================================
; This is based on regrid_6.ncl, which regrids from a high-resolution
; (1x1) fixed grid to two different lower resolution fixed-offset
; grids (2x3 and 5x5).
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

;----------------------------------------------------------------------
; Write the regridded variable to a file using the "inefficient" method.
;----------------------------------------------------------------------
procedure write_netcdf(infile, outfilename, var_regrid, varname, interp_method)
local outfilename, ofile, global
begin
    system("rm -f " + outfilename)
    ofile = addfile(outfilename,"c")

    print("--------------------------------------------------")
    print("Writing results to '" + outfilename + "'...")

;---Create variable to hold global file attributes
    global = True
    copy_VarAtts(infile, global)

    if (isatt(infile,"title")) then
      global@TITLE = "REMAPPED: " + infile@title
    end if
    global@remap = "NCL: ESMF_regrid_with_weights (NCL version '" + \
                   get_ncl_version() + "')"
    global@remap_method  = interp_method
    global@creation_date = systemfunc("date")
    
    fileattdef( ofile, global )               ; copy global file attributes
    filedimdef( ofile,var_regrid!0,-1,True)   ; force an unlimited dimension
;
; Write variables to file. Coordinate arrays will be written 
; automatically
;
   ofile->$varname$ = var_regrid
end

;----------------------------------------------------------------------
; Main code
;----------------------------------------------------------------------
begin
    WRITE_RESULTS = True 

;---Input file
    srcFileName     = "pregpcp.test.daily.nc"

;---Output (and input) files
    srcGridName     = "src_SCRIP.nc"
    dstGridName_2x3 = "dst_SCRIP_2x3.nc"
    dstGridName_5x5 = "dst_SCRIP_5x5.nc"
    wgtFile_2x3_pfx = "Fixed_2_2x3"
    wgtFile_5x5_pfx = "Fixed_2_5x5"
    outFile_2x3_pfx = "pregpcp_regrid_2x3"
    outFile_5x5_pfx = "pregpcp_regrid_5x5"

;---Interpolation methods to use
    methods  = (/"bilinear","patch","conserve"/)
    nmethods = dimsizes(methods)

;---Set to True if you want to skip any of these steps
    SKIP_SRC_SCRIP_GEN     = False
    SKIP_DST_SCRIP_GEN_2x3 = False
    SKIP_DST_SCRIP_GEN_5x5 = False
    SKIP_WGT_GEN_2x3       = False
    SKIP_WGT_GEN_5x5       = False

;----------------------------------------------------------------------
; Step 1, part 1
;     Convert lat/lon grid from a NetCDF file to a SCRIP convention 
;     file.
;----------------------------------------------------------------------
    sfile = addfile(srcFileName,"r")

    x     = short2flt(sfile->data)                ; 12 x 180 x 360
    x     = x(:,::-1,:)                           ; required to be S->N
    dimx  = dimsizes( x )
    ntim  = dimx(0)
    nlat  = dimx(1)
    mlon  = dimx(2)

    if(.not.SKIP_SRC_SCRIP_GEN) then
      Opt                = True
      Opt@ForceOverwrite = True
      Opt@PrintTimings   = True
      Opt@Title          = "GPCP Grid"

      rectilinear_to_SCRIP(srcGridName,x&lat,x&lon,Opt)

;---Clean up
      delete(Opt)
   end if

;----------------------------------------------------------------------
; Step 1, part 2a
;     Convert 2x3 destination grid to SCRIP convention file.
;----------------------------------------------------------------------
   NLAT2x3 =  90
   MLON2x3 = 120                              
   LAT2x3  = latGlobeFo(NLAT2x3, "LAT2x3", "latitude" , "degrees_north")  
   LON2x3  = lonGlobeFo(MLON2x3, "LON2x3", "longitude", "degrees_east" ) 

   if(.not.SKIP_DST_SCRIP_GEN_2x3) then
      Opt                = True
      Opt@ForceOverwrite = True
      Opt@PrintTimings   = True
      Opt@Title          = "2x3"

      rectilinear_to_SCRIP(dstGridName_2x3,LAT2x3,LON2x3,Opt)

;---Clean up
      delete(Opt)
    end if

;----------------------------------------------------------------------
; Step 1, part 2b
;     Convert 5x5 destination grid to SCRIP convention file.
;----------------------------------------------------------------------
    NLAT5x5 = 36
    MLON5x5 = 72                               
    LAT5x5  = latGlobeFo(NLAT5x5, "LAT5x5", "latitude" , "degrees_north")  
    LON5x5  = lonGlobeFo(MLON5x5, "LON5x5", "longitude", "degrees_east" )  

    if(.not.SKIP_DST_SCRIP_GEN_5x5) then
      Opt                = True
      Opt@ForceOverwrite = True
      Opt@PrintTimings   = True
      Opt@Title          = "5x5"

      rectilinear_to_SCRIP(dstGridName_5x5,LAT5x5,LON5x5,Opt)

;---Clean up
      delete(Opt)
    end if

;----------------------------------------------------------------------
; Graphics setup before we start looping across each
; interpolation method.
;----------------------------------------------------------------------
    wks = gsn_open_wks("png","ESMF_all"); send graphics to PNG file

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
    res@cnLevels             = (/0.1,1,2.5,5,10,15,20,25,50,75/)

    res@cnMissingValFillPattern = 0         ; make 'missing' black
    res@cnMissingValFillColor   = "black"

    res@lbLabelBarOn         = False    ; turn off individual cb's
     
    res@mpCenterLonF         = 210.
    res@mpFillOn             = False

;---Resources for paneling
    resP                     = True
    resP@gsnMaximize         = True
    resP@gsnPanelLabelBar    = True                ; add common colorbar
    resP@lbLabelFontHeightF  = 0.0175              ; change font size

    nt = 0    ; First time step

;----------------------------------------------------------------------
; Loop across each interpolation method and generate the weights 
; for both a 5x5 and 2x3 grid, apply the weights for the
; interpolation, and plot.
;----------------------------------------------------------------------
    do i=0,nmethods-1
      print("Regridding using method = " + methods(i))
;----------------------------------------------------------------------
; Step 2, part 2a
;     Generate the weights that take you from the 1x1 grid to
;     a 2x3 grid.
;----------------------------------------------------------------------
      if(.not.SKIP_WGT_GEN_2x3) then
        wgtFile = wgtFile_2x3_pfx + "_" + methods(i) + ".nc"

        Opt                      = True
        Opt@ForceOverwrite       = True
        Opt@InterpMethod         = methods(i)
        Opt@PrintTimings         = True
;       Opt@Debug                = True

        ESMF_regrid_gen_weights(srcGridName,dstGridName_2x3,wgtFile,Opt)

;---Clean up
        delete(Opt)
      end if

;----------------------------------------------------------------------
; Step 2, part 2b
;     Generate the weights that take you from the 0.25 x 0.25 grid to
;     a 5x5 grid.
;----------------------------------------------------------------------
      if(.not.SKIP_WGT_GEN_5x5) then
        wgtFile = wgtFile_5x5_pfx + "_" + methods(i) + ".nc"

        Opt                      = True
        Opt@ForceOverwrite       = True
        Opt@InterpMethod         = methods(i)
        Opt@PrintTimings         = True
;       Opt@Debug                = True

        ESMF_regrid_gen_weights(srcGridName,dstGridName_5x5,wgtFile,Opt)

;---Clean up
        delete(Opt)
      end if

;----------------------------------------------------------------------
; Step 3
;     Apply the weights to a given variable on the GPCP file.
;----------------------------------------------------------------------
      Opt                = True
      Opt@PrintTimings   = True
;     Opt@Debug          = True

;---2x3
      wgtFile = wgtFile_2x3_pfx + "_" + methods(i) + ".nc"
      x_regrid_2x3 = ESMF_regrid_with_weights(x,wgtFile,Opt)
      printVarSummary(x_regrid_2x3)

;---5x5
      wgtFile = wgtFile_5x5_pfx + "_" + methods(i) + ".nc"
      x_regrid_5x5 = ESMF_regrid_with_weights(x,wgtFile,Opt)
      printVarSummary(x_regrid_5x5)

      if(WRITE_RESULTS) then
        out_filename = outFile_5x5_pfx + "_" + methods(i) + ".nc"
        write_netcdf(sfile, out_filename, x_regrid_5x5, "precip", methods(i))

        out_filename = outFile_2x3_pfx + "_" + methods(i) + ".nc"
        write_netcdf(sfile, out_filename, x_regrid_2x3, "precip", methods(i))
      end if

;----------------------------------------------------------------------
; Plotting section
;----------------------------------------------------------------------
      sdims = tostring(dimsizes(x(0,:,:)))
      res@gsnLeftString   = "Original 1x1 degree grid (" + \
                              str_join(sdims," x ") + ")"

      plot(0) = gsn_csm_contour_map_ce(wks,x(nt,:,:), res)

      sdims = tostring(dimsizes(x_regrid_2x3(0,:,:)))
      res@gsnLeftString   = "Regridded to 2x3 degree grid (" + \
                            str_join(sdims," x ") + ")"

      plot(1) = gsn_csm_contour_map_ce(wks,x_regrid_2x3(nt,:,:), res)

      sdims = tostring(dimsizes(x_regrid_5x5(0,:,:)))
      res@gsnLeftString   = "Regridded to 5x5 degree grid (" + \
                            str_join(sdims," x ") + ")"

      plot(2) = gsn_csm_contour_map_ce(wks,x_regrid_5x5(nt,:,:), res)

;---Panel three plots on page
      resP@txString            = "Fixed-to-Fixed using '" + \
                                 methods(i) + "' regridding"

      gsn_panel(wks,plot,(/3,1/),resP)               ; now draw as one plot

;---Clean up before next time through loop
      delete(x_regrid_2x3)
      delete(x_regrid_5x5)
    end do    ; end methods
end
