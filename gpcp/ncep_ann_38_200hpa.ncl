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
wks=gsn_open_wks("pdf", "ncep_ann_200hpa")
gsn_define_colormap(wks, "temp_diff_18lev")

temp=dim_avg_n_Wrap(t, 0)
uwnd=dim_avg_n_Wrap(u, 0)
vwnd=dim_avg_n_Wrap(v, 0)

;temperature
res=True
res@gsnDraw=False
res@gsnFrame=False
res@gsnAddCyclic=True
res@cnLinesOn=False
res@pmTickMarkDisplayMode="Always"

res@gsnLeftString="Annual mean temperature and vectors in 200hpa"
res@gsnRightString="degree"

res@cnFillOn=True
res@cnLevelSelectionMode="AutomaticLevels"
;res@cnLevels=(/-57,-56,-55,-54,-53,-52,-51/)
;res@cnFillColors=(/4,6,8,10,12,14,16,18/)
;res@lbOrientation="Vertical"

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

base=gsn_csm_contour_map_overlay(wks, temp, hgt, res, hres)
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
resv@vcMinMagnitudeF=1
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
plot=gsn_csm_vector(wks, uwnd, vwnd, resv)

overlay(base, plot)
draw(base)
frame(wks)

end 