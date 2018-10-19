begin
  filename   = "gfs.t12z.sflux00-06.nc"
  f          = addfile(filename,"r")
  t          = f->TMP_P8_L233_GGA0_avg(0,:,:)

  printVarSummary(t)
  print(num(ismissing(t)))

  wks = gsn_open_wks("x11","GFS")

  res                       = True

  res@gsnMaximize           = True           ; maximize plot in frame
;  res@gsnDraw               = False          ; don't draw plot yet
;  res@gsnFrame              = False          ; don't advance frame yet

  res@cnFillOn              = True
  res@cnFillMode            = "RasterFill"
  res@trGridType            = "TriangularMesh"
  res@cnLineLabelsOn        = False
  res@cnLinesOn             = False

  mnmxint                   = nice_mnmxintvl(min(t),max(t),25,False)
  res@cnLevelSelectionMode  = "ManualLevels"
  res@cnMinLevelValF        = mnmxint(0)
  res@cnMaxLevelValF        = mnmxint(1)
  res@cnLevelSpacingF       = mnmxint(2)

  res@gsnAddCyclic          = False

  res@mpOutlineOn           = True
  res@mpFillOn              = False

  plot = gsn_csm_contour_map(wks,t,res)
end
