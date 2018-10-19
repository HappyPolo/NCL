;=========================================;
; regrid_5.ncl
;
; Concepts illustrated:
;   - Interpolating from a fixed grid to a gaussian grid using spherical harmonics 
;   - Drawing color-filled contours over a cylindrical equidistant map
;   - Paneling two plots vertically on a page
;
;=========================================;
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
begin
;=========================================;
; open original grid
;=========================================;
  in = addfile("T2m_1x1.nc","r")
  orig = in->T
;=========================================;
; interpolate to new grid
;=========================================;
  newgrid  = f2gsh_Wrap(orig(0,:,:),(/64,128/),0)
;=========================================;
; create plots of original and regridded data
;=========================================;
  wks = gsn_open_wks("ps" ,"regrid")           ; open ps file
  gsn_define_colormap(wks,"gui_default")       ; choose colormap
  plot = new(2, graphic)

  res                     = True               ; plot mods desired
  res@cnFillOn            = True               ; turn on color   
  res@gsnSpreadColors     = True               ; use full color map
  res@cnLinesOn           = False              ; no contour lines
  res@cnLineLabelsOn      = False              ; no line labels
  res@lbLabelAutoStride   = True               ; nice label bar labels

  res@gsnAddCyclic        = False              ; don't add cyclic point

  res@mpMinLonF            = -180              ; sets min lon
  res@mpMaxLonF            =  0.               ; set max lon

  res@gsnDraw             = False              ; don't draw yet
  res@gsnFrame            = False              ; don't advance frame yet

  res@tiMainString    = "Fixed Grid (lat=180, lon=360)"
  plot(0)  = gsn_csm_contour_map_ce(wks,orig(0,:,{180:360}),res) 

  res@tiMainString    = "f2gsh: (/64,128/)"
  plot(1)  = gsn_csm_contour_map_ce(wks,newgrid(:,{180:360}),res) 
;=========================================;
; create panel plot
;=========================================;
  gsn_panel(wks, plot,(/2,1/),False)
end
