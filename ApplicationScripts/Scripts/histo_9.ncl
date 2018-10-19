;*************************************************
; histo_9.ncl
;
; Concepts illustrated:
;   - Overlaying a histogram on a cylindrical equidistant map
;   - Specifying the width and height of a histogram
;   - Turning off histogram tickmarks and labels
;   - Generating dummy data using "random_uniform"
;
;*************************************************
;
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"

begin
;
; Generate some random data for the histogram.
;
  x = random_normal(0.,5.,1000)
;
; Open a workstation and define a colormap.
; Change "x11" to "ps" if you want a PostScript file.
;
  wks = gsn_open_wks("png","histo") ; send graphics to PNG file
  gsn_define_colormap(wks,"temp1")
;
; Define map limits.
; 
  minlat   =  30.
  maxlat   =  90.
  minlon   = -90.
  maxlon   =  35.
;
; Start setting up map resources.
;
  mpres             = True
  mpres@gsnFrame    = False         ; Don't advance frame.
  mpres@gsnMaximize = True          ; Maximize plot in window.

  mpres@tiMainString = "This is a title"
;
; Set up map limits.
;
  mpres@mpMinLatF   = minlat
  mpres@mpMaxLatF   = maxlat
  mpres@mpMinLonF   = minlon
  mpres@mpMaxLonF   = maxlon
;
; Draw map, but don't advance frame.
;
  map = gsn_csm_map_ce(wks,mpres)

; 
; We need to calculate where to put the histogram in 
; terms of lat/lon coordinates, and then translate this
; to NDC (0 to 1) coordinates.
;
; Here, I'm assuming here that we want the histogram to be
; about 40 lat/lon degrees in height and width, and centered
; on the map.
;
   lon_width  = 40.      ; Width in lon degrees
   lat_height = 40.      ; Width in lat degrees
   startlon   = minlon + ((maxlon - minlon) - lon_width)/2.
   startlat   = minlat + ((maxlat - minlat) - lat_height)/2.
;
; Translate to NDC coordinates.
;
   xndc = new(2,float)   
   yndc = new(2,float)   
   datatondc(map,(/startlon,startlon+lon_width/), \
                 (/startlat,startlat+lat_height/),xndc,yndc)
;
; Set up some histogram resources.
;
  histres = True
;
; These next four resources control where the histogram is drawn,
; and how big it is.
;
  histres@vpXF      = xndc(0)
  histres@vpYF      = yndc(1)
  histres@vpWidthF  = xndc(1) - xndc(0)
  histres@vpHeightF = yndc(1) - yndc(0)

;
; Turn off X and Y tick marks and X/Y borders.
;
  histres@tmXBOn       = False
  histres@tmYROn       = False
  histres@tmYLOn       = False
  histres@tmXBBorderOn = False
  histres@tmXTBorderOn = False
  histres@tmYLBorderOn = False
  histres@tmYRBorderOn = False
;
; Turn off X axis label.
;
  histres@tiYAxisOn = False
;
; Draw histogram.
;
  histogram = gsn_histogram(wks,x,histres)

end
