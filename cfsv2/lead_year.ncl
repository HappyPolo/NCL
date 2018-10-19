load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
begin

;input data
f1=addfile("/home/ys-ug/data/era-interim/precip.mon.mean.nc", "r")
fh=addfile("/home/ys-ug/data/hgt.sfc.nc", "r")

pe=f1->r(48:383,34:44,48:74)
hgt=short2flt(fh->hgt(0,:,:))

f2=addfile("/home/yangsong3/lcz/data/cfsv2_output/pre/pre.em24.out.nc", "r")
p=(f2->pre(:,:,:,:))
pa=g2fsh_Wrap(p, (/121,240/))
pa=pa(:,:,::-1,:)
pc=pa(:,:,34:44,48:74)
pc=pc*86400

wks=gsn_open_wks("x11", "/home/ys-ug/fei_cy/lead_year")

;convertions
dim      = dimsizes(pe)
pr_clm   = onedtond(ndtooned(pe),(/dim(0)/12,12,dim(1),dim(2)/))
pr_clm!0 = "year"
pr_clm!1 = "month"
pr_clm!2 = "lat"
pr_clm!3 = "lon"
copy_VarCoords_1(pe(lat|:,lon|:,time|:), pr_clm(lat|:,lon|:,year|:,month|:))
pr_clm&year  = ispan(1983, 2010, 1)
printVarSummary(pr_clm)

pr_era = dim_avg_n_Wrap(pr_clm(:,:,:,:), (/2,3/))
printVarSummary(pr_era)
delete(dim)

dim    = dimsizes(pc)
u_mon  = onedtond(ndtooned(pc), (/dim(0)/12, 12, dim(1), dim(2), dim(3)/))
u_mon!0 = "year"
u_mon!1 = "month"
u_mon!2 = "lead"
u_mon!3 = "lat"
u_mon!4 = "lon"
u_mon&year = ispan(1983, 2010, 1)
printVarSummary(u_mon)

pr_cfsv2=dim_avg_n_Wrap(u_mon(:,:,:,:,:), (/3,4/))
printVarSummary(pr_cfsv2)
delete(dim)

;calculations
pr_era_avg=new(12,float)
pr_cfsv2_avg=new((/12,10/),float)
pr_era_avg     = dim_avg_n_Wrap(pr_era,0)
pr_cfsv2_avg    = dim_avg_n_Wrap(pr_cfsv2,0)

r_pr = new((/12, 10/), typeof(pr_cfsv2), getFillValue(pr_cfsv2))

do i=0,11
    do j=0,9
        r_pr(i,j) = escorc_n(pr_era(:,i), pr_cfsv2(:,i,j), 0, 0)
    end do 
end do 

wks=gsn_open_wks("png","lead_year")
plot  = new(4,graphic)
mon = (/"Jan","Feb","Mar","Apr","May","Jun","Jul","Aug","Sep","Oct","Nov","Dec"/)

;plot resources

x=ispan(0, 9, 1)
dim=dimsizes(x)

res                   = True  
res@vpHeightF         = 0.6                      ; change aspect ratio of plot
res@vpWidthF          = 0.7 
res@vpYF              = 0.45           

res@tmYUseLeft        = False ; Make right axis independent of left 
res@trXMinF           = min(x)
res@trXMaxF           = max(x)
res@trYMaxF           = 1
res@trYMinF           = -1  
res@tiXAxisString    = "lead month"
res@tmXBMode          = "Explicit"
res@tmXBValues        = x
res@tmXBLabels        = (/"0","1","2","3","4","5","6","7","8","9"/)

res@gsnYRefLineThicknesses = 2
res@gsnYRefLineDashPattern = 0
res@gsnYRefLineColor = "black"

res@xyLineColor      = "black"
res@xyLineThicknessF  = 4
res@xyDashPattern     =0
res@xyMarkLineModes    = (/"MarkLines","MarkLines","MarkLines","MarkLines","MarkLines","MarkLines","MarkLines","MarkLines","MarkLines","MarkLines","MarkLines","MarkLines"/)
res@xyMarkers          =(/0,1,2,3,4,5,6,7,8,9,10,11/)
res@xyMarkerSizeF=0.01
res@xyMarkerColor     = "black"

res@pmLegendDisplayMode="Always"
res@pmLegendSide="top"
res@pmLegendParallelPosF=0.75
res@pmLegendOrthogonalPosF=0
res@pmLegendWidthF=0.2
res@pmLegendHeightF=0.2
res@xyExplicitLegendLabels=(/"Jan","Feb","Mar","Apr","May","Jun","Jul","Aug","Sep","Oct","Nov","Dec"/)

res@tmYROn            = False ; Turn off right tickmarks 
res@tmXTOn            = False ; Turn off top tickmarks 
res@lgLabelFontHeightF=0.01

res@gsnLeftString  = ""
res@gsnRightString = ""
res@tiYAxisString     = "Correlation"
do i=0,11
    do k=0,9
        if (prob(i,j).lt.0.05) then
            print("month:"+i+"    "+"lead_"+j+"    "+prob(i,j))
        end if
    end do
end do

xy1 = gsn_csm_xy(wks,x,r_pr,res)


end 