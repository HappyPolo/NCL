;gpcp_d.ncl
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
begin
        
  f                                    =addfile("/mnt/e/data/precip.mon.mean.nc","r")
  prc                                  =f->precip(0:359,:,:)

  dsizes                               =dimsizes(prc)
  nlat                                 =dsizes(1)
  mlon                                 =dsizes(2) 
  ;pr                                   =new((/dsizes(0),nlat,mlon/),"float")

  ;x=j*12+5
  ;do j=0,dsizes(0)
   ; pr(j,:,:)=prc(j,:,:)
  ;end do


  prd                                   =dtrend_msg_n(ispan(0,359,1), prc(0:359,:,:),True,True,0)
  copy_VarCoords(prc,prd)
  pr_var                                =dim_variance_n_Wrap(prd,0)

  wks=gsn_open_wks("x11","d_v")

  res                                   =True

  

  res@mpMaxLonF                         =140
  res@mpMinLonF                         =60
  res@mpMaxLatF                         =60
  res@mpMinLatF                         =15
res@cnFillOn             = True     ; turn on color fill
   res@cnFillPalette = "precip3_16lev"
   res@cnLinesOn            = False    ; turn of contour lines
   res@cnLineLabelsOn       =  False       ; Turn off contour lines

   res@cnLevelSelectionMode    = "ExplicitLevels"              
   res@cnLevels                = (/0.1,0.2,0.4,0.6,0.8,1.0,1.2,1.5,2.0,3.0,5.0,10.0/)

   res@lbOrientation        = "vertical"   ; vertical label barb's
   res@lbLabelFontHeightF   = 0.012        ; change font size
   res@pmLabelBarWidthF     =  0.1     
   res@pmLabelBarOrthogonalPosF = -0.01    ; move a bit to left

   res@gsnLeftString        = "Sept_d_var"
   res@gsnRightString       = ""
   res@gsnCenterString      = "GPCP"
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;set contour2;;
sres = True

sres@cnFillOn = False
sres@cnLinesOn= True
sres@cnLevelSelectionMode = "ExplicitLevels"
sres@cnLevels = (/15000.0/)
sres@cnLineLabelsOn = False
sres@cnLineThicknessF =3.0
sres@cnConstFLabelOn  =False
sres@cnInfoLabelOn    =False
        
sres@gsnDraw      =  False                   
sres@gsnFrame     =  False

sres@gsnLeftString        = ""
sres@gsnRightString       = ""
  plot =gsn_csm_contour_map(wks,pr_var, res)
end