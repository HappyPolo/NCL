;----------------------------------------------------------------------
;  lb_19.ncl
;----------------------------------------------------------------------
; Concepts illustrated:
;   - Recreating a labelbar from scratch based on an existing contour plot
;   - Using "setvalues" to set resource values
;   - Using "getvalues" to retrieve resource values
;----------------------------------------------------------------------
;
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"


;----------------------------------------------------------------------
; This procedure recreates a labelbar associated with the given
; contour plot, and then draws the original plot without the
; labelbar, and the reconstructed labelbar on a page by itself.
;----------------------------------------------------------------------
undef("contour_labelbar")
procedure contour_labelbar(wks,plot)
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
        print("contour_labelbar: Error: can't determine type of plot")
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
    print("contour_labelbar: Error: Couldn't extract labelbar associated with this plot")
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
    print("contour_labelbar: Error: Couldn't extract labelbar associated with this plot")
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
    "lbPerimOn"            : perim_on
    "lbTitleOn"            : title_on
    "lbMonoFillPattern"    : mono_fill_pattern
    "lbBoxLinesOn"         : box_lines_on
    "lbLabelsOn"           : labels_on
  end getvalues

;
; Set some labelbar resources. Note: Not every single 
; labelbar resource is retrieved and set here. If the
; labelbar is not being recreated properly, then you
; may need to add some more resources to the "getvalues"
; block above, and then set them below.
;
  lbres                      = True

;---Set width and height of labelbar itself
  lbres@vpHeightF            = lbar_h
  lbres@vpWidthF             = lbar_w


; Allow more control over labelbars.
  lbres@lbAutoManage         = False

  lbres@lbOrientation        = lbar_orient
  lbres@lbLabelPosition      = lbar_side
  lbres@lbLabelFontHeightF   = lbar_fh

; Turn various features on and off.
  lbres@lbLabelsOn           = labels_on
  lbres@lbPerimOn            = perim_on
  lbres@lbTitleOn            = title_on
  lbres@lbMonoFillPattern    = mono_fill_pattern
  lbres@lbBoxLinesOn         = box_lines_on
  lbres@lbFillColors         = lbar_colors

; Which point to position labelbar about.
  lbres@lbJustification      = lbar_just
  lbres@lbLabelAlignment     = lbar_aln
  lbres@lbLabelJust          = lbar_ljust

  lbres@lbLabelAutoStride    = True        ; NO LONGER NEEDED IN V6.1.0 

;---Regenerate the labelbar
  nboxes = dimsizes(lbar_colors)
  lbid = gsn_create_labelbar_ndc(wks,nboxes,lbar_labels,lbar_x,lbar_y,lbres)

;---Turn off the current labelbar so we can draw the one we just regenerated.
  setvalues views(0)
    "lbLabelBarOn" : False
  end setvalues

;
; Draw just the labelbar. It should be in the same place as if it
; had been drawn with the plot.
;
  setvalues plot
    "tiMainString" : "Plot without labelbar"
  end setvalues

  draw(plot)
  frame(wks)

  draw(lbid)
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

  nsub = maxind(ind(icemon&hlat.le.0))  ; Subscript location of northernmost hlat to be plotted.

  wks = gsn_open_wks("ps","lb") ; send graphics to PS file

  res                     = True
  res@gsnMaximize         = True
  res@gsnPaperOrientation = "Portrait"

  res@cnFillOn          = True
  res@tiMainFontHeightF = 0.025
  res@tiMainString      = "Plot with labelbar"
;
; Create a stereographic map with an elliptical boundary and
; change the center of the projection.
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

;---Create and draw contours over a map. A labelbar should also be drawn.
  map = gsn_csm_contour_map(wks,icemon(0:nsub,:),res)

;---Reconstruct the labelbar and draw the plot and it on separate pages.
  contour_labelbar(wks,map)
end
