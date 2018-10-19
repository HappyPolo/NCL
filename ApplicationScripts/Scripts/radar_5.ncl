;**************************************************************
; radar_5.ncl
;
; Concepts illustrated:
;   - Drawing four radar plots in a page, each using different colormap
;   - Plotting radar (r,theta) data, treat like station data.
;   - Adding radar grid circles and lines with polylines
;   - Reading binary data using "cbinread"
;**************************************************************
;This example was contributed by QinRui, 262990004@qq.com.
;**************************************************************
;
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"

begin
  res                      = True

  res@gsnDraw              = False
  res@gsnFrame             = False
  res@gsnMaximize          = True

  res@cnFillOn             = True
  res@cnLinesOn            = False
  res@cnFillMode           = "RasterFill"
  res@cnLevelSelectionMode = "ExplicitLevels"

  res@lbOrientation        = "Vertical"
  res@lbRasterFillOn       = False
  res@lbBoxLinesOn         = False

;---------read data, (de,ku) means (theta,r) ->(364,1000)--------------
  de_sum = 364
  ref  = cbinread("ref.dat",de_sum*1000,"float")
  zdr  = cbinread("zdr.dat",de_sum*1000,"float")
  vel  = cbinread("vel.dat",de_sum*1000,"float")
  rohv = cbinread("rohv.dat",de_sum*1000,"float")
  de   = cbinread("degree.dat",de_sum,"float")

  ref@_FillValue  =   95.5
  zdr@_FillValue  = -327.68
  vel@_FillValue  =   -7.055118
  rohv@_FillValue =  -32.768

;-------------make the 1D XArray and YArray------------------------
  x = new(de_sum*1000,"float")
  y = new(de_sum*1000,"float")
  do d=0,de_sum-1
    rad=de(d)/360*3.14*2
    sin_=sin(rad)
    cos_=cos(rad)
    do ku=0,999
      x(d*1000+ku)=sin_*ku*0.15
      y(d*1000+ku)=cos_*ku*0.15
    end do
  end do

;---Set coordinate arrays
  res@sfXArray = x
  res@sfYArray = y

;------------open wks------------------------------------------------
  wks=gsn_open_wks("png","radar")   ; send graphics to PNG file
  cmap = read_colormap_file("radar_qinrui") ; read color map data

  setvalues wks
    "wkForegroundColor":(/1.,1.,1./)
    "wkBackgroundColor":(/0.,0.,0./)
  end setvalues

;----ploting with local resources and colormap for each 1 of 4--------
  plot = new(4,"graphic")

  res@gsnLeftString        = "REF"
  res@gsnRightString       = "dBz"
  res@cnLevels             = fspan(0,65,14)
  res@cnFillPalette        = cmap(:14,:)

  plot(0) = gsn_csm_contour(wks,ref,res)

  res@gsnLeftString        = "ZDR"
  res@gsnRightString       = "dB"
  res@cnLevels             = (/-6,-5,-4,-3,-2,-1,-0.5,0.5,1,2,3,4,5,6/)
  res@cnFillPalette        = cmap(15:29,:)
  plot(1) = gsn_csm_contour(wks,zdr,res)

  res@gsnLeftString        = "VEL"
  res@gsnRightString       = "m/s"
  res@cnLevels             = fspan(-6,7,14)
  res@cnFillPalette        = cmap(30:44,:)
  plot(2) = gsn_csm_contour(wks,vel,res)

  res@gsnLeftString        = "ROHV"
  res@gsnRightString       = "1"
  res@cnLevels             = (/0.06,0.5,0.6,0.7,0.8,0.85,0.9,0.92,0.93,\
                               0.94,0.95,0.96,0.97,0.98/)
  res@cnFillPalette        = cmap(45:59,:)
  plot(3) = gsn_csm_contour(wks,rohv,res)

;-------adding radar grid circles and lines with polylines----------------
  poly = new((/4,7,400/),"graphic")

  pl    = True
  theta = fspan(0,6.28,400)
  c     = cos(theta)
  s     = sin(theta)
  r     = fspan(-150,150,200)

  do grh=0,3
    poly(grh,0,0) = gsn_add_polyline(wks,plot(grh),c*150,s*150,pl)
    do i=0,398,2
      poly(grh,1,i/2) = gsn_add_polyline(wks,plot(grh),c(i:i+1)*100, \
                                                       s(i:i+1)*100,pl)
    end do
    do i=0,396,4
      poly(grh,2,i/4)=gsn_add_polyline(wks,plot(grh),c(i:i+2)*50, \
                                                     s(i:i+2)*50,pl)
    end do
    do i=0,198,2
      poly(grh,3,i/2)=gsn_add_polyline(wks,plot(grh),r(i:i+1)*cos(0),\
                                                     r(i:i+1)*sin(0),pl)
      poly(grh,4,i/2)=gsn_add_polyline(wks,plot(grh),r(i:i+1)*cos(1.57), \
                                                     r(i:i+1)*sin(1.57),pl)
      poly(grh,5,i/2)=gsn_add_polyline(wks,plot(grh),r(i:i+1)*cos(3.14/4), \
                                                     r(i:i+1)*sin(3.14/4),pl)
      poly(grh,6,i/2)=gsn_add_polyline(wks,plot(grh),r(i:i+1)*cos(3.14/4), \
                                                    -r(i:i+1)*sin(3.14/4),pl)
    end do
  end do ;grh

;-------------panel and done--------------------------------------------
  pnl                      = True
  pnl@gsnMaximize          = True
  pnl@gsnPaperOrientation  = "portrait"
  pnl@txString             = "DualPol_Radar 20110729_07:31_BJT 2.4~S~o~N~"

  gsn_panel(wks,plot,(/2,2/),pnl)
end
