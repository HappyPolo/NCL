;gpcc去趋势求方差
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
begin
  f1                              =addfile("/mnt/e/data/precip.mon.total.1x1.v7.nc", "r")
  f2                              =addfile("/mnt/e/data/precip.mon.mean.nc","r")
  prc1                            =f1->precip(936:1295,:,:)
printVarSummary(prc1)

  ;dsizes_p                        =dimsizes(prc)
  prc2                            =f2->precip(0:359,:,:)
printVarSummary(prc2)
  prc_d2                          =dtrend_msg_n(ispan(0,359,1), prc2,True, True,0)
  prc_d1                           =dtrend_msg_n(ispan(0,359,1),prc1,True,True,0)
printVarSummary(prc_d1)
printVarSummary(prc_d2)
  copy_VarCoords(prc1,prc_d1)
  prc_var1                         =dim_variance_n_Wrap(prc_d1,0)
;printVarSummary(prc_var1)

  wks                             =gsn_open_wks("x11","gpcc")

  res                             =True

  res@mpMaxLonF                   =140
  res@mpMinLonF                   =60
  res@mpMaxLatF                   =60
  res@mpMinLatF                   =0

  res@cnFillOn                    =True
  res@cnLinesOn                   =False
  res@cnLevelSelectionMode        ="AutomaticLevels"



plot=gsn_csm_contour_map(wks,prc_var, res)

end



  
