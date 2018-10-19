;*****************************************************
; xy_19.ncl
;
; Concepts illustrated:
;   - Drawing an XY plot with three different Y axes
;   - Drawing a custom legend inside an XY plot
;   - Maximizing the size of several different objects on a frame
;   - Maximizing plots after they've been created
;*****************************************************
;
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
;*****************************************************
begin
; Create variables to contain data.
;
  ncurve = 3
  npts = 129

;
; Read ASCII file xy.asc
;
  x1_y3 = asciiread(ncargpath("data")+"/asc/xy.asc",4*129,"float")
;
;  xy.asc has 4 vars of length 129 longitudes, lon, u, v, t
;
;     The data is taken at 43N latitude.  Longitude is an index
;     1-129 standing for 0 deg - 360 deg in steps of 360/128?
;     u and v are in m/s, and t is in deg K.
;

  lon = (x1_y3(0:512:4) -1.) * 360./128.
  u   = x1_y3(1:513:4)
  v   = x1_y3(2:514:4)
  t   = (x1_y3(3:515:4) - 273.15) * 9./5. * 32.

  wks = gsn_open_wks("png","xy") ; send graphics to PNG file

  res1             = True
  res2             = True
  res3             = True

  res1@gsnMaximize = True
  res1@trXMaxF     = max(lon)    ; Control end of X axis

  plot = gsn_csm_xy3(wks,lon,t,u,v,res1,res2,res3)

  res1@xyLineColor = "red"       ; t
  res2@xyLineColor = "green"     ; u
  res3@xyLineColor = "blue"      ; v

  res1@tiYAxisString    = "t"
  res2@tiYAxisString    = "u"
  res3@tiYAxisString    = "v"

  res3@amOrthogonalPosF = 0.72   ; Move "v" axis line to right a little.

  plot = gsn_csm_xy3(wks,lon,t,u,v,res1,res2,res3)

;
; Set up resources for a customized legend.
;
  lgres                    = True
  lgres@lgLineColors       = (/"red","green","blue"/)
  lgres@lgItemType         = "Lines"        ; show lines only (default)
  lgres@lgLabelFontHeightF = .08            ; legend label font thickness
  lgres@vpWidthF           = 0.13           ; width of legend (NDC)
  lgres@vpHeightF          = 0.10           ; height of legend (NDC)
  lgres@lgPerimThicknessF  = 2.0            ; thicken the box perimeter
  lgres@lgMonoDashIndex    = True
  lgres@lgDashIndex        = 0

  labels = (/"t","u","v"/)
  nitems = dimsizes(labels)                 ; number of legend items

; Create legend
  lbid = gsn_create_legend(wks,nitems,labels,lgres)

;
; Use gsn_add_annotation to attach this legend to our existing plot.
; This way, if we resize the plot, the legend will stay with the
; plot and be resized automatically.
;
  amres                  = True

;
; Point (0,0) is the dead center of the plot. Point (0,.5) is center,
; flush bottom. Point (0.5,0.5) is flush bottom, flush right.
;
  amres@amJust           = "BottomRight"    ; Use bottom right corner of box
                                            ; for determining its location.
  amres@amParallelPosF   = 0.5              ; Move legend to right
  amres@amOrthogonalPosF = 0.5              ; Move legend down.

  annoid = gsn_add_annotation(plot,lbid,amres)  ; add legend to plot

;**********************************
; Now maximize the plot
;**********************************   
; Maximize these plots for PS or PDF output. If output is                    
; to an X11 window or an NCGM file, then this routine doesn't                
; do anything.                                                               
  
  psres = True                                                               
  maximize_output(wks,psres)  ; calls draw and frame for you 
end
