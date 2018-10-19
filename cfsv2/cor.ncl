load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl"

begin

ystt=198301
ylst=201012

;---South China 
latNN = 30
latSS = 20
lonRR = 120
lonLL = 110

season = "DJF"

;================================================================================== get lat/lon metadata
;read precipitation data
dir="ls /home/yangsong3/data/observation/GPCC/"
filename = "precip.mon.total.1x1.v7.nc"

fils = systemfunc(dir + filename)

f1   = addfile(fils,"r")

time = f1->time
YYYYMM = cd_calendar(time, -1) 
print(min(YYYYMM))
print(max(YYYYMM))


iYYYYMM = ind(YYYYMM.ge.ystt.and.YYYYMM.le.ylst)

pre = f1->precip(iYYYYMM,:,:)
var = pre
pre := pre/30
copy_VarMeta(var, pre)
pre@units = "mm/d"
printVarSummary(pre)
delete(var)

dim      = dimsizes(pre)
pr_clm   = month_to_season(pre, season)

printVarSummary(pr_clm)

pr_mn_cfsr  = dim_avg_n_Wrap(pr_clm(:,{20:26},{105:120}), (/1,2/))

printVarSummary(pr_mn_cfsr)

delete([/dir, filename, fils, f1, time, iYYYYMM, YYYYMM, dim, pr_clm/])

;=================================================================================== CFSv2 data
dim = dimsizes(pre)
delete(pre)

jlat = dim(1)
ilon = dim(2)
delete(dim)

dir="ls /home/yangsong3/lcz/data/cfsv2_output/pre/"
filename = "pre.em24.out.nc"

fils = systemfunc(dir + filename)

f1   = addfile(fils,"r")

time = f1->time
YYYYMM = cd_calendar(time, -1) 

iYYYYMM = ind(YYYYMM.ge.ystt.and.YYYYMM.le.ylst)

var = f1->pre(iYYYYMM,:,:,:)
printVarSummary(var)

u = g2fsh(var,(/jlat,ilon/))
u = u*86400
copy_VarCoords_2(var, u)
u!2 = "lat"
u!3 = "lon"
u&lat = fspan(-89.5, 89.5, 180)
u&lon = fspan(0.5, 359.5, 360)
u&lat@units   = "degrees_north"
u&lon@units   = "degrees_east"

dim    = dimsizes(u)
u_mon  = onedtond(ndtooned(u), (/dim(0)/12, 12, dim(1), dim(2), dim(3)/))
u_mon!0 = "year"
u_mon!1 = "month"
u_mon!2 = "lead"
u_mon!3 = "lat"
u_mon!4 = "lon"
u_mon&year = ispan(1983, 2010, 1)
u_mon&lat = u&lat
u_mon&lon = u&lon

;South China 105-120E, 20-28N
pr_cfsv2 = dim_avg_n_Wrap(u_mon(:,:,:,{latSS:latNN},{lonLL:lonRR}), (/3,4/))
printVarSummary(pr_cfsv2)

pr_mn_cfsv2 = new((/dim(0)/12, dim(1)-2/), typeof(pr_cfsv2), getFillValue(pr_cfsv2))

do i =0, 7  ;lead month, the longest lead month is 7-lead because of the Feb.
    pr_mn_cfsv2(:,i) = (pr_cfsv2(:, 5, i)+pr_cfsv2(:, 6, i+1)+pr_cfsv2(:, 7, i+2))/3  ;i+0-lead month of Apr., i+1-lead month of May., i+2-lead month of Jun
end do 
copy_VarCoords_1(pr_cfsv2(year|:,lead|:,month|:), pr_mn_cfsv2)
pr_mn_cfsv2!1 = "lead"
printVarSummary(pr_mn_cfsv2)

delete([/dir, filename, fils, f1, time, ystt, ylst, iYYYYMM, YYYYMM, var, u, dim, u_mon/])

;------------------------------------------------------------------------------------
; dtrend and standardize before FFT

;pr_cfsv2     = dtrend_msg_n(pr_cfsv2&year, pr_cfsv2, True, False, 0)
;pr_mn_cfsv2 = dtrend_msg_n(pr_mn_cfsv2&year, pr_mn_cfsv2, True, False, 0)

pr_mn_cfsr  = dim_standardize_n_Wrap(pr_mn_cfsr, 1, 0)
pr_mn_cfsv2 = dim_standardize_n_Wrap(pr_mn_cfsv2, 1, 0)


;------------------------------------------------------------------------------------
; correlation
r_pr_mn = new((/8/), typeof(pr_mn_cfsv2), getFillValue(pr_mn_cfsv2))

do j=0,7
  r_pr_mn(j) = escorc_n(pr_mn_cfsr, pr_mn_cfsv2(:,j), 0, 0)
end do 

print("month_"+season+" = "+r_pr_mn)
;------------------------------------------------------------------------------------------------------------------------------------
;plots
;------------------------------------------------------------------------------------------------------------------------------------
wks=gsn_open_wks("png","/home/yangsong3/lcz/ncl/plots/first_rainy/non_filter/cfsv2/test")
;gsn_define_colormap(wks,"sunshine_9lev")              ; choose colormap
plot  = new(4,graphic)


;-----draw interannual index and linear trend 

x=ispan(1983, 2010, 1)
dim=dimsizes(x)
y1=new((/4,dim(0)/),typeof(pr_mn_cfsv2), getFillValue(pr_mn_cfsv2))
y1(0,:)  = pr_mn_cfsr
y1(1:3,:) = pr_mn_cfsv2(lead|0:2,year|:)


res                   = True  
res@gsnDraw           = False                   
res@gsnFrame          = False

res@xyLineThicknessF  = 3.5
res@vpHeightF         = 0.3                      ; change aspect ratio of plot
res@vpWidthF          = 0.7     

res@tmYUseLeft        = False ; Make right axis independent of left 
res@trXMinF           = min(x)-0.5
res@trXMaxF           = max(x)+0.5
res@trYMaxF           = 4
res@trYMinF           = -4


res@gsnYRefLine         = 0  
res@xyLineColors = (/"black","red","chartreuse4","darkgoldenrod4"/)
res@xyLineThicknessF  = 3

res@tmYROn            = False ; Turn off right tickmarks 
res@tmXTOn            = False ; Turn off top tickmarks 

; Change y axis string and color for each plot.
;--- March
res@gsnLeftString     = season
res@tiYAxisString     = " " 
xy1 = gsn_csm_xy(wks,x,y1,res)

draw(xy1)

;***********************************************
; legend resources
;***********************************************
 lgres                    = True
 lgres@lgLineColors       = (/"black","red","chartreuse4","darkgoldenrod4"/)    ; colors for legend lines
 lgres@vpWidthF           = 0.1                   ; width of legend (NDC)
 lgres@vpHeightF          = 0.1                   ; height of legend (NDC)
 lgres@lgPerimOn          = False                 ; turn off perimeter
 lgres@lgDashIndexes      = (/0,0,0,0/)              ; dash indexes
 lgres@lgLineThicknessF   = 3
 lgres@lgLineLabelStrings = (/" "," "," "," "/)             ; no labels in lines

gsn_legend_ndc(wks,3,(/"OBS","LM0","LM1","LM2"/),0.45,0.95,lgres)

frame(wks) 


;------------------------------------------------------------------------------- correlation coeficent in different lead time 
x:=ispan(0, 7, 1)
y1 := r_pr_mn

res                   = True  
res@gsnDraw           = False                   
res@gsnFrame          = False

res@vpHeightF         = 0.3                      ; change aspect ratio of plot
res@vpWidthF          = 0.7            

res@tmYUseLeft        = False ; Make right axis independent of left 
res@trXMinF           = min(x)
res@trXMaxF           = max(x)
res@trYMaxF           = 1
res@trYMinF           = -1  
res@tiXAxisString    = "lead month"
res@tmXBMode          = "Explicit"
res@tmXBValues        = x
res@tmXBLabels        = (/"0","1","2","3","4","5","6","7"/);(/"3","4","5","6","7"/)

res@gsnYRefLine      := (/-0.37,0,0.37/)
res@gsnYRefLineThicknesses = 1.5 
res@gsnYRefLineDashPatterns = (/1,0,1/)
res@gsnYRefLineColors := "black"
res@xyLineColors      := "black"
res@xyLineThicknessF  := 4
;res@xyMarkLineMode    = "MarkLines"
;res@xyMarker          = 16
;res@xyMarkerColor     = "black"

res@tmYROn            = False ; Turn off right tickmarks 
res@tmXTOn            = False ; Turn off top tickmarks 


res@gsnLeftString = "(b)"
res@tiYAxisString     = season
xy1 = gsn_csm_xy(wks,x,y1,res)


; Add some text strings to the plot
                 ; Nine text strings

   txres               = True             
   txres@txFont        = "helvetica" 
   txres@txFontHeightF = 0.015
   txid = gsn_add_text (wks,xy1,"R(0)="+r_pr_mn(0), 1.3, 0.8 ,txres)


draw(xy1)

frame(wks) 


end 