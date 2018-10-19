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
assignFillValue(pe, pc)

wks=gsn_open_wks("png","/home/ys-ug/fei_cy/correl")
plot  = new(4,graphic)
base  = new(4,graphic)
plotb = new(4,graphic)

;calculations
dim      = dimsizes(pe)
pr_clm   = onedtond(ndtooned(pe),(/dim(0)/12,12,dim(1),dim(2)/))
pr_clm!0 = "year"
pr_clm!1 = "month"
pr_clm!2 = "lat"
pr_clm!3 = "lon"
copy_VarCoords_1(pe(lat|:,lon|:,time|:), pr_clm(lat|:,lon|:,year|:,month|:))
pr_clm&year  = ispan(1983, 2010, 1)

dim    = dimsizes(pc)
u_mon  = onedtond(ndtooned(pc), (/dim(0)/12, 12, dim(1), dim(2)/))
u_mon!0 = "year"
u_mon!1 = "month"
u_mon!2 = "lat"
u_mon!3 = "lon"
copy_VarCoords_1(pe(lat|:,lon|:,time|:), u_mon(lat|:,lon|:,year|:,month|:))
u_mon&year = ispan(1983, 2010, 1)

era_JJA=(pr_clm(:,6,:,:)+pr_clm(:,7,:,:)+pr_clm(:,5,:,:))/3
cfsv2_JJA=(u_mon(:,6,:,:)+u_mon(:,7,:,:)+u_mon(:,5,:,:))/3

pr_era      = dim_standardize_n_Wrap(pr_clm, 1, 0)
pr_cfsv2    = dim_standardize_n_Wrap(u_mon, 1, 0)
era_std     = dim_standardize_n_Wrap(era_JJA, 1, 0)
cfsv2_std   = dim_standardize_n_Wrap(cfsv2_JJA, 1, 0)
name=(/"JJA","JUN","JUL","AUG"/)

r_pr = new((/4, 121, 240/), typeof(pr_cfsv2), getFillValue(pr_cfsv2))
pro=new((/28,4, 121, 240/), typeof(pr_cfsv2), getFillValue(pr_cfsv2))
prob=new((/4, 121, 240/), typeof(pr_cfsv2), getFillValue(pr_cfsv2))
era_a=dim_avg_n_Wrap(era_std, 0)
cfsv2_a=dim_avg_n_Wrap(cfsv2_std, 0)
era_avg=dim_avg_n_Wrap(pr_era, 0)
cfsv2_avg=dim_avg_n_Wrap(pr_cfsv2, 0)

;era_var=dim_variance_n_Wrap(pr_era, 0)
;cfsv2_var=dim_variance_n_Wrap(pr_cfsv2, 0)
;era_v=dim_variance_n_Wrap(era_std, 0)
;cfsv2_v=dim_variance_n_Wrap(cfsv2_std, 0)

do i=0,120
    do j=0,239
        r_pr(0,i,j) = escorc_n(era_std(:,i,j), cfsv2_std(:,i,j), 0, 0)
        pro(:,0,i,j)= student_t(era_std(:,i,j), cfsv2_std(:,i,j))
        do k=1,3
        	r_pr(k,i,j) = escorc_n(pr_era(:,k+4,i,j), pr_cfsv2(:,k+4,i,j), 0, 0)
            pro(:,k,i,j) = student_t(pr_era(:,k+4,i,j), pr_cfsv2(:,k+4,i,j))
        end do 
    end do 
end do 
prob=dim_avg_n_Wrap(pro, 0)
copy_VarCoords(pr_clm(0,0,:,:), r_pr(0,:,:))
copy_VarCoords(pr_clm(0,0,:,:), prob(0,:,:))
res=True
res@gsnDraw=False
res@gsnFrame=False
res@gsnAddCyclic=False
res@cnLinesOn=False
res@pmTickMarkDisplayMode="Always"

res@gsnRightString="mm/day"

res@cnFillOn=True
res@cnLevelSelectionMode="ExplicitLevels"
res@cnLevels=(/-0.8,-0.6,-0.4,-0.2,0,0.2,0.4,0.6,0.8/)
res@cnFillColors=(/80,90,100,110,120,140,150,160,170,180/)
res@lbLabelBarOn=False

res@mpMaxLatF=60
res@mpMinLatF=-10
res@mpMaxLonF=160
res@mpMinLonF=40
plot=gsn_csm_contour_map(wks, prob(0,:,:), res)
end 