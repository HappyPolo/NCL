load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
begin

    fu =addfile("/mnt/e/data/ncl/uwnd.week15.nc", "r")
    fv =addfile("/mnt/e/data/ncl/vwnd.week15.nc", "r")
    u0 = short2flt(fu->uwnd(:,{850},{12:20},{110:115}))
    v0 = short2flt(fv->vwnd(:,{850},{12:20},{110:115}))

    time = cd_calendar(u0&time, -5)
    ID = ind(time(:,1).eq.12.and.time(:,0).ge.1980.and.time(:,0).le.2009)
    u = u0(ID,:,:)
    v = v0(ID,:,:)

    u_avg = dim_avg_n_Wrap(u, (/1,2/))
    v_avg = dim_avg_n_Wrap(v, (/1,2/))
    ; printVarSummary(u_avg)


    res = True
    res@xyMarkLineMode = "Markers"
    res@xyMarker = 17
    res@xyMarkerSizeF = 0.04

    res@tiXAxisString = "Uwnd"
    res@tiYAxisString = "Vwnd"

    wks = gsn_open_wks("x11", "name")
    plot=gsn_csm_xy(wks, u_avg, v_avg, res)




end