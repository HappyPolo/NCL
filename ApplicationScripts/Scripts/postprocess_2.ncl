begin
  a = addfile("$NCARG_ROOT/lib/ncarg/data/cdf/uv300.nc","r")
  u = a->U(1,:,:)
  wks = gsn_open_wks("png","postprocess")

  res = True
  res@vpXF           = 0.0
  res@vpYF           = 1.0
  res@vpWidthF       = 1.0
  res@vpHeightF      = 1.0
  res@gsnTickMarksOn = False

  res@cnFillOn       = True
  res@cnLinesOn      = False
  res@cnLineLabelsOn = False
  res@cnInfoLabelOn  = False
  res@lbLabelBarOn   = False
  res@gsnRightString = ""
  res@gsnLeftString  = ""

  plot = gsn_csm_contour(wks,u,res)
  
  getvalues plot
    "vpWidthF"  : vpw
    "vpHeightF" : vph
  end getvalues
  print(vpw)
  print(vph)
end



