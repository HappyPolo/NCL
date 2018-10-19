load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
begin

    f=addfile("/mnt/f/data/hgt.sfc.nc", "r")
    hgt=short2flt(f->hgt(0,:,:))
    wks=gsn_open_wks("x11", "mask")
    gsn_define_colormap(wks, "wh-bl-gr-ye-re")
    
    res=True
    res@gsnDraw=False
    res@gsnFrame=False
    res@cnFillOn=True
    res@cnLinesOn=False
	res@cnLevelSelectionMode="Explicitlevels"
	res@cnLevels=(/10,50,100,200,300,500,0600,800,1000,2000,3000,6000/)
    res@mpMaxLonF=140
    res@mpMinLonF=60
    res@mpMinLatF=0
    res@mpMaxLatF=60

    base=gsn_csm_contour_map(wks, hgt, res)
    lnres=True
    ;lnres@gsnDraw=True
    ;lnres@gsnFrame=True
    plot=gsn_add_shapefile_polygons(wks, base, "~/software/ncl/tibetan/tibetan.shp", lnres)
    maximize_output(wks, False)


end
