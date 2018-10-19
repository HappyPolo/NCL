begin
  start_script_time = get_cpu_time()

  filename   = "grid.t.20d.nc"
  f          = addfile(filename,"r")
  ht          = f->HT
  ht@lat2d    = f->TLAT             ; for plotting purposes
  ht@lon2d    = f->TLONG
  ht@lon2d    = where(ht@lon2d.gt.180,ht@lon2d-360,ht@lon2d)
  printVarSummary(ht)
  printMinMax(ht@lon2d,0)
  printMinMax(ht@lat2d,0)
  print(num(ismissing(ht)))

  wks = gsn_open_wks("png","GRIDT_raster")

  res                       = True

  res@gsnMaximize           = True           ; maximize plot in frame
;  res@gsnDraw               = False          ; don't draw plot yet
;  res@gsnFrame              = False          ; don't advance frame yet

  res@cnFillOn              = True
  res@cnFillMode            = "RasterFill"
;  res@trGridType            = "TriangularMesh"
  res@cnLineLabelsOn        = False
  res@cnLinesOn             = False

  mnmxint                   = nice_mnmxintvl(min(ht),max(ht),16,False)
  res@cnLevelSelectionMode  = "ManualLevels"
  res@cnMinLevelValF        = mnmxint(0)
  res@cnMaxLevelValF        = mnmxint(1)
  res@cnLevelSpacingF       = mnmxint(2)

  res@gsnAddCyclic          = False

  res@mpOutlineOn           = True
  res@mpFillOn              = False

  plot = gsn_csm_contour_map(wks,ht,res)

  end_script_time = get_cpu_time()
  print("Elapsed script time = " + (end_script_time-start_script_time) + " CPU seconds.")
end
