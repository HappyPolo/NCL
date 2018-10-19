begin
  filename   = "v5_rel04_BC5_ne120_t12_pop62.pop.h.0001-01_partial.nc"
  f          = addfile(filename,"r")
  t          = f->TEMP(0,0,:,:)    ; 2400 x 3600

  t@lat2d    = f->TLAT             ; for plotting purposes
  t@lon2d    = f->TLONG
  printVarSummary(t)
  printMinMax(t@lon2d,0)
  printMinMax(t@lat2d,0)
  print(num(ismissing(t)))

  wks = gsn_open_wks("x11","POP")

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
