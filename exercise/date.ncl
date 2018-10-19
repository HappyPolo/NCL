;日期转换
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"

begin 
    
    f                    =addfile("/mnt/e/data/precip.mon.mean.nc", "r")
    prc                  =f->precip
    time                 =prc&time
    yyyymm               =cd_calendar(time, -1)
    print(yyyymm)
end

prc_y_yavg(i,:,:)      =(prc(j,:,:)+prc(j+1,:,:)+prc(j+2,:,:)+prc(j+3,:,:)+prc(j+4,:,:)+prc(j+5,:,:)+prc(j+6,:,:)+prc(j+7,:,:)+prc(j+8,:,:)+prc(j+9,:,:)+prc(j+10,:,:)+prc(j+11,:,:))/12