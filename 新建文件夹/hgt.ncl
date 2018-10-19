;hgt

begin 

   f=addfile("/home/ys-ug/data/USGS_gtopo30_0.47x0.63_remap_c061106.nc", "r")
   hgt=(f->PHIS(:,:))
   hgt=hgt/9.8
   wks=gsn_open_wks("x11", "name")
   print(max(hgt))
   ;hgt=mask(hgt, hgt.gt.3000, False)
   res=True
   res@cnFillOn  =True
   res@cnLinesOn =True
   res@gsnMaximize=True
   res@cnLevelSelectionMode ="ExplicitLevels"
   ;res@cnLevels   =(/2000/)
   ;res@mpMaxLonF  =140
   ;res@mpMinLonF  =60
   ;res@mpMinLatF  =10
   ;res@mpMaxLatF  =60
   res@cnMissingValFillColor="black"
   ;res@cnFillColors=(/"white","white"/)
   plot=gsn_csm_contour_map(wks, hgt(:,:), res)
print("all")
   end
