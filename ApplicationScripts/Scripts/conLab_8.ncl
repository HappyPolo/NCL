;----------------------------------------------------------------------
; conLab_8.ncl
;
; Concepts illustrated:
;   - Formatting contour line labels to force the number of digits
;   - Generating dummy data using "generate_2d_array"
;   - Making the labelbar be vertical
;   - Formatting labelbar labels using "sprintf"
;----------------------------------------------------------------------
; See tickmark example tm_8.ncl for more xxxFormat examples:
;
; http://www.ncl.ucar.edu/Applications/Images/tm_8_lg.png
;----------------------------------------------------------------------
;
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"

begin
;---Generate some dummy data.
  data = generate_2d_array(15, 15, -100., 100., 0, (/100,100/))

;---Contour levels to use.
  data_levels = ispan(-85,85,5) + 5.587

;---Open a png file to draw graphics to.
  wks = gsn_open_wks("png","conLab")

;---Set up resources.
  res                       = True

  res@gsnMaximize           = True

  res@cnFillOn              = True        ; Turn on contour fill
  res@cnLineLabelsOn        = True        ; Turn on contour line labels

  res@cnLevelSelectionMode = "ExplicitLevels"
  res@cnLevels             = data_levels

  res@lbOrientation        = "Vertical"

  res@tiMainString         = "Default line labels and labelbar labels"
  plot = gsn_csm_contour(wks,data,res)  ; Create filled contour plot


  res@cnLineLabelFormat    = "0@;*.3f"                      ; Only one value after decimal point
  res@lbLabelStrings       = sprintf("%5.1f",data_levels)   ; Format the labelbar labels
  res@tiMainString         = "Formatted line labels and labelbar labels"

  plot = gsn_csm_contour(wks,data,res)  ; Create filled contour plot



end
