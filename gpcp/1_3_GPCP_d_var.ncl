 load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
 load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
begin
f0=addfile("/mnt/e/data/USGS_gtopo30.nc","r")
f2=addfile("/mnt/e/data/precip.mon.mean.nc","r")

hgt=f0->PHIS
pr0=f2->precip(0:359,:,:) ;1979-2008

;***************************************************************
;;compute;;

  dsizes_pr0 = dimsizes(pr0)
  nlat       = dsizes_pr0(1)
  mlon       = dsizes_pr0(2)
pr=new((/30,nlat,mlon/),"float")
  x=j*12+5
  do j=0,29
  y=j*12+8
  pr(j,:,:)  =pr0(y,:,:)
  ;dim_avg_n_Wrap(pr0(x:y,:,:),0) ;;Jun to Sept
  end do
;printVarSummary(pr)

pr_d=dtrend_msg_n(ispan(0,29,1),pr,True,True,0)
copy_VarCoords(pr,pr_d)
pr_var  = dim_variance_n_Wrap(pr_d,0) ;;compute variance

;;create plots;;
        wks = gsn_open_wks("x11","GPCP_Sept_var")

        res = True
;;set map;;
        res@mpMinLatF                   = 0
        res@mpMaxLatF                   = 60
        res@mpMinLonF                   = 30
        res@mpMaxLonF                   = 140
        res@mpFillOn                    = False
        res@mpOutlineOn                 = True
        res@gsnDraw      =  False                   ; do not draw the plot
        res@gsnFrame     =  False

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;set contour1;;

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
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;plot;;

        contour1 = gsn_csm_contour_map(wks,pr_var,res)
        contour2 = gsn_csm_contour(wks,hgt,sres)

        overlay(contour1,contour2)

  draw(contour2)
  frame(wks)  
end

