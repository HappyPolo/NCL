;----------------------------------------------------------------------
; conLev_9.ncl
;
; Concepts illustrated:
;   - Generating a bullseye pattern for contours
;   - Contouring at exact contour levels
;   - Centering labels with respect to labelbar boxes
;----------------------------------------------------------------------
;
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"

begin
;---Generate some dummy data
  M     = 25
  ispn  = conform_dims((/M,M/),ispan(-M/2,M/2,1)^2,1)
  jspn  = conform_dims((/M,M/),ispan(-M/2,M/2,1)^2,0)
  data  = 100. - sqrt(64*(jspn + ispn))

;---Force all values to be multiples of 10 from -30 to 100.
  levels  = ispan(-40,110,10)    ; -40 and 110 are well outside range of data
  nlevels = dimsizes(levels)
  do i=0,nlevels-2
    data = where(data.gt.levels(i).and.data.lt.levels(i+1),levels(i+1),data)
  end do

;---Start the graphics
  wks = gsn_open_wks("png","conLev")

;---Default contour plot
  cnres                     = True
  cnres@cnFillOn             = True
  cnres@cnFillPalette        = "BlueYellowRed"
  cnres@cnLinesOn            = False
  cnres@cnLineLabelsOn       = False
  cnres@lbOrientation        = "Vertical"

  cnres@tiMainString         = "Let NCL pick the contour levels"
  contour = gsn_csm_contour(wks,data,cnres)

;---Specify contour levels
  cnres@cnLevelSelectionMode = "ExplicitLevels"
  cnres@cnLevels             = ispan(-30,90,10)      ; note 90, and not 100!
  cnres@lbLabelStrings       = ispan(-30,100,10)+""  ; need 1 more label than we have levels
  cnres@lbLabelAlignment     = "BoxCenters"

; If you want the labels inside the boxes
;  cnres@lbLabelPosition      = "Center"
;  cnres@pmLabelBarWidthF     = 0.15
;  cnres@lbLabelFontColor     = "white"

  cnres@tiMainString         = "Contouring at exact levels"
  contour = gsn_csm_contour(wks,data,cnres)
end
