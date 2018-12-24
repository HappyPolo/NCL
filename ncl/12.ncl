load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
begin

    f = addfile("/mnt/e/scripts/ncl/ncl/week17/hgt.week17.nc", "r")
    h = f->hgt(:,:,{0:80},{60:180})
    ; h = where(H(0,{925},:,:).le.1000, true_value, false_value)

    res = True
    res@gsnDraw =False
    res@gsnFrame = False
    res@gsnAddCyclic = False 
    res@mpMaxLatF = 80
    res@mpMinLatF = 0
    res@mpMinLonF = 60
    res@mpMaxLonF = 180
    res@cnLinesOn = False
    res@cnFillOn = True
    res@cnInfoLabelOn = False
    res@cnLevelSelectionMode = "ManualLevels"
    res@cnMaxLevelValF = 900
    res@cnMinLevelValF = 500
    res@cnLevelSpacingF = 20
    res@lbLabelBarOn = False
    res@cnLineLabelsOn = False

    lnres = True
    lnres@gsLineThicknessF=3.
    lnres@gsLineDashPattern=1
    lnres@gsFillColor = "gray"

    wks = gsn_open_wks("png", "12")
base = new(6, graphic)
plot = new(6, graphic)
do i = 0,5
    base(i) = gsn_csm_contour_map(wks, h(i,{925},:,:), res)
    plot(i) = gsn_add_shapefile_polygons(wks, base(i), "/mnt/e/scripts/ncl/shapefile/tibetan/tibetan.shp", lnres)
; draw(base)
; frame(wks)
end do 
resp = True
resp@gsnPanelCenter = True
resp@gsnPanelDebug = True
resp@gsnPanelFigureStrings = (/"(a)","(b)","(c)","(d)","(e)","(f)"/)
resp@gsnPanelFigureStringsPerimOn = True
resp@gsnPanelFigureStringsBackgroundFillColor = "white"
resp@gsnPanelLabelBar =  True
gsn_panel(wks, base, (/3,2/), resp) 
end