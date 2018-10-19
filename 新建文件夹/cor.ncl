load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
begin

ystt=198301
ylst=201012

;---South China 
latNN = 20
latSS = 10
lonRR = 105
lonLL = 95

;================================================================================== get lat/lon metadata
;read precipitation data
dir="ls /home/yangsong3/data-observation/GPCP-precip/"
filename = "precip.mon.mean.nc"

fils = systemfunc(dir + filename)

f1   = addfile(fils,"r")

time = f1->time
YYYYMM = cd_calendar(time, -1) 
print(min(YYYYMM))
print(max(YYYYMM))


iYYYYMM = ind(YYYYMM.ge.ystt.and.YYYYMM.le.ylst)

pre = f1->precip(iYYYYMM,:,:)
var = pre
copy_VarMeta(var, pre)
pre@units = "mm/d"
printVarSummary(pre)
delete(var)

dim      = dimsizes(pre)
pr_clm   = onedtond(ndtooned(pre),(/dim(0)/12,12,dim(1),dim(2)/))
pr_clm!0 = "year"
pr_clm!1 = "month"
pr_clm!2 = "lat"
pr_clm!3 = "lon"
copy_VarCoords_1(pre(lat|:,lon|:,time|:), pr_clm(lat|:,lon|:,year|:,month|:))
pr_clm&year  = ispan(1983, 2010, 1)
printVarSummary(pr_clm)

pr_cfsr = dim_avg_n_Wrap(pr_clm(:,:,{20:26},{105:120}), (/2,3/))
printVarSummary(pr_cfsr)

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
u&lat = fspan(-89.5, 89.5, jlat)
u&lon = fspan(0.5, 359.5, ilon)
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
pr_cfsv2 = dim_avg_n_Wrap(u_mon(:,:,:,\
         {latSS:latNN},{lonLL:lonRR}), (/3,4/))
printVarSummary(pr_cfsv2)


delete([/dir, filename, fils, f1, time, ystt, ylst, iYYYYMM, YYYYMM, var, u, dim, u_mon/])

;------------------------------------------------------------------------------------
; dtrend and standardize before FFT

;pr_cfsv2     = dtrend_msg_n(pr_cfsv2&year, pr_cfsv2, True, False, 0)
;pr_mn_cfsv2 = dtrend_msg_n(pr_mn_cfsv2&year, pr_mn_cfsv2, True, False, 0)

pr_cfsr     = dim_standardize_n_Wrap(pr_cfsr, 1, 0)
pr_cfsv2    = dim_standardize_n_Wrap(pr_cfsv2, 1, 0)



;------------------------------------------------------------------------------------
; correlation
r_pr = new((/12, 10/), typeof(pr_cfsv2), getFillValue(pr_cfsv2))

do i=0,11
    do j=0,9
        r_pr(i,j) = escorc_n(pr_cfsr(:,i), pr_cfsv2(:,i,j), 0, 0)
    end do 
end do 


;------------------------------------------------------------------------------------------------------------------------------------
;plots
;------------------------------------------------------------------------------------------------------------------------------------
wks=gsn_open_wks("x11","test")
gsn_define_colormap(wks, "BlAqGrYeOrRe")
plot  = new(4,graphic)

mon = (/"Jan","Feb","Mar","Apr","May","Jun","Jul","Aug","Sep","Oct","Nov","Dec"/)
do i=0,11
;-----draw interannual index and linear trend 

x=ispan(1983, 2010, 1)
dim=dimsizes(x)
y1=new((/4,dim(0)/),typeof(pr_cfsv2), getFillValue(pr_cfsv2))
y1(0,:)  = pr_cfsr(:,i)
y1(1:3,:) = pr_cfsv2(lead|0:2,month|i,year|:)


res                   = True  
res@gsnDraw           = False                   
res@gsnFrame          = False

res@xyLineThicknessF  = 3.5
res@vpHeightF         = 0.3                      ; change aspect ratio of plot
res@vpWidthF          = 0.7 
res@vpYF              = 0.85    

res@tmYUseLeft        = False ; Make right axis independent of left 
res@trXMinF           = min(x)-0.5
res@trXMaxF           = max(x)+0.5
res@trYMaxF           = 4
res@trYMinF           = -4


res@gsnYRefLine         = 0  
;res@xyLineColors = (/"black","red","chartreuse4","darkgoldenrod4"/)
res@xyLineThicknessF  = 3

res@tmYROn            = False ; Turn off right tickmarks 
res@tmXTOn            = False ; Turn off top tickmarks 

; Change y axis string and color for each plot.
;--- March
res@gsnLeftString     = "(a)"
res@gsnRightString     = mon(i)
res@tiYAxisString     = " " 
xy1 = gsn_csm_xy(wks,x,y1,res)

draw(xy1)

;***********************************************
; legend resources
;***********************************************
 lgres                    = True
 ;lgres@lgLineColors       = (/"black","red","chartreuse4","darkgoldenrod4"/)    ; colors for legend lines
 lgres@vpWidthF           = 0.1                   ; width of legend (NDC)
 lgres@vpHeightF          = 0.07                   ; height of legend (NDC)
 lgres@lgPerimOn          = False                 ; turn off perimeter
 lgres@lgDashIndexes      = (/0,0,0,0/)              ; dash indexes
 lgres@lgLineThicknessF   = 3
 lgres@lgLineLabelStrings = (/" "," "," "," "/)             ; no labels in lines

gsn_legend_ndc(wks,3,(/"OBS","LM0","LM1","LM2"/),0.6,0.85,lgres)

;frame(wks) 


;------------------------------------------------------------------------------- correlation coeficent in different lead time 
x:=ispan(0, 9, 1)
y1 := r_pr(i,:)

res                   = True  
res@gsnDraw           = False                   
res@gsnFrame          = False

res@vpHeightF         = 0.3                      ; change aspect ratio of plot
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
res@tmXBLabels        = (/"0","1","2","3","4","5","6","7","8","9"/);(/"3","4","5","6","7"/)

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

res@gsnLeftString  = "(b)"
res@gsnRightString = " "
res@tiYAxisString     = "Correlation"
xy1 = gsn_csm_xy(wks,x,y1,res)


; Add some text strings to the plot
                 ; Nine text strings

   txres               = True             
   txres@txFont        = "helvetica" 
   txres@txFontHeightF = 0.015
   txid = gsn_add_text (wks,xy1,"R(0)="+r_pr(i,0), 1.3, 0.8 ,txres)


draw(xy1)

frame(wks) 

delete([/x, y1,xy1, res/])
end do 
end 
