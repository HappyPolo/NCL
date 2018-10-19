;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;           FILE: zmmsf.ncl
;         AUTHOR: David Stepaniak, /NCAR/CGD/CAS
; DATE INITIATED: 9 April 1999
;  LAST MODIFIED: Tue Apr 13 11:34:48 MDT 1999
;
;    DESCRIPTION: Computes ZONAL MEAN MERIDIONAL STREAM FUNCTION based on the
;                 the CCM Processor definition of meridional stream function
;                 MPSI which is given by
;
;                                                           / ps(lat,lon)
;                                                          |
;                                          2 pi a cos(lat) | 
;                   MPSI(lev,lat,lon)  =   --------------- |  V(lev,lat,lon) dp
;                                                g         |
;                                                          |
;                                                         / p(lev,lat,lon)
;
;                 where V is the meridional wind, p pressure, ps surface
;                 pressure, a the radius of the earth, and g the acceleration
;                 of gravity. The coordinate dimensions are given by lev,
;                 the pressure level dimension, lat, the latitude dimension,
;                 and lon, the longitude dimension.
;
;                 It is important to note that the meridional stream function
;                 using this definition is valid only in the zonal mean -- not
;                 at any single longitude. Thus, the zonal mean meridional
;                 stream function must be obtained by taking the zonal mean
;                 of MPSI. (The calculation of MPSI and its zonal mean is
;                 performed by this function.)
;
;      REFERENCE: Buja, L. E. (1994) CCM Processor User's Guide (Unicos 
;                 Version). NCAR Technical Note NCAR/TN-384+IA, pages B-17
;                 to B-18.
;
;      INVOKE AS: psi = zmmsf( v, p, lat, ps, msg )
;
;      ARGUMENTS: 
;
;              v: Three-dimensional (lev,lat,lon) array of meridional wind 
;                 values in which THE PRESSURE LEVEL DIMENSION MUST BE ORDERED
;                 TOP TO BOTTOM. Units must be m s^-1. Type float.
;              p: One-dimensional array of pressure level values of vertical
;                 dimension ORDERED TOP TO BOTTOM. Units must be Pa. Type float.
;                 The first value must be greater than 500 Pa (5mb), and the
;                 last value must be less than 100500 Pa (1005mb).
;            lat: One-dimensional array of latitude values of latitude dimension
;                 in degrees. Type float.
;             ps: Two-dimensional (lat,lon) array of surface pressures. Units
;                 must be Pa. Type float.
;            msg: Missing value (fill value) of stream function where v occurs
;                 below the earth's surface. Type float.
;
;        RETURNS:
;
;            psi: Two-dimensional (lev,lat) array of zonal mean meridional 
;                 stream function values in which the first dimension is pres-
;                 sure level, and the second dimension is latitude. THE PRESSURE
;                 LEVEL DIMENSION IS ORDERED TOP TO BOTTOM UPON RETURN. Missing
;                 values (msg) are assigned to psi where v occurs below ground.
;                 Units are kg s^-1. Type float.
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

  undef("zmmsf")

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  function zmmsf( v[*][*][*]:float, \
                        p[*]:float, \
                      lat[*]:float, \
                    ps[*][*]:float, \
                         msg:float  )

  local dimsv, nlvl, nlat, nlon, dimsp, dimslat, dimsps, p_t, p_o, ptmp, dp, \
        pi, a, g, mpsi, psi, psitmp, vtmp, jlon, ilat, klvl, c, flag

  begin
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Check and cross-reference dimensions of v, p, lat, and ps:

  dimsv = dimsizes(v)      ; Diagnose shape of v.
   nlvl = dimsv(0)         ; Diagnose number of pressure levels.
   nlat = dimsv(1)         ; Diagnose number of latitudes.
   nlon = dimsv(2)         ; Diagnose number of longitudes.

  dimsp = dimsizes(p)      ; Diagnose length of p.

  if ( .not. ( nlvl .eq. dimsp(0) ) ) then

   print("FATAL ERROR:")
   print("The number of levels contained by argument p")
   print("does not match the extent of the pressure level")
   print("dimension of argument v.")
   print("Execution halted in function zmmsf.")
   exit

  end if

  dimslat = dimsizes(lat)  ; Diagnose length of lat.

  if ( .not. ( nlat .eq. dimslat(0) ) ) then

   print("FATAL ERROR:")
   print("The number of latitudes contained by argument lat")
   print("does not match the extent of the latitude dimension")
   print("of argument v.")
   print("Execution halted in function zmmsf.")
   exit

  end if

  dimsps = dimsizes(ps)    ; Diagnose length of ps.

  if ( .not. ( nlat .eq. dimsps(0) ) ) then

   print("FATAL ERROR:")
   print("The number of latitudes contained by argument ps")
   print("does not match the extent of the latitude dimension")
   print("of argument v.")
   print("Execution halted in function zmmsf.")
   exit

  end if

  if ( .not. ( nlon .eq. dimsps(1) ) ) then

   print("FATAL ERROR:")
   print("The number of longitudes contained by argument ps")
   print("does not match the extent of the longitude dimension")
   print("of argument v.")
   print("Execution halted in function zmmsf.")
   exit

  end if

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Make sure that p is monotonic increasing, and check bounds of p:

  do klvl = 1, nlvl - 1

   if ( .not. (p(klvl) .gt. p(klvl-1)) ) then 

    print("FATAL ERROR:")
    print("The values of p do not increase monotonically.")
    print("Execution halted in function zmmsf.")
    exit

   end if

  end do

  if ( .not. ( p(0) .gt. 500. ) ) then

   print("FATAL ERROR:")
   print("The first pressure level value is less than")
   print("or equal to 500 Pa (5mb). It must be greater")
   print("than 500 Pa (5mb).")
   print("Execution halted in function zmmsf.")
   exit

  end if

  if ( .not. ( p(nlvl-1) .lt. 100500. ) ) then

   print("FATAL ERROR:")
   print("The last pressure level value is greater than")
   print("or equal to 100500 Pa (1005mb). It must be less")
   print("than 100500 Pa (1005mb).")
   print("Execution halted in function zmmsf.")
   exit

  end if
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Set up pressure thickness of each level:

