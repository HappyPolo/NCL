load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
begin

    dir = "/mnt/e/scripts/ncl/ncl/week16/"
    fu = addfile(dir+"uwnd.mon.mean.week16.nc", "r")
    fv = addfile(dir+"vwnd.mon.mean.week16.nc", "r")

    u = fu->uwnd(:,{925},{0:60},{0:180})
    v = fv->vwnd(:,{925},{0:60},{0:180})

    time = cd_calendar(u&time, -1)
    jan = ispan(198101, 201001, 100)
    jul = ispan(198107, 201007, 100)
    jan_id = get1Dindex(time,jan)
    jul_id = get1Dindex(time,jul)

    u_jan_avg = dim_avg_n_Wrap(u(jan_id,:,:), 0)
    v_jan_avg = dim_avg_n_Wrap(v(jan_id,:,:), 0)
    u_jul_avg = dim_avg_n_Wrap(u(jul_id,:,:), 0)
    v_jul_avg = dim_avg_n_Wrap(v(jul_id,:,:), 0)

    res = True

    res@gsnFrame =False
    res@gsnDraw = False
    res@gsnAddCyclic = False
    res@cnInfoLabelOn = False


    rescn = res 

    res@mpMaxLatF = 60
    res@mpMinLatF = 0
    res@mpMaxLonF = 180
    res@mpMinLonF = 0

    res@cnFillOn = True
    res@cnLinesOn =False

    res@cnFillPalette = "BlueWhiteOrangeRed"
    res@cnLevelSelectionMode = "ManualLevels"
    res@cnLineLabelsOn = False

    res@cnMaxLevelValF = 10
    res@cnMinLevelValF = -10
    res@cnLevelSpacingF = 2

    res@lbLabelBarOn       = False
res2 = res 
    res@tiMainString = "January"
    res@gsnLeftString = ""
    res2@tiMainString = "July"
    res2@tiMainOffsetYF = -0.01
    res2@gsnLeftString = ""


    rescn@cnFillOn = False
    rescn@cnLinesOn = True
    rescn@cnLevelSelectionMode = "ManualLevels"
    rescn@cnMaxLevelValF = 16
    rescn@cnMinLevelValF = -16
    rescn@cnLevelSpacingF = 2



    rescn@gsnLeftString = ""
    rescn@gsnRightString = ""     
    rescn@cnLineLabelsOn = True
    rescn@cnLineLabelBackgroundColor = -1

    rescn@gsnContourZeroLineThicknessF = 0
    rescn@gsnContourNegLineDashPattern = 8

    rescn@cnLineLabelPlacementMode     ="Computed"



    rescn@cnLineThicknessF = 3
    rescn@cnLineLabelFontHeightF = 0.012
    rescn@cnLineLabelAngleF = 0.0
    rescn@cnLineLabelDensityF = 2

base = new(2, "graphic")
plot = new(2, "graphic")

    wks = gsn_open_wks("png", dir+"16303003.week16")

    base(0) = gsn_csm_contour_map_ce(wks, u_jan_avg, res)
    base(1) = gsn_csm_contour_map_ce(wks, u_jul_avg, res2)
    plot(0) = gsn_csm_contour(wks, v_jan_avg, rescn)
    plot(1) = gsn_csm_contour(wks, v_jul_avg, rescn)

    overlay(base(0), plot(0))
    overlay(base(1), plot(1))

    resp                          =True
    resp@gsnPanelCenter           =True 
    resp@gsnPanelDebug            =True 
    resp@gsnPanelFigureStrings    =(/"(a)","(b)"/) 
    resp@gsnPanelFigureStringsBackgroundFillColor="white"
    resp@gsnPanelFigureStringsFontHeightF =0.01
    resp@amJust                   ="BottomLeft"
    resp@gsnPanelFigureStringsPerimOn     =True 
    resp@gsnPanelLabelBar         =True 
    resp@gsnLeftString            =""
    resp@gsnRightString           =""
    resp@gsnMaximize              =False
    resp@txString                 ="u && v wind(1981-2010) 925hPa"
    resp@gsnPanelMainFontHeightF  = 0.03
    ; resp@gsn[anm]
    resp@gsnPanelLabelBar         =True
    resp@gsnPanelFigureStringsPerimOn=True
    resp@lbLabelOffsetF           =0.1 
    resp@lbLabelFontHeightF       =0.024
    resp@lbLabelFontColor         ="black"
    resp@lbLabelFontThicknessF    =2
    resp@lbLabelStride            =2 
    resp@pmLabelBarOrthogonalPosF =-0.03
    ; resp@pmLabelBarParallelPosF = -0.1
    resp@lbBoxEndCapStyle         = "TriangleBothEnds"
    resp@pmLabelBarWidthF         =0.8 ;宽度
    resp@pmLabelBarHeightF        =0.05 ;高度


    gsn_panel(wks, base, (/2,1/), resp)

end