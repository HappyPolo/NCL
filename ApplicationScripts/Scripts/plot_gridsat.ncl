begin
  filename        = "GridSat-B1.1989.07.31.00.v01r01.irwin.nc"
  f               = addfile(filename,"r")
  irwin           = short2flt(f->irwin(0,:,:))
  irwin@long_name = str_sub_str(irwin@long_name,"~","approx. ")

  printVarSummary(irwin)
  print(num(ismissing(irwin)))

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

   res@cnLevelSelectionMode = "ManualLevels" ; set manual contour levels
   res@cnMinLevelValF       = 180.0              ; set min contour level
   res@cnMaxLevelValF       = 320.0              ; set max contour level
   res@cnLevelSpacingF      =   4.0              ; set contour spacing

   res@mpCenterLonF     = 60


  mnmxint                   = nice_mnmxintvl(min(irwin),max(irwin),25,False)
  res@cnLevelSelectionMode  = "ManualLevels"
  res@cnMinLevelValF        = mnmxint(0)
  res@cnMaxLevelValF        = mnmxint(1)
  res@cnLevelSpacingF       = mnmxint(2)

  res@gsnAddCyclic          = False

  res@mpOutlineOn           = True
  res@mpFillOn              = False

  plot = gsn_csm_contour_map(wks,irwin,res)
end
