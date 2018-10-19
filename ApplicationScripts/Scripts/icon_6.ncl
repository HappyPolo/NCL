;*********************************************************************
; icon_6.ncl
;
; Concepts illustrated:
;   - Plotting ICON model data
;   - Contouring one-dimensional X, Y, Z data
;   - Manually overlaying high resolution nest onto a coarse global grid
;   - Overlaying three sets of contours on a map
;   - Using draw order resources to draw filled contours and lines last
;   - Changing the center latitude and longitude for an orthographic projection
;   - Drawing raster contours
;
;*********************************************************************
;
;---------------------------------------------------------------
; This script makes contour plot of 750 hPa vorticity 
; for the Mountain-induced Rossby wave train test.
;---------------------------------------------------------------
 load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
 load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
 load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
;---------------------------------------------------------------
 begin
  wcStrt        = systemfunc("date")
  Model         = "ICOHDC" 
  Resolution_g  = "R2B4L31"  ; global resolution 
  Resolution_n1 = "R2B5L31"  ; resolution nest 1
  Resolution_n2 = "R2B6L31"  ; resolution nest 2
  ConfigStr     = "D1 spr0.90" 

  LeftString     = "850 hPa VOR. (10~S~-6~N~ s~S~-1~N~) at day 20"
  RightString_g  = "global:  " + Model+" "+Resolution_g+" " +ConfigStr 
  RightString_n1 = "nest 1:  " + Model+" "+Resolution_n1+" "+ConfigStr
  RightString_n2 = "nest 2:  " + Model+" "+Resolution_n2+" "+ConfigStr
  CenterString   = ""

  Diri      =  "./"
  DataFileName_global = "MRWB4N6_DOM01_R2B04L31_0002_VOR_T19_L26.nc"  ; input global field
  DataFileName_nest1  = "MRWB4N6_DOM02_R2B05L31_0002_VOR_T19_L26.nc"  ; input nest 1
  DataFileName_nest2  = "MRWB4N6_DOM03_R2B06L31_0002_VOR_T19_L26.nc"  ; input nest 2

  VarName      = "VOR"             ; variable name in the input file 
  
  colormap  = "BlueDarkRed18"     
  scale     = 1e6

  varMin = -45.  ; minimum contour level
  varMax =  45.  ; maximum contour level
  varInt =   5.  ; interval between contours

  GraphicFile  = "icon"   ; name of output file
  
  rad2deg = get_r2d("float")    ; radians to degrees

;---------------------------------------------------------------
; read in the meteorological field and grid information
;---------------------------------------------------------------

  File_g  = addfile(Diri+DataFileName_global, "r" ) ; open global data file
  File_n1 = addfile(Diri+DataFileName_nest1, "r"  ) ; open nest 1
  File_n2 = addfile(Diri+DataFileName_nest2, "r"  ) ; open nest 2

  VOR_global = File_g->$VarName$(0,0,:)   ; dims: (time,lev,cell)
  VOR_global = VOR_global*scale

  VOR_nest1 = File_n1->$VarName$(0,0,:)   ; dims: (time,lev,cell)
  VOR_nest1 = VOR_nest1*scale

  VOR_nest2 = File_n2->$VarName$(0,0,:)   ; dims: (time,lev,cell)
  VOR_nest2 = VOR_nest2*scale

  x_g = File_g->clon *rad2deg    ; cell center, lon, global grid
  y_g = File_g->clat *rad2deg    ; cell center, lat, global grid

  x_n1 = File_n1->clon *rad2deg  ; cell center, lon, nest 1
  y_n1 = File_n1->clat *rad2deg  ; cell center, lat, nest 1

  x_n2 = File_n2->clon *rad2deg  ; cell center, lon, nest 2
  y_n2 = File_n2->clat *rad2deg  ; cell center, lat, nest 2

; note: clon and clat are longitude and latitude of triangle centers.
;       Locations of the cell corners are given by 
;       clon_vertices and clat_vertices in the nc file.


;---------------------------------------------------------------
; make plot
;---------------------------------------------------------------

  wks = gsn_open_wks("ps",GraphicFile)  ; open a graphic workstation
  gsn_define_colormap(wks,colormap)     ; use the BlueDarkRed18 colormap

; Set up resources for contour/map plot.
  ResC                 = True

  ResC@gsnFrame        = False          ; do not advance the frame
  ResC@gsnDraw         = False          ; do not draw
  ResC@gsnLeftString   = LeftString     ; annotations
  ResC@gsnCenterString = CenterString   ;
  ResC@gsnRightString  = RightString_g  ;
  ResC@gsnMaximize     = True           ; maximize plot
  ResC@gsnSpreadColors = True           ; automatically choose the fill colors
  ResC@gsnCenterStringOrthogonalPosF = 0.09
  ResC@gsnRightStringOrthogonalPosF  = 0.09
  ResC@gsnLeftStringOrthogonalPosF   = 0.09

  ResC@sfXArray        = x_g       ; These are 1D arrays, so a triangular
  ResC@sfYArray        = y_g       ; mesh will be created internally.

  ResC@cnFillOn             = True      ; do color fill 
  ResC@cnFillMode           = "RasterFill"
  ResC@cnRasterSmoothingOn  = True      ; turn on raster smoothing
  ResC@cnLevelSelectionMode = "ManualLevels"
  ResC@cnMinLevelValF       = varMin
  ResC@cnMaxLevelValF       = varMax
  ResC@cnLevelSpacingF      = varInt

  FontHeight                = 0.014
  ResC@tiMainString         = Model
  ResC@tiXAxisFontHeightF   = FontHeight
  ResC@tiYAxisFontHeightF   = FontHeight

  ResC@lbLabelBarOn         = True 
  ResC@lbTitleString        = VOR_global@long_name+" in "\ 
                              + "10~S~-6~N~ s~S~-1~N~"
  ResC@lbTitlePosition      = "Bottom"
  ResC@lbTitleFontHeightF   = 0.015
  ResC@lbLabelFontHeightF   = 0.010

  ResC@pmLabelBarHeightF        = 0.08
  ResC@pmLabelBarWidthF         = 0.7
  ResC@pmLabelBarOrthogonalPosF = 0.04

  ResC2                      = ResC   ; Make copy before seting map resources.

  ResC@mpProjection          = "Orthographic" ; choose projection
  ResC@mpPerimOn             = False    ; turn off box around plot
  ResC@mpFillOn              = False    ; no map fill
  ResC@mpCenterLonF          = 110.     ; specify the plot domain
  ResC@mpCenterLatF          = 23.      ;
  ResC@mpMinLatF             =-90.      ;
  ResC@mpMaxLatF             = 90.      ;
  ResC@mpGridAndLimbOn       = True     ; draw grid lines and limb line
  ResC@mpGridLineDashPattern = 2        ; choose pattern used to draw the grid
 

; Create the plot (global field), but don't draw and don't advance the frame.
  base = gsn_csm_contour_map(wks,VOR_global,ResC)

;+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
;  plot high resolution field  (nest 1)
;+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  delete( ResC2@sfXArray )
  delete( ResC2@sfYArray )
  ResC2                             = True

  ResC2@gsnFrame                    = False
  ResC2@gsnDraw                     = False 
  ResC2@sfXArray                    = x_n1  ; These are 1D arrays, so a triangular
  ResC2@sfYArray                    = y_n1  ; mesh will be created internally.
  ResC2@cnFillMode                  = "Areafill" 
  ResC2@cnMissingValFillColor       = -1
  ResC2@cnMissingValPerimOn         = True
  ResC2@cnMissingValPerimDashPattern= 0     ; choose linestyle for perimeter lines
  ResC2@cnMissingValPerimThicknessF = 3     ; choose perimeter line thickness
  ResC2@cnFillDrawOrder      = "PostDraw"
  ResC2@cnLineDrawOrder      = "PostDraw"
  ResC2@gsnRightString  = RightString_n1 
  ResC2@gsnRightStringOrthogonalPosF=0.05


  plot_nest1 = gsn_csm_contour(wks,VOR_nest1,ResC2)


;+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
;  plot high resolution field  (nest 2)
;+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  delete( ResC2@sfXArray )
  delete( ResC2@sfYArray ) 

  ResC2@sfXArray        = x_n2  ; These are 1D arrays, so a triangular
  ResC2@sfYArray        = y_n2  ; mesh will be created internally.

  ResC2@gsnRightString              = RightString_n2 
  ResC2@gsnRightStringOrthogonalPosF=0.01

  plot_nest2 = gsn_csm_contour(wks,VOR_nest2,ResC2)

; Overlay the nested fields onto the global field
  overlay(base,plot_nest1)
  overlay(base,plot_nest2)

; Drawing the base will also draw the two high-resolution fields
  draw(base)             ; draw plots
  frame(wks)             ; Advance the frame
 
end
