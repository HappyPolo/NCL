begin
    fue=addfile("/home/ys-ug/data/era-interim/uwnd.mon.mean.nc","r")
	fve=addfile("/home/ys-ug/data/era-interim/vwnd.mon.mean.nc","r")
	fh=addfile("/home/ys-ug/data/hgt.sfc.nc","r")
	ue=short2flt(fue->u(:,{850},:,:))
	ve=short2flt(fve->v(:,{850},:,:))

wks=gsn_open_wks("x11", "/home/ys-ug/kt/zonal_wind1")
    ue_JJA=month_to_season(ue,"JJA")
    ve_JJA=month_to_season(ve,"JJA")
    ue_JJA_zm=dim_avg_n_Wrap(ue_JJA, "(/0,2/)")
    ve_JJA_zm=dim_avg_n_Wrap(ve_JJA, "(/0,2/)")
    ue_JJA_dif=new((/181,360/), float)
    ve_JJA_dif=new((/181,360/), float)
    do i=0,180
        do j=0,359
            ue_JJA_dif(i,j)=ue_JJA(i,j)-ue_JJA_zm(i)
            ve_JJA_dif(i,j)=ve_JJA(i,j)-ve_JJA_zm(i)
        end do
    end do
    copy_VarCoords(ue(0,:,:), ue_JJA_dif)
    copy_VarCoords(ue(0,:,:), ve_JJA_dif)
    res=True
    plot=gsn_csm_streamline_map_ce(wks, ue_JJA_dif, ve_JJA_dif, res)
end