;*************************************************
; tdpack_6.ncl
;************************************************
;
; This file is loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"

begin
;
; Set the desired minimum and maximum values of U, V, and W.
;
  umin = -1
  vmin = -1.
  wmin = -1.
  umax =  1.
  vmax =  1.
  wmax =  1.
;
; Set the desired values of parameters determining the eye position.
; ang1 is a bearing angle, ang2 is an elevation angle, and rmul is a
; multiplier of the length of the diagonal of the data box, specifying
; the distance from the center of the box to the eye.
;
  ang1 = -35.
  ang2 = 25.
  rmul = 2.9
;
; Define the number of points to be used in defining the curve.
;
  ncrv = 1001

;
; Define the conversion constant from degrees to radians.
;
  dtor = .017453292519943
;
; Define labels for the edges of the box.
;
  unlb = " -1 -.8 -.6 -.4 -.2 0 .2 .4 .6 .8 1 "
  vnlb = " -1 -.8 -.6 -.4 -.2 0 .2 .4 .6 .8 1 "
  wnlb = " -1 -.8 -.6 -.4 -.2 0 .2 .4 .6 .8 1 "

  uilb = "U Coordinate Values"
  vilb = "V Coordinate Values"
  wilb = "W Coordinate Values"
;
; Define the curve.
;
  ii   = ispan(0,ncrv-1,1)*1.
  xcrv = .75*cos(dtor*(ii/(ncrv-1))*720.)
  ycrv = .75*sin(dtor*(ii/(ncrv-1))*720.)
  zcrv = -.75+1.5*ii/(ncrv-1)
;
; Open workstation.
;
  wks = gsn_open_wks("png","tdpack")  ; send graphics to PNG file

;
; Use a 25-degree (instead of the default 20-degree) field of view.
;
  tdsetp ("FOV",25.)
;
; Make TDPACK characters a bit bigger.
;
  tdsetp ("cs1",1.25)
;
; Find the midpoint of the data box (to be used as the point looked at).
;
  umid = .5*(umin+umax)
  vmid = .5*(vmin+vmax)
  wmid = .5*(wmin+wmax)
;
; Determine the distance (R) from which the data box will be viewed and,
; given that, the eye position.
;
  r = rmul*sqrt((umax-umin)^2+(vmax-vmin)^2+(wmax-wmin)^2)

  ueye = umid+r*cos(dtor*ang1)*cos(dtor*ang2)
  veye = vmid+r*sin(dtor*ang1)*cos(dtor*ang2)
  weye = wmid+r*sin(dtor*ang2)
;
; Initialize TDPACK.
;
  tdinit ((/ueye,veye,weye/),(/umid,vmid,wmid/),(/umid,vmid,wmid+r/),0.)
;
; Draw labels for the axes.
;
  tdlbls (wks,(/umin,vmin,wmin/),(/umax,vmax,wmax/),(/unlb,vnlb,wnlb/), \
              (/uilb,vilb,wilb/),1)
;
; Draw the sides of the box that could be hidden.
;
  tdgrds (wks,(/umin,vmin,wmin/),(/umax,vmax,wmax/),(/.1*(umax-umin), \
                                                      .1*(vmax-vmin), \
                                                      .1*(wmax-wmin)/),12,1)
;
; Draw the curve in pieces, with an arrowhead on each one.
;
  do j=1,ncrv-1,100
;
; Compute the number of points on this piece.
;
    npts=min((/100,ncrv-j+1/))
    j1 = j-1
    j2 = j1 + npts
;
; Draw a curve.  The fourth argument says whether or not there is to be
; an arrowhead on the end of the curve and, if so, how many points are
; to be used in drawing its conical base (48, in the third case) and how
; many of those points are to be connected to the tip (12, in the third
; case).
;
;   tdcurv (wks,xcrv(j1:j2),ycrv(j1:j2),zcrv(j1:j2),0,.2,.1)
;   tdcurv (wks,xcrv(j1:j2),ycrv(j1:j2),zcrv(j1:j2),1,.2,.1)
;   tdcurv (wks,xcrv(j1:j2),ycrv(j1:j2),zcrv(j1:j2),12048,.2,.1)

    tdcurv (wks,xcrv(j1:j2),ycrv(j1:j2),zcrv(j1:j2),12048,.2,.1)
  end do
;
; Draw the sides of the box that could not be hidden.
;
  tdgrds (wks,(/umin,vmin,wmin/),(/umax,vmax,wmax/),(/.1*(umax-umin), \
                                                      .1*(vmax-vmin), \
                                                      .1*(wmax-wmin)/),12,0)
;
; Advance the frame.
;
  frame(wks)
end
