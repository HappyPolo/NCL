;;;;;;;;;;;;;;;betainc(回归)
prc=dim_avg_n_Wrap(precip(time,lat,lon), (/0,1/))
rcu(:,:)=regCoef(prc(:),u(:,:,:))
rev(:,:)=regCoef(prc(:),v(:,:,:))
tval=onedtond((rcu@tval,dimsizes(rcu(:,:))))
df=onedtond(rcu@nptxy, dimsizes(rcu(:,:)))
b=tvalb=0.5
prob(:,:)=betainc(df/(df+tval^2), df/2.0, b)

;;;;;;;;;;;;;;;;ttest
prob=ttest(ave1, var1, 数量, ave2, var2, 数量, False, False)
plot=gsn_csm_contour(wks, prob, res)
opt=True
opt@gsnShadeFillType="pattern"
opt@gsnShadeLow    =17
opt@gsnShadeFillScaleF=0.005
opt@gsnShadeFillDotSizeF=0.02
plot=gsn_contour_shade(plot, 0.05, 100, opt)