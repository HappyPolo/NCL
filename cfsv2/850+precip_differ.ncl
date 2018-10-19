begin

;input data
f1=addfile("/mnt/f/data/ERA-interim/monthly/precip.mon.mean.nc", "r")
fu1=addfile("/mnt/f/data/ERA-interim/monthly/uwnd.mon.mean.nc", "r")
fv1=addfile("/mnt/f/data/ERA-interim/monthly/vwnd.mon.mean.nc", "r")
fh=addfile("/mnt/f/data/NCEP/hgt.sfc.nc", "r")

prc=f1->r(48:383,:,:)
u1=short2flt(fu1->u(48:383,{850},:,:))
v1=short2flt(fv1->v(48:383,{850},:,:))
hgt=short2flt(fh->hgt(0,:,:))

f2=addfile("/mnt/f/data/CFSV2_output/pre/pre.em24.out.nc", "r")
fu2=addfile("/mnt/f/data/CFSV2_output/u850/u850.em24.out.nc", "r")
fv2=addfile("/mnt/f/data/CFSV2_output/v850/v850.em24.out.nc", "r")

wks=gsn_open_wks("x11", "/mnt/f/pdf/850+precip_differ")
do i=0,9,3
pgrd=f2->pre(:,i,:,:)
u2=fu2->ugrd(:,i,:,:)
v2=fv2->vgrd(:,i,:,:)
p=g2fsh_Wrap(pgrd, (/121,240/))

;p&lat@units="degrees_north"
;p&lon@units="degrees_east"
;u2&lat@units="degrees_north"
;u2&lon@units="degrees_east"
;v2&lat@units="degrees_north"
;v2&lon@units="degrees_east"

;calculations

prc_ann=dim_avg_n_Wrap(prc, 0)
p_ann=dim_avg_n_Wrap(p, 0)
gsn_define_colormap(wks, "MPL_gist_yarg")

base=new(4,graphic)
plot=new(4,graphic)

;p1MAM=month_to_season(prc, "MAM")
p1JJA=month_to_season(prc, "JJA")
;p1SON=month_to_season(prc, "SON")
p1clm=clmMonTLL(prc)

;p2MAM=month_to_season(p, "MAM")
p2JJA=month_to_season(p, "JJA")
;p2SON=month_to_season(p, "SON")
p2clm=clmMonTLL(p)

;prc1=dim_avg_n_Wrap(p1MAM, 0)-dim_avg_n_Wrap(86400*p2MAM, 0)
prc2=dim_avg_n_Wrap(p1JJA, 0)-86400*dim_avg_n_Wrap(p2JJA, 0)
;prc3=dim_avg_n_Wrap(p1SON, 0)-86400*dim_avg_n_Wrap(p2SON, 0)
prc4=prc3
prc4=(p1clm(0,:,:)+p1clm(1,:,:)+p1clm(11,:,:))/3-86400*(p2clm(0,:,:)+p2clm(1,:,:)+p2clm(11,:,:))/3

pt=dim_avg_n_Wrap(p1MAM, 0)
copy_VarCoords(pt, prc1)
copy_VarCoords(pt, prc2)
copy_VarCoords(pt, prc3)
copy_VarCoords(pt, prc4)


;u1MAM=month_to_season(u1, "MAM")
;v1MAM=month_to_season(v1, "MAM")
;u2MAM=month_to_season(u2, "MAM")
;v2MAM=month_to_season(v2, "MAM")
;uwnd1=dim_avg_n_Wrap(u1MAM, 0)+dim_avg_n_Wrap(u2MAM, 0)
;vwnd1=dim_avg_n_Wrap(v1MAM, 0)+dim_avg_n_Wrap(v2MAM, 0)

u1JJA=month_to_season(u1, "JJA")
v1JJA=month_to_season(v1, "JJA")
u2JJA=month_to_season(u2, "JJA")
v2JJA=month_to_season(v2, "JJA")
uwnd2=dim_avg_n_Wrap(u1JJA, 0)+dim_avg_n_Wrap(u2JJA, 0)
vwnd2=dim_avg_n_Wrap(v1JJA, 0)+dim_avg_n_Wrap(v2JJA, 0)

