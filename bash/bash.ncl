begin
	f=addfile("/mnt/f/data/NCEP/air.mon.mean.nc","r")
	t=short2flt(f->air(0:9,0,:,:))
	wks=gsn_open_wks("pdf","bash")
	res=True
	res@gsnRightString=""
	res@gsnLeftString=""
	;res@cnLevelSelectionMode="ManualLevels"
	;res@cnMinLevelValF=100
	;res@cnMaxLevelValF=300
	;res@cnLevelSpacingF=40

	res@cnFillOn=True
	res@cnLinesOn=False
	res@cnLineLabelsOn=False
	do i=0,9
			res@tiMainString="test"+i
			plot=gsn_csm_contour_map(wks,t(i,:,:),res)
	end do
end

