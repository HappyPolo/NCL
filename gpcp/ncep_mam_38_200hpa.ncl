begin

;input data
f=addfile("/mnt/e/data/air.mon.mean.nc", "r")
fu=addfile("/mnt/e/data/uwnd.mon.mean.nc", "r")
fv=addfile("/mnt/e/data/vwnd.mon.mean.nc", "r")
fh=addfile("/mnt/e/data/hgt.sfc.nc", "r")

t=f->air(372:731,{200},:,:)
u=fu->uwnd(372:731,{200},:,:)
v=fv->vwnd(372:731,{200},:,:)
hgt=short2flt(fh->hgt(0,:,:))

;calculations
base=new(4,graphic)
plot=new(4,graphic)
wks=gsn_open_wks("pdf", "ncep_mam_38_200hpa")
gsn_define_colormap(wks, "temp_diff_18lev")

tMAM=month_to_season(t, "MAM")
uMAM=month_to_season(u, "MAM")
vMAM=month_to_season(v, "MAM")

temp1=dim_avg_n_Wrap(tMAM, 0)
uwnd1=dim_avg_n_Wrap(uMAM, 0)
vwnd1=dim_avg_n_Wrap(vMAM, 0)

tJJA=month_to_season(t, "JJA")
uJJA=month_to_season(u, "JJA")
vJJA=month_to_season(v, "JJA")

temp2=dim_avg_n_Wrap(tJJA, 0)
uwnd2=dim_avg_n_Wrap(uJJA, 0)
vwnd2=dim_avg_n_Wrap(vJJA, 0)

tSON=month_to_season(t, "SON")
uSON=month_to_season(u, "SON")
vSON=month_to_season(v, "SON")

temp3=dim_avg_n_Wrap(tSON, 0)
uwnd3=dim_avg_n_Wrap(uSON, 0)
vwnd3=dim_avg_n_Wrap(vSON, 0)

tclm=clmMonTLL(t)
uclm=clmMonTLL(u)
vclm=clmMonTLL(v)

temp4=temp3
uwnd4=uwnd3
vwnd4=vwnd3

temp4=(tclm(0,:,:)+tclm(1,:,:)+tclm(11,:,:))/3
uwnd4=(uclm(0,:,:)+uclm(1,:,:)+uclm(11,:,:))/3
vwnd4=(vclm(0,:,:)+vclm(1,:,:)+vclm(11,:,:))/3

;temperature
res=True
res@gsnDraw=False
res@gsnFrame=False
res@gsnAddCyclic=True
res@cnLinesOn=False
res@pmTickMarkDisplayMode="Always"

res@gsnRightString="degree"

res@cnFillOn=True
res@cnLevelSelectionMode="AutomaticLevels"
;res@cnLevelSelectionMode="ExplicitLevels"
;res@cnLevels=(/-60,-58,-56,-54,-52,-50,-48,-46,-44/)
;res@cnFillColors=(/2,4,6,8,10,12,14,16,18,20/)
;res@lbLabelBarOn=False

res@mpMaxLatF=60
res@mpMinLatF=10
res@mpMaxLonF=140
res@mpMinLonF=60

;height 
hres=True
hres@gsnAddCyclic=True
hres@cnLinesOn=True
hres@cnFillOn=False
hres@cnInfoLabelOn=False

hres@tiMainString=""
hres@cnLevelSelectionMode="ExplicitLevels"
hres@cnLevels=(/2000/)
hres@cnLineLabelsOn=False
hres@cnLineColor="black"
hres@cnLineThicknessF=3
hres@cnLineDashPattern=12

base(0)=gsn_csm_contour_map_overlay(wks, temp1, hgt, res, hres)
base(1)=gsn_csm_contour_map_overlay(wks, temp2, hgt, res, hres)
base(2)=gsn_csm_contour_map_overlay(wks, temp3, hgt, res, hres)
base(3)=gsn_csm_contour_map_overlay(wks, temp4, hgt, res, hres)

;vector
resv=True
resv@gsnDraw=False
resv@gsnFrame=False
resv@pmTickMarkDisplayMode="Always"

resv@gsnLeftString=""
resv@gsnRightString=""

resv@vcGlyphStyle="FillArrow"
resv@vcFillArrowEdgeColor="black"
resv@vcFillArrowFillColor="black"
resv@vcMinMagnitudeF=1.0
resv@vcMinDistanceF=0.04

resv@vcFillArrowWidthF=0.02
resv@vcFillArrowHeadXF=0.2
resv@vcFillArrowHeadInteriorXF=0.1
resv@vcFillArrowHeadYF=0.1

resv@vcRefAnnoOn=True
resv@vcRefMagnitudeF=30
resv@vcRefLengthF=0.05
resv@vcRefAnnoBackgroundColor="white"
resv@vcRefAnnoPerimOn=False
resv@vcRefAnnoFontHeightF=0.015
resv@vcRefAnnoString1On=True
resv@vcRefAnnoString2On=False
resv@vcRefAnnoString1="30m/s"
resv@vcRefAnnoOrthogonalPosF=-0.25
resv@vcRefAnnoParallelPosF=1

;plot command
plot(0)=gsn_csm_vector(wks, uwnd1, vwnd1, resv)
plot(1)=gsn_csm_vector(wks, uwnd2, vwnd2, resv)
plot(2)=gsn_csm_vector(wks, uwnd3, vwnd3, resv)
plot(3)=gsn_csm_vector(wks, uwnd4, vwnd4, resv)

overlay(base(0), plot(0))
overlay(base(1), plot(1))
overlay(base(2), plot(2))
overlay(base(3), plot(3))

;panels 
pres=True
pres@txString="Seasons"
pres@gsnPanelLabelBar=True
pres@gsnPanelFigureStrings=(/"A","B","C","D"/)
pres@amJust="TopLeft"
gsn_panel(wks, base, (/2,2/), pres)
end 