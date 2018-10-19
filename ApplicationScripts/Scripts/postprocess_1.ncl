begin
  a = addfile("$NCARG_ROOT/lib/ncarg/data/cdf/uv300.nc","r")
  u = a->U(1,:,:)
  wks = gsn_open_wks("png","postprocess")

  res          = True
  res@cnFillOn = True
  plot = gsn_csm_contour_map(wks,u,res)

  delete(wks)   ; Closes the PNG
  cmd1 = "convert -trim postprocess.png postprocess_lg.png"
  cmd2 = "convert -trim -geometry 200x200 -contrast postprocess_lg.png postprocess_sm.png"
  system(cmd1)
  system(cmd2)

end



