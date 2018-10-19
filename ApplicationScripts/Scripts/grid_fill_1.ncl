;*************************************************
; grid_fill_1.ncl
;*************************************************
;
; Concepts illustrated:
;   - Generating dummy data using "generate_2d_array"
;   - Using array syntax to arbitrarily set points to _FillValue
;   - Setting arguments for "poisson_grid_fill"
;   - Illustrating before and after application of poisson_grid_fill
;   - Changing the stride of the labelbar labels
;
;*************************************************
;
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl" 
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl" 

begin
;******************************************************************
; Generate data: the array is *not* cyclic
;******************************************************************
  mlon  = 720
  nlat  = 360
  za     = generate_2d_array(25,25,-100.,100.,0,(/nlat,mlon/))

  za!0   = "lat"
  za!1   = "lon"
  za&lon =  lonGlobeF (mlon, "lon", "longitude", "degrees_east")
  za&lat =  latGlobeFo(nlat, "lat", "latitude" , "degrees_north")

  za@_FillValue = 1e20

;******************************************************************
; Set blocks of missing points for demo: arbitrary
;******************************************************************
  zb    = za               ; save for demo plot
  zb({ 70: 90},{ 50: 75}) = 1e20
  zb({-60:-35},{ 20: 40}) = 1e20
  zb({-70:-45},{250:340}) = 1e20
  zb({-20: 35},{170:210}) = 1e20
  zb({ 70: 90},{250:350}) = 1e20
  zb({ 40: 60},{320:360}) = 1e20
  zb({  0:  5},{100:150}) = 1e20
  
;******************************************************************
; set the poisson_grid_fill arguments
;******************************************************************
  zc    = zb               ; save for demo plot
 
  nscan = 2000             ; usually *much* fewer
  eps   = 0.001            ; variable depended
  gtype = False            ; "gendat" does not generate cyclic fields
  guess = 0                ; use zonal means
  relc  = 0.6              ; standard relaxation coef
  opt   = 0

  poisson_grid_fill(zc, gtype, guess, nscan, eps, relc, opt)

;******************************************************************
; plot for compare
;******************************************************************
  
  wks   = gsn_open_wks("png","grid_fill")   ; send graphics to PNG file
  plot  = new(3,graphic)     

  res                     = True
  res@gsnDraw             = False           ; don't draw
  res@gsnFrame            = False           ; don't advance frame
  
  res@cnFillOn            = True            ; turn on color
  res@cnFillPalette       = "amwg"          ; set color map
 ;res@cnLinesOn           = False           ; turn off contour lines
  res@cnLineLabelsOn      = False           ; turn off contour line labels

  res@cnLevelSelectionMode =  "ManualLevels"   
  res@cnMinLevelValF       = -80. 
  res@cnMaxLevelValF       =  80.        
  res@cnLevelSpacingF      =  10.       

  res@lbLabelBarOn        = False           ; turn off individual cb's
  res@mpCenterLonF        = 180.
  res@mpFillOn            = False

  res@gsnCenterString = "Original grid"
  plot(0) = gsn_csm_contour_map(wks,za,res) 
   
  res@gsnCenterString = "Grid with Missing sections"
  plot(1) = gsn_csm_contour_map(wks,zb,res) 
   
  res@gsnCenterString = "Grid after poisson_grid_fill"
  plot(2) = gsn_csm_contour_map(wks,zc,res) 

;************************************************
; create panel
;************************************************
  resP                     = True                ; modify the panel plot
 ;resP@txString            = title
  resP@gsnMaximize         = True                ; make large
  resP@gsnPanelLabelBar    = True                ; add common colorbar
 ;resP@lbLabelStride       = 2                   ; force every other label 
 ;resP@lbLabelFontHeightF  = 0.0125              ; make labels smaller [0.2 default]
  gsn_panel(wks,plot,(/3,1/),resP)               ; now draw as one plot
end
