load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
begin
    
    nrow=72*128
    data=asciiread("/mnt/e/data/For_Fortran/Precip/SURF_CLI_CHN_PRE_MON_GRID_0.5-196101(1).txt", (/nrow/),"float")
    data@_FillValue= -9999.0
    prc=onedtond(data, (/72,128/))
    prc@_FillValue= -9999.0
    prc!0="lat"
    prc!1="lon"
    lat=fspan(18,54,72)
    lon=fspan(72, 136, 128)
    lon@units="degrees_east"
    lat@units="degrees_north"
    prc&lat=lat
    prc&lon=lon
    
    print(prc(0,:))
    wks=gsn_open_wks("x11", "e")
gsn_define_colormap(wks, "wh-bl-gr-ye-re")
    
    res =True
    res@cnFillOn=True
    res@cnLinesOn=False
    res@sfXArray=lon
    res@sfYArray=lat
    res@gsnAddCyclic=False
    res@mpMaxLatF=54
    res@mpMinLatF=18
    res@mpMaxLonF=136
    res@mpMinLonF=72
    plot=gsn_csm_contour_map(wks, prc, res)
end