load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
begin

    ft = addfile("/mnt/e/data/ty/air.nc", "r")
    fu = addfile("/mnt/e/data/ty/uwnd.nc", "r")
    fv = addfile("/mnt/e/data/ty/vwnd.nc", "r")
    fd = addfile("/mnt/e/data/ty/div.nc", "r")
    u = short2flt(fu->u(:,:,::-1,:))
    v = short2flt(fv->v(:,:,::-1,:))
    T = short2flt(ft->t(:,:,::-1,:))
    T0 = T
    T0 = 273.15
    t = T
    copy_VarCoords(T, t)

    lat = u&latitude
    lev = u&level 

    gridType = 1
    opt = 0

    pv = pot_vort_isobaric(lev, u, v, t, lat, gridType, opt)

    
end 