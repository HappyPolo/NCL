;*************************************************
; tdpack_5.ncl
;************************************************
;
; This file is loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"

begin
;
; Declare the size of the triangle array.
;
  mtri = 100000
;
; Read in the triangle list. (In the Fortran version of this program,
; the triangles are calculated. Here we just read them from a file.)
;
  rtri = fbinrecread("tdpack5.bin",0,(/mtri,10/),"float")

;
; Define a couple of temporary variables to be used in sorting the list.
;
  rtwk = new((/2,mtri/),float)
;
; Define the positions of the eye.
;
  eye = (/ 6.0, 5.0, 2.5 /)

;
; WOSW is the width of each stereo window, as a fraction of the width of
; the plotter frame.
;
  wosw = 0.55
;
; Set a flag that says how to set the position of the light source:
; IPLS=0 implies a light source at the position of the observer; IPLS=1
; implies a light source at the position of the sun; IPLS=2 implies a
; light source 90 degrees of longitude away from the sun and on the
; equator.
;
  ipls = 2
;
; Set the default value of the flag that says whether the basic color
; scheme will be white on black (IBOW=0) or black on white (IBOW=1).
;
  ibow = 1
;
; Set the desired value of the flag that says whether shading of the
; surfaces will be done using gray scales (ICLR=0) or colors (ICLR=1).
;
  iclr = 1
;
; Define default values of the shading parameters.  Use SHDE near 0
; for brighter colors and SHDE near 1 for pastel shades.  Use SHDR
; near 0 for a small range of shades and SHDR near 1 for a full range
; of shades.
;
  shde = 0.01
  shdr = 0.99

;
; Define the latitude and longitude of the sun.
;
  slat = 25.
  slon = 80.

;
; Define the conversion constant from degrees to radians.
;
  dtor = 0.017453292519943

;
; Compute the position on the surface of the globe where the sun is
; directly overhead.  (This seems to be a good position to look at.)
;
  uaim = .5+.5*cos(.017453292519943*slat)*cos(.017453292519943*slon)
  vaim = .5+.5*cos(.017453292519943*slat)*sin(.017453292519943*slon)
  waim = .5+.5*sin(.017453292519943*slat)

;
; Determine where the light source is.
;
  if (ipls.eq.0) then
    tdsetp ("LSU",0.)
    tdsetp ("LSV",0.)
    tdsetp ("LSW",0.)
  else
    if (ipls.eq.1) then
      tdsetp ("LSU",.5+1000.*cos(dtor*slat)*cos(dtor*slon))
      tdsetp ("LSV",.5+1000.*cos(dtor*slat)*sin(dtor*slon))
      tdsetp ("LSW",.5+1000.*sin(dtor*slat)               )
    else
      qlat = 0.
      qlon = slon-90.
      tdsetp ("LSU",.5+1000.*cos(dtor*qlat)*cos(dtor*qlon))
      tdsetp ("lsv",.5+1000.*cos(dtor*qlat)*sin(dtor*qlon))
      tdsetp ("lsw",.5+1000.*sin(dtor*qlat)               )
    end if
  end if
;
; Set the shading flag.
;
  tdsetp ("SHD",1)

;
; Open a workstation
;
  wks = gsn_open_wks("png","tdpack")   ; send graphics to PNG file

;
; Define colors to use.
;
  tdclrs (wks,ibow,shde,shdr,11,42,7)

;
; Define TDPACK rendering styles 1, 2, and 3, using black-and-white
; shading or colored shading, whichever is selected.
;
  if (iclr.eq.0) then
    tdstrs (1,43,74, 43, 74,-1,-1,1,0.,0.,0.)
    tdstrs (2,43,74, 43, 74,-1,-1,1,0.,0.,0.)
    tdstrs (3,43,74, 43, 74,-1,-1,1,0.,0.,0.)
    tdstrs (4,43,74, 43, 74,-1,-1,1,0.,0.,0.)
  else
    tdstrs (1,43,74,107,138,-1,-1,1,0.,0.,0.)
    tdstrs (2,43,74, 75,106,-1,-1,1,0.,0.,0.)
    tdstrs (3,43,74,139,170,-1,-1,1,0.,0.,0.)
    tdstrs (4,42,42, 42, 42,-1,-1,1,0.,0.,0.)
  end if

; Number of triangles used.
  ntri = 70920

;
; Initialize the eye position to do a left-eye view.
;
  otep=0.
;
; Initialize TDPACK.
;
  tdinit (eye,(/uaim,vaim,waim/),(/uaim,vaim,waim+1./),otep)
;
; Order the triangles in the triangle list.
;
  itwk = tdotri (rtri,ntri,rtwk,1)
;
; Render the triangles in the triangle list.
;
  tddtri (wks,rtri,ntri,itwk)

;
; Advance the frame.
;
  frame(wks)

end

