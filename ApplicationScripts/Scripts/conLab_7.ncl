;----------------------------------------------------------------------
; conLab_7.ncl
;
; Concepts illustrated:
;   - Controlling which contour lines get labeled
;   - Generating dummy data using "generate_2d_array"
;   - Using "getvalues" to retrieve resource values
;   - Using "setvalues" to set resource values
;----------------------------------------------------------------------
;
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"

begin
;---Generate some dummy data.
  data = generate_2d_array(15, 15, -100., 100., 0, (/100,100/))

;---Open a PNG file to draw graphics to.
  wks = gsn_open_wks("png","conLab")

;---Set up resources.
  res                     = True

  res@gsnMaximize         = True

  res@cnFillOn            = True        ; Turn on contour fill
  res@cnLineLabelsOn      = True        ; Turn on contour line labels
  res@cnLineLabelInterval = 1           ; Default is 2
  res@lbOrientation       = "Vertical"  ; Default is horizontal

  res@tiMainString        = "positive & negative contours are labeled"

  plot = gsn_csm_contour(wks,data,res)  ; Create filled contour plot

;---Retrieve the contour levels used
  getvalues plot
    "cnLevels" : levels
  end getvalues

;---Create an array to set a flag for each contour level
  nlevels = dimsizes(levels)
  flags   = new(nlevels,string)

;---Loop through each level and set the corresponding "flags" value.
  do i=0,nlevels-1
    if(levels(i).lt.0) then
      flags(i) = "LineOnly"
    else
      flags(i) = "LineAndLabel"
    end if
  end do
;
; Set this new resource in the plot we've already created,
; and redraw the plot.
;
  setvalues plot
    "tiMainString" : "only zero & positive contours are labeled"
    "cnLevelFlags" : flags
  end setvalues

  draw(plot)
  frame(wks)

end
