;================================================
;  lb_13.ncl
;================================================
; Concepts illustrated:
;   - Drawing a custom labelbar
;   - Retrieving the current color map as an array of RGB triplets
;   - Using drawNDCGrid to draw a nicely labeled NDC grid
;   - Changing the width and height of a labelbar
;   - Turning on the perimeter around a labelbar
;   - Removing margins around a labelbar
;   - Making the labelbar be vertical
;   - Changing the font height of labelbar labels
;   - Setting the fill colors for a labelbar
;   - Left-justifying the labelbar labels
;   - Moving labels away from a labelbar
;   - Setting the exact width of labelbar boxes
;================================================
;
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
;
; This file still has to be loaded manually
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl"

begin

  wks = gsn_open_wks("png", "lb")    ; send graphics to PNG file

  cmap = read_colormap_file("cosam12")

; Draw labeled NDC grid
  drawNDCGrid(wks)

; Set up resources for a labelbar
  levels = fspan(1.0,12.0,12)
  labels = levels + ""

  lbres                      = True

; Set initial width and height.
  lbres@vpHeightF            = 0.4
  lbres@vpWidthF             = 0.03

; Allow more control over labelbars.
  lbres@lbAutoManage         = False

; No margins around labelbar.
  lbres@lbBottomMarginF      = 0.0
  lbres@lbLeftMarginF        = 0.0
  lbres@lbRightMarginF       = 0.0
  lbres@lbTopMarginF         = 0.0

; Turn various features on and off.
  lbres@lbLabelsOn           = True
  lbres@lbPerimOn            = True
  lbres@lbTitleOn            = False
  lbres@lbMonoFillPattern    = True
  lbres@lbOrientation        = "Vertical"
;
; This specifies the proportion of the space in the direction
; perpendicular to the labelbar orientation that is occupied by the
; colorbar. By default it is 0.33, or 1/3 of the width specified by
; vpWidthF in the case of a vertically oriented labelbar.
;
  lbres@lbBoxMinorExtentF    = 1.0

  lbres@lbFillColors         = cmap(0:dimsizes(levels)-1,:)

; Which point to position labelbar about.
  lbres@lbJustification      = "TopLeft"

  lbres@lbLabelAlignment     = "InteriorEdges"

  lbres@lbLabelJust          = "CenterLeft"
  lbres@lbLabelOffsetF       = 0.5

; Loop and create four different labelbars with
; different label heights.

  do i=0,3
    xpos = 0.2 + 0.2*i
    if (i.eq.0) then
      lbres@lbLabelFontHeightF   = 0.01
    end if
    if (i.eq.1) then
      lbres@lbLabelFontHeightF   = 0.02
    end if
    if (i.eq.2) then
      lbres@lbLabelFontHeightF   = 0.05
    end if
    if (i.eq.3) then
      lbres@lbLabelFontHeightF   = 0.1
    end if
    lbid = gsn_create_labelbar_ndc(wks,dimsizes(levels)+1,labels, \
                                   xpos,0.8,lbres)
    draw(lbid)
  end do

  frame(wks)    ; Advance frame

end

