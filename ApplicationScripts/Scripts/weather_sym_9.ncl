;****************************************
; weather_sym_9.ncl
;
; Concepts illustrated:
;   - Drawing vectors
;   - Setting parameters for weather routines
;   - Drawing orthographic maps
;****************************************
;
; This file is loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"

begin
  cmap = (/               \
           (/1.,1.,1./),  \
           (/0.,0.,0./),  \
           (/1.,0.,0./),  \
           (/0.,1.,0./),  \
           (/0.,0.,1./),  \
           (/0.,0.,0./),  \
           (/0.,1.,1./),  \
           (/1.,0.,1./)   \
         /)
  wks = gsn_open_wks("png","weather_sym")  ; send graphics to PNG file
  gsn_define_colormap(wks,cmap)

;
;  Draw an orthographic map centered at lat/lon = (70.,-10.).
;  Don't advance the frame, since we want to add wind barbs.
;
  mpres              = True
  mpres@gsnFrame     = False
  mpres@mpLimitMode  = "Corners"
  mpres@mpLeftCornerLatF  =  55.
  mpres@mpLeftCornerLonF  = -50.
  mpres@mpRightCornerLatF =  85.
  mpres@mpRightCornerLonF = -20.
  mpres@mpCenterLatF =  70.
  mpres@mpCenterLonF = -10.
  mpres@mpPerimOn = True
  mpres@vpHeightF = 1.
  mpres@vpWidthF  = 1.
  mpres@vpXF = 0.
  mpres@vpYF = 1.
  mpres@mpGridSpacingF = 10.

  map = gsn_map(wks,"Orthographic",mpres)

;
;  Establish the relationship between a reference vector and
;  the length in NDC space of such a vector on the plot.
;  Here, a vector of length 40. in user space with be 0.08 
;  NDC units on the plot.
;
  wmsetp("vrs - size of reference vector in user space", 40.)
  wmsetp("vrn - size of reference vector on plot in NDC space", 0.08)

;
;  Draw vectors with a common base along different directions.
;
  wmsetp("vcw - linewidth scale",3.)
  wmsetp("vcc - vector color",2)
  wmvectmap(wks, 70., -40.,  0., 80.)
  wmsetp("vcc - vector color",3)
  wmvectmap(wks, 70., -40., 80., 80.)
  wmsetp("vcc - vector color",4)
  wmvectmap(wks, 70., -40., 80.,  0.)
  wmsetp("vcc - vector color",5)
  wmvectmap(wks, 70., -40.,-80.,  0.)
  wmsetp("vcc - vector color",6)
  wmvectmap(wks, 70., -40.,  0.,-80.)
  wmsetp("vcc - vector color",7)
  wmvectmap(wks, 70., -40.,-80.,-80.)

;
;  Draw label box
;
  wmvlbl(wks,0.95,0.)

  frame(wks)          ; Advance the frame.
end
