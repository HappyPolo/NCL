load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
begin

;input data
f1=addfile("/home/ys-ug/data/era-interim/precip.mon.mean.nc", "r")
fh=addfile("/home/ys-ug/data/hgt.sfc.nc", "r")

pe=f1->r(48:383,:,:)
hgt=short2flt(fh->hgt(0,:,:))

f2=addfile("/home/yangsong3/lcz/data/cfsv2_output/pre/pre.em24.out.nc", "r")
p=(f2->pre(:,0,:,:))
pc=g2fsh_Wrap(p, (/121,240/))
pc=pc(:,::-1,:)
pc=pc*86400
printVarSummary(pc)

;preparations
wks=gsn_open_wks("x11", "/home/ys-ug/fei_cy/correl3")
gsn_define_colormap(wks, "NCV_blue_red")

plot_5=new(4, graphic)
plot_6=new(4, graphic)
plot_7=new(4, graphic)
plot_8=new(4, graphic)

pe5=new((/28,121,240/),float)
pe6=new((/28,121,240/),float)
pe7=new((/28,121,240/),float)
pe8=new((/28,121,240/),float)

pc5=new((/28,121,240/),float)
pc_6=new((/28,121,240/),float)
pc7=new((/28,121,240/),float)
pc8=new((/28,121,240/),float)

pc3_5=new((/28,121,240/),float)
pc3_6=new((/28,121,240/),float)
pc3_7=new((/28,121,240/),float)
pc3_8=new((/28,121,240/),float)

pc6_5=new((/28,121,240/),float)
pc6_6=new((/28,121,240/),float)
pc6_7=new((/28,121,240/),float)
pc6_8=new((/28,121,240/),float)
 
pc9_5=new((/28,121,240/),float)
pc9_6=new((/28,121,240/),float)
pc9_7=new((/28,121,240/),float)
pc9_8=new((/28,121,240/),float)

p3=(f2->pre(:,3,:,:))
pc3=g2fsh_Wrap(p3, (/121,240/))
pc3=pc3(:,::-1,:)
pc3=pc3*86400

p6=(f2->pre(:,6,:,:))
pc6=g2fsh_Wrap(p6, (/121,240/))
pc6=pc6(:,::-1,:)
pc6=pc6*86400

p9=(f2->pre(:,9,:,:))
pc9=g2fsh_Wrap(p9, (/121,240/))
pc9=pc9(:,::-1,:)
pc9=pc9*86400

;calculations
do i=0,27,1
    pe5(i,:,:)=pe(4+12*i,:,:)
    pe6(i,:,:)=pe(5+12*i,:,:)
    pe7(i,:,:)=pe(6+12*i,:,:)
    pe8(i,:,:)=pe(7+12*i,:,:)

    pc5(i,:,:)=pc(4+12*i,:,:)
    pc_6(i,:,:)=pc(5+12*i,:,:)
    pc7(i,:,:)=pc(6+12*i,:,:)
    pc8(i,:,:)=pc(7+12*i,:,:)

    pc3_5(i,:,:)=pc3(4+12*i,:,:)
    pc3_6(i,:,:)=pc3(5+12*i,:,:)
    pc3_7(i,:,:)=pc3(6+12*i,:,:)
    pc3_8(i,:,:)=pc3(7+12*i,:,:)

    pc6_5(i,:,:)=pc6(4+12*i,:,:)
    pc6_6(i,:,:)=pc6(5+12*i,:,:)
    pc6_7(i,:,:)=pc6(6+12*i,:,:)
    pc6_8(i,:,:)=pc6(7+12*i,:,:)
 
    pc9_5(i,:,:)=pc9(4+12*i,:,:)
    pc9_6(i,:,:)=pc9(5+12*i,:,:)
    pc9_7(i,:,:)=pc9(6+12*i,:,:)
    pc9_8(i,:,:)=pc9(7+12*i,:,:)
end do 

ccr5=escorc_n(pe5, pc5, 0, 0)
ccr5_3=escorc_n(pe5, pc3_5, 0, 0)
ccr5_6=escorc_n(pe5, pc6_5, 0, 0)
ccr5_9=escorc_n(pe5, pc9_5, 0, 0)
dims=dimsizes(pe5)
prob5=rtest(ccr5, dims(0), opt)
copy_VarCoords(pe5, prob5)
ccr6=escorc_n(pe6, pc_6, 0, 0)
ccr6_3=escorc_n(pe6, pc3_6, 0, 0)
ccr6_6=escorc_n(pe6, pc6_6, 0, 0)
ccr6_9=escorc_n(pe6, pc9_6, 0, 0)

ccr7=escorc_n(pe7, pc7, 0, 0)
ccr7_3=escorc_n(pe7, pc3_7, 0, 0)
ccr7_6=escorc_n(pe7, pc6_7, 0, 0)
ccr7_9=escorc_n(pe7, pc9_7, 0, 0)

ccr8=escorc_n(pe8, pc8, 0, 0)
ccr8_3=escorc_n(pe8, pc3_8, 0, 0)
ccr8_6=escorc_n(pe8, pc6_8, 0, 0)
ccr8_9=escorc_n(pe8, pc9_8, 0, 0)

copy_VarCoords(pe(0,:,:),ccr5)
copy_VarCoords(pe(0,:,:),ccr5_3)
copy_VarCoords(pe(0,:,:),ccr5_6)
copy_VarCoords(pe(0,:,:),ccr5_9)

