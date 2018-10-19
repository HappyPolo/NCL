load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
begin

;input data
fh=addfile("/home/ys-ug/data/hgt.sfc.nc", "r")
fu=addfile("/home/ys-ug/data/cfsv2/u850.em24.out.nc", "r")
fv=addfile("/home/ys-ug/data/cfsv2/v850.em24.out.nc", "r")
fue=addfile("/home/ys-ug/data/era-interim/uwnd.mon.mean.nc", "r")
fve=addfile("/home/ys-ug/data/era-interim/vwnd.mon.mean.nc", "r")

uwnde=short2flt(fue->u(0:383,30,:,:))
vwnde=short2flt(fve->v(0:383,30,:,:))

hgt=short2flt(fh->hgt(0,:,:))
uwnd=fu->ugrd(:,0,::-1,:)
vwnd=fv->vgrd(:,0,::-1,:)
wks1=gsn_open_wks("png", "/home/ys-ug/fei_cy/CFSv2-ERA_summer")
printVarSummary(uwnd)
printVarSummary(uwnde)
end