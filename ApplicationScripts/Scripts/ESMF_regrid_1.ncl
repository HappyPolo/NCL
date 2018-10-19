;======================================================================
; ESMF_regrid_1.ncl
;
; Concepts illustrated:
;   - Interpolating from one grid to another using ESMF_regrid
;   - Interpolating data from an NCEP grid to a 5x5 degree global grid
;   - Writing data to a NetCDF file using the easy but inefficient method
;======================================================================
; This example is identical to ESMF_all_1.ncl, except it does the
; regridding in one call to "ESMF_regrid".  See ESMF_wgts_1.ncl
; for a faster example of regridding using an existing weights file.
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
    PLOT_RESULTS  = True
    WRITE_RESULTS = True 
    INTERP_METHOD = "bilinear"      ; default

;----------------------------------------------------------------------
; Regridding section
;----------------------------------------------------------------------

;---Read data from input file containing source grid
    srcFileName = "sst.nc"
    sfile       = addfile(srcFileName,"r")
    temp        = sfile->TEMP                 ; ( TIME, DEPTH, LAT, LON )
    printVarSummary(temp)

;---Get leftmost two dimensions
    dims_orig   = dimsizes(temp)
    ntim        = dims_orig(0)
    ndpt        = dims_orig(1)

;---Set up options for regridding
    Opt                   = True

    Opt@WgtFileName       = "NCEP_2_Rect.nc"   ; default is "weights_file.nc"
    Opt@SrcInputFileName  = srcFileName        ; optional, but good idea
    Opt@SrcTitle          = "NCEP Grid"
    Opt@SrcMask2D         = where(ismissing(temp(0,0,:,:)),0,1)

;---Destination file options
    Opt@DstGridType       = "5x5"               ; 5x5 degree grid
    Opt@DstLLCorner       = (/ -60.d,   0.d/)
    Opt@DstURCorner       = (/  60.d, 355.d/)

    Opt@ForceOverwrite    = True
    ;;Opt@PrintTimings    = True
    ;;Opt@Debug           = True

;----------------------------------------------------------------------
; Regrid the data. "temp" contains 1D coordinate arrays,
; so these are used automatically as the "source" grid.
;----------------------------------------------------------------------
    temp_regrid = ESMF_regrid(temp,Opt)
    printVarSummary(temp_regrid)

;----------------------------------------------------------------------
; Write the regridded variable to a file using the "inefficient" method.
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
     
    if(PLOT_RESULTS) then
;---Get dimension sizes of regridded variable
      dims_regrid = dimsizes(temp_regrid)

;----------------------------------------------------------------------
; Plot the original and regridded data.
;----------------------------------------------------------------------
      wks = gsn_open_wks("png","ESMF_regrid")     ; send graphics to PNG file

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

;---Be sure to use same levels across all times and depths
      mnmxint = nice_mnmxintvl( min(temp_regrid), max(temp_regrid), 18, False)
      res@cnLevelSelectionMode = "ManualLevels"
      res@cnMinLevelValF       = mnmxint(0)
      res@cnMaxLevelValF       = mnmxint(1)
      res@cnLevelSpacingF      = mnmxint(2)

      res@lbLabelBarOn        = False             ; Labelbar will be in panel

      title_orig   = "NCEP monthly means temp: original data (" + \
                     str_join(tostring(dims_orig(2:3))," x ") + ")"

      title_regrid = "NCEP monthly means temp: regridded to 5x5 grid (" +\
                     str_join(tostring(dims_regrid(2:3))," x ") + ")"

;---Resources for paneling
      pres                  = True
      pres@gsnMaximize      = True
      pres@gsnPanelLabelBar = True

;---Make a copy of each resource list
      res_orig                = res
      res_orig@gsnAddCyclic   = False
      res_orig@tiMainString   = title_orig

      res_regrid              = res
      res_regrid@gsnAddCyclic = True
      res_regrid@tiMainString = title_regrid

;---Loop across each timestep and depth and compare the two plots.
      do nt=0,ntim-1
        do nd=0,ndpt-1
           res_orig@gsnCenterString = "time = " + temp&TIME(nt) + \
                                      ", depth = " + temp&DEPTH(nd)
           res_regrid@gsnCenterString = "time = " + temp&TIME(nt) + \
                                        ", depth = " + temp&DEPTH(nd)

;---Create plot of original variable
          plot_orig = gsn_csm_contour_map(wks,temp(nt,nd,:,:),res_orig)

;---Create plot of regridded variable
          plot_regrid = gsn_csm_contour_map(wks,temp_regrid(nt,nd,:,:),res_regrid)

;---Draw both plots on one frame
          gsn_panel(wks,(/plot_orig,plot_regrid/),(/2,1/),pres)
        end do
      end do
    end if
end
