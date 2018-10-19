;----------------------------------------------------------------------
; stream_10.ncl 
;
; Concepts illustrated:
;   - Drawing color streamlines over a map
;   - Using the stLevelPalette resource to assign a color palette
;   - Paneling two plots on a page with a horizontal labelbar
;   - Paneling two plots on a page with a vertical labelbar
;   - Customizing a labelbar in a panel plot
;   - Adding figure strings to paneled plots
;----------------------------------------------------------------------
; Many thanks to Alan Brammer of the University at Albany who provided
; the initial version of this example and a fix to gsn_panel so users
; can now panel color streamline plots with a common labelbar.
;----------------------------------------------------------------------
; This example will only work with NCL V6.3.0 or later.
;----------------------------------------------------------------------

begin
  ncout = addfile("temp_out.nc","r")
  ugrid =  ncout->u1
  vgrid =  ncout->v1

  wks = gsn_open_wks("png","stream")       ; send graphics to PNG file
  mpres                       = True
  mpres@gsnDraw               = False      ; will panel plots later
  mpres@gsnFrame              = False

;---Zoom in on map
  mpres@mpMaxLatF             =  50
  mpres@mpMinLatF             = -10
  mpres@mpMaxLonF             =  30
  mpres@mpMinLonF             = -50

  mpres@mpFillOn              = False
  mpres@mpOutlineOn           = True
  mpres@mpDataBaseVersion     = "MediumRes"   ; slightly better outlines

;---Data is regional
  mpres@gsnAddCyclic          = False

;---Change the streamline levels
  mpres@stLevelPalette        = "MPL_Spectral"
  mpres@stLevelSelectionMode  = "ManualLevels"
  mpres@stMinLevelValF        = 1
  mpres@stMaxLevelValF        = 10.
  mpres@stLevelSpacingF       = 1.

  mpres@stMonoLineColor       = False
  mpres@stLineThicknessF      = 2.0         ; default is 1.0

  mpres@pmTickMarkDisplayMode = "Always"    ; more detailed tickmarks

  mpres@lbLabelBarOn          = False       ; will add one in panel plot

;---Create the two plots
  plots = new(2, graphic)
  do t=0, 1
    plots(t) = gsn_csm_streamline_map(wks, ugrid, vgrid, mpres)
  end do

;---Set up paneling resources
  panres                       = True 
  panres@gsnMaximize           = True
  panres@gsnPanelFigureStrings = (/"a","b"/)
  panres@gsnPanelLabelBar      = True

;---First plot
  panres@txString              = "Streamline panels with horizontal labelbar"
  gsn_panel(wks, plots, (/2,1/), panres)

;---Second plot
  panres@lbOrientation         =  "vertical"
  panres@txString              = "Streamline panels with short vertical labelbar"
  gsn_panel(wks, plots, (/1,2/), panres)

;---Third plot
  panres@pmLabelBarHeightF     = 0.85
  panres@pmLabelBarWidthF      = 0.1
  panres@lbLabelFontHeightF    = 0.01
  panres@txString              = "Streamline panels with long vertical labelbar"
  panres@gsnPanelFigureStringsFontHeightF = 0.02    ; make these larger
  gsn_panel(wks, plots, (/2,1/), panres)
end
