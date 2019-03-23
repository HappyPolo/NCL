load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
begin

	f= addfile("/home/ys-ug/data/NCEP/air.mon.mean.nc", "r")
	t=f->air
	lat=f->lat
    time=cd_calendar(f->time, -1)
    print(time)
	; t_JJA=month_to_season(t, "JJA")
 ;    printVarSummary(t_JJA)

end