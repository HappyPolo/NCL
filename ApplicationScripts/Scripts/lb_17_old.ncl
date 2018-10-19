;----------------------------------------------------------------------
;  lb_17_old.ncl
;----------------------------------------------------------------------
; This script shows the old way of drawing triangles at the end of a
; labelbar. In NCL V6.4.0 a new lbBoxEndCapStyle resource was added
; to make this easier.
;----------------------------------------------------------------------;
; Concepts illustrated:
;   - Drawing a custom labelbar with triangles at each end
;   - Recreating a labelbar from scratch
;   - Using "setvalues" to set resource values
;   - Using "getvalues" to retrieve resource values
;----------------------------------------------------------------------
;
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"

;----------------------------------------------------------------------
; This procedure modifies the labelbar to replaced the end boxes with
; triangles.
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
    "vpXF"              : vpx
    "vpYF"              : vpy
    "vpWidthF"          : vpw
    "vpHeightF"         : vph
    "lbOrientation"     : orient
    "lbLabelPosition"   : lpos       ; 0=top, 1=bottom, 2=right, 3=left
    "lbFillColors"      : colors
    "lbBoxLinesOn"      : box_lines_on
    "lbBoxLineColor"    : box_line_color
    "lbBoxMinorExtentF" : mnr_ext
    "lbBoxMajorExtentF" : mjr_ext
    "lbBottomMarginF"   : lbar_bot
    "lbTopMarginF"      : lbar_top
    "lbRightMarginF"    : lbar_rgt
    "lbLeftMarginF"     : lbar_lft
    "lbMaxLabelLenF"    : lbar_llen
    "lbLabelOffsetF"    : lbar_loff
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
; This procedure recreates the labelbar associated with the given
; plot so it can replace the end boxes with triangles.
;----------------------------------------------------------------------
undef("labelbar_w_tri_ends")
procedure labelbar_w_tri_ends(wks,plot)
local views, lbres, just_strs, lbar_x, lbar_y, lbar_h, lbar_w, \
  lbar_orient, lbar_side, lbar_colors, lbar_labels, lbar_frac, lbar_ext, \
  lbar_bot, lbar_top, lbar_rgt, lbar_lft, lbar_fh, lbar_aln, lbar_ljust, \
  lbar_just, lbar_mnr, lbar_mjr, lbar_loff , lbid, nboxes, class_name, \
  labebar_object
begin
;
; This code attemps to see what kind of plot we have and
; to extract the labelbar from it.
;
  class_name = NhlClassName(plot)
  if(class_name.eq."mapPlotClass") then
    if(isatt(plot,"contour")) then
      getvalues plot@contour
        "pmAnnoViews" : views
      end getvalues
    else
      if(isatt(plot,"vector")) then
        getvalues plot@vector
          "pmAnnoViews" : views
        end getvalues
      else
        print("labelbar_w_tri_ends: Error: can't determine type of plot")
        return
      end if
    end if
  else
    getvalues plot
      "pmAnnoViews" : views
   end getvalues
  end if

;---Error checking
  if(all(ismissing(views))) then
    print("labelbar_w_tri_ends: Error: Couldn't extract labelbar associated with this plot")
    return
  end if

;---Attempt to extract labelbar
  labelbar_object = new(1,graphic)
  do i=0,dimsizes(views)-1
    if(NhlClassName(views(i)).eq."labelBarClass")  then
      labelbar_obj = views(i)
    end if
  end do

;---Error checking
  if(ismissing(labelbar_obj)) then
    print("labelbar_w_tri_ends: Error: Couldn't extract labelbar associated with this plot")
    return
  end if

;---Retrieve labelbar resources associated with plot so we can regenerate it.
  getvalues labelbar_obj
    "vpXF"                 : lbar_x
    "vpYF"                 : lbar_y
    "vpHeightF"            : lbar_h
    "vpWidthF"             : lbar_w
    "lbOrientation"        : lbar_orient
    "lbLabelPosition"      : lbar_side
    "lbFillColors"         : lbar_colors
    "lbLabelStrings"       : lbar_labels
    "lbBoxFractions"       : lbar_frac
    "lbBoxMinorExtentF"    : lbar_ext
    "lbBottomMarginF"      : lbar_bot
    "lbTopMarginF"         : lbar_top
    "lbRightMarginF"       : lbar_rgt
    "lbLeftMarginF"        : lbar_lft
    "lbLabelFontHeightF"   : lbar_fh
    "lbLabelAlignment"     : lbar_aln
    "lbLabelJust"          : lbar_ljust
    "lbJustification"      : lbar_just
    "lbBoxMinorExtentF"    : lbar_mnr
    "lbBoxMajorExtentF"    : lbar_mjr
    "lbLabelOffsetF"       : lbar_loff
  end getvalues

;
; We are going to set lbMinorExtentF to 1.0 so we know exactly where the
; labelbar boxes start and end on the frame. This means that we need to
; recalculate the width or height, depending on whether we have a vertical
; or horizontal labelbar.
;

;--- lbar_orient=0 => horizontal labelbar
  if(lbar_orient.eq.0) then  
    lbar_h = lbar_h * lbar_mnr
    lbar_y = lbar_y - 0.07
  else 
    lbar_w = lbar_w * lbar_mnr
    lbar_x = lbar_x + 0.02
  end if

;---Set some labelbar resources
  lbres                      = True

; Set initial width and height.

  lbres@vpHeightF            = lbar_h
  lbres@vpWidthF             = lbar_w

  lbres@lbLabelFontHeightF   = lbar_fh

; Allow more control over labelbars.
  lbres@lbAutoManage         = False

  lbres@lbOrientation        = lbar_orient
  lbres@lbLabelPosition      = lbar_side

; No margins around labelbar.
  lbres@lbBottomMarginF      = 0.0 ; lbar_bot
  lbres@lbLeftMarginF        = 0.0 ; lbar_lft
  lbres@lbRightMarginF       = 0.0 ; lbar_rgt
  lbres@lbTopMarginF         = 0.0 ; lbar_top

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
  lbres@lbBoxMinorExtentF    = 1.0       ; lbar_mnr
  lbres@lbBoxMajorExtentF    = lbar_mjr

  lbres@lbBoxLinesOn         = True    ; True is the default

  lbres@lbFillColors         = lbar_colors

; Which point to position labelbar about.
  lbres@lbJustification      = lbar_just
  lbres@lbLabelAlignment     = lbar_aln
  lbres@lbLabelJust          = lbar_ljust

  lbres@lbLabelOffsetF       = lbar_loff + 0.3

;---Regenerate the labelbar
  nboxes = dimsizes(lbar_colors)
  lbid = gsn_create_labelbar_ndc(wks,nboxes,lbar_labels,lbar_x,lbar_y,lbres)

;---Turn off the current labelbar so we can draw the one we just regenerated.
  setvalues views(0)
    "lbLabelBarOn" : False
  end setvalues

;
; Draw plot, draw new labelbar, and then draw triangles
; over the end labelbar boxes.
;
  draw(plot)
  draw(lbid)
  add_labelbar_triangles(wks,lbid,lbar_w,lbar_h)

  frame(wks)
end

;----------------------------------------------------------------------
; Main code
;----------------------------------------------------------------------

begin
  filen = ncargpath("data") + "/cdf/fice.nc"
  f     = addfile(filen,"r")

  fice = f->fice       ; Read fice -- ice concentration
                       ; Calculate the January (nmo=0) average.
  nmo    = 0
  icemon = dim_avg_n_Wrap(fice(nmo::12,:,:),0)
  icemon = where(icemon.eq.0., icemon@_FillValue,icemon)      ; Set 0.0 to _FillValue.
  wks = gsn_open_wks("png","lb") ; send graphics to PNG file

  res                   = True
  res@gsnMaximize       = True
  res@cnFillOn          = True
  res@cnFillPalette     = "cosam12"
  res@tiMainFontHeightF = 0.025
;
; Create a stereographic map with an elliptical boundary and change
; the center of the projection.
;
  res@mpProjection                = "Stereographic"
  res@mpEllipticalBoundary        = True
  res@mpCenterLatF                = -90.
  res@mpLimitMode                 = "Angles"
  res@mpBottomAngleF              = 40.
  res@mpLeftAngleF                = 40.
  res@mpRightAngleF               = 40.
  res@mpTopAngleF                 = 40.
  res@mpFillOn                    = False
  res@mpGeophysicalLineColor      = "gray"
  res@mpLandFillColor             = "gray"

  res@lbOrientation               = "Vertical"

  res@tiMainString                = "Default labelbar"

  nsub = maxind(ind(icemon&hlat.le.0))  ; Subscript location of northernmost hlat to be plotted.
  map = gsn_csm_contour_map(wks,icemon(0:nsub,:),res)

;---Redraw plot with labelbar w/triangular ends
  res@gsnDraw              = False
  res@gsnFrame             = False
  res@tiMainString         = "Labelbar with triangular ends"
  map = gsn_csm_contour_map(wks,icemon(0:nsub,:),res)

  labelbar_w_tri_ends(wks,map)

end
