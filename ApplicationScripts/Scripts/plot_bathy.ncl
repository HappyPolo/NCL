;----------------------------------------------------------------------
; Concepts illustrated:
;   - Drawing bathymetry of an ocean model
;   - Overlaying line contours on filled contours
;   - Drawing polylines on a map
;   - Drawing hatched polygons
;   - Adding text to a map
;   - Using Python colorbars for NCL
;----------------------------------------------------------------------
; This script was contributed by Nicolas Barrier, a PhD student at 
; Laboratoire de Physique des Oceans, Brest (FRANCE)
;----------------------------------------------------------------------
;
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
;
; This file still has to be loaded manually
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl"

; Function that generates levels from min, max, step
undef("create_levels")
function create_levels(m:numeric,M:numeric,ecart:numeric)
local n
begin
n=floattointeger((M-m)/ecart)
test=fspan(m,M,n+1)
statut=new(dimsizes(test),string)
do indtest=0,dimsizes(test)-1
  statut(indtest)="NoLine"
end do

iii=ind(test.eq.0)
if(.not.ismissing(iii))
  statut(iii)="LineOnly"
end if

test@statut=statut
test@indice=iii
return(test)
end

begin

  ; Define the domain limits
  latmin=25
  latmax=80
  lonmin=-90
  lonmax=22

  ; Read the mesh file of the models
  dirin="./"
  fin=addfile(dirin+"mesh_g85_fcvar.nc","r")
  tmask=fin->tmask(0,0,:,:)
  lon=fin->nav_lon ; longitude
  lat=fin->nav_lat ; latitude
  bathyi=fin->hdept ; model bathymetry
  bathy=(/bathyi(0,:,:)/1000./) ; convert to kilometers
  bathy=mask(bathy,tmask.eq.0,False) ; masking
  sss=dimsizes(lon)
  nlat=sss(0)

  wks=gsn_open_wks("png",get_script_prefix_name()) ; send graphics to PNG file
  cmap = read_colormap_file("GMT_ocean_py") ; Loading of the python colorbar
  cmap = cmap(::-1,:) ; reverse the colorbar

  ; Define the resources for the filled contours
  
  res=True
  
  ; gsn resources
  res@gsnDraw=False
  res@gsnFrame=False
  res@gsnSpreadColors=True
  res@gsnSpreadColorEnd=129
  res@gsnSpreadColorStart=2

  ;sf resources
  res@sfXArray=lon
  res@sfYArray=lat

  ; cn resources
  res@cnFillOn=True
  res@cnFillPalette=cmap(:127,:)
  res@cnFillMode="RasterFill"
  res@cnLevelSelectionMode="ExplicitLevels"
  res@cnLevels=create_levels(0,10,0.1)
  res@cnLinesOn=False
  res@cnFillDrawOrder="PreDraw"

  ; mp resources
  res@mpLimitMode="LatLon" 
  res@mpMinLatF=latmin
  res@mpMinLonF=lonmin
  res@mpMaxLatF=latmax
  res@mpMaxLonF=lonmax
  res@mpFillOn=True
  res@mpLandFillColor=newindex
  res@mpInlandWaterFillColor=newindex

  ; lb resources
  res@lbLabelStride=10
  res@lbTitleString="Bathymetry (km)"
  res@lbTitlePosition="Bottom"
  res@lbTitleFontHeightF=0.015
 
  ; Define the resources for the line contours

  res2=res
  delete(res2@cnLevels)
  res2@cnLevels=ispan(0,10,1)
  res2@cnFillOn=False
  res2@cnLinesOn=True
  res2@cnMonoLineColor=True
  res2@cnLineColor="black"
  res2@cnLineLabelsOn=False
  res2@cnInfoLabelOn=False

  map=gsn_csm_contour_map(wks,bathy(:nlat-2,1:),res) ; draw the filled contours
  plot2=gsn_csm_contour(wks,bathy(:nlat-2,1:),res2) ; overlay the line contours
  overlay(map,plot2)
 
  ; Definition of the section coordinates

  dsox=(/-34,-22/)
  dsoy=(/68.,65.5/)
  
  ifox=(/-15.,-7.5/)
  ifoy=(/65.,62.5/)
      
  fsox=(/-7.5,-5./)
  fsoy=(/62.5,58./)
      
  mdnx=(/-3,7/)
  mdny=(/57,60/)

  nonx=(/-22.,-0.5,15./)
  nony=(/77.5,77.,78./)

  barx=(/18,15/)
  bary=(/69,78/)
  
  marx=(/-21.065,-34.685,-35.459,-29.887,-29./)
  mary=(/64.86,56.189,53.036,52.011,43./)
  
  qdex=(/-29,-9/)
  qdey=(/43,52/)
  
  qdwx=(/-29,-49,-53/)
  qdwy=(/43,42,47/)

  bafx=(/-64,-52/)
  bafy=(/66,67/)
  
  hudx=(/-65,-66/)
  hudy=(/59,64/)
  
  itsx=(/-6,-4/)
  itsy=(/55,57/)
  
  spux=(/-56.355,-56.2/)
  spuy=(/52.406,51.223/)
  
  ; section lines resources
  lres=True
  lres@gsLineThicknessF = 4.0            ; line thickness   
  lres@gsLineColor      = newindex      ; color of lines

  dum1 = gsn_add_polyline(wks,map,dsox , dsoy ,lres)
  dum2 = gsn_add_polyline(wks,map,ifox , ifoy ,lres)
  dum3 = gsn_add_polyline(wks,map,fsox , fsoy ,lres)
  dum4 = gsn_add_polyline(wks,map,spux , spuy ,lres)
  dum5 = gsn_add_polyline(wks,map,marx , mary ,lres)
  dum6 = gsn_add_polyline(wks,map,qdwx , qdwy ,lres)
  dum7 = gsn_add_polyline(wks,map,qdex , qdey ,lres)
  dum8 = gsn_add_polyline(wks,map,itsx , itsy ,lres)
  dum9 = gsn_add_polyline(wks,map,bafx , bafy ,lres)
  dum10 = gsn_add_polyline(wks,map,hudx , hudy ,lres)
  dum11 = gsn_add_polyline(wks,map,mdnx , mdny ,lres)
  dum12 = gsn_add_polyline(wks,map,nonx , nony ,lres)
  dum13 = gsn_add_polyline(wks,map,barx , bary ,lres)
  
  ; resources for the filled polygones
  polres=True
  polres@gsFillIndex=newindex
  polres@gsFillColor  =newindex
  
  
  polres@gsFillIndex=17 ; change the hatching patterns 
  x=(/-21.065, -34.685, -35.459, -29.887, -29.,-29, -49, -53,-56.355, -56.2,-65, -66,-64, -52,-34, -22/)
  y=(/64.86 ,  56.189,  53.036,  52.011,  43., 43, 42, 47,52.406,  51.223,59, 64,66, 67,68.,   65.5/)
  dum14=gsn_add_polygon(wks,map,x,y,polres)
  delete(x)
  delete(y)

  polres@gsFillIndex=3 ; change the hatching patterns 
  x=(/-6, -4,-5.,-7.5,-7.5,-15. ,-21.065, -34.685, -35.459, -29.887, -29.,-29,  -9      /)
  y=(/55, 57,58.,62.5,62.5,65.,64.86 ,  56.189,  53.036,  52.011,  43.,43, 52   /)
  dum15=gsn_add_polygon(wks,map,x,y,polres)
  delete(x)
  delete(y)

  polres@gsFillIndex=4 ; change the hatching patterns 
  x=(/-34, -22,-15. ,  -7.5,-7.5, -5.,-3 , 7,18, 15,15,-0.5,-22/)
  y=(/68.,   65.5,65.,   62.5,62.5,  58.,57, 60,69, 78,78,77,77.5/)
  dum16=gsn_add_polygon(wks,map,x,y,polres)
  delete(x)
  delete(y)
  
  ; Names of the sections with their coordinates
  names=(/"dso","ifo","fso","mdn","non","bar","mar","42e","42w","baf","hud","its","spu"/)
  lonlab=(/-28.0, -11.25, -6.25, 2.0-1, -2.5, 16.5+1, -30.019200000000001-3.5, -19.0, -43.666666666666664, -58.0-1, -65.5-5, -5.0, -56.277500000000003-5/)
  latlab=(/68.75, 63.75+2, 60.25+2, 58.5-1, 77.5+2, 73.5, 53.819200000000002+1, 47.5, 44.0-2, 66.5+3, 61.5, 56.0, 51.814499999999995/)
  
  ; Text resources
  txres               = True
  txres@txFontHeightF = 0.012
  txres@txFont        = "helvetica-bold"
  txres@txJust ="topLeft"
  
  ; Write the names of the sections
  i=0
  text0 = gsn_add_text(wks,map,names(i),lonlab(i),latlab(i),txres)
  i=1
  text1 = gsn_add_text(wks,map,names(i),lonlab(i),latlab(i),txres)
  i=2
  text2 = gsn_add_text(wks,map,names(i),lonlab(i),latlab(i),txres)
  i=3
  text3 = gsn_add_text(wks,map,names(i),lonlab(i),latlab(i),txres)
  i=4
  text4 = gsn_add_text(wks,map,names(i),lonlab(i),latlab(i),txres)
  i=5
  text5 = gsn_add_text(wks,map,names(i),lonlab(i),latlab(i),txres)
  i=6
  text6 = gsn_add_text(wks,map,names(i),lonlab(i),latlab(i),txres)
  i=7
  text7 = gsn_add_text(wks,map,names(i),lonlab(i),latlab(i),txres)
  i=8
  text8 = gsn_add_text(wks,map,names(i),lonlab(i),latlab(i),txres)
  i=9
  text9 = gsn_add_text(wks,map,names(i),lonlab(i),latlab(i),txres)
  i=10
  text10 = gsn_add_text(wks,map,names(i),lonlab(i),latlab(i),txres)
  
  ; For ifs/spu we add a line from land to the section, and add the name
  i=11
  poly1=gsn_add_polyline(wks,map,(/lonlab(i)-1,lonlab(i)+7/),(/latlab(i)-0.5,latlab(i)-7/),False)
  text11 = gsn_add_text(wks,map,names(i),lonlab(i)+7+0.3,latlab(i)-7-0.3,txres)
  
  i=12
  poly2=gsn_add_polyline(wks,map,(/lonlab(i)+5,lonlab(i)-5/),(/latlab(i),latlab(i)/),False)
  text12 = gsn_add_text(wks,map,names(i),lonlab(i)-9,latlab(i)+0.6,txres)

  draw(map)
  frame(wks)
   

end
