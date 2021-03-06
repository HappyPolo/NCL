load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
begin

;input data
;ft=addfile("/home/ys-ug/data/era-interim/air.mon.mean.nc", "r")
;fh=addfile("/home/ys-ug/data/hgt.sfc.nc", "r")
;fu=addfile("/home/ys-ug/data/era-interim/uwnd.mon.mean.nc", "r")
;fv=addfile("/home/ys-ug/data/era-interim/vwnd.mon.mean.nc", "r")

ft=addfile("/home/ys-ug/data/air.mon.mean.nc", "r")
fh=addfile("/home/ys-ug/data/hgt.sfc.nc", "r")
fu=addfile("/home/ys-ug/data/uwnd.mon.mean.nc", "r")
fv=addfile("/home/ys-ug/data/vwnd.mon.mean.nc", "r")

;temp=short2flt(ft->t(0:383,30,{10:70},{50:130}))
;hgt=short2flt(fh->hgt(0,{10:70},{50:130}))
;uwnd=short2flt(fu->uwnd(0:383,30,{10:70},{50:130}))
;vwnd=short2flt(fv->vwnd(0:383,30,{10:70},{50:130}))

temp=ft->air(0:827,2,{10:70},{50:130})
hgt=fh->hgt(0,{10:70},{50:130})
uwnd=fu->uwnd(0:827,2,{10:70},{50:130})
vwnd=fv->vwnd(0:827,2,{10:70},{50:130})

wks=gsn_open_wks("x11", "/home/ys-ug/fei_cy/zonal wind")
gsn_define_colormap(wks, "GMT_gray")
printVarSummary(temp)
printVarSummary(uwnd)

;pt calculatitudeion
pt=new((/828,25,33/),float)
copy_VarCoords(temp, pt)
pt=temp
pt=pt*(1000/850)^0.286

dim      = dimsizes(pt)
t_clm   = onedtond(ndtooned(pt),(/dim(0)/12,12,dim(1),dim(2)/))
t_clm!0 = "year"
t_clm!1 = "month"
t_clm!2 = "latitude"
t_clm!3 = "longitude"
t_clm&year  = ispan(1948, 2016, 1)
copy_VarCoords_1(pt(latitude|:,longitude|:,time|:), t_clm(latitude|:,longitude|:,year|:,month|:))
t_ann=dim_avg_n_Wrap(t_clm, 0)
t_jja=(t_ann(5,:,:)+t_ann(6,:,:)+t_ann(7,:,:))/3
t_djf=(t_ann(0,:,:)+t_ann(1,:,:)+t_ann(11,:,:))/3
delete(dim)

;wind calculatitudeion
dim      = dimsizes(uwnd)
u_clm   = onedtond(ndtooned(uwnd),(/dim(0)/12,12,dim(1),dim(2)/))
u_clm!0 = "year"
u_clm!1 = "month"
u_clm!2 = "latitude"
u_clm!3 = "longitude"
u_clm&year  = ispan(1948, 2016, 1)
copy_VarCoords_1(uwnd(latitude|:,longitude|:,time|:), u_clm(latitude|:,longitude|:,year|:,month|:))
u_ann=dim_avg_n_Wrap(u_clm, 0)
delete(dim)

dim    = dimsizes(vwnd)
v_clm  = onedtond(ndtooned(vwnd), (/dim(0)/12, 12, dim(1), dim(2)/))
v_clm!0 = "year"
v_clm!1 = "month"
v_clm!2 = "latitude"
v_clm!3 = "longitude"
v_clm&year = ispan(1948, 2016, 1)
copy_VarCoords_1(vwnd(latitude|:,longitude|:,time|:), v_clm(latitude|:,longitude|:,year|:,month|:))
v_ann=dim_avg_n_Wrap(v_clm, 0)
delete(dim)

u_jja=(u_ann(5,:,:)+u_ann(6,:,:)+u_ann(7,:,:))/3
v_jja=(v_ann(5,:,:)+v_ann(6,:,:)+v_ann(7,:,:))/3
u_djf=(u_ann(0,:,:)+u_ann(1,:,:)+u_ann(11,:,:))/3
v_djf=(v_ann(0,:,:)+v_ann(1,:,:)+v_ann(11,:,:))/3

u_zm1=dim_avg_n_Wrap(u_jja, 1)
v_zm1=dim_avg_n_Wrap(v_jja, 1)
u_zm2=dim_avg_n_Wrap(u_djf, 1)
v_zm2=dim_avg_n_Wrap(v_djf, 1)

u_dif_jja=new((/25,33/), float)
u_dif_djf=new((/25,33/), float)
v_dif_jja=new((/25,33/), float)
v_dif_djf=new((/25,33/), float)

do i=0,24,1
    do j=0,32,1
        u_dif_jja(i,j)=u_jja(i,j)-u_zm1(i)
        v_dif_jja(i,j)=v_jja(i,j)-v_zm1(i)
        u_dif_djf(i,j)=u_djf(i,j)-u_zm2(i)
        v_dif_djf(i,j)=v_djf(i,j)-v_zm2(i)
    end do 
end do 

;height 
hres=True
hres@gsnDraw=False
hres@gsnFrame=False
hres@cnLinesOn=True
hres@cnFillOn=True 
hres@cnInfoLabelOn=False
hres@gsnAddCyclic=False

hres@tiMainString=""
hres@cnLevelSelectionMode="ExplicitLevels"
hres@cnLevels=(/2000/)
hres@cnLineLabelsOn=False
hres@cnLineColor=7
hres@cnFillColors=(/11,7/)
hres@cnLineThicknessF=3
hres@cnLineDashPattern=12

hres@mpMaxLonF=130
hres@mpMinLonF=50
hres@mpMaxLatF=70
hres@mpMinLatF=10

;potential temperature
tres=True 
tres@gsnDraw=False
tres@gsnFrame=False 
tres@cnLineLabelsOn=True 
tres@gsnAddCyclic=False

tres@cnLinesOn=True 
tres@cnFillOn=False 
tres@cnLineDashPattern=2
tres@cnLevelSpacingF=4
tres@stMinDistanceF=0.1

;streamline 
;res=True
;res@gsnDraw=False
;res@gsnFrame=False 

;res@trXMaxF=130
;res@trXMinF=50
;res@trYMaxF=70
;res@trYMinF=10

;plot command
copy_VarCoords(uwnd(0,:,:), t_jja)
copy_VarCoords(uwnd(0,:,:), t_djf)
copy_VarCoords(uwnd(0,:,:), u_dif_jja)
copy_VarCoords(uwnd(0,:,:), v_dif_jja)
copy_VarCoords(uwnd(0,:,:), u_dif_djf)
copy_VarCoords(uwnd(0,:,:), v_dif_djf)

plot=new(2, graphic)
base=new(2, graphic)

base(0)=gsn_csm_streamline_contour_map(wks, u_dif_jja, v_dif_jja, hgt, hres)
base(1)=gsn_csm_streamline_contour_map(wks, u_dif_djf, v_dif_djf, hgt, hres)
plot(0)=gsn_csm_contour(wks, t_jja, tres)
plot(1)=gsn_csm_contour(wks, t_djf, tres)

overlay(base(0), plot(0))
draw(base(0))
frame(wks)
overlay(base(1), plot(1))
draw(base(0))
frame(wks)

end 