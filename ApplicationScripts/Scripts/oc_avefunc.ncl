function oc_ave_spatial_n(x[*][*][*]:numeric,in:file)
; x    - the [nobs,nlat,nlon] array to be averaged.
; in   - pointer to model file

; history: developed on 3/11/99 as part of CMPS
; modified 4/20/99 to put more into fortran. combined area and ave.
;**************************************
begin
;**************************************
; determine dimensions
;**************************************
  size = dimsizes(x)
  nobs = size(0)
  nlat = size(1)
  nlon = size(2)
;**************************************
; get spatial variables
;**************************************
  coord1 = x!1
  coord2 = x!2
  test1  = tochar(coord1)
  test2  = tochar(coord2)
  type1  = test1(4)
  type2  = test2(4)

  latt = in->lat_t
  latu = in->lat_u
;**************************************
; calculate areas (dx and dy are in cm)
;**************************************
   if(type1.eq."t".and.type2.eq."t")then       ; tracer grid
     dx = in->dxt
     dy = in->dyt
   end if
 
   if(type1.eq."u".and.type2.eq."u")then       ; velocity grid
     dx = in->dxu
     dy = in->dyu
   end if
;**************************************
; calculate average
;**************************************
   a=new( (/nobs/),typeof(x))
   if(isatt(x,"_FillValue"))then
     miss = x@_FillValue 
   else
     miss = -999.
   end if
   OCSUBS::oc_ave_spatial(type1,miss,nobs,nlat,nlon,dx,dy,latt,latu,x,a)
;   copyatt(a,x)
   return (a)
end
;==================================================
;==================================================
function oc_ave_vol_n(x[*][*][*][*]:numeric,in:file)
; x    - the [nobs,nlev,nlat,nlon] array to be averaged.
; in   - pointer to model file
; history: developed on 3/30/99 as part of CMPS
;          modified 4/21/99 to put more into fortran
;**************************************
begin
;**************************************
; determine dimensions
;**************************************
  size=dimsizes(x)
  nobs=size(0)
  nlev=size(1)
  nlat=size(2)
  nlon=size(3)
;**************************************
; get spatial variables
;**************************************
  coord1 = x!2
  coord2 = x!3
  test1 = tochar(coord1)
  test2 = tochar(coord2)
  type1 = test1(4)
  type2 = test2(4)

  latt = in->lat_t
  latu = in->lat_u

  if(type1.eq."t".and.type2.eq."t")then       ; tracer grid
     dx = in->dxt
     dy = in->dyt
   end if
 
   if(type1.eq."u".and.type2.eq."u")then      ; velocity grid
     dx = in->dxu
     dy = in->dyu
   end if

  if( isdim(x,"z_w") )then
    zfac = in->dzz
  else
    zfac = in->dz
  end if
;**************************************
; calculate average
;**************************************
   a=new( (/nobs/),typeof(x))
   if(isatt(x,"_FillValue"))then
     miss = x@_FillValue 
   else
     miss = -999.
   end if
   OCSUBS::oc_ave_vol(type1,miss,nobs,nlev,nlat,nlon,dx,dy,zfac,latt,latu,x,a)
;   copyatt(a,x)
   return (a)
;**************************************
end
;===================================================
;===================================================
function oc_ave_spatialbylev_n(x[*][*][*][*]:numeric,in:file)
; x    - the [nobs,nlev,nlat,nlon] array to be averaged.
; in   - pointer to model file
; history: developed on 3/12/99 as part of CMPS
;          modified 4/21/99 to put more into fortran
;**************************************
begin
;**************************************
; determine dimensions
;**************************************
  size=dimsizes(x)
  nobs=size(0)
  nlev=size(1)
  nlat=size(2)
  nlon=size(3)
;**************************************
; get spatial variables
;**************************************
  coord1 = x!2
  coord2 = x!3

  test1 = tochar(coord1)
  test2 = tochar(coord2)
  type1 = test1(4)
  type2 = test2(4)

  latt = in->lat_t
  latu=in->lat_u
;**************************************
; calculate areas
;**************************************
   if(type1.eq."t".and.type2.eq."t")then       ; tracer grid
     dx = in->dxt
     dy = in->dyt
   end if
 
   if(type2.eq."u".and.type2.eq."u")then       ; velocity grid
      dx = in->dxu
      dy = in->dyu
   end if
;**************************************
; calculate average
;**************************************
   a=new( (/nobs,nlev/),typeof(x))
   if(isatt(x,"_FillValue"))then
     miss = x@_FillValue 
   else
     miss = -999.
   end if
   OCSUBS::oc_ave_spatialbylev(type1,miss,nobs,nlev,nlat,nlon,dx,dy,latt,latu,x,a)
;   copyatt(a,x)
   return (a)
;**************************************
end