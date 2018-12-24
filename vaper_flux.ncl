;2014年台风季——整层水汽输送
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/skewt_func.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/wind_rose.ncl" 
load "$NCARG_ROOT/lib/ncarg/nclscripts/cnmap/cnmap.ncl"


begin                            


tyname=tofloat(201409)
tystart=todouble(2014071206)
tyend=todouble(2014071918)


f1=addfile("/home/data/uwnd.2014.nc", "r")
f2=addfile("/home/data/vwnd.2014.nc","r")
f3=addfile("/home/data/shum.2014.nc","r")
f4=addfile("/home/data/pres.sfc.2014.nc","r")
ff5=asciiread("/home/data/track/tracksh_s.txt",-1,"float")
f5=asciiread("/home/data/track/tracksh_s.txt",(/(dimsizes(ff5)/4),4/),"float")
yy=f5(:,0)
xx=f5(:,1)
ist=f5(:,3)
x=xx(ind(ist.eq.tyname))
y=yy(ind(ist.eq.tyname))
t0=tystart
tt=tyend
uwnd=f1->uwnd
t=cd_calendar(f1->time,3)
level=f1->level
lat=f1->lat
lon=f1->lon
vwnd=f2->vwnd
shum=f3->shum
pres=f4->pres
p=f3->level
dlat=fspan(35,-20,toint(55/2.5+1))
dlon=fspan(45,150,toint(105/2.5+1))
u=short2flt(uwnd(ind(t.eq.t0):ind(t.eq.tt),0:7,get1Dindex(lat,dlat),get1Dindex(lon,dlon)))
v=short2flt(vwnd(ind(t.eq.t0):ind(t.eq.tt),0:7,get1Dindex(lat,dlat),get1Dindex(lon,dlon)))
q=short2flt(shum(ind(t.eq.t0):ind(t.eq.tt),:,get1Dindex(lat,dlat),get1Dindex(lon,dlon)))
ps=short2flt(pres(ind(t.eq.t0):ind(t.eq.tt),get1Dindex(lat,dlat),get1Dindex(lon,dlon)))
qu=new(dimsizes(q),"float")
qu=q*u
qv=q*v
copy_VarMeta(q,qu)
copy_VarMeta(q,qv)
linlog=1
pbot=1000
ptop=100      
g=9.8
vint_qu=vibeta(p,qu(time|:,lat|:,lon|:,level|:),linlog,ps,pbot,ptop)/g*100  
copy_VarMeta(qu(:,0,:,:),vint_qu)
vint_qv=vibeta(p,qv(time|:,lat|:,lon|:,level|:),linlog,ps,pbot,ptop)/g*100  
copy_VarMeta(qv(:,0,:,:),vint_qv)
n=dimsizes(t(ind(t.eq.t0):ind(t.eq.tt)))  
mm=sqrt(vint_qu^2+vint_qv^2)
copy_VarMeta(vint_qu,mm)


do i=0,n-1
ti=t(ind(t.eq.t0)+i)
z_qu=vint_qu(i,:,:)
z_qv=vint_qv(i,:,:)
m=mm(i,:,:)
wks =gsn_open_wks("png","vapour_flux"+i)
gsn_define_colormap(wks,"BlAqGrYeOrReVi200")    
vcres = True
vcres@gsnAddCyclic  = False 
vcres@gsnDraw      = False                        ; don't draw yet
vcres@gsnFrame     = False                        ; don't advance frame yet
vcres@mpDataSetName         = "Earth..3"   ; This new database contains  
vcres@mpDataBaseVersion     = "MediumRes"  ; Medium resolution database
vcres@mpOutlineOn           = True         ; Turn on map outlines
vcres@mpProjection          = "CylindricalEquidistant"
vcres@mpGeophysicalLineThicknessF = 0.7      ; double the thickness of geophysical boundaries
vcres@mpNationalLineThicknessF    = 1.0      ; double the thickness of national boundaries
vcres@pmTickMarkDisplayMode = "Always"
vcres@mpMinLatF         = min(dlat)                         
vcres@mpMaxLatF         = max(dlat)                        
vcres@mpMinLonF         = min(dlon)                        
vcres@mpMaxLonF         = max(dlon)                                                        
vcres@lbLabelBarOn = True
vcres@vcRefMagnitudeF         = 10.0              ; make vectors larger
vcres@vcRefLengthF            = 0.0018            ; ref vec length
vcres@vcGlyphStyle            = "CurlyVector"    ; turn on curly vectors
vcres@vcMinDistanceF          = 0.017            ; thin out vectors
vcres@vcRefAnnoOn = False
vcres@vcMonoFillArrowFillColor  = True
vcres@vcLineArrowThicknessF  = 2.0
vcres@vcRefAnnoOn  =False 
vcres@vcVectorDrawOrder= "PostDraw" 
vcres@tiMainString          ="vaper_flux : kg/(m*s)"
vcres@gsnLeftString =ti
vcres@gsnRightString ="Rammasun(1409)" 
plot=gsn_csm_vector_map(wks,z_qu,z_qv,vcres)  ; create plot 


cnres           = True
cnres@china     = True       ;draw china map or not
cnres@river     = True       ;draw changjiang&huanghe or not
cnres@province  = False       ;draw province boundary or not
cnres@nanhai    = False       ;draw nanhai or not 
cnres@diqu      = False       ; draw diqujie or not
chinamap = add_china_map(wks,plot,cnres)


txres               = True                            
txres@txFontHeightF = 0.020             ; Set the font height
txres@txPerimOn     = True
txres@txBackgroundFillColor =0
txres@txPerimColor    = 0


res                 = True                    ; plot mods desired
res@gsnDraw         = False                   ; don't draw yet
res@gsnFrame        = False                   ; don't advance frame yet
res@cnFillOn        = True                    ; turn on color
res@gsnSpreadColors = True                    ; use full colormap 
res@gsnSpreadColorStart = 0
res@gsnSpreadColorEnd   = 199
res@cnLinesOn       = False                   ; turn off contour lines
res@cnLineLabelsOn  = False                   ; tuen off line labels
res@cnInfoLabelOn =False 
res@gsnLeftString=""
res@gsnRightString=""
res@cnLevelSelectionMode="ExplicitLevels" 
res@cnLevels=(/200,300,400,500,600,700,800,900,1000/)
res@lbLabelBarOn = True
res@lbLabelStride       = 2         ; plot every other colar bar label
res@lbOrientation        = "vertical"         ; vertical label bars
res@lbLeftMarginF =-0.5
;m=smth9(m,0.5,0.25,False)
plot1 = gsn_csm_contour(wks,m,res)


overlay(plot,plot1)


mstring = "p"
fontnum = 37
xoffset = 0.0
yoffset = 0.0
ratio   = 1.0
size    = 1.0
angle   = 0.0
new_index = NhlNewMarker(wks, mstring, fontnum, xoffset, yoffset, ratio, size, angle)
mkres               = True
mkres@gsMarkerSizeF = 0.02
mkres@gsMarkerColor = "red"
mkres@gsMarkerThicknessF=5.0
mkres@gsMarkerIndex = new_index
mkres@tfPolyDrawOrder = "PostDraw"  
dum=gsn_add_polymarker(wks, plot, x(i), y(i), mkres)


delete(z_qu)
delete(z_qv)
delete(ti)
delete(m)
print(i)


maximize_output(wks,False)
end do


end 
