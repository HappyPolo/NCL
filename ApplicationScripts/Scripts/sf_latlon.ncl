if(.not.isvar("f")) then
  dq = str_get_dq()
  print("ncl -n 'f=" + dq + "xxxxx.shp" + dq + "' sf_latlon.ncl")
  exit
end if

a   = addfile(f,"r")
lat = a->y
lon = a->x

print("  res@mpMinLatF = " + min(lat))
print("  res@mpMaxLatF = " + max(lat))
print("  res@mpMinLonF = " + min(lon))
print("  res@mpMaxLonF = " + max(lon))
