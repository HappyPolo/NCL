;*************************************************
; icon_1.ncl
;
; Concepts illustrated:
;   - Plotting ICON model data
;   - Contouring one-dimensional X, Y, Z data
;   - Using triangular meshes to create contours
;
;*************************************************

;------------------------------------
; Hui Wan (MPI-M, 2009)
;------------------------------------
; Script type: visualization
;---------------------------------------------------------------
; This script makes contour plot of 850 hPa divergence 
; for the Jablonowski-Williamson steady state test.
;---------------------------------------------------------------
 load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
 load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
;---------------------------------------------------------------
 begin

  Model      = "ICOHDC" 
  Resolution = "R2B4L31" 
  ConfigStr  = "D1 spr0.90" 

  LeftString   = "850 hPa div. (10~S~-6~N~ s~S~-1~N~) at day 9"
  RightString  = Model+" "+Resolution+" "+ConfigStr 
  CenterString = ""

  DataFileName = "DIV850_day9.nc"  ; input
  VarName      = "DIV"             ; variable name in the input file       

  colormap  = "testcmap"
  scale     = 1e6

  varMin = -15.  ; minimum contour level
  varMax =  15.  ; maximum contour level
  varInt =   3.  ; interval between contours

  rad2deg = get_r2d("float")   ; radians to degrees

;---------------------------------------------------------------
; read in the meteorological field and grid information
;---------------------------------------------------------------

  File = addfile( DataFileName, "r" )

  var = File->$VarName$(0,0,:)   ; dims: (time,lev,cell)
  var = var*scale

  x = File->clon *rad2deg   ; cell center, lon
  y = File->clat *rad2deg   ; cell center, lat

; note: clon and clat are longitude and latitude of triangle centers.
;       Locations of the cell corners are given by 
;       clon_vertices and clat_vertices in the nc file.

;---------------------------------------------------------------
; make plot
;---------------------------------------------------------------

  wks = gsn_open_wks("ps","icon")
  gsn_define_colormap(wks,colormap)

  ResC                = True

  ResC@gsnMaximize    = True 

  ResC@cnFillOn       = True
  ResC@cnLinesOn      = False
  ResC@cnInfoLabelOn  = False

; This doesn't make the script run faster.
;  ResC@cnFillMode          = "RasterFill"
;  ResC@cnRasterSmoothingOn = True

  FontHeight = 0.018

  ResC@tiXAxisFontHeightF        = FontHeight
  ResC@tiYAxisFontHeightF        = FontHeight
  ResC@tmXBLabelFontHeightF      = FontHeight
  ResC@tmYLLabelFontHeightF      = FontHeight
  ResC@gsnStringFontHeightF      = FontHeight - 0.002
  ResC@tmXBLabelJust             = "CenterCenter"

  ResC@mpProjection   = "CylindricalEquidistant"
  ResC@mpLimitMode    = "LatLon"
  ResC@mpCenterLonF   = 180.
  ResC@mpMinLonF      =  90.
  ResC@mpMaxLonF      = 270.
  ResC@mpMinLatF      =  25.
  ResC@mpMaxLatF      =  75.

  ResC@gsnMajorLonSpacing =  30. 
  ResC@gsnMinorLonSpacing =  10.
  ResC@gsnMajorLatSpacing =  15. 
  ResC@gsnMinorLatSpacing =   5. 

  ResC@mpGeophysicalLineColor = "transparent"
  ResC@mpFillOn               = False

  ResC@sfXArray = x      ; These are 1D arrays, so a triangular mesh
  ResC@sfYArray = y      ; will be used to create the contours.

  ResC@lbLabelBarOn             = True 
  ResC@pmLabelBarHeightF        = 0.07
  ResC@pmLabelBarWidthF         = 0.7
  ResC@pmLabelBarOrthogonalPosF = 0.25
  ResC@lbLabelAutoStride        = True
  ResC@lbLabelFontHeightF       = FontHeight

  ResC@cnLevelSelectionMode = "ManualLevels"
  ResC@gsnSpreadColors      = True

  ResC@gsnLeftString   = LeftString 
  ResC@gsnCenterString = CenterString
  ResC@gsnRightString  = RightString 

  ResC@cnMinLevelValF  = varMin
  ResC@cnMaxLevelValF  = varMax
  ResC@cnLevelSpacingF = varInt

  plot = gsn_csm_contour_map(wks,var,ResC)

end

