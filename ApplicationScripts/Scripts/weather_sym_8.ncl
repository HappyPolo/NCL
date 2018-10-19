;******************************************
; weather_sym_8.ncl
;
; Concepts illustrated:
;   - Drawing vectors
;   - Drawing arrows
;   - Using "hsvrgb" to create a color map
;   - Setting parameters for weather routines
;******************************************
;
; This file is loaded by default in NCL V6.2.0 and newer
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"

begin

  d2r = 0.0174532925
;
;  Set up color map array with gray as the background color
;  and going around the color hues for the rest.
;
  cmap = new((/37,3/),float)
  cmap(0,:) = (/0.3,0.4,0.5/)
  do i=1,36
    cmap(i,:) = hsvrgb((/(i+24)*10,1.,1./))
  end do

  wks = gsn_open_wks("png","weather_sym")  ; send graphics to PNG file
  gsn_define_colormap(wks,cmap)

  kount = 1
;     
; Set up some vector control parameter values.
;
  wmsetp("vrs - reference vector size",1.)
  wmsetp("vrn - NDC size corresponding to vrs",0.275)
  wmsetp("vcw - vector line width scale",3.)
;
;  Draw vectors radiating from a point having different colors
;  and vector arrow head sizes.
;
  do i=0,350,10
    u = cos(i*d2r)
    v = sin(i*d2r)
    wmsetp("vcc - vector color",kount)
    wmsetp("vch - arrow head size",(0.025/350.)*i+0.01)
;
;  Draw vector.
;
    wmvect(wks, 0.375, 0.4, u, v)
    kount = kount+1
  end do
;
;  Draw some vectors with different angles between the
;  arrow head and the tail, with different vector line widths,
;  and with different sizes.
;
  rr = 0.325
  do i=0,9
    alpha = i*d2r*10.
    x = rr*cos(alpha) + 0.375
    y = rr*sin(alpha) + 0.4
    wmsetp("vcw - width scale factor",i+1.)
    wmsetp("vva - angle between arrow head and tail",40.-3.*i)
    wmsetp("vcc - color index",i+1)
;
;  Size scale factor.
;
    rscale = 3.5-0.4*abs((4.-i))
    wmvect(wks,x,y,rscale*rr*cos(alpha),rscale*rr*sin(alpha))
  end do

;
;  Plot a vector label box at lower right.
;
  wmsetp("vlf - vector label foreground color index",1)
  wmvlbl(wks,1.,0.)

  frame(wks)          ; Advance the frame.
end
