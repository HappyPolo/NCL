;----------------------------------------------------------------------
; newcolor_17.ncl
;
; Concepts illustrated:
;   - Showing features of the new color display model
;   - Drawing partially transparent filled contours
;   - Using transparency to show overlap of positive and negative contours
;   - Overlaying filled contours on filled contours with transparency
;   - Changing the contour line thickness
;   - Drawing positive and negative contours in different colors
;----------------------------------------------------------------------
; NOTE: This example will only work with NCL V6.1.0 and later.
;----------------------------------------------------------------------
;
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
;***********************************************************************;
; This function returns the RGBA triplets associated with a 
; given list of named colors.  The "A" value is always returned 
; as the value of 1.0. This function basically calls namedcolor2rgb and
; adds the "A" value.
; 
; A n x 4 array is returned, where "n" is the number of 
; named colors input.
;
; If a color is not found, missing values are returned for 
; that color.
;
; This function will be in Version 6.2.0 of NCL
;***********************************************************************;
undef("namedcolor2rgba")
function namedcolor2rgba(names[*]:string)
local rgb_array, rgba_array
begin
  rgb_array  = namedcolor2rgb(names)
  ncolors    = dimsizes(rgb_array(:,0))
  rgba_array = new((/ncolors,4/),typeof(rgb_array))
  rgba_array(:,0:2) = rgb_array
  rgba_array(:,3) = where(.not.ismissing(rgb_array(:,2)),1.0,\
                           rgba_array@_FillValue)
  return(rgba_array)
end

;----------------------------------------------------------------------
; Main code
;----------------------------------------------------------------------
begin
;---Generate some dummy data with positive and negative values
  data1  = generate_2d_array(11, 6,-10,10,5,(/50,50/))
  data2  = generate_2d_array( 5,15,-10,10,5,(/50,50/))

;---Start the graphics
  wks = gsn_open_wks("png","newcolor")  ; send graphics to PNG file

;---Set some plot options
  res                     = True

  res@gsnDraw             = False       ; Don't draw plots or advance
  res@gsnFrame            = False       ; frame (need to overlay later)

  res@cnFillOn            = True        ; Turn on contour fill
  res@cnInfoLabelOn       = False       ; Turn off info label
  res@cnLineLabelsOn      = False       ; Turn off line labels
  res@lbLabelBarOn        = False       ; Will draw in panel later

;---Add contour lines so we can see where they overlap
  res@cnLineThicknessF    = 3.0
  res@cnLineDrawOrder     = "PostDraw"

;---Only two contour levels: negative (< 0) and positive (> 0)
  res@cnLevelSelectionMode = "ExplicitLevels"
  res@cnLevels             = 0.0

;
; Create two contour fill colors: slate blue and white. 
; Make them both fully opaque (=1.0).
; 
  sblue = namedcolor2rgba("slateblue")
  res@cnFillColors         = (/sblue(0,:),(/1.,1.,1.,1./)/)

;---Create two identical plots. One will be used for the base of the overlay.
  res@cnLineColor          = "yellow"
  res@tiMainString         = "Plot1"
  orig_plot1 = gsn_csm_contour(wks,data1,res)

  res@tiMainString         = "Plot2 overlaid on Plot1"
  ovly_plot1 = gsn_csm_contour(wks,data1,res)

;
; Use the same contour fill colors, except make white fully transparent.
; This means that you will see slate blue at locations where one or
; both plots have overlapping negative contours, and white at
; locations where both plots have overlapping positive contours.
;
  res@cnFillColors         = (/sblue(0,:),(/1.,1.,1.,0./)/)

;---Again, create two duplicate plots, one for overlaying.
  res@cnLineColor          = "orange"
  res@tiMainString         = "Plot2"
  orig_plot2 = gsn_csm_contour(wks,data2,res)
  ovly_plot2 = gsn_csm_contour(wks,data2,res)

;---Overlay plot2 on plot1.  Nothing gets drawn here.
  overlay(ovly_plot1,ovly_plot2)

;---Draw the two original plots and overlay plot on one page.
  pres                  = True
  pres@gsnMaximize      = True
  pres@gsnPanelLabelBar = True
  gsn_panel(wks,(/orig_plot1,orig_plot2,ovly_plot1/),(/1,3/),pres)
end
