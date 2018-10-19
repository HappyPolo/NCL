;----------------------------------------------------------------------
;  lb_16_old.ncl
;----------------------------------------------------------------------
; Concepts illustrated:
;   - Drawing a custom labelbar with triangles at each end
;   - Changing the width and height of a labelbar
;   - Changing the font height of labelbar labels
;   - Setting the fill colors for a labelbar
;   - Setting the exact width of labelbar boxes
;   - Using "getvalues" to retrieve the size of a labelbar
;----------------------------------------------------------------------
; This script shows the old way of drawing triangles at the end of a
; labelbar. In NCL V6.4.0 a new lbBoxEndCapStyle resource was added
; to make this easier.
;----------------------------------------------------------------------;
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"


;----------------------------------------------------------------------
; This section modifies the labelbar to have triangles at each end.
;
; Note: this code is a bit messy. You can now use lbBoxEndCapStyle
; to more easily add triangles at the end of a labelbar.
;----------------------------------------------------------------------

undef("add_labelbar_triangles")
procedure add_labelbar_triangles(wks,labelbar_id,lw,lh)
local nboxes, box1_color, box2_color, orient, vpx, vpy, vph, vpw, colors, \
box1_lft, box1_rgt, box1_top, box1_bot, box2_lft, box2_rgt, box2_top, \
box2_bot, box_mid, gnres, gnres
begin
;---Get some information about the labelbar
  getvalues labelbar_id
    "vpXF"            : vpx
    "vpYF"            : vpy
    "vpWidthF"        : vpw
    "vpHeightF"       : vph
    "lbOrientation"   : orient
    "lbLabelPosition" : lpos       ; 0=top, 1=bottom, 2=right, 3=left
    "lbFillColors"    : colors
    "lbBoxLinesOn"    : box_lines_on
    "lbBoxLineColor"  : box_line_color
  end getvalues

  nboxes     = dimsizes(colors)
  box1_color = colors(0)
  box2_color = colors(nboxes-1)

;--- orient=0 => horizontal labelbar
  if(orient.eq.0) then  
;---Size of each box in the labelbar
    box_size = lw/nboxes
;---Get the NDC locations of the left box
    box1_lft = vpx
    box1_rgt = vpx + box_size
    box2_lft = vpx+lw - box_size
    box2_rgt = vpx+lw
    if(lpos.eq.1) then              ; 1=bottom 
      box1_top = vpy
      box1_bot = vpy-lh
      box_mid  = vpy-lh/2.          ; triangle point
    else                            ; 0=top
      box1_top = vpy-vph+lh
      box1_bot = vpy-vph
      box_mid  = vpy-vph+(lh/2.)    ; triangle point
    end if
;---Get the NDC locations of the right box
    box2_top = box1_top
    box2_bot = box1_bot
  else                              ; Vertical labelbar
;---Size of each box in the labelbar
    box_size = lh/nboxes
;---Get the NDC locations of the bottom box
    box1_bot = vpy-lh
    box1_top = vpy-lh + box_size
    box2_top = vpy
    box2_bot = vpy - box_size

    if(lpos.eq.2) then              ; 2=right
;---Get the NDC locations of the bottom box
      box_mid  = vpx + lw/2.    ; This is for the triangle
      box1_lft = vpx
      box1_rgt = vpx + lw
    else                            ; 3=left
      box_mid  = vpx + vpw - lw/2.    ; This is for the triangle
      box1_lft = vpx + vpw - lw
      box1_rgt = vpx + vpw
    end if
;---Get the NDC locations of the top box
    box2_lft = box1_lft
    box2_rgt = box1_rgt
  end if

;---Variable to hold resources for triangle colors.
  gnres = True

;---Draw the labelbar again
  draw(labelbar_id)

;---Fill-in the two end box rectangles in background color (white)
  gnres@gsFillColor = "white"
  gsn_polygon_ndc(wks,(/box1_lft,box1_rgt,box1_rgt,box1_lft,box1_lft/),\
                      (/box1_top,box1_top,box1_bot,box1_bot,box1_top/), \
                      gnres)
  gsn_polygon_ndc(wks,(/box2_lft,box2_rgt,box2_rgt,box2_lft,box2_lft/),\
                      (/box2_top,box2_top,box2_bot,box2_bot,box2_top/),\
                      gnres)

;---Draw the two triangles, both with fill and outlines.


;
; Fill the end boxes in white to mask them out. We have to be
; clever about this in order to get rid of the box outline too.
;
  gnres@gsFillColor      = "white"
  dlt = 0.01
  if(orient.eq.0) then     ; horizontal labelbar
;---Left box
    gsn_polygon_ndc(wks,(/box1_rgt,box1_lft-dlt,box1_lft-dlt,box1_rgt,box1_rgt/),\
                        (/box1_top+dlt,box1_top+dlt,box1_bot-dlt,box1_bot-dlt,box1_top/), \
                         gnres)
;---Right box
    gsn_polygon_ndc(wks,(/box2_lft,box2_rgt+dlt,box2_rgt+dlt,box2_lft,box2_lft/),\
                         (/box2_top+dlt,box2_top+dlt,box2_bot-dlt,box2_bot-dlt,box2_top+dlt/),\
                         gnres)
  else                     ; vertical labelbar
;---Bottom box
    gsn_polygon_ndc(wks,(/box1_lft-dlt,box1_lft-dlt,box1_rgt+dlt,box1_rgt+dlt,box1_lft/),\
                         (/box1_top,box1_bot-dlt,box1_bot-dlt,box1_top,box1_top/), \
                         gnres)
;---Top box
    gsn_polygon_ndc(wks,(/box2_lft-dlt,box2_lft-dlt,box2_rgt+dlt,box2_rgt+dlt,box2_lft-dlt/),\
                         (/box2_bot,box2_top+dlt,box2_top+dlt,box2_bot,box2_bot/),\
                         gnres)
  end if

;---Fill the trianges and draw the edges in black.
  gnres@gsEdgesOn   = True
  if(orient.eq.0) then     ; horizontal labelbar
;---Left triangle
    if(box_lines_on) then
      gnres@gsEdgeColor = box_line_color
    else
      gnres@gsEdgeColor = box1_color
    end if
    gnres@gsFillColor = box1_color
    gsn_polygon_ndc(wks,(/box1_rgt,box1_rgt,box1_lft,box1_rgt/), \
                        (/box1_top,box1_bot, box_mid,box1_top/),gnres)
;---Right triangle
    if(box_lines_on) then
      gnres@gsEdgeColor = box_line_color
    else
      gnres@gsEdgeColor = box2_color
    end if
    gnres@gsFillColor = box2_color
    gsn_polygon_ndc(wks,(/box2_lft,box2_lft,box2_rgt,box2_lft/), \
                        (/box2_top,box2_bot, box_mid,box2_top/),gnres)

  else                    ; vertical labelbar
;---Bottom triangle
    if(box_lines_on) then
      gnres@gsEdgeColor = box_line_color
    else
      gnres@gsEdgeColor = box1_color
    end if
    gnres@gsFillColor = box1_color
    gsn_polygon_ndc(wks,(/box1_lft,box1_rgt, box_mid,box1_lft/), \
                        (/box1_top,box1_top,box1_bot,box1_top/),gnres)

;---Top triangle
    if(box_lines_on) then
      gnres@gsEdgeColor = box_line_color
    else
      gnres@gsEdgeColor = box2_color
    end if
    gnres@gsFillColor = box2_color
    gsn_polygon_ndc(wks,(/box2_lft,box2_rgt, box_mid,box2_lft/), \
                        (/box2_bot,box2_bot,box2_top,box2_bot/),gnres)
  end if
end

;----------------------------------------------------------------------
; Main code
;----------------------------------------------------------------------

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
    lbar_x1 = 0.45
    lbar_y1 = 0.9
    lbar_x2 = 0.60
    lbar_y2 = 0.9
  else
    lbar_h  = 0.05
    lbar_w  = 0.8
    lbar_x1 = 0.1
    lbar_x2 = 0.1
    lbar_y1 = 0.60
    lbar_y2 = 0.45
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

  lbid1 = gsn_create_labelbar_ndc(wks,nboxes,labels,lbar_x1,lbar_y1,lbres)

  lbid2 = gsn_create_labelbar_ndc(wks,nboxes,labels,lbar_x2,lbar_y2,lbres)

  draw(lbid1)
  draw(lbid2)

;---Replace end boxes with triangles.
  add_labelbar_triangles(wks,lbid2,lbar_w,lbar_h)

  frame(wks)
end
