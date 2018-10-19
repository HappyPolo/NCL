load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
begin

;input data
f1=addfile("/home/ys-ug/data/era-interim/precip.mon.mean.nc", "r")
fh=addfile("/home/ys-ug/data/hgt.sfc.nc", "r")
prc=f1->r(48:383,:,:)
hgt=short2flt(fh->hgt(0,:,:))

f2=addfile("/home/yangsong3/lcz/data/cfsv2_output/pre/pre.em24.out.nc", "r")
pgrd=f2->pre(:,0,:,:)
p=g2fsh_Wrap(pgrd, (/121,240/))
p=p(:,::-1,:)

;p&lat@units="degrees_north"
;p&lon@units="degrees_east"
;u2&lat@units="degrees_north"
;u2&lon@units="degrees_east"
;v2&lat@units="degrees_north"
;v2&lon@units="degrees_east"

;calculations
wks=gsn_open_wks("x11", "/home/ys-ug/fei_cy/precip_differ")
prc_ann=dim_avg_n_Wrap(prc, 0)
p_ann=dim_avg_n_Wrap(p, 0)
gsn_define_colormap(wks, "temp_diff_18lev")

base=new(4,graphic)

p1MAM=month_to_season(prc, "MAM")
p1JJA=month_to_season(prc, "JJA")
p1SON=month_to_season(prc, "SON")
p1clm=clmMonTLL(prc)

p2MAM=month_to_season(p, "MAM")
p2JJA=month_to_season(p, "JJA")
p2SON=month_to_season(p, "SON")
p2clm=clmMonTLL(p)

prc1=dim_avg_n_Wrap(p1MAM, 0)-dim_avg_n_Wrap(86400*p2MAM, 0)
prc2=dim_avg_n_Wrap(p1JJA, 0)-86400*dim_avg_n_Wrap(p2JJA, 0)
prc3=dim_avg_n_Wrap(p1SON, 0)-86400*dim_avg_n_Wrap(p2SON, 0)
prc4=prc3
prc4=(p1clm(0,:,:)+p1clm(1,:,:)+p1clm(11,:,:))/3-86400*(p2clm(0,:,:)+p2clm(1,:,:)+p2clm(11,:,:))/3

pt=dim_avg_n_Wrap(p1MAM, 0)
copy_VarCoords(pt, prc1)
copy_VarCoords(pt, prc2)
copy_VarCoords(pt, prc3)
copy_VarCoords(pt, prc4)

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
res@cnLevels=(/-10,-8,-6,-4,-2,2,4,6,8,10,12,14/)
res@cnFillColors=(/2,4,6,7,8,10,12,14,15,16,17,18,20/)
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
hres@cnLineColor="black"
hres@cnLineThicknessF=3
hres@cnLineDashPattern=12

base(0)=gsn_csm_contour_map_overlay(wks, prc1, hgt, res, hres)
base(1)=gsn_csm_contour_map_overlay(wks, prc2, hgt, res, hres)
base(2)=gsn_csm_contour_map_overlay(wks, prc3, hgt, res, hres)
base(3)=gsn_csm_contour_map_overlay(wks, prc4, hgt, res, hres)

;panels 
pres=True
pres@txString="precip_differ"
pres@gsnPanelLabelBar=True
pres@gsnPanelFigureStrings=(/"A","B","C","D"/)
;pres@amJust="TopLeft"
gsn_panel(wks, base, (/2,2/), pres)

end