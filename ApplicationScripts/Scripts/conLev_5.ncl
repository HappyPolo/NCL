; ===========================================
; conLev_5.ncl
;
; Concepts illustrated:
;   - Creating contours for a constant field
;   - Explicitly setting contour levels
;   - Explicitly setting the fill colors for contours
;   - Centering labels with respect to labelbar boxes
; ===========================================
;
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"

;----------------------------------------------------------------------
; Main code
;----------------------------------------------------------------------
begin
;---Create a dummy array that will initially contain all missing values
  x = new((/33,33/),float)

;---Fill in values to make a square
  x(6:26,6:26) = 100.

;---Set all missing values to some non-missing value
  x = where(ismissing(x),50,x)

  wks   = gsn_open_wks ("png", "conLev") ; send graphics to PNG file
 
  res                      = True
  res@gsnMaximize          = True

  res@cnFillOn             = True
  res@cnFillColors         = (/"NavyBlue","Yellow"/)

  res@cnLevelSelectionMode = "ExplicitLevels"
;---Use a value that's between the two values, 50 and 100.
  res@cnLevels             = (/75/) 

  res@lbLabelAlignment     = "BoxCenters"
  res@lbLabelStrings       = (/"missing values","100"/)

  plot = gsn_csm_contour(wks, x, res)

;---Change the look of the labelbar
  delete(res@lbLabelStrings)

  res@cnFillColors     = (/"White","Yellow"/)

  res@lbLabelAlignment = "InteriorEdges"    ; This is the default
  res@lbLabelStrings   = "100"
  res@lbBoxLinesOn     = False

;---You may get a warning from setting this resource.
  res@lbFillColors     = (/"Yellow","Yellow"/)

  plot = gsn_csm_contour(wks, x, res)
end
