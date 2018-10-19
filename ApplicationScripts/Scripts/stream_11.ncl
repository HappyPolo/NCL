;----------------------------------------------------------------------
; stream_11.ncl 
;
; Concepts illustrated:
;   - Drawing streamlines colored by another field over a map
;----------------------------------------------------------------------
; Many thanks to Alan Brammer of the University at Albany who provided
; the initial version of this example which was modified to color
; the streamlines based on the field "p1". Alan also contributed the
; gsn_csm_streamline_scalar_xxxx functions which we added to V6.3.0.
;----------------------------------------------------------------------
; This example will only work with NCL V6.3.0 or later.
;----------------------------------------------------------------------

begin
  ncout = addfile("temp_out.nc","r")
  pgrid = ncout->p1
  ugrid = ncout->u1
  vgrid = ncout->v1

wtype = "png"
;
; These lines were commented out due to the fact that they make the plot
; unmanageably large.
; wtype@wkWidth = 2500
; wtype@wkHeight = 2500
  wks = gsn_open_wks(wtype,"stream")
;
; The following line is for debugging purposes.  Uncomment it to debug.
;  wks = gsn_open_wks("x11","stream")

  mpres                       = True

  mpres@gsnMaximize           = True

;---Zoom in on map
  mpres@mpMinLatF             = -12
  mpres@mpMaxLatF             =  48
  mpres@mpMinLonF             = -44
  mpres@mpMaxLonF             =  35

;  mpres@mpFillOn              = False
  mpres@mpOutlineOn           = True
  mpres@mpDataBaseVersion     = "MediumRes"   ; slightly better outlines
  mpres@mpLandFillColor = "gray91"
;---Data is regional
  mpres@gsnAddCyclic          = False

;---Change the streamline levels
  mpres@stLevelSpacingF       = 30.

  mpres@stLevelPalette        = "ncl_default" ; "MPL_Spectral" 
  mpres@stLineThicknessF      = 5.0         ; default is 1.0
;  mpres@stLevelSelectionMode  = "ManualLevels"
;  mpres@stMinLevelValF        = 1
;  mpres@stMaxLevelValF        = 10.
;  mpres@stLevelSpacingF       = 1.

  mpres@pmTickMarkDisplayMode = "Always"    ; more detailed tickmarks

  mpres@tiMainString          = "Streamlines colored by another field"

  plot = gsn_csm_streamline_scalar_map(wks, ugrid, vgrid, pgrid, mpres)

end
