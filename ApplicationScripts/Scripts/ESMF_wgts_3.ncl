;======================================================================
; ESMF_wgts_3.ncl
;
; Concepts illustrated:
;   - Interpolating from one grid to another using ESMF_regrid_with_weights
;   - Interpolating from one grid to another using an existing weights file
;   - Interpolating data from a fixed high-res grid to T42 and T85 grids
;======================================================================
; This example is identical to ESMF_regrid_3.ncl, except it assumes
; the weights file already exists, and does regridding using 
; "ESMF_regrid_with_weights".  This is the best method to use if you 
; already have the weights.
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
;---Prefixes for weights files
    wgtFile_T85_pfx = "Rect_2_T85"
    wgtFile_T42_pfx = "Rect_2_T42"

;---Interpolation methods to use
    methods  = (/"bilinear","patch","conserve"/)
    nmethods = dimsizes(methods)

;---File containing source grid
    sfile = addfile("TEST.TRMM_3B43V6_CLM.1998-2005.nc","r")
    prc   = sfile->TRMM_PRC           ; (time,lat,lon) => (1,480,1440)
    prc   = prc/3
    dimx  = dimsizes(prc)
    nlat  = dimx(1)
    latS  = prc&lat(0)                  ; south extent of input grid
    latN  = prc&lat(nlat-1)             ; north extent

;----------------------------------------------------------------------
; Graphics setup before we start looping across each
; interpolation method.
;----------------------------------------------------------------------
    wks = gsn_open_wks("png","ESMF_wgts"); send graphics to PNG file

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
      wgt_filename   = wgtFile_T85_pfx + "_" + methods(i) + ".nc"
      prc_regrid_T85 = ESMF_regrid_with_weights(prc,wgt_filename,False)
      printVarSummary(prc_regrid_T85)

;---Regrid to T42 grid
      wgt_filename   = wgtFile_T42_pfx + "_" + methods(i) + ".nc"
      prc_regrid_T42 = ESMF_regrid_with_weights(prc,wgt_filename,False)
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
