;----------------------------------------------------------------------
;  lb_16.ncl
;----------------------------------------------------------------------
; Concepts illustrated:
;   - Using lbBoxEndCapStyle to draw triangles at the end of a labelbar
;   - Changing the width and height of a labelbar
;   - Changing the font height of labelbar labels
;   - Setting the fill colors for a labelbar
;   - Setting the exact width of labelbar boxes
;   - Using "getvalues" to retrieve the size of a labelbar
;----------------------------------------------------------------------
; This shows how to use the new lbBoxEndCapStyle resource introduced
; in NCL V6.4.0 for drawing triangles at one or both ends of a 
; labebar.
;----------------------------------------------------------------------
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"

begin
  lbar_orient = "Vertical"
  lbar_side   = "Right"

;  lbar_orient = "Horizontal"
;  lbar_side   = "Bottom"

  wks = gsn_open_wks("png", "lb")    ; send graphics to PNG file
  gsn_define_colormap(wks,"StepSeq25")

; Set up resources for a labelbar
  nlevels = 12
  levels  = fspan(1.0,12.0,nlevels)
  labels  = levels + ""
  nboxes  = nlevels+1

;---Set width/height and location of labelbar.
  if(str_lower(lbar_orient).eq."vertical") then
    lbar_h  = 0.8
    lbar_w  = 0.05
    lbar_x1 = 0.30
    lbar_x2 = 0.45
    lbar_x3 = 0.60
    lbar_x4 = 0.75

    lbar_y1 = 0.9
    lbar_y2 = 0.9
    lbar_y3 = 0.9
    lbar_y4 = 0.9
  else
    lbar_h  = 0.05
    lbar_w  = 0.8
    lbar_x1 = 0.1
    lbar_x2 = 0.1
    lbar_x3 = 0.1
    lbar_x4 = 0.1

    lbar_y1 = 0.75
    lbar_y2 = 0.60
    lbar_y3 = 0.45
    lbar_y4 = 0.30
  end if

;---Set some labelbar resources
  lbres                      = True

; Set initial width and height.
  lbres@vpHeightF            = lbar_h
  lbres@vpWidthF             = lbar_w

; Allow more control over labelbars.
  lbres@lbAutoManage         = False

  lbres@lbOrientation        = lbar_orient
  lbres@lbLabelPosition      = lbar_side

; No margins around labelbar.
  lbres@lbBottomMarginF      = 0.0
  lbres@lbLeftMarginF        = 0.0
  lbres@lbRightMarginF       = 0.0
  lbres@lbTopMarginF         = 0.0

; Turn various features on and off.
  lbres@lbLabelsOn           = True
  lbres@lbPerimOn            = False
  lbres@lbTitleOn            = False
  lbres@lbMonoFillPattern    = True
;
; This specifies the proportion of the space in the direction
; perpendicular to the labelbar orientation that is occupied by the
; colorbar. By default it is 0.33, or 1/3 of the width specified by
; vpWidthF in the case of a vertically oriented labelbar.
;
  lbres@lbBoxMinorExtentF    = 1.0

  lbres@lbBoxLinesOn         = True    ; True is the default

  lbres@lbFillColors         = ispan(2,nboxes+1,1)

; Which point to position labelbar about.
  lbres@lbJustification      = "TopLeft"

  lbres@lbLabelAlignment     = "InteriorEdges"

  lbres@lbLabelJust          = "CenterLeft"
  lbres@lbLabelOffsetF       = 0.5

  lbres@lbLabelFontHeightF   = 0.015

  lbres@lbBoxEndCapStyle = "RectangleEnds"   ; the default
  lbid1 = gsn_create_labelbar_ndc(wks,nboxes,labels,lbar_x1,lbar_y1,lbres)

  lbres@lbBoxEndCapStyle = "TriangleLowEnd"
  lbid2 = gsn_create_labelbar_ndc(wks,nboxes,labels,lbar_x2,lbar_y2,lbres)

  lbres@lbBoxEndCapStyle = "TriangleHighEnd"
  lbid3 = gsn_create_labelbar_ndc(wks,nboxes,labels,lbar_x3,lbar_y3,lbres)

  lbres@lbBoxEndCapStyle = "TriangleBothEnds"
  lbid4 = gsn_create_labelbar_ndc(wks,nboxes,labels,lbar_x4,lbar_y4,lbres)

  draw(lbid1)
  draw(lbid2)
  draw(lbid3)
  draw(lbid4)

  frame(wks)
end
