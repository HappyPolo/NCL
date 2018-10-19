;*************************************************************** 
; ST4_1.ncl 
; 
; Concepts illustrated: 
;   - Reading a GRIB file that has no file extension identifier
;   - Explicitly setting contour levels and colors
;   - Use resources to explicitly color regions of missing values
;***************************************************************
; These library files are loaded by default in NCL V6.2.0 and newer
;
;;load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl" 
;;load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl" 
;**************************************************************

; -------------------------- MAIN -----------------------------

  diri = "./"
  fili = "ST4.2016060123.01h"
  pthi = diri+fili
                                                                ; Not required ...
  setfileoption("grb","SingleElementDimensions","Initial_time") ; Force 'time' dimension

  f = addfile(pthi+".grb", "r")                   ; add .grb extension
 ;print(f)                                        ; file overview (ncl_filedump)
    
  x = f->A_PCP_GDS5_SFC_acc1h                     ; total precip
  printVarSummary(x)
  printMinMax(x,1)

 ;rot   = f->g5_rot_3
  lat2d = f->g5_lat_1   ; (:,881,1121); corners : ( 23.117, 19.80426, 45.61898, 53.51062 )
  lon2d = f->g5_lon_2   ; (:,881,1121); corners : ( -119.023, -80.74809, -59.95461, -134.0418 )

  dimll = dimsizes(lat2d)
  nlat  = dimll(0)
  mlon  = dimll(1)

  wks  = gsn_open_wks ("png", "ST4_1")    ; open workstation

  res                        = True               ; plot mods desired
 ;res@gsnPaperOrientation    = "Portrait"         ; force portrait
  res@gsnMaximize            = True               ; make ps/eps/pdf large [no effect x11]
  res@gsnAddCyclic           = False              ; regional data

  res@cnFillOn               = True               ; color fill  
  res@cnLinesOn              = False              ; no contour lines
  res@cnLineLabelsOn         = False              ; no contour labels
  res@cnInfoLabelOn          = False              ; no contour info label
 ;res@cnFillMode             = "RasterFill"       ; slow here
  res@cnFillMode             = "CellFill"         ; fast here    
  res@cnMissingValFillPattern= 0
  res@cnMissingValFillColor  = "Gray"
   
  res@cnLevelSelectionMode   = "ExplicitLevels"
  res@cnLevels               = (/0.1,1,2.5,5,10,15,20,25,50,75/) ; "mm/day"

  colors = (/"gray98"    \        
            ,"PaleTurquoise","PaleGreen","SeaGreen3" ,"Yellow"  \
            ,"Orange","HotPink","Red","Violet", "Purple", "Brown"/) 
  res@cnFillPalette          = colors   ; set color map
  
 ;res@mpDataBaseVersion      = "MediumRes"        ; better map outlines
  res@pmTickMarkDisplayMode  = "Always"           ; turn on tickmarks
  
  res@tiMainString           = fili
  res@tiMainFontHeightF      = 0.020              ; smaller title
  res@tiMainOffsetYF         = -0.005             ; move title down
  
  x@lat2d = lat2d
  x@lon2d = lon2d

  res@mpMinLatF            = min(lat2d) - 1       ; +/-  are small buffer
  res@mpMaxLatF            = max(lat2d) + 1
  res@mpMinLonF            = min(lon2d) - 1
  res@mpMaxLonF            = max(lon2d) + 1
  res@mpCenterLonF         = 0.5*(res@mpMinLonF + res@mpMaxLonF)
  res@mpFillOn             = False                ; no default land fill

  res@mpGridAndLimbOn      = True
  res@mpGridLatSpacingF    = 2
  res@mpGridLonSpacingF    = 2
  res@mpGridLineColor      = "LightGray"
  res@mpGridLineDashPattern= 6 ;http://www.ncl.ucar.edu/Document/Graphics/Images/dashpatterns.png

  plot = gsn_csm_contour_map(wks,x(0,:,:),res)    ; Draw contours over a map.
