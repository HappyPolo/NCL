;======================================================================
; ESMF_regrid_31.ncl
;
; Concepts illustrated:
;   - Interpolating from one grid to another using ESMF_regrid
;   - Interpolating data from a high-res categorical grid to a 1 degree grid
;   - Customizing a labelbar in a panel plot
;   - Adding a legend to a panel plot
;======================================================================
;
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
;
; These files still have to be loaded manually
load "$NCARG_ROOT/lib/ncarg/nclscripts/esmf/ESMF_regridding.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl"

;----------------------------------------------------------------------
; Return RGB values for CERES Map Land Classification
;----------------------------------------------------------------------
function get_igbp_colors()
begin
  rgb = (/ (/ 50, 136,   4/), \
           (/ 68,  92,  22/), \
           (/  5,  50,   4/), \
           (/ 13,  97,   4/), \
           (/ 26, 194,   9/), \
           (/123, 179, 121/), \
           (/178, 180,   7/), \
           (/255, 255,   4/), \
           (/179, 230,  81/), \
           (/255, 255, 194/), \
           (/167, 252, 238/),\
           (/253, 168,  64/), \
           (/255,   0,   0/), \
           (/208, 137, 253/), \
           (/249, 249, 249/), \
           (/188, 188, 188/), \
           (/161, 200, 237/), \
           (/167, 252, 238/)/)

  return(rgb/255.)
end

;----------------------------------------------------------------------
; Add a legend at the bottom of the page describing the meaning of
; the colors.
;----------------------------------------------------------------------
procedure add_legend(wks)
local info, ninfo, nrow, ncol, n, xx, yy
begin
  info     = (/ " 1  Evergreen Needleleaf", \  ; n=0
                " 2  Evergreen Broadleaf ", \
                " 3  Deciduous Needleleaf", \
                " 4  Deciduous Broadleaf ", \
                " 5  Mixed Forest        ", \
                " 6  Closed Shrublands   ", \
                " 7  Open Shrublands     ", \
                " 8  Woody Savannas      ", \
                " 9  Savannas            ", \
                "10  Grasslands          ", \
                "11  Permanent Wetlands  ", \
                "12  Croplands           ", \
                "13  Urban and Built-up  ", \
                "14  Cropland Mosaics    ", \
                "15  Snow and Ice        ", \
                "16  Bare Soil and Rocks ", \
                "17  Water Bodies        ", \
                "18  Tundra              "  /) ; n=17

  ninfo = dimsizes(info)

  rtxt = True
  rtxt@txJust        = "CenterLeft"
  rtxt@txFontHeightF = 0.009
                            ; 3 rows x 6 columns of text
  n  = 0
  xx = 0.21
  do ncol=0,3
     yy = 0.13
     nrow = 0
    do while (nrow.le.4.and.n.lt.ninfo)
       gsn_text_ndc (wks,info(n),xx,yy,rtxt)
       yy = yy - 3*rtxt@txFontHeightF
       n = n+1
       nrow = nrow + 1
    end do
     xx = xx + 0.15
  end do
end

;----------------------------------------------------------------------
; Main code
;----------------------------------------------------------------------

begin
  diri = "./"                          ; input directory
  fili = "IGBPa_1198.map.nc"
  f    = addfile (diri+fili, "r")
  var  = f->CLASS                      ; note: type byte
                                       ; contains coordinate arrays.
;---Set up regridding options
  dest_grid_type = "1deg"
  interp_method  = "neareststod"
  wgt_file_name  = "IGBPa_vegland_to_1deg.nc"

;
; The first time you run this script, you may need to set this False.
; Otherwise, set this to True and the script will run *much* faster.
;
  have_wgts_file = False

  if(have_wgts_file) then
    var_regrid = ESMF_regrid_with_weights(var,wgt_file_name,False)
  else
    Opt                   = True

    Opt@SrcMask2D         = where(.not.ismissing(var),1,0) ; Necessary if has
    Opt@InterpMethod      = interp_method
                                                           ; missing values.
    Opt@DstGridType       = "1deg"
    Opt@WgtFileName       = wgt_file_name

    Opt@ForceOverwrite    = True
    Opt@PrintTimings      = True
    Opt@Debug             = True

    var_regrid = ESMF_regrid(var,Opt)     ; Do the regridding
  end if

  printVarSummary(var_regrid)           ; Check that everything
  printMinMax(var_regrid,0)             ; looks okay.

  var_dims        = dimsizes(var)
  var_regrid_dims = dimsizes(var_regrid)

;----------------------------------------------------------------------
; Start the graphics.
;----------------------------------------------------------------------
  wks = gsn_open_wks("png","ESMF_regrid")    ; send graphics to PNG file

  res                  = True                ; plot mods desired
  res@gsnDraw          = False
  res@gsnFrame         = False
  res@gsnMaximize      = True 
  res@gsnAddCyclic     = False

  res@cnFillOn         = True               ; color Fill 
  res@cnFillMode       = "RasterFill"       ; Raster Mode
  res@cnFillPalette    = get_igbp_colors()
  res@cnLinesOn        = False              ; Turn off contour lines
  res@cnLineLabelsOn   = False              ; Turn off contour line labels
  res@lbLabelBarOn     = False              ; Turn on in panel
  res@cnLevelSelectionMode = "ExplicitLevels" ; set explict contour levels
  res@cnLevels             = ispan(1,17,1) + 0.5   ; 1.5, ..., 17.5

  res@mpCenterLonF     = 0                  ; set map center
  res@mpFillOn         = False

  res@gsnLeftString    = "Original data"
  res@gsnRightString   = str_join("" + var_dims," x ")
  plot_orig   = gsn_csm_contour_map_ce(wks, var, res) ; create plot

  res@gsnLeftString    = "Regridded to " + dest_grid_type
  res@gsnRightString   = str_join("" + var_regrid_dims," x ")
  plot_regrid = gsn_csm_contour_map_ce(wks, var_regrid, res) ; create plot

  pres                          = True
  pres@gsnFrame                 = False
  pres@gsnPaperOrientation      = "Portrait"
  pres@gsnMaximize              = True

  pres@txString                 = fili + ": " + var@long_name

  pres@gsnPanelBottom           = 0.1                ; leave room for legend

;---resources to customize labelbar
  pres@gsnPanelLabelBar         = True
  pres@lbLabelStrings           = "" + ispan(1,18,1)  
  pres@lbLabelPosition          = "Center"           ; label position
  pres@lbLabelAlignment         = "BoxCenters"       ; label orientation
  pres@lbLabelFontHeightF       = 0.01
  pres@pmLabelBarOrthogonalPosF = 0.02

  gsn_panel(wks,(/plot_orig,plot_regrid/),(/2,1/),pres)

  add_legend(wks)     ; Add some text at bottom describing the labelbar colors
  frame(wks)
end
