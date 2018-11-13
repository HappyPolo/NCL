load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
begin
    f         = addfile("/mnt/f/data/ncl/air.sig995.201701.nc","r")

    air      = f->air(0,:,:)

    wks    = gsn_open_wks("X11","air_sfc_20170101")
    gsn_define_colormap(wks,"BlueWhiteOrangeRed")

    res                     = True
    res@cnFillOn        = True
    res@mpMinLatF       = 15.
    res@mpMaxLatF       = 30.
    res@mpMinLonF       = 70.
    res@mpMaxLonF   = 150.
    res@tiMainString = "1 Jan 2017"
    res@gsnLeftString = "Chen_Kt"
    res@gsnRightString = systemfunc("date")
    
    plot    = gsn_csm_contour_map_ce(wks,air,res)
end
