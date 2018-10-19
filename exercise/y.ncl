;precip.ncl
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"

begin

  f                                 =addfile("/mnt/e/data/GPCP_precip_DATA/gpcp_v2.2.2008.nc/","r")

  precip                            =f->Precip
  
  wks=gsn_open_wks("x11","precip_2008")
  gsn_define_colormap(wks, "rainbow+white+gray")

  res                               =True

  plot =gsn_csm_xy(wks,precip&time,precip(0,{30:60},{30}), res)
end

