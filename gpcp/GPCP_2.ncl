;GPCP_2.NCL
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"

begin

    f                             =addfile("/mnt/e/data/gpcp_v2.2.1979-2015.nc","r")
    prc                           =f->Precip
    date                          =prc&time
;print(date)
    
    prc                           =where(prc.lt.0.05,0.0,prc)
    
    

    YYYYMM                        =cd_calendar(date,-1)
print(YYYYMM)
    clat                          =latRegWgt(prc&lat,"double",0)
    prcAvg                        =wgt_areaave_Wrap(prc,clat,1.0,0)
    prcZon                        =dim_avg_n_Wrap(prc,2)
;print(prcAvg)
    prcZonAvg                     =dim_avg_n_Wrap(prcZon,0)
    prcZonAvg@longname            ="prc time average"
    prcZonAvg@units               =prc@units

    prcGlbAvg                     =sum(prcZonAvg*clat)/sum(clat)
    prcGlbAvg@longname            ="Global Average"
    prcGlbAvg@units               =prc@units



    wks= gsn_open_wks("x11", "CPCP_2")

    ntim                          =dimsizes(date)
    yrstrt                        =date(0)/10000
    yslast                        =date(ntim-1)/10000
    plot =new(2,"graphic")

    res                           =True
    res@gsnDraw                   =False
    res@gsnFrame                  =False
    res@vpHeightF                 =0.4
    res@vpWidthF                  =0.8

    res@trXMinF                   =1979
    res@trXMaxF                   =2016
    res@tmXBFormat                ="f"
    res@tmYLFormat                ="f"
    res@xyLineThicknessF          =(/2.0/)
    res@xyLineColors              =(/"blue"/)

    res@vpXF                      =0.1

    res@tiYAxisString             ="Global:prc (mm/day)"
    res@gsnYRefLine               =avg(prcGlbAvg)
    res@gsnCenterString           ="Areal Mean="+sprintf("%4.2f",avg(prcGlbAvg))+"mm/day"

    
    yrfrac                        =yyyymm_to_yyyyfrac(YYYYMM,0.0)
;print(yrfrac)
    plot(0)=gsn_csm_xy(wks,yrfrac,prcAvg, res)
    delete(res@gsnCenterString)

    res@tiYAxisString             ="Zonal Mean (mm/day)"

    res@trXMinF                   =-90
    res@trXMaxF                   =90
    plot(1)=gsn_csm_xy(wks,prcZonAvg&lat,prcZonAvg, res)

    resp                          =True
    resp@txString                 ="Areal Precipitation"
    resp@gsnPanelBottom           =0.1
    gsn_panel(wks, plot,(/2,1/), resp)
   
   

end
