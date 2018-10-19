;precip 年均
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"

begin 

   f                         =addfile("/mnt/e/data/precip.mon.mean.nc", "r")
   prc                       =f->precip(0:359,:,:)
   dims                      =dimsizes(prc)
   nlat                      =dims(1)
   mlon                      =dims(2)

   prc_y                     =new((/12,nlat,mlon/), float)
   prc_yavg                  =new((/30,nlat,mlon/), float)
   plot                      =new(30, graphic)

   do i=0,29
      y=i*12
      do j=0,11,1
         prc_y(j,:,:)        =prc(y+j,:,:)
      end do
      prc_yavg(i,:,:)        =dim_avg_n_Wrap(prc_y,0)
   end do
   copy_VarCoords(prc, prc_yavg)
printVarSummary(prc_yavg)

      wks=gsn_open_wks("pdf", "/mnt/e/ncl/annual_mean_precip")
gsn_define_colormap(wks, "wh-bl-gr-ye-re")
      res                       =True
      res@cnLinesOn             =False
      res@cnFillOn              =True

      res@gsnDraw               =False
      res@gsnFrame              =False

      res@mpMaxLatF             =60
      res@mpMinLatF             =10
      res@mpMaxLonF             =140
      res@mpMinLonF             =60



      resp                      =True

  do i=0,29

      year                      =1979+i
      res@gsnLeftString         =(year)+"annual_mean_precip"
      plot(i)=gsn_csm_contour_map_ce(wks, prc_yavg(0,:,:), res)
  end do

      

  
   


end