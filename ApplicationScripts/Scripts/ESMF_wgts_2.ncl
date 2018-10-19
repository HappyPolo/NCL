;======================================================================
; ESMF_wgts_2.ncl
;
; Concepts illustrated:
;   - Interpolating from one grid to another using ESMF_regrid_with_weights
;   - Interpolating from one grid to another using an existing weights file
;   - Interpolating data from a fixed high-res grid to fixed offset 2x3 and 5x5 degree grids
;   - Writing data to a NetCDF file using the easy but inefficient method
;======================================================================
; This example is identical to ESMF_regrid_2.ncl, except it assumes
; the weights file already exists, and does regridding using 
; "ESMF_regrid_with_weights".  This is the best method to use if you 
; already have the weights.
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

;---Filename prefixes for weight files
    wgtFile_2x3_pfx = "Fixed_2_2x3"
    wgtFile_5x5_pfx = "Fixed_2_5x5"
    outFile_2x3_pfx = "pregpcp_regrid_2x3"
    outFile_5x5_pfx = "pregpcp_regrid_5x5"

;---Interpolation methods used (weight file names will be constructed from these)
    methods  = (/"bilinear","patch","conserve"/)
    nmethods = dimsizes(methods)

;---Read variable to regrid
    sfile = addfile("pregpcp.test.daily.nc","r")
    x     = short2flt(sfile->data)                ; 12 x 180 x 360
    x     = x(:,::-1,:)                           ; required to be S->N

;----------------------------------------------------------------------
; Graphics setup before we start looping across each
; interpolation method.
;----------------------------------------------------------------------
    wks = gsn_open_wks("png","ESMF_wgts")          ; send graphics to PNG file

    colors = (/"Snow","PaleTurquoise","PaleGreen","SeaGreen3" ,"Yellow",  \
              "Orange","HotPink","Red","Violet", "Purple", "Brown"/)
   
    plot = new (3, "graphic")
     
    res                      = True                ; plot mods desired
    res@gsnDraw              = False               ; don't draw
    res@gsnFrame             = False               ; don't advance frame
     
    res@cnFillOn             = True                ; turn on color fill
    res@cnFillPalette        = colors              ; set color map
    res@cnLinesOn            = False               ; turn of contour lines
    res@cnFillMode           = "RasterFill"        ; Raster Mode
    res@cnLinesOn            = False               ; Turn off contour lines
    res@cnLineLabelsOn       = False               ; Turn off contour lines
    res@cnLevelSelectionMode = "ExplicitLevels"              
    res@cnLevels             = (/0.1,1,2.5,5,10,15,20,25,50,75/)

    res@cnMissingValFillPattern = 0                ; solid fill
    res@cnMissingValFillColor   = "black"

    res@lbLabelBarOn            = False
     
    res@mpCenterLonF            = 210.
    res@mpFillOn                = False

;---Resources for paneling
    resP                     = True
    resP@gsnMaximize         = True
    resP@gsnPanelLabelBar    = True                ; add common colorbar
    resP@lbLabelFontHeightF  = 0.0175              ; change font size

    nt = 0    ; First time step

;----------------------------------------------------------------------
; Loop across each interpolation method and use the existing weights
; files to do the regridding.
;----------------------------------------------------------------------
    do i=0,nmethods-1
;---Regrid to 2x3 grid
      wgt_filename  = wgtFile_2x3_pfx + "_" + methods(i) + ".nc"
      x_regrid_2x3  = ESMF_regrid_with_weights(x,wgt_filename,False)
      printVarSummary(x_regrid_2x3)

;---Regrid to 5x5 grid
      wgt_filename  = wgtFile_5x5_pfx + "_" + methods(i) + ".nc"
      x_regrid_5x5  = ESMF_regrid_with_weights(x,wgt_filename,False)
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
