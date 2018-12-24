load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
begin

    f = addfile("/mnt/e/scripts/ncl/ncl/week16/air.sig995.2016.nc", "r")
    h = f->air(:,{0:80},{60:180})
    ; h = where(H(0,{925},:,:).le.1000, true_value, false_value)
    dt = h(1,:,:)-h(0,:,:)
    copy_VarCoords(h(0,:,:), dt)
    res = True
    res@gsnDraw =False
    res@gsnFrame = False
    res@gsnAddCyclic = False 
    res@mpMaxLatF = 80
    res@mpMinLatF = 0
    res@mpMinLonF = 60
    res@mpMaxLonF = 180
    res@cnLinesOn = True
    res@cnFillOn = False
    res@cnInfoLabelOn = False
    res@cnLevelSelectionMode = "ManualLevels"
    res@cnMaxLevelValF = 12
    res@cnMinLevelValF = -12
    res@cnLevelSpacingF = 1
    ; res@lbLabelBarOn = False
    res@cnLineLabelsOn = False
    res@gsnContourNegLineDashPattern = 16
    res@gsnContourZeroLineThicknessF = 5
    res@cnLineThicknessF = 2
    ; res@gsnContourPosLineDashPattern = 
    ; res@ 

    lnres = True
    lnres@gsLineThicknessF=3.
    lnres@gsLineDashPattern=1
    lnres@gsFillColor = "gray"

    wks = gsn_open_wks("x11", "name")
base = new(6, graphic)
plot = new(6, graphic)
; do i = 0,5
i = 0
    base(i) = gsn_csm_contour_map(wks, dt(:,:), res)
    base(i)=ColorNegDashZeroPosContour(base(i),"blue","black","red")
    ; plot(i) = gsn_add_shapefile_polygons(wks, base(i), "/mnt/e/scripts/ncl/shapefile/tibetan/tibetan.shp", lnres)
draw(base(i))
frame(wks(i))
; end do 
; resp = True
; resp@gsnPanelCenter = True
; resp@gsnPanelDebug = True
; resp@gsnPanelFigureStrings = (/"(a)","(b)","(c)","(d)","(e)","(f)"/)
; resp@gsnPanelFigureStringsPerimOn = True
; resp@gsnPanelFigureStringsBackgroundFillColor = "white"
; resp@gsnPanelLabelBar =  True
; gsn_panel(wks, base, (/3,2/), resp) 
end