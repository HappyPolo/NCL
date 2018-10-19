;*************************************************
; tdpack_4.ncl
;************************************************
;
; This file is loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"

begin
;
; Create parameters specifying the maximum sizes of the arrays defining
; data and the arrays required for dealing with the list of triangles.
;
  imax = 31
  jmax = 31
  kmax = 31
  mtri = 200000

;
; Declare a local array to hold the triangle list and a couple of
; temporary variables to be used in sorting the list.
;
  rtri = new((/mtri,10/),float)
  rtwk = new((/2,mtri/),float)
;
; Set the desired minimum and maximum values of U, V, and W.
;
  umin = -1.
  vmin = -1.
  wmin = -1.
  umax =  1.
  vmax =  1.
  wmax =  1.

;
; Set the desired values of the dimensions of the data arrays.  Note
; that IDIM must not exceed IMAX, that JDIM must not exceed JMAX, and
; that KDIM must not exceed KMAX.
;
  idim = 31
  jdim = 31
  kdim = 31

;
; Set the desired values of parameters determining the eye position.
; ANG1 is a bearing angle, ANG2 is an elevation angle, and RMUL is a
; multiplier of the length of the diagonal of the data box, specifying
; the distance from the center of the box to the eye.
;
  ang1 = -35.
  ang2 =  25.
  rmul =   2.9
;
; Set the desired value of the flag that says whether the basic color
; scheme will be white on black (IBOW=0) or black on white (IBOW=1).
;
  ibow = 1
;
; Set the desired value of the flag that says whether shading of the
; surfaces will be done using gray scales (ICLR=0) or colors (ICLR=1).
;
  iclr = 1
;
; Set the desired values of the shading parameters.  Values of SHDE
; near 0 give brighter colors and values near 1 give pastel shades.
; Values of SHDR near 0 give a narrow range of shades and values near
; 1 give a wide range of shades.
;
  shde = 0.1
  shdr = 0.8
;
; Set the desired values of the rendering-style indices for the
; isosurface and the simple surface, respectively.
;
  iirs = 2
  isrs = 3
;
; Define the conversion constant from degrees to radians.
;
  dtor = 0.017453292519943
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
; Open a workstation
;
  wks = gsn_open_wks("png","tdpack")   ; send graphics to PNG file

  tdclrs (wks,ibow,shde,shdr,11,42,4)
;
; Fill data arrays defining a simple surface and an isosurface.  The
; simple surface is defined by the equation "w=s(u,v)"; the function
; "s" is approximated by the contents of the array S: S(I,J) is the
; value of s(U(I),V(J)), where I goes from 1 to IDIM and J from 1 to
; JDIM.  The isosurface is defined by the equation f(u,v,w)=1.; the
; function f is approximated by the contents of the array F: F(I,J,K)
; is the value of f(U(I),V(J),W(K)), where I goes from 1 to IDIM, J
; from 1 to JDIM, and K from 1 to KDIM.
;
;
; Define data for a simple surface.
;
  u = umin + (1.*ispan(0,idim-1,1)/(idim-1)) * (umax - umin)
  v = vmin + (1.*ispan(0,jdim-1,1)/(jdim-1)) * (vmax - vmin)
  w = wmin + (1.*ispan(0,kdim-1,1)/(kdim-1)) * (wmax - wmin)
  s = new((/jmax,imax/),float)
  f = new((/kmax,jmax,imax/),float)

  s(0:jdim-1,0:idim-1) = 2.*exp(-2.*(conform(s(0:jdim-1,0:idim-1),u,1)^2+ \
                                     conform(s(0:jdim-1,0:idim-1),v,0)^2))-1.
  f(0:kdim-1,0:jdim-1,0:idim-1) = \
                           1.25*conform(f(0:kdim-1,0:jdim-1,0:idim-1),u,2)^2+ \
                           1.25*conform(f(0:kdim-1,0:jdim-1,0:idim-1),v,1)^2+ \
                             5.*conform(f(0:kdim-1,0:jdim-1,0:idim-1),w,0)^2
;
; Select font number 25, turn on the outlining of filled fonts, set the
; line width to 1, and turn off the setting of the outline color.
;
  pcsetp ("FN - FONT NUMBER",25)
  pcsetp ("OF - OUTLINE FLAG",1)
  pcsetp ("OL - OUTLINE LINE WIDTH",1.)
  pcsetp ("OC - OUTLINE LINE COLOR",-1.)
