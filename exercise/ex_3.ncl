;03.ncl
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"

begin 

   
  ;do i=1,803
  
  fv                                 =addfile("~/ncl/vwnd.mon.mean.nc", "r")
  fw                                 =addfile("~/ncl/omega.mon.mean.nc","r")
  v                                  =fv->vwnd(0,:,:,:)
  w                                  =fw->omega(0,:,:,:)

;end do

  wAVE                               =avg(w(:,:,{90}))
  vAVE                               =avg(v(:,:,{90}))
  scale                              =fabs(vAVE/wAVE)
  wscale                             =w*scale
  printVarSummary(w)
  copy_VarCoords(w, wscale)

  wks                                =gsn_open_wks("x11", "3_0")
  gsn_define_colormap(wks, "amwg256")

  res                                =True
  res@gsnLeftString                  =""
  res@gsnRightString                 =""
  res@gsnAddCyclic                   =True

  res@cnLinesOn                      =False
  res@cnFillOn                       =True
  res@cnLevelSelectionMode           ="ExplicitLevels"
  res@cnMaxLevelValF                 =1.2
  res@cnMinLevelValF                 =-0.5
  res@cnLevelSpacingF                =0.1
  res@cnFillColors                   =(/113,110,100,80,60,40,20,15,10,2,130,140,150,160,170,180,190,200/)

  
  res@vcMapDirection                 =False
  res@vcRefMagnitudeF                = 10                
  res@vcRefLengthF                   = 0.045             
  res@vcGlyphStyle                   = "CurlyVector"      
  res@vcMinDistanceF                 = 0.01               
  res@vcMapDirection                 = False
  

  plot =gsn_csm_pres_hgt_vector(wks, w(:,:,{90}), v({1000:100},:,{90}), wscale(:,:,{90}), res)

end
