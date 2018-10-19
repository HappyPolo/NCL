;----------------------------------------------------------------------
; plot_jetstream_icon.ncl
;
; Concepts illustrated:
;   - Plotting ICON model data
;   - Plotting line contours over filled contours with transparency
;   - Adding text strings as an annotation of a plot
;   - Using "cd_string" to produce a nice time label for a title
;----------------------------------------------------------------------
; This example was contributed by Guido Cioni
;----------------------------------------------------------------------
;
; This file still has to be loaded manually
load "$NCARG_ROOT/lib/ncarg/nclscripts/contrib/cd_string.ncl"

begin
;
; Open ICON model level output file. Note, "ICON.nc" is a placeholder filename.
; You will need to substitute your own ICON model file. The one used here had
; 2949120 cells, with one time step and one level.
;
  fname = "ICON.nc"
  f     = addfile(fname, "r")  

;---Read variables off file and do some conversions
  lev1    = 30000.
  RAD2DEG = get_r2d("float")
  geopt = f->z(:,{lev1},:)
  u     = f->u(:,{lev1},:)
  v     = f->v(:,{lev1},:)
  lon   = f->clon * RAD2DEG    ; N x 3
  lat   = f->clat * RAD2DEG    ; N x 3
  time  = f->time

  geopt = geopt/100.
  speed = sqrt(u^2+v^2)*3.6
  lev1  = lev1 * 0.01
  lev1@units = "hPa"
  copy_VarCoords(u, speed)

;---Start graphics section
 wks = gsn_open_wks("png","plot_jetstream_icon")     ; send graphics to PNG file

;---Define plot options for two sets of contour plots
  Res                              = True
  Res@gsnMaximize                  = True   ; Maximize plot in frame.
  Res@gsnDraw                      = False
  Res@gsnFrame                     = False

  Res@sfXArray                     = lon    ; Define lat/lon values for each
  Res@sfYArray                     = lat    ; cell value

;---Set filled contour resources
  ResF                             = Res

  ResF@cnFillOn                    = True            ; Turn on color fill
  ResF@cnFillMode                  = "RasterFill"    ; Faster contouring!
  ResF@cnLinesOn                   = False           ; Turn off contour lines

  ResF@lbLabelFontHeightF          = 0.01
  ResF@lbBoxEndCapStyle            = "TriangleBothEnds"

;
; Read color map and set first color to transparent. Note that in
; order for transparency to work with raster fill, you must also
; set the color to black (0,0,0).
;
  cmap_r      = read_colormap_file("wind_17lev")
  cmap_r(0,:) = 0.0

  ResF@cnFillPalette               = cmap_r

;---Manually set contour levels
  ResF@cnLevelSelectionMode        = "ManualLevels"
  ResF@cnMinLevelValF              = 50
  ResF@cnMaxLevelValF              = 250 
  ResF@cnLevelSpacingF             = 10

  ResF@lbOrientation               = "Vertical"
  ResF@pmLabelBarWidthF            = 0.05

;---SATELLITE projection
  ResF@mpProjection                = "Satellite" ; choose map projection
  ResF@mpCenterLonF                = 330.0       ; choose center lon
  ResF@mpCenterLatF                = 65        ; choose center lat
  ResF@mpSatelliteDistF            = 3.0         ; choose satellite view

;---Nicer map outlines
  ResF@mpDataSetName               = "Earth..4"     
  ResF@mpFillOn                    = True
  ResF@mpOutlineOn                 = True 
  ResF@mpLandFillColor             = "gray90"

;---Titles
  ResF@gsnLeftString               = "ICON"
  ResF@gsnRightString              = "Copyright DWD"
  ResF@gsnStringFontHeightF        = 0.012

  nt = 0   ; first time step
  ResF@gsnCenterString= "Forecast for "+cd_string(time(nt), "%d %c. %Y")+" at "+\
                         cd_string(time(nt), "%H:%M")+" UTC"

;---Set line contour resources
  ResL                            = Res     ; Line contour resources

  ResL@cnLinesOn                  = True
  ResL@cnFillOn                   = False
  ResL@cnInfoLabelOn              = False  

;---Manually set contour levels
  ResL@cnLevelSelectionMode       = "ManualLevels"
  ResL@cnMinLevelValF             = round(min(geopt),0)
  ResL@cnMaxLevelValF             = round(max(geopt),0)
  ResL@cnLevelSpacingF            = 10

  ResL@cnLineThicknessF           = 3
  ResL@cnLineColor                = "gray60"
  ResL@cnLineLabelFontHeightF     = 0.004
  ResL@cnLineLabelDensityF        = 1.5

  ResL@cnHighLabelsOn             = True      ; turn on high/low labels
  ResL@cnLowLabelsOn              = True
  ResL@cnLowLabelString           = "L"
  ResL@cnHighLabelString          = "H"
  ResL@cnLowLabelBackgroundColor  = "transparent"
  ResL@cnHighLabelBackgroundColor = "transparent"
  ResL@cnLineLabelBackgroundColor = "transparent"

  ResL@gsnLeftString              = ""    ; turn off subtitles for line
  ResL@gsnRightString             = ""    ; contour plot

;---Create both filled and line contour plots; not drawn yet
  PlotL = gsn_csm_contour(wks,geopt(nt,:),ResL)
  PlotF = gsn_csm_contour_map(wks,speed(nt,:),ResF)

;---Set some text and annotation resources
  txres                       = True
  txres@txPerimOn             = True
  txres@txBackgroundFillColor = "White"
  txres@txFontHeightF         = 0.012

  amres1                      = True 
  amres1@amParallelPosF       = -0.5          ; Left side of plot
  amres1@amOrthogonalPosF     = -0.5          ; Top of plot
  amres1@amJust               = "TopLeft"     ; Top left corner of text string to be
                                              ; aligned with top left edge of plot.
  amres2                      = True 
  amres2@amParallelPosF       = -0.5          ; Left side of plot
  amres2@amOrthogonalPosF     = 0.5           ; Bottom of plot
  amres2@amJust               = "BottomLeft"  ; Bottom left corner of text string to be
                                              ; aligned with bottom left edge of plot.
  run_string       = "Run: " + str_sub_str(time@units,"minutes since ","")
  plot_description = "Winds (intensity in km/h) and geopotential (dam) at " + \
                     lev1+" " + lev1@units

;---Create text objects and attach them to filled contour plot
  txid1 = gsn_create_text(wks, run_string, txres)
  txid2 = gsn_create_text(wks, plot_description, txres)
  amid1 = gsn_add_annotation(PlotF, txid1, amres1)
  amid2 = gsn_add_annotation(PlotF, txid2, amres2)

  overlay(PlotF, PlotL)  ; Overlay line contours on filled contours
  draw(PlotF)            ; This draws everything
  frame(wks)
end
