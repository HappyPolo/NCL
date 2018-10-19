;-----------------------------------------------------------
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
;-----------------------------------------------------------
begin

  ;--- read files ---
  nc_p = addfile("output_pres.nc", "r")
  nc_q = addfile("output_shum.nc", "r")
  nc_t = addfile("output_theta.nc", "r")
  nc_z = addfile("output_ht.nc", "r")

  ;--- read variables ---
  pres = nc_p->pres
  shum = nc_q->shum
  theta = nc_t->theta
  hgt = nc_z->ht(0,0,:,:)/9.80655

  ;--- get dimensions ---
  time = nc_p->time
  lev  = nc_p->lev
  lat  = nc_p->lat
  lon  = nc_p->lon

  dims = dimsizes(pres)
  nlev = dims(1)
  nlat = dims(2)
  nlon = dims(3)

  ;--- add time dimension to hgt variable ---
  hgt2 = conform(theta(:,0,:,:), hgt, (/ 1,2 /))
  copy_VarCoords(pres(:,0,:,:), hgt2)
  pres@_FillValue=2e+20

  ;--- convert potential temperature to temperature
  p0 = 1000.0    ; referance pressure [mb]
  cp = 1004.0    ; specific heat at constant pressure for air [J/(kg-K)] 
  Rgas = 287.0   ; specific gas constant for air [J/(kg-K)]
  Lv = 2400.0    ; latent heat of evaporation [approx 2400 kJ/kg at 25C]
  Rcp = Rgas/cp  ; constant

  tt_s = theta/(p0/pres)^Rcp  
  tt = tt_s-(Lv/cp)*shum

  ;--- calculate virtual temperature
  tkv  = tt*(1.+shum*0.61)
  copy_VarCoords(theta, tkv)

  ;--- calculate geopotemtial height in hybrid levels ---
  geop_hgt = hydro(pres(time|:,lat|:,lon|:,lev|:), \
                   tkv(time|:,lat|:,lon|:,lev|:), \
                   hgt2(time|:,lat|:,lon|:))
  copy_VarCoords(pres(time|:,lat|:,lon|:,lev|:), geop_hgt)

  ;--- reorder dimensions ---
  geop_hgt2 = geop_hgt(time|:,lev|:,lat|:,lon|:)

  do k = 0, nlev-1
    print(sprinti("%3d", k)+" "+\
          sprintf("%7.2f", tt(1,k,15,10))+" "+\
          sprintf("%7.2f", pres(1,k,15,10))+" "+\
          sprintf("%7.2f", hgt2(1,15,10))+" "+\
          sprintf("%7.2f", geop_hgt2(1,k,15,10))+" "+\
          sprintf("%7.2f", geop_hgt2(120,k,15,10)))
          ;sprintf("%7.2f", theta(0,k,10,10))+" "+\
          ;sprintf("%7.2f", pres(0,k,10,10))+" "+\
          ;sprintf("%8.5e", shum(0,k,10,10))+" "+\
          ;sprintf("%7.2f", tt_s(0,k,10,10))+" "+\
          ;sprintf("%7.2f", tt(0,k,10,10))+" "+\
          ;sprintf("%7.2f", tkv(0,k,10,10))+" "+\
          ;sprintf("%7.2f", hgt2(0,10,10))+" "+\
          ;sprintf("%7.2f", geop_hgt(k)))
          ;sprintf("%7.2f", geop_hgt(0,k,10,10)))
  end do

  ;---------------------------------------------------------
  ; Create NetCDF file (geopotential height)
  ;---------------------------------------------------------

  fout = "output_hgt.nc"
  system("/bin/rm -f "+fout)
  nc = addfile(fout, "c")

  ;--- enable define mode ---
  setfileoption(nc, "DefineMode", True)

  ;--- predefine coordinate variables ---
  dimNames = (/ "time", "lev", "lat", "lon" /)
  dimSizes = (/ -1, nlev, nlat, nlon /)
  dimUnlim = (/ True , False, False, False /)
  filedimdef(nc, dimNames, dimSizes, dimUnlim)

  ;--- predefine dimension of variables ---
  filevardef(nc, "time", "double", (/ "time" /))
  filevardef(nc, "lev", "float", (/ "lev" /))
  filevardef(nc, "lat", "float", (/ "lat" /))
  filevardef(nc, "lon", "float", (/ "lon" /))
  filevardef(nc, "hgt", "float", (/ "time", "lev", "lat", "lon" /))

  ;--- add attributes to variables ---
  attr = True
  attr@units = "meter"
  attr@long_name = "Geopotential Height"
  filevarattdef(nc, "hgt", attr)
  delete(attr)

  filevarattdef(nc, "time", time)

  attr = True
  attr@positive = "up"
  attr@long_name = "Hybrid Pressure Level"
  filevarattdef(nc, "lev", attr)
  delete(attr)
  filevarattdef(nc, "lev", lev)

  filevarattdef(nc, "lat", lat)
  filevarattdef(nc, "lon", lon) 

  ;--- exit define mode ---
  setfileoption(nc, "DefineMode", False)

  ;--- fill data ---
  nc->time = (/ time /)
  nc->lev = (/ lev /)
  nc->lon = (/ lon /) 
  nc->lat = (/ lat /)
  nc->hgt = (/ geop_hgt2 /)

 ;---------------------------------------------------------
  ; Create NetCDF file (geopotential height)
  ;---------------------------------------------------------

  fout = "output_temp.nc"
  system("/bin/rm -f "+fout)
  nc2 = addfile(fout, "c")

  ;--- enable define mode ---
  setfileoption(nc2, "DefineMode", True)

  ;--- predefine coordinate variables ---
  dimNames = (/ "time", "lev", "lat", "lon" /)
  dimSizes = (/ -1, nlev, nlat, nlon /)
  dimUnlim = (/ True , False, False, False /)
  filedimdef(nc2, dimNames, dimSizes, dimUnlim)

  ;--- predefine dimension of variables ---
  filevardef(nc2, "time", "double", (/ "time" /))
  filevardef(nc2, "lev", "float", (/ "lev" /))
  filevardef(nc2, "lat", "float", (/ "lat" /))
  filevardef(nc2, "lon", "float", (/ "lon" /))
  filevardef(nc2, "temp", "float", (/ "time", "lev", "lat", "lon" /))

  ;--- add attributes to variables ---
  attr = True
  attr@units = "kelvin"
  attr@long_name = "Temperature"
  filevarattdef(nc2, "temp", attr)
  delete(attr)

  filevarattdef(nc2, "time", time)

  attr = True
  attr@positive = "up"
  attr@long_name = "Hybrid Pressure Level"
  filevarattdef(nc2, "lev", attr)
  delete(attr)
  filevarattdef(nc2, "lev", lev)

  filevarattdef(nc2, "lat", lat)
  filevarattdef(nc2, "lon", lon)

  ;--- exit define mode ---
  setfileoption(nc2, "DefineMode", False)

  ;--- fill data ---
  nc2->time = (/ time /)
  nc2->lev = (/ lev /)
  nc2->lon = (/ lon /)
  nc2->lat = (/ lat /)
  nc2->temp = (/ tt /)

end
