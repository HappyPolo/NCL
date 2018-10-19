;======================================================================
; ESMF_wgts_1.ncl
;
; Concepts illustrated:
;   - Interpolating from one grid to another using ESMF_regrid_with_weights
;   - Interpolating from one grid to another using an existing weights file
;   - Interpolating data from an NCEP grid to a 5x5 degree global grid
;   - Writing data to a NetCDF file using the easy but inefficient method
;======================================================================
; This example is identical to ESMF_regrid_1.ncl, except it assumes
; the weights file already exists, and does regridding using 
; "ESMF_regrid_with_weights".  This is the best method to use if you 
; already have the weights.
;======================================================================
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
    WRITE_RESULTS = True 

;----------------------------------------------------------------------
; Regridding section
;----------------------------------------------------------------------

;---Read data from input file containing source grid
    srcFileName = "sst.nc"
    sfile       = addfile(srcFileName,"r")
    temp        = sfile->TEMP                    ; 1 x 1 x 64 x 181

;---Regrid temp using existing weights file
    temp_regrid = ESMF_regrid_with_weights(temp,"NCEP_2_Rect.nc",False)
    printVarSummary(temp_regrid)

;----------------------------------------------------------------------
; Plot the original and regridded data.
;----------------------------------------------------------------------
    wks = gsn_open_wks("png","ESMF_wgts")       ; send graphics to PNG file

    res                     = True              ; Plot mods desired.
    res@gsnDraw             = False             ; We will panel later.
    res@gsnFrame            = False

    res@gsnMaximize         = True              ; Maximize plot
    
    res@mpMaxLatF           = 60                ; choose map range
    res@mpMinLatF           = -60 

    res@cnFillOn            = True              ; color plot desired
    res@cnFillPalette       = "gui_default"     ; set color map
    res@cnLinesOn           = False             ; turn off contour lines
    res@cnLineLabelsOn      = False             ; turn off contour lines

    res@cnLevelSelectionMode =  "ManualLevels"  ; manual levels
    res@cnMinLevelValF       = 4                ; min level
    res@cnMaxLevelValF       = 32               ; max level
    res@cnLevelSpacingF      =  2               ; interval

    res@lbLabelBarOn        = False             ; Labelbar will be in panel

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
      global@remap_method  = "bilinear"
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