;
; Make TDPACK characters a bit bigger.
;
  tdsetp ("cs1",1.25)
;
; Define TDPACK rendering styles 1 through 7, using black-and-white
; shading or colored shading, whichever is selected.  The indices
; 1-7 can then be used as arguments in calls to TDITRI, TDSTRI, and
; TDMTRI.
;
  if (iclr.eq.0) then
;
; Rendering styles 1-7 are all gray on both sides:
;
    tdstrs (1,43,74, 43, 74,-1,-1,1,0.,0.,0.)
    tdstrs (2,43,74, 43, 74,-1,-1,1,0.,0.,0.)
    tdstrs (3,43,74, 43, 74,-1,-1,1,0.,0.,0.)
    tdstrs (4,43,74, 43, 74,-1,-1,1,0.,0.,0.)
    tdstrs (5,43,74, 43, 74,-1,-1,1,0.,0.,0.)
    tdstrs (6,43,74, 43, 74,-1,-1,1,0.,0.,0.)
    tdstrs (7,43,74, 43, 74,-1,-1,1,0.,0.,0.)
  else
    tdstrs (1,43,74, 43, 74,-1,-1,1,0.,0.,0.)
    tdstrs (2,43,74, 75,106,-1,-1,1,0.,0.,0.)
    tdstrs (3,43,74,107,138,-1,-1,1,0.,0.,0.)
    tdstrs (4,43,74,139,170,-1,-1,1,0.,0.,0.)
    tdstrs (5,43,74,171,202,-1,-1,1,0.,0.,0.)
    tdstrs (6,43,74,203,234,-1,-1,1,0.,0.,0.)
    tdstrs (7,43,74,235,266,-1,-1,1,0.,0.,0.)
  end if
;
; Initialize the count of triangles in the triangle list.
;
  ntri = 0
;
; Add to the triangle list triangles representing a simple surface.
;
  tdstri (u,v,s,rtri,ntri,isrs)

  if (ntri.eq.mtri) then
    print("Triangle list overflow in tdstri.")
    exit
  end if
;
; Add to the triangle list triangles representing an isosurface.
;
  tditri (u,v,w,f,1.,rtri,ntri,iirs)

  if (ntri.eq.mtri) then
    print ("Triangle list overflow in tditri.")
    exit
  end if
;
; Find the midpoint of the data box (to be used as the point looked at).
;
  umid=.5*(umin+umax)
  vmid=.5*(vmin+vmax)
  wmid=.5*(wmin+wmax)
;
; Determine the distance (R) from which the data box will be viewed and,
; given that, the eye position.
;
  r=rmul*sqrt((umax-umin)^2+(vmax-vmin)^2+(wmax-wmin)^2)

  ueye=umid+r*cos(dtor*ang1)*cos(dtor*ang2)
  veye=vmid+r*sin(dtor*ang1)*cos(dtor*ang2)
  weye=wmid+r*sin(dtor*ang2)
;
; Initialize the stereo offset argument to do a single view.
;
  otep=0.
;
; Initialize TDPACK.
;
  tdinit ((/ueye,veye,weye/),(/umid,vmid,wmid/), \
          (/umid,vmid,wmid+r/),otep)
;
; Order the triangles in the triangle list.
;
  itwk = tdotri (rtri,ntri,rtwk,1)

  if (ntri.eq.mtri) then
    print ("Triangle list overflow in tdotri.")
    exit
  end if
;
; Draw labels for the axes.
;
  tdlbls (wks,(/umin,vmin,wmin/),(/umax,vmax,wmax/), \
          (/unlb,vnlb,wnlb/),(/uilb,vilb,wilb/),1)
;
; Draw the sides of the box that could be hidden.
;
  tdgrds (wks,(/umin,vmin,wmin/),(/umax,vmax,wmax/), \
         (/.1*(umax-umin),.1*(vmax-vmin),.1*(wmax-wmin)/), 12,1)
;
; Draw the triangles in the triangle list.
;
  tddtri (wks,rtri,ntri,itwk)
;
; Draw the sides of the box that could not be hidden.
;
  tdgrds (wks,(/umin,vmin,wmin/),(/umax,vmax,wmax/), \
           (/.1*(umax-umin),.1*(vmax-vmin),.1*(wmax-wmin)/), 12,0)

  frame(wks)
end