; Pressure levels are mapped into the ODD indices of one dimensional arrays 
; with indices 0, 1, 2, ... 2*nlv arranged from top to bottom.

; Pressure level interfaces are mappped into the EVEN indices of the same
; one dimensional arrays with indices 0, 1, 2, ... 2*nlv arranged from top to
; bottom.


                 p_t = 5*100.
                           ; Pressure at top of column, Pa.

                 p_o = 1005*100.
                           ; Pressure at bottom of column, Pa

                ptmp = new( (/2*nlvl+1/), float, msg )
                           ; Temporary array to hold pressure at each
                           ; pressure level and interface, Pa.

  ptmp(1:2*nlvl-1:2) = p(0:nlvl-1:1)
                           ; Assign pressures at each pressure level. Pa.

  ptmp(2:2*nlvl-2:2) = ( ptmp(3:2*nlvl-1:2) + ptmp(1:2*nlvl-3:2) ) / 2.
                           ; Compute pressure at interfaces, except
                           ; at top and bottom of column, Pa.

             ptmp(0) = p_t
                           ; Assign pressure at top of column, Pa.

        ptmp(2*nlvl) = p_o
                           ; Assign pressure at bottom of column, Pa.

                  dp = new( (/2*nlvl+1/), float, msg )
                           ; Declare array to hold pressure thickness of each
                           ; level, Pa.

    dp(1:2*nlvl-1:2) = ptmp(2:2*nlvl:2) - ptmp(0:2*nlvl-2:2)
                           ; Compute pressure thickness of each level, Pa.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Perform vertical integral of v as a function of level, latitude, and
; longitude:

       pi = 3.141593
            ; The value of pi in radians.

        g = 9.80616
            ; Gravitaional acceleration, m s^-2.

        a = 6.37122e6
            ; Radius of earth, m.

     mpsi = new( dimsv, float, msg )
            ; Declare mpsi (MPSI, meridional stream function array)
            ; with same shape and type as argument v.

   psitmp = new( (/2*nlvl+1/), float, msg )
            ; Declare one-dimensional array to hold temporary values of the
            ; meridional stream function during integration at fixed latitude.

     vtmp = new( (/2*nlvl+1/), float, msg )
            ; Declare one-dimensional array to hold temporary values of the
            ; meridional wind during integration at fixed latitude.

  do jlon = 0, nlon - 1

   do ilat = 0, nlat - 1

            psitmp(0) = 0.
                        ; Implement top boundary condition for psitmp.
     psitmp(1:2*nlvl) = msg
                        ; Initialize all lower interfaces and levels of psitmp
                        ; as the missing value. 
     vtmp(0:2*nlvl:2) = 0.
                        ; Initialize interfaces of vtmp as 0.
   vtmp(1:2*nlvl-1:2) = v(0:nlvl-1:1,ilat,jlon)
                        ; Map v into the pressure levels of vtmp.
                    c = 2. * pi * a * cos( lat(ilat) * pi / 180 ) / g
                        ; Compute multiplicative constant of integral as
                        ; a function of latitude.

     do klvl = 1, 2*nlvl - 1, 2
           ; This is the integration loop, from top of atmosphere to
           ; the earth's surface.

        flag = klvl

        if ( ptmp(klvl) .gt. ps(ilat,jlon) ) then
           ; Check if variable occurs on a level below ground. Get out
           ; of integration loop if this is so.
           break
        end if

        psitmp(klvl+1) = psitmp(klvl-1) - c * vtmp(klvl) * dp(klvl)
           ; Obtain psitmp on interfaces.

     end do

                  psitmp(flag+1) = -psitmp(flag-1)
                             ; This mapping of a below-ground interface
                             ; reflection point ensures that the averaging
                             ; in the next line closes off contours just
                             ; above the earth's surface in almost
                             ; all cases.

                psitmp(1:flag:2) = ( psitmp(2:flag+1:2) + psitmp(0:flag-1:2) ) / 2.
                             ; Obtain psitmp at pressure levels as an average
                             ; of psitmp at interfaces.

      mpsi(0:nlvl-1:1,ilat,jlon) = psitmp(1:2*nlvl-1:2)
                             ; Map all pressure levels of psitmp into vertical
                             ; dimension of psi; psi will have the msg value
                             ; where it occurs below ground.


   end do
  end do

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Perform zonal average of mpsi (MPSI):

  psi = new( (/nlvl,nlat/), float, msg )
        ; Declare two-dimensional lev-lat array to store and return zonal mean
        ; of mpsi (MPSI).

  do klvl = 0, nlvl - 1

     psi(klvl,:) = dim_avg( mpsi(klvl,:,:) )

  end do
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Delete temporary arrays:

  delete(vtmp)
  delete(ptmp)
  delete(dp)
  delete(psitmp)
  delete(dimsp)
  delete(dimslat)
  delete(dimsps)
  delete(mpsi)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

  return(psi)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

  end

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
