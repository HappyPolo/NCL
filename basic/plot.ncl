ColorNegDashZeroPosContour(plot,ncolor,zcolor,pcolor)
;用实线表示0之正值，虚线表示赋值，同时用不同颜色表示

gsn_add_polygon(wks, plot, x, y, res)
;plot中添加多边形，XY为坐标

gsn_add_polyline(wks, plot, x, y, res)
;添加任意折线

gsn_add_polymarker(wks, plot, x, y, res)
;添加标识

gsn_add_shapefile_polygons(wks, plot, shp_name, res)
;根据shapefile添加多边形

gsn_add_shapefile_polylines(wks, plot, shp_name, res)
;根据shp添加折线

gsn_add_shapefile_polymarkers(wks, plot, shp_name, res)
;根据shp添加标识

gsn_add_text(wks, plot, text, x, y, res)
;添加文本

gsn_attach_plots(base_plot, plots, res_base, res_plots)
;在底图旁添加附属图形

gsn_contour_shade(plot, lowval, highval, opt)
;用不同颜色或图案填充等值线高低值区

gsn_csm_attach_zonal_means(wks, map, data, res)
;在等值线图右侧添加纬向平均

gsn_csm_blank_plot(wks, res)
;绘制一刻度线向外侧空白图

gsn_csm_contour(wks, data, res)

gsn_csm_contour_map(wks, data, res)

gsn_csm_contour_map_ce(wks, data, res)

gsn_csm_contour_map_overlay(wks, data1, data2, res1, res2)
;叠加两组等值线

gsn_csm_contour_map_polar(wks, data, res)

gsn_csm_hov(wks, data, res)
;绘制Hovmueller(时间-经度)图

gsn_csm_lat_time(wks, data, res)
;绘制时间纬度图

gsn_csm_map(wks, res)
;绘制地图

gsn_csm_map_ce(wks, res)
;圆柱投影

gsn_csm_map_polar(wks, res)

gsn_csm_pres_hgt(wks, data, res)
;绘制经度纬度或时间随气压／高度的垂直剖面图

gsn_csm_pres_hgt_streamline(wks, data, xcomp, zcomp, res)
;在气压\高度剖面图中添加流线

gsn_csm_pres_hgt_vector(wks, data, xcomp, zcomp, res)
;添加箭头

gsn_csm_streamline(wks, u, v, res)

gsn_csm_streamline_contour_map(wks, u, v, data, res)
;同时绘制等值线和流线

gsn_csm_streamline_contour_map_ce(wks, u, v, data, res)

gsn_csm_x2y(wks, x1, x2, y, res1, res2)
;绘制两个X轴的XY图

gsn_csm_x2y2(wks, x1, x2, y1, y2, res1, res2)
;绘制有两个XY轴的XY图

gsn_csm_xy(wks, x, y, res)
;绘制XY图

gsn_csm_xy2(wks, x, y1, y2, res1, res2)
;绘制两个Y轴

gsn_csm_xy3(wks, x, yL, yR, yR2, resL, resR, resR2)
;绘制3个Y轴

gsn_csm_y(wks, y, res)
;绘制xy图，X轴数值为Y下标

gsn_define_colormap(wks, color_map)

gsn_draw_colormap(wks)
;绘制当前色板

gsn_legend_ndc(wks, nitems, labels, x, y, res)
;在单位坐标系内绘制图例

gsn_merge_colormaps(wks, color_map1, color_map2)
;合并两色板

gsn_open_wks(type, name)

gsn_panel(wks, plots, dims, res)

gsn_polygon_ndc(wks, x, y, res)
;在单位坐标系内绘制多边形

gsn_polyline_ndc(wks, x, y, res)

gsn_polymarker_ndc(wks, x, y, res)

gsn_text_ndc(wks, text, x, y, res)

overlay(base_id, transform_id)

read_colormap_file(filename)

ShadeCOI(wks,plot,w,time,res)

WindRoseColor(wks,wspd,wdir,numPetals,circFr,spdBounds,colorBounds,res)


;用不同颜色填充箭头
gsn_define_colormap(wks, "MPL_autumn")
prob=where(abs(probeu_mon).lt.0.1.or.\
            abs(probev_mon).lt.0.1,1.0,2.0)
res=True
res@gsnSpreadColorStart=1
res@gsnSpreadColorEnd=18
gsn_csm_vector_scalar(wks, u, v, prob, res)

;打点
opt=True
opt@gsnShadeFillType="pattern"
opt@gsnShadeLow    =17
opt@gsnShadeFillScaleF=0.005
opt@gsnShadeFillDotSizeF=0.02 
plot=gsn_contour_shade(plot, 0.1, 100, opt)
