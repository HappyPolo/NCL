;去趋势求方差
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
begin

    f                                      =addfile("/mnt/e/gpcp_v2.2.1979-2015.nc","r")
    prc                                    =f->Precip
    Time                                   =prc&prc



    prcdtr                                 =dtrend_msg_n(Time, prc,True,True,1)
print(prcdtr)

end