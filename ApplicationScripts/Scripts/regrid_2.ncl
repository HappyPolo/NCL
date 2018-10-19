;=========================================;
; regrid_2.ncl
;
; Concepts illustrated:
;   - Interpolating from a gaussian grid to another using spherical harmonics
;   - Drawing color-filled contours over a cylindrical equidistant map
;   - Paneling two plots vertically on a page
;   - Setting the labelbar label stride in a panel plot
;   - Adding a common labelbar to paneled plots
;   - Turning off the individual contour labelbar
; 
;=========================================;
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"

begin
;=========================================;
; open original grid
;=========================================;
  in = addfile("T2m.nc","r")
  orig = in->T
;=========================================;
; interpolate to new grid
;=========================================;
  newgrid  = g2gsh_Wrap(orig,(/64,128/),0) 
;=========================================;
; create plots of original and regridded data
;=========================================;
  wks = gsn_open_wks("ps" ,"regrid")       ; open ps file
  gsn_define_colormap(wks,"gui_default")   ; choose colormap
  plot = new(2, graphic)

  res                     = True               ; plot mods desired
  res@cnFillOn            = True               ; turn on color   
  res@gsnSpreadColors     = True               ; use full color map
  res@cnLinesOn           = False              ; no contour lines
  res@cnLineLabelsOn      = False              ; no line labels

  res@gsnDraw             = False              ; don't draw yet
  res@gsnFrame            = False              ; don't advance frame yet

  res@cnLevelSelectionMode =  "ManualLevels"   ; manual levels
  res@cnMinLevelValF       = 255               ; min level
  res@cnMaxLevelValF       = 305               ; max level
  res@cnLevelSpacingF      =   5               ; interval

  res@lbLabelBarOn         = False             ; turn off label bar



  res@tiMainString    = "NCEP (lat=94, lon=192)"
  plot(0)  = gsn_csm_contour_map_ce(wks,orig(0,:,:),res) 

  res@tiMainString    = "g2gsh:(/64,128/)"
  plot(1)  = gsn_csm_contour_map_ce(wks,newgrid(0,:,:),res) 
;=========================================;
; create panel plot
;=========================================;
  pres                  = True
  pres@gsnPanelLabelBar = True             ; common label bar
  pres@lbLabelStride       = 2             ; every other label
  gsn_panel(wks, plot,(/2,1/),pres)
end
