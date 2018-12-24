load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
begin
    
    dir = "/mnt/e/scripts/ncl/ncl/week16/"
    fu = addfile(dir+"uwnd.week15.nc", "r")
    fv = addfile(dir+"vwnd.week15.nc", "r")

    u = fu->uwnd(:,{250},{0:75},{0:240})
    v = fv->vwnd(:,{250},{0:75},{0:240}) 

    t = cd_calendar(u&time, -1)
    dec = ispan(198012, 200812, 100)
    jan = ispan(198101, 200901, 100)
    feb = ispan(198102, 200902, 100)
    djf = new(dimsizes(dec)*3, float)
    djf =toint(ndtooned(transpose((/dec,jan,feb/))))
    id_djf = get1Dindex(t, djf)

    u_DJF_avg = dim_avg_n_Wrap(u(id_djf,:,:),0)
    v_DJF_avg = dim_avg_n_Wrap(v(id_djf,:,:),0)
;=========================================================================
;=========================================================================
wks = gsn_open_wks("x11", "name")
gsn_define_colormap(wks, "MPL_GnBu")

    res = True 

    res@gsnDraw = False
    res@gsnFrame = False
    res@cnLineLabelsOn = False

    res@cnLinesOn = False
    res@cnFillOn = True


    res@mpMaxLonF = 240
    res@mpCenterLonF = 120
    res@mpMinLonF = 0
    res@mpMaxLatF = 75
    res@mpMinLatF = 0

    res@gsnAddCyclic = False

    resv = True

    resv@gsnFrame = False
    resv@gsnDraw = False
    resv@gsnAddCyclic = False
    resv@vcGlyphStyle = "LineArrow"
    resv@vcMonoLineArrowColor = True
    resv@vcLineArrowColor = "black"

    resv@gsnLeftString =""
    resv@gsnRightString = ""

    resv@vcRefAnnoOn = True
    resv@vcRefMagnitudeF = 40
    resv@vcRefLengthF = 0.05
    resv@vcMinDistanceF = 0.02

    resv@vcRefAnnoString2          ="10 m/s"
    base = gsn_csm_contour_map_ce(wks, u_DJF_avg, res)
    plot = gsn_csm_vector(wks, u_DJF_avg, v_DJF_avg, resv)

    overlay(base, plot)
    draw(base)
    frame(wks)

end