;***************************************************************************
; narr_4.ncl
;
;***************************************************************************
; [1] Read Grib file
; [2] Use Cylindrical Equidistant and Robinson projections: Lower 48 
; [3] Plot sample level              
;**************************************************************
;
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"  
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"  
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"

begin
  fili    = "merged_AWIP32.1979010100.3D.NARR.grb"    ; input GRIB

;*******************************************
; open file and read in data
;*******************************************
  f       = addfile (fili, "r")
  lat2d   = f->gridlat_221                 ; (277,349)
  lon2d   = f->gridlon_221
                                          
  x       = f->U_GRD_221_ISBL              ; (29,277,349)    
                                           ; (lv_ISBL0, gridx_221, gridy_221)
 ;printVarSummary(x)
 ;print("x:  min="+min(x)+"   max="+max(x))     

  dimx    = dimsizes( x )
  klev    = dimx(0)
  nlat    = dimx(1)
  mlon    = dimx(2)

;********************************************
; create plots
;********************************************
  kl      = 10                     ; arbitrary level to plot

  x@lat2d = lat2d                  ; associate coordinates with variable
  x@lon2d = lon2d

  plot    = new (2, "graphic")

  wks     = gsn_open_wks ("png", "narr")          ; send graphics to PNG file
  
  res                        = True               ; plot mods desired for original grid
  res@gsnAddCyclic           = False              ; regional data
  res@gsnDraw                = False              ; do not draw
  res@gsnFrame               = False              ; do not advance frame

  res@cnFillOn               = True               ; color fill  
  res@cnFillPalette          = "BlAqGrYeOrReVi200"; set color map
  res@cnFillMode             = "RasterFill"
  res@cnLinesOn              = False              ; no contour lines
  res@cnLineLabelsOn         = False              ; no contour labels

  res@lbLabelBarOn           = False
  res@cnLevelSelectionMode   = "ManualLevels"     ; set manual contour levels
  res@cnMinLevelValF         = -25.               ; set min contour level
  res@cnMaxLevelValF         =  50.               ; set max contour level
  res@cnLevelSpacingF        =   5.               ; set contour spacing
  
  res@mpGridAndLimbOn        = True
  res@mpGridLineDashPattern  = 2                  ; lat/lon lines as dashed
  res@pmTickMarkDisplayMode  = "Always"           ; turn on tickmarks
  res@tmXTOn                 = False

  res@mpLimitMode            = "LatLon"        
  res@mpMinLatF              =   23.5   
  res@mpMinLonF              = -125.
  res@mpMaxLatF              =   50.
  res@mpMaxLonF              =  -66.5

  res@mpOutlineBoundarySets  = "USStates"         ; turn on state boundaries
     
  res@mpProjection           = "CylindricalEquidistant" 
  res@gsnCenterString        = res@mpProjection
  plot(0) = gsn_csm_contour_map(wks,x(kl,:,:),res)   

  res@mpProjection           = "Robinson" 
  res@gsnCenterString        = res@mpProjection
  res@mpMinLonF              = -118.0
  res@mpMaxLonF              =  -67.5
  plot(1) = gsn_csm_contour_map(wks,x(kl,:,:),res)  

  panres = True                                    ; set up panel resources
 ;panres@gsnPaperOrientation = "portrait"          ; force portrait
  panres@gsnMaximize         = True
  panres@gsnPanelLabelBar    = True
  gsn_panel(wks,plot,(/2,1/),panres)

end
