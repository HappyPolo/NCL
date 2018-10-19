;----------------------------------------------------------------------
; overlay_8.ncl
;
; Concepts illustrated:
;   - Overlaying an XY plot on a contour plot
;   - Drawing a scatter plot
;   - Generating dummy data using "random_uniform"
;   - Generating a bullseye pattern for contours
;----------------------------------------------------------------------
;
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"

begin
;---Generate dummy bullseye data for contour plot
  M    = 25
  ispn = conform_dims((/M,M/),ispan(-M/2,M/2,1)^2,1)
  jspn = conform_dims((/M,M/),ispan(-M/2,M/2,1)^2,0)
  T    = 100. - sqrt(64*(jspn + ispn))

;---Add coordinate arrays
  T!0 = "y"
  T!1 = "x"
  T&x = fspan(min(ispn),max(ispn),M)
  T&y = fspan(min(ispn),max(ispn),M)

;---Generate dummy data for XY plot
  x = random_uniform(floor(min(ispn)),ceil(max(ispn)),50)
  y = random_uniform(floor(min(ispn)),ceil(max(ispn)),50)

;---Start the graphics
  wks = gsn_open_wks("png","overlay") ; send graphics to PNG file

;---XY plot
  xyres                = True
  xyres@gsnDraw        = False      ; Will draw after overlay
  xyres@gsnFrame       = False

  xyres@xyMarkLineMode = "Markers"  ; Create a scatter plot
  xyres@xyMarker       = 16
  xyres@xyMarkerSizeF  = 9.0
  xyres@xyMarkerColor  = "black"    ;   the default

  plot_xy = gsn_csm_xy(wks,x,y,xyres)

;---Contour plot
  cnres               = True
  cnres@gsnMaximize   = True
  cnres@gsnDraw       = False      ; Will draw after overlay
  cnres@gsnFrame      = False

  cnres@cnFillOn      = True
  cnres@lbOrientation = "Vertical"

  cnres@tiMainString  = "Overlaying an XY plot on a contour plot"
  plot_contour = gsn_csm_contour(wks,T,cnres)

;---Overlay the plots.
  overlay(plot_contour,plot_xy)

;---Draw the "base" plot, which now contains both plots.
  draw(plot_contour)
  frame(wks)

end