;u1SON=month_to_season(u1, "SON")
;v1SON=month_to_season(v1, "SON")
;u2SON=month_to_season(u2, "SON")
;v2SON=month_to_season(v2, "SON")
;uwnd3=dim_avg_n_Wrap(u1SON, 0)+dim_avg_n_Wrap(u2SON, 0)
;vwnd3=dim_avg_n_Wrap(v1SON, 0)+dim_avg_n_Wrap(v2SON, 0)

;u1clm=clmMonTLL(u1)
;v1clm=clmMonTLL(v1)
;u2clm=clmMonTLL(u2)
;v2clm=clmMonTLL(v2)
;uwnd4=uwnd3
;vwnd4=vwnd3
;uwnd4=(u1clm(0,:,:)+u1clm(1,:,:)+u1clm(11,:,:))/3+(u2clm(0,:,:)+u2clm(1,:,:)+u2clm(11,:,:))/3
;vwnd4=(v1clm(0,:,:)+v1clm(1,:,:)+v1clm(11,:,:))/3+(v2clm(0,:,:)+v2clm(1,:,:)+v2clm(11,:,:))/3

;precipitation
res=True
res@gsnDraw=False
res@gsnFrame=False
res@gsnAddCyclic=True
res@cnLinesOn=False
res@pmTickMarkDisplayMode="Always"

res@gsnLeftString="Obs-Hindcast"
res@gsnRightString=""

res@cnFillOn=True
res@cnLevelSelectionMode="ExplicitLevels"
;res@cnLevels=(/-14,-12,-10,-8,-6,-4,-2,2,4,6,8,10/)
;res@cnFillColors=(/2,3,4,5,6,7,8,10,12,14,16,18/)
res@lbLabelBarOn=False

res@mpMaxLatF=60
res@mpMinLatF=0
res@mpMaxLonF=140
res@mpMinLonF=40

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
hres@cnLineColor="red"
hres@cnLineThicknessF=3
hres@cnLineDashPattern=12

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
resv@vcMinDistanceF=0.02

resv@vcFillArrowWidthF=0.02
resv@vcFillArrowHeadXF=0.2
resv@vcFillArrowHeadInteriorXF=0.1
resv@vcFillArrowHeadYF=0.1

resv@vcRefAnnoOn=True
resv@vcRefMagnitudeF=20
resv@vcRefLengthF=0.05
resv@vcRefAnnoBackgroundColor="white"
resv@vcRefAnnoPerimOn=False
resv@vcRefAnnoFontHeightF=0.015
resv@vcRefAnnoString1On=True
resv@vcRefAnnoString2On=False
resv@vcRefAnnoString1="20m/s"
resv@vcRefAnnoOrthogonalPosF=0
resv@vcRefAnnoParallelPosF=1

    ress                           =True
    ress@gsnDraw                 =False
    ress@gsnFrame                =False

    ress@gsnLeftString                 =""
    ress@gsnRightString                =""
    ;ress@stSpanLevelPalette            ="matlab_hot"
    ress@stLevelSpacingF               =2.
    ress@stMonoLineColor               =True
    ress@stMinDistanceF                =0.03
    ress@stMinLineSpacingF             =0.007
    ress@stArrowLengthF                =0.005



base(0)=gsn_csm_contour_map_overlay(wks, prc1, hgt, res, hres)
base(1)=gsn_csm_contour_map_overlay(wks, prc2, hgt, res, hres)
base(2)=gsn_csm_contour_map_overlay(wks, prc3, hgt, res, hres)
base(3)=gsn_csm_contour_map_overlay(wks, prc4, hgt, res, hres)


;plot command
plot(0)=gsn_csm_streamline(wks, uwnd1, vwnd1, ress)
plot(1)=gsn_csm_streamline(wks, uwnd2, vwnd2, ress)
plot(2)=gsn_csm_streamline(wks, uwnd3, vwnd3, ress)
plot(3)=gsn_csm_streamline(wks, uwnd4, vwnd4, ress)

overlay(base(0), plot(0))
;draw(base(0))
;frame(wks)
overlay(base(1), plot(1))
;draw(base(1))
;frame(wks)
overlay(base(2), plot(2))
;draw(base(2))
;frame(wks)
overlay(base(3), plot(3))
;draw(base(3))
;frame(wks)

;panels 
pres=True
pres@txString="Seasons____lead_"+i
pres@gsnPanelLabelBar=True
pres@gsnPanelFigureStrings=(/"A","B","C","D"/)
;pres@amJust="TopLeft"
gsn_panel(wks, base, (/2,2/), pres)
print(i+"down")

end do 

end
