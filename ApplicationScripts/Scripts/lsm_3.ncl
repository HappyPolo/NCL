;*************************************************
; NCL Graphics: lsm_3.ncl
;************************************************
;
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl" 
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl" 
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
;
; This file still has to be loaded manually
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl"
;************************************************
begin
;************************************************
; read in netCDF file
;************************************************
  a = addfile("atmos.nc","r")
;************************************************
; read in data
;************************************************
  precc = a->PRECC 
  precl = a->PRECL
;************************************************
; calculate precipitation rate
;************************************************
  prect = precc                ; trick to save coordinate variables
  prect = (precc+precl)*8.64e7
  prect@long_name = "precipitation rate"
  prect@units     = "m/s"
;************************************************
; plot parameters
;************************************************
  wks = gsn_open_wks("png","lsm")                ; send graphics to PNG file

  gsn_define_colormap(wks,"BlAqGrYeOrReVi200")

  plot = new(4,graphic)
  res                      = True                ; plot mods desired
  
  res@cnFillMode            = "RasterFill"       ; raster plot
  res@cnFillOn              = True               ; color on
;  res@cnFillPalette         = "BlAqGrYeOrReVi200"; set color map
  res@lbLabelBarOn          = False              ; no label bar
  res@cnLinesOn             = False              ; no contour lines
  res@cnLineLabelsOn        = False             ; no line labels
  res@cnFillColors          = (/170,138,123,105,91,72,47,35,31,22,5/)  
  res@cnLevelSpacingF       = 3.0 
  res@mpOutlineBoundarySets = "AllBoundaries"   ; state and country boundaries
  res@gsnDraw               = False             ; don't draw
  res@gsnFrame              = False             ; don't advance frame
;************************************************
; plot one
;************************************************
  res@mpMinLatF            =  10.                ; set min lat
  res@mpMaxLatF            =  30.                ; set max lat
  res@mpMinLonF            = -110.               ; set min lon
  res@mpMaxLonF            =  -90.               ; set max lon
  plot(0) = gsn_csm_contour_map(wks,prect(0,:,:), res)   ; create plot
;************************************************
; plot two
;************************************************
  res@mpMinLatF            =  10.               ; set min lat
  res@mpMaxLatF            =  30.               ; set max lat
  res@mpMinLonF            = -90.               ; set min lon
  res@mpMaxLonF            = -70.               ; set max lon
  plot(1) = gsn_csm_contour_map(wks,prect(0,:,:), res)   ; create plot
;************************************************
; plot three
;************************************************
  res@mpMinLatF            =  -10               ; set min lat
  res@mpMaxLatF            =  10.               ; set max lat
  res@mpMinLonF            = -90.               ; set min lon
  res@mpMaxLonF            = -70.               ; set max lon
  plot(2) = gsn_csm_contour_map(wks,prect(0,:,:), res)   ; create plot
;************************************************
; plot four
;************************************************
  res@mpMinLatF            =  30.               ; set min lat
  res@mpMaxLatF            =  50.               ; set max lat
  res@mpMinLonF            = -90.               ; set min lon
  res@mpMaxLonF            = -70.               ; set max lon
  plot(3) = gsn_csm_contour_map(wks,prect(0,:,:), res)   ; create plot
;************************************************
; create panel plot
;************************************************
  resPanel                  = True
  resPanel@txString         = "An LSM-style raster plot" ; add common title
  resPanel@gsnMaximize      = True                       ; use full page
  resPanel@gsnPanelLabelBar = True                       ; add color bar

  gsn_panel(wks,plot,(/2,2/),resPanel)

  end
