;----------------------------------------------------------------------
;  lb_15.ncl
;----------------------------------------------------------------------
; Concepts illustrated:
;   - Reversing a labelbar in a contour plot
;   - Centering labels with respect to labelbar boxes
;   - Using "getvalues" to retrieve the labels and colors of a labelbar
;   - Using "setvalues" to set the labels and colors of a labelbar
;   - Making the labelbar be vertical
;   - Querying a plot object to get its annotations
;   - Using "setvalues" to change the main title of an existing plot
;   - Maximizing plots after they've been created
;----------------------------------------------------------------------
;
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"

;----------------------------------------------------------------------
; This procedure reverses the colors and the labels in a labelbar
; attached to a plot.
;----------------------------------------------------------------------
procedure reverse_labelbar(plt)
local anno_ids, i, colors, labels
begin

;---Get all annotations associated with this plot.
  getvalues plt
    "pmAnnoViews" : anno_ids
  end getvalues

;---Find the labelbar, and reverse it.
  do i=0,dimsizes(anno_ids)-1
    if(NhlClassName(anno_ids(i)).eq."labelBarClass") then

;---Get the colors and the strings
      getvalues anno_ids(i)
        "lbFillColors"   : colors
        "lbLabelStrings" : labels
      end getvalues

;---Set the colors and the strings, but reverse them with "::-1"
      setvalues anno_ids(i)
        "lbFillColors"   : colors(::-1)
        "lbLabelStrings" : labels(::-1)
      end setvalues
    end if
  end do
end

;----------------------------------------------------------------------
; Main code
;----------------------------------------------------------------------

begin
;---Generate some dummy data.
  nx   = 100
  ny   = 100
  data = generate_2d_array(10, 10, 1., 12, 0, (/ny,nx/))

  wks = gsn_open_wks("png","lb")  ; send graphics to PNG file

;---Create a simple color contour plot with a vertical labelbar
  res                      = True

  res@gsnMaximize          = True

  res@cnFillOn             = True
  res@cnFillPalette        = "percent_11lev"
  res@cnLevelSelectionMode = "ExplicitLevels"
  res@cnLevels             = ispan(1,10,1)+.5

  res@lbOrientation        = "Vertical"
  res@lbLabelPosition      = "Center"           ; label position
  res@lbLabelAlignment     = "BoxCenters"       ; label orientation
  res@lbLabelStrings       = ispan(1,11,1)      ; Define labels ourselves

  res@tiMainString         = "Default labelbar"

  plot = gsn_csm_contour(wks,data,res)

;---Reverse the labelbar and draw plot again.
  reverse_labelbar(plot)

;---Change the title
  setvalues plot
    "tiMainString" : "Reversed labelbar"
  end setvalues

  draw(plot)
  frame(wks)
end
