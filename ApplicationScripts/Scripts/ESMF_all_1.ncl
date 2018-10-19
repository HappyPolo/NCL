;======================================================================
; ESMF_all_1.ncl
;
; Concepts illustrated:
;   - Interpolating from one grid to another using ESMF software
;   - Interpolating data from an NCEP grid to a 5x5 degree global grid
;   - Writing data to a NetCDF file using the easy but inefficient method
;======================================================================
; This example is identical to ESMF_regrid_1.ncl, except it does the
; regridding in separate steps.  See ESMF_wgts_1.ncl for a faster 
; example of regridding using an existing weights file.
;======================================================================
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
    WRITE_RESULTS = True 
    INTERP_METHOD = "bilinear"

;---Input file
    srcFileName = "sst.nc"

;---Output (and input) files
    srcGridName = "src_SCRIP.nc"
    dstGridName = "dst_SCRIP.nc"
    wgtFileName = "NCEP_2_Rect.nc"

;---Set to True if you want to skip any of these steps
    SKIP_SRC_SCRIP_GEN = False
    SKIP_DST_SCRIP_GEN = False
    SKIP_WGT_GEN       = False

;----------------------------------------------------------------------
; Step 1, part 1
;     Convert original NetCDF file to an SCRIP convention file.
;----------------------------------------------------------------------
    sfile = addfile(srcFileName,"r")
    temp  = sfile->TEMP                 ; ( TIME, DEPTH, LAT, LON )

    if(.not.SKIP_SRC_SCRIP_GEN) then
;--- Convert to a SCRIP Convention file.
      Opt                = True
      Opt@ForceOverwrite = True
      Opt@PrintTimings   = True
      Opt@Title          = "NCEP Grid"
      Opt@Mask2D         = where(ismissing(temp(0,0,:,:)),0,1)

      rectilinear_to_SCRIP(srcGridName,temp&LAT,temp&LON,Opt)

;---Clean up
      delete(Opt)
   end if

;----------------------------------------------------------------------
; Step 1, part 2
;     Convert destination grid to a SCRIP convention file.
;----------------------------------------------------------------------
    if(.not.SKIP_DST_SCRIP_GEN) then
      Opt                = True
      Opt@LLCorner       = (/ -60.d,   0.d/)
      Opt@URCorner       = (/  60.d, 355.d/)
      Opt@ForceOverwrite = True
      Opt@PrintTimings   = True

      latlon_to_SCRIP(dstGridName,"5x5",Opt)

;---Clean up
      delete(Opt)
    end if

;----------------------------------------------------------------------
; Step 2
;     Generate the weights that take you from the NCEP grid to a
;     5x5 degree grid.
;----------------------------------------------------------------------
    if(.not.SKIP_WGT_GEN) then
     
      Opt                  = True
      Opt@WgtFileName      = "NCEP_2_5deg.nc"   ; default is "weights_file.nc"
      Opt@InterpMethod     = INTERP_METHOD      ; patch takes longer
      Opt@ForceOverwrite   = True
      Opt@PrintTimings     = True
      Opt@Debug            = True

      ESMF_regrid_gen_weights(srcGridName,dstGridName,wgtFileName,Opt)

;---Clean up
      delete(Opt)
    end if

;----------------------------------------------------------------------
; Step 3
;     Apply the weights to a given variable on the NCEP file.
;----------------------------------------------------------------------
    Opt                = True
;   Opt@Debug          = True
    Opt@PrintTimings   = True

    temp_regrid = ESMF_regrid_with_weights(temp,wgtFileName,Opt)

    printVarSummary(temp_regrid)

;----------------------------------------------------------------------
; Step 4
;     Plot the original and regridded data.
;----------------------------------------------------------------------
    wks = gsn_open_wks("png","ESMF_all")        ; send graphics to PNG file

    res                     = True              ; Plot mods desired.
    res@gsnDraw             = False             ; We will panel later.
    res@gsnFrame            = False

    res@gsnMaximize         = True              ; Maximize plot
    
    res@mpMaxLatF           = 60                 ; choose map range
    res@mpMinLatF           = -60 

    res@cnFillOn            = True              ; color plot desired
    res@cnFillPalette       = "gui_default"     ; set color map
    res@cnLinesOn           = False             ; turn off contour lines
    res@cnLineLabelsOn      = False             ; turn off contour lines

    res@cnLevelSelectionMode =  "ManualLevels"   ; manual levels
    res@cnMinLevelValF       = 4                 ; min level
    res@cnMaxLevelValF       = 32                ; max level
    res@cnLevelSpacingF      =  2                ; interval

    res@lbLabelBarOn        = False              ; Labelbar will be in panel

;---Plot data on original grid
    res@gsnAddCyclic = False

    dims = tostring(dimsizes(temp(0,0,:,:)))
    res@tiMainString = "NCEP monthly means temp: original data (" + \
                       str_join(dims," x ") + ")"
    plot_orig = gsn_csm_contour_map(wks,temp(0,0,:,:),res)     

;---Plot data interpolated onto 5x5 degree grid
    res@gsnAddCyclic = True

    dims = tostring(dimsizes(temp_regrid(0,0,:,:)))
    res@tiMainString = "NCEP monthly means temp: regridded to 5x5 grid (" +\
                       str_join(dims," x ") + ")"
    plot_regrid = gsn_csm_contour_map(wks,temp_regrid(0,0,:,:),res)

;---Resources for paneling
    pres                  = True
    pres@gsnMaximize      = True
    pres@gsnPanelLabelBar = True

    gsn_panel(wks,(/plot_orig,plot_regrid/),(/2,1/),pres)

;----------------------------------------------------------------------
; Step 5
;     Write the regridded data to a NetCDF file
;----------------------------------------------------------------------
    if(WRITE_RESULTS) then
      rgrdFileName = "sst_regrid.nc"
      system("rm -f " + rgrdFileName)
      rgrd_nc = addfile(rgrdFileName,"c")

;---Create variable to hold global file attributes
      global = True
      copy_VarAtts(sfile, global)

      if (isatt(sfile,"title")) then
        global@TITLE = "REMAPPED: " + sfile@title
      end if
      global@remap         = "NCL: ESMF_regrid_with_weights (NCL version '" + \
                             get_ncl_version() + "')"
      global@remap_method  = INTERP_METHOD
      global@creation_date = systemfunc("date")
    
      fileattdef( rgrd_nc, global )        ; copy global file attributes
      filedimdef(rgrd_nc,"TIME",-1,True)   ; force an unlimited dimension
;
; Write variables to file. Coordinate arrays will be written 
; automatically
;
      rgrd_nc->TEMP       = temp_regrid
      rgrd_nc->DEPTHedges = sfile->DEPTHedges
    end if
end