copy_VarCoords(pe(0,:,:),ccr6)
copy_VarCoords(pe(0,:,:),ccr6_3)
copy_VarCoords(pe(0,:,:),ccr6_6)
copy_VarCoords(pe(0,:,:),ccr6_9)

copy_VarCoords(pe(0,:,:),ccr7)
copy_VarCoords(pe(0,:,:),ccr7_3)
copy_VarCoords(pe(0,:,:),ccr7_6)
copy_VarCoords(pe(0,:,:),ccr7_9)

copy_VarCoords(pe(0,:,:),ccr8)
copy_VarCoords(pe(0,:,:),ccr8_3)
copy_VarCoords(pe(0,:,:),ccr8_6)
copy_VarCoords(pe(0,:,:),ccr8_9)
wrf_smooth_2d(ccr5,3)
wrf_smooth_2d(ccr5_3,3)
wrf_smooth_2d(ccr5_6,3)
wrf_smooth_2d(ccr5_9,3)
;precipitation
res=True
res@gsnDraw=False
res@gsnFrame=False
res@gsnAddCyclic=True
res@cnLinesOn=False
res@pmTickMarkDisplayMode="Always"

res@gsnLeftString=""
res@gsnRightString=""

res@cnFillOn=True
res@cnLevelSelectionMode="ExplicitLevels"
res@cnLevels=(/-0.8,-0.6,-0.4,-0.2,0,0.2,0.4,0.6,0.8/)
res@cnFillColors=(/80,90,100,110,120,140,150,160,170,180/)
res@lbLabelBarOn=False

res@mpMaxLatF=60
res@mpMinLatF=-10
res@mpMaxLonF=160
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
        opt=True
        opt@gsnShadeFillType="pattern"
        opt@gsnShadeLow    =17
        opt@gsnShadeFillScaleF=0.005
        opt@gsnShadeFillDotSizeF=0.02 

                resb   =True
        resb@cnFillOn=False
        resb@cnLinesOn=True
        resb@gsnDraw=False
        resb@gsnFrame=False
        resb@gsnLeftString=""
        resb@gsnRightString=""
        resb@cnLevelSelectionMode="ExplicitLevels"
        resb@cnLevels=(/0.05/)
        resb@cnInfoLabelOn = False
        resb@cnLineDashPattern=13

;plot command
base5=gsn_csm_contour(wks,prob5 , resb)
base5=gsn_contour_shade(base5, 0.05, 100, opt)
plot_5(0)=gsn_csm_contour_map_overlay(wks, ccr5, hgt, res, hres)
overlay(plot_5(0), base5)
plot_5(1)=gsn_csm_contour_map_overlay(wks, ccr5_3, hgt, res, hres)
plot_5(2)=gsn_csm_contour_map_overlay(wks, ccr5_6, hgt, res, hres)
plot_5(3)=gsn_csm_contour_map_overlay(wks, ccr5_9, hgt, res, hres)

plot_6(0)=gsn_csm_contour_map_overlay(wks, ccr6, hgt, res, hres)
plot_6(1)=gsn_csm_contour_map_overlay(wks, ccr6_3, hgt, res, hres)
plot_6(2)=gsn_csm_contour_map_overlay(wks, ccr6_6, hgt, res, hres)
plot_6(3)=gsn_csm_contour_map_overlay(wks, ccr6_9, hgt, res, hres)

plot_7(0)=gsn_csm_contour_map_overlay(wks, ccr7, hgt, res, hres)
plot_7(1)=gsn_csm_contour_map_overlay(wks, ccr7_3, hgt, res, hres)
plot_7(2)=gsn_csm_contour_map_overlay(wks, ccr7_6, hgt, res, hres)
plot_7(3)=gsn_csm_contour_map_overlay(wks, ccr7_9, hgt, res, hres)

plot_8(0)=gsn_csm_contour_map_overlay(wks, ccr8, hgt, res, hres)
plot_8(1)=gsn_csm_contour_map_overlay(wks, ccr8_3, hgt, res, hres)
plot_8(2)=gsn_csm_contour_map_overlay(wks, ccr8_6, hgt, res, hres)
plot_8(3)=gsn_csm_contour_map_overlay(wks, ccr8_9, hgt, res, hres)

;panels 
p1res=True
p1res@txString="precip_correl_5"
p1res@gsnPanelLabelBar=True
p1res@gsnPanelFigureStrings=(/"0","3","6","9"/)

p2res=True
p2res@txString="precip_correl_6"
p2res@gsnPanelLabelBar=True
p2res@gsnPanelFigureStrings=(/"0","3","6","9"/)

p3res=True
p3res@txString="precip_correl_7"
p3res@gsnPanelLabelBar=True
p3res@gsnPanelFigureStrings=(/"0","3","6","9"/)

p4res=True
p4res@txString="precip_correl_8"
p4res@gsnPanelLabelBar=True
p4res@gsnPanelFigureStrings=(/"0","3","6","9"/)

gsn_panel(wks, plot_5, (/2,2/), p1res)
gsn_panel(wks, plot_6, (/2,2/), p2res)
gsn_panel(wks, plot_7, (/2,2/), p3res)
gsn_panel(wks, plot_8, (/2,2/), p4res)

end