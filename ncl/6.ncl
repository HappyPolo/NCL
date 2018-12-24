load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
begin

    f = readAsciiTable("/mnt/e/data/ncl/air_cma_201101.txt", 13, "integer", 0)
    ; printVarSummary(f)
    airID = ind(f(:,0) .eq.59082.and.f(:,4).eq.2011.and.f(:,5).eq.1.)
   air = f(airID,7)/10
   air_ano = dim_rmvmean(air)
   t = ispan(1, 31, 1)

   res = True
   res@tiMainString = "air_ano 201101"
   res@gsnRightString = "degC"
   res@gsnXYBarChart = True

   res@gsnYRefLine = 0
   res@gsnAboveYRefLineBarColors ="Red"
   res@gsnBelowYRefLineBarColors ="Blue"

   res@tiXAxisString = "day"
   res@tiYAxisString = "air"
   res@trXMinF = 0.5
   res@trXMaxF = 31.5

   res@vpXF = 0.15
   res@vpYF = 0.7
   res@vpWidthF = 0.8
   res@vpHeightF = 0.4

   wks=gsn_open_wks("x11", "name")
   plot=gsn_csm_xy(wks, t, air_ano, res)






end