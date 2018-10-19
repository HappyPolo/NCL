begin
  fili = "IGBPa_1198.map.nc"
  f    = addfile (fili, "r")
  x    = f->CLASS                      ; note: type byte
  x    = lonFlip(x)              ; 0 to 360 ---> -180 to 180

  printVarSummary(x)
  print(num(ismissing(x)))

  wks = gsn_open_wks("x11","VEGLAND")

  res                       = True

  res@gsnMaximize           = True           ; maximize plot in frame
;  res@gsnDraw               = False          ; don't draw plot yet
;  res@gsnFrame              = False          ; don't advance frame yet

  res@cnFillOn              = True
  res@cnFillMode            = "RasterFill"
;  res@trGridType            = "TriangularMesh"
  res@cnLineLabelsOn        = False
  res@cnLinesOn             = False

  res@cnLevelSelectionMode = "ExplicitLevels"              ; set explict contour levels
  res@cnLevels         = integertobyte(ispan(2,17,1))

  res@gsnAddCyclic          = False

  res@mpOutlineOn           = True
  res@mpFillOn              = False

  plot = gsn_csm_contour_map(wks,x,res)
end
