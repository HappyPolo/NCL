;----------------------------------------------------------------------
; ESMF_regrid_24.ncl
;
; Concepts illustrated:
;   - Interpolating from one grid to another using ESMF_regrid
;   - Interpolating data from a POP grid to a 1x1 rectilinear grid
;----------------------------------------------------------------------
; This example uses the ESMF application "ESMF_RegridWeightGen" to 
; generate the weights.
;
; For more information about ESMF:
;
;        http://www.earthsystemmodeling.org/
;
; This script uses built-in functions that are only available in 
; NCL V6.1.0 and later.
;----------------------------------------------------------------------
; This script regrids a POP grid to a 1.0 degree world grid and
; plots sea water potential temperature on the new grid.
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
;---Interpolation methods
    methods        = (/"bilinear","patch"/)     ; ,"conserve"/)

;---Input file
    srcDirName     = "./"
    srcFileName    = "gx1v3.210.pop.h.0001-01.nc"
    varName        = "TEMP"

;---Get data and lat/lon grid from source Grid; uses surface level and initial time
    sfile          = addfile(srcFileName,"r")
    x              = sfile->$varName$(0,0,:,:)
    x@lat2d        = sfile->TLAT
    x@lon2d        = sfile->TLONG

;---Specify a name for the destination regridded variable (no spaces)
  ;;DstGridDir     = "./"
    DstGridName    = "1x1"   

;---Create the destination rectilinear lat/lon
    lat            = fspan(-89.5, 89.5,180)
    lon            = fspan(  0.5,359.5,360)

;---Specify name of weight file(s) to be generated; name of destination grid; dst directory
    WgtFileDir     = "./"
    WgtFileName    = "POP_gx1v3_to_"+DstGridName+"."+methods+".nc"

    Opt                  = True
    Opt@SrcFileName      = "POP_gx1v3_SCRIP.nc"   ; source grid description file name
    Opt@DstFileName      = "Globe1deg_SCRIP.nc"   ; destination grid description file name
    Opt@ForceOverwrite   = True

    Opt@SrcMask2D        = where(.not.ismissing(x),1,0)  ; land/ocean mask

    Opt@DstTitle         = "Global Grid 1-degree Resolution"
    Opt@DstGridLat       = lat  
    Opt@DstGridLon       = lon

    ;;Opt@PrintTimings   = True
    ;;Opt@Debug          = True

;----------------------------------------------------------------------
; Setup for graphics
;----------------------------------------------------------------------
    wks = gsn_open_wks("png","ESMF_regrid")     ; send graphics to PNG file

;---Resources to share between both plots
    res                     = True              ; Plot mods desired.

    res@gsnDraw             = False             ; Will panel later
    res@gsnFrame            = False             ; Will panel later

    res@gsnMaximize         = True              ; Maximize plot

    res@cnFillOn            = True              ; color plot desired
    res@cnFillPalette       = "ncl_default"     ; set color map
    res@cnLinesOn           = False             ; turn off contour lines
    res@cnLineLabelsOn      = False             ; turn off contour labels
    res@cnFillMode          = "RasterFill"      ; turn raster on      
  
    mnmxint = nice_mnmxintvl( min(x), max(x), 16, False)
    res@cnLevelSelectionMode = "ManualLevels"
    res@cnMinLevelValF       = mnmxint(0)
    res@cnMaxLevelValF       = mnmxint(1)
    res@cnLevelSpacingF      = mnmxint(2)
 
    res@mpFillOn            = False

    res@trGridType         = "TriangularMesh"  ; allow missing coordinates
    res@gsnAddCyclic       = False

    res@pmLabelBarWidthF   = 0.7
    res@lbLabelBarOn       = False   ; Will do this in panel

    res@gsnAddCyclic       = True

;---Resources for paneling
    pres                  = True
    pres@gsnMaximize      = True
    pres@gsnPanelLabelBar = True
    pres@lbLabelFontHeightF = 0.01

;----------------------------------------------------------------------
; Loop across each method and generate interpolation weights for 
; POP Grid to World Grid    
;----------------------------------------------------------------------
    plot_regrid = new(dimsizes(methods),graphic)

    do i=0,dimsizes(methods)-1
      print("Generating interpolation weights from POP to")
      print("Global grid using the " + methods(i) + " method.")

      Opt@WgtFileName  = WgtFileName(i)
      
      Opt@InterpMethod = methods(i)

;----------------------------------------------------------------------
; Interpolate data from POP to destination grid.
;----------------------------------------------------------------------

      x_regrid = ESMF_regrid(x,Opt)
      printVarSummary(x_regrid)

;----------------------------------------------------------------------
; Plotting section
;----------------------------------------------------------------------

;---Resources for plotting original data
      res@tiMainString = "Data on original POP grid (" + \
                         str_join(tostring(dimsizes(x))," x ") + ")"
      plot_orig   = gsn_csm_contour_map(wks,x,res)

;---Resources for plotting regridded data
      res@tiMainString = "POP to destination grid (" + \
                         methods(i) + ") (" + \
                         str_join(tostring(dimsizes(x_regrid))," x ") + ")"
      plot_regrid(i) = gsn_csm_contour_map(wks,x_regrid,res)

;---Panel two plots
      gsn_panel(wks,(/plot_orig,plot_regrid(i)/),(/2,1/),pres)

;---Clean up before next time in loop.
      delete(x_regrid)
    end do
end

