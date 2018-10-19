;================================================
;  lb_14.ncl
;================================================
; Concepts illustrated:
;   - Generating dummy data using "generate_2d_array"
;   - Centering labels with respect to labelbar boxes
;   - Adding labels to both ends of a labelbar
;   - Changing the font height of labelbar labels
;   - Using "getvalues" to retrieve the size of a plot
;   - Using "getvalues" to retrieve contour levels
;   - Making the labelbar be vertical
;   - Using "sprintf" to create nicely formatted text strings
;   - Forcing the paper orientation to be "portrait"
;================================================
;
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"

begin
;---Generate some dummy data.
  dmin = -20.3
  dmax =  17.7
  data = generate_2d_array(10, 12, dmin, dmax, 0, (/100,100/))
  
  wks = gsn_open_wks("png","lb")         ; send graphics to PNG file

; Set up resources.
  res                     = True
  res@gsnMaximize         = True
  res@cnFillOn            = True        ; Turn on contour fill
  res@cnFillPalette       = "testcmap"
  res@lbLabelFontHeightF  = 0.01
  res@tiMainString        = "Labelbar: InteriorEdges (default)"

;---Use default labelbar.
  plot = gsn_csm_contour(wks,data,res)
  
;--------Second plot-----------------------------------
; Move the labelbar labels so they are centered under
; each box. This requires changing the labels as well.
;------------------------------------------------------

;
; Retrieve the contour levels used in previous plot so
; we can create new labels for the next two plots.
;
  getvalues plot
    "cnLevels" : levels
    "vpWidthF" : width
  end getvalues
  nlevels = dimsizes(levels)
  spacing = levels(1) - levels(0)

;---Use "BoxCenters" labelbar
  res@lbLabelAlignment = "BoxCenters"
;
; Shift the levels over by half their spacing since we're
; going to center the labels under the labelbar boxes.
;
  levels_plus1              = new(nlevels+1,float)
  levels_plus1(0:nlevels-1) = levels-(spacing/2.)
  levels_plus1(nlevels)     = levels_plus1(nlevels-1) + spacing

  res@gsnPaperOrientation = "Portrait"
  res@lbLabelStrings      = sprintf("%6.2f",levels_plus1)
  res@lbOrientation       = "Vertical"
  res@tiMainString        = "Labelbar: BoxCenters"

  plot = gsn_csm_contour(wks,data,res)

;--------Third plot-----------------------------------
; Add min/max labels to end of labelbar
;------------------------------------------------------

;---Use "ExternalEdges" labelbar
  res@lbLabelAlignment = "ExternalEdges"

;---Need one more string than what we had before.
  delete(res@lbLabelStrings)
  levels_plus2            = new(nlevels+2,float)
  levels_plus2(1:nlevels) = levels
  levels_plus2(0)         = floor(dmin)
  levels_plus2(nlevels+1) = ceil(dmax)

  res@lbLabelStrings = sprintf("%5.1f",levels_plus2)
  res@tiMainString   = "Labelbar: ExternalEdges"
  plot = gsn_csm_contour(wks,data,res)

end
