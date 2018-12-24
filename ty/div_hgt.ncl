load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
begin

	f = addfile("/mnt/e/data/ty/uwnd.nc", "r")

	dv = short2flt(f->u)

	res = True

	res@cnLinesOn = False
	res@cnFillOn = True

    res@tmYRTickSpacingF     = 10
    ; res@tmYLTickSpacingF     = 

        res@cnLevelSelectionMode = "ManualLevels"
    res@cnMaxLevelValF = 600
    res@cnMinLevelValF = 490
    res@cnLevelSpacingF = 4

    



	res@cnFillPalette = "NCV_blue_red"

	wks = gsn_open_wks("x11", "/mnt/e/scripts/ncl/ty/div_hgt/divhgt")

time = cd_calendar(dv&time, -5)
do i =0,15
        res@tiMainString=sprinti("%4i", time(i,0))+"-"+sprinti("%02i", time(i,1))+"-"\
    +sprinti("%02i", time(i,2))+" "+sprinti("%02i", time(i,3))+":00 (GMT)"

    plot1 = gsn_csm_pres_hgt(wks, dv(i,:,{0:90},{113}), res)
end do 
end 