;************************************
; unique_3.ncl
;
; Concepts illustrated:
;   - Drawing filled contours over a Robinson map
;   - Drawing three different types of plots on one page
;   - Drawing bar charts
;   - Attaching polylines and polymarkers to an XY plot
;   - Shading particular areas in an XY plot
;   - Drawing both a vertical and horizontal labelbar
;************************************
;
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
;
; This file still has to be loaded manually
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl"

begin
     diri  = ncargpath("data") + "/cdf/"    ; Location of NetCDF files

     type = "png" 
;     type@wkColorModel = "cmyk"
     wks = gsn_open_wks(type,"unique")
     gsn_merge_colormaps(wks,"BlWhRe","default")

     print("Reading the new ice mask and topo file")
     a = addfile(diri+"ice5g_21k_1deg.nc","r")
     topo = a->Topo
     icem = a->Icemask
        
     topo = mask(topo,icem.eq.1,True)          ;keep topo when icem.eq.1
     delete(icem)

     print("Beginning bar chart section")
     arr =    (/-2.22,-0.54,-1.4, -3.,-1.2,0.1/)
     minval = (/-2.6, -0.68, -2., -4.,-1.4/)
     maxval = (/-1.87,-0.4,  -1.,-1.9,-1.0/)
;========================================================================== 
     res = True

     res@gsnDraw  = False
     res@gsnFrame = False

     res@vpWidthF  = 0.4
     res@vpHeightF = 0.22
     res@vpXF      = .145
     res@vpYF      = .97
     res@trXMinF   = 0.
     res@trXMaxF   = 7.
     res@trYMinF   = -4.8
     res@trYMaxF   = 1.
        
     res@gsnXYBarChart               = True
     res@gsnYRefLine                 = 0.              ; reference line  
     res@gsnYRefLineThicknessF       = 3.0
     res@gsnAboveYRefLineBarPatterns = (/-1,-1,-1,-1,-1,-1/)
     res@gsnBelowYRefLineBarPatterns = (/-1,-1,-1,-1,-1,-1/)
     res@gsnXYBarChartBarWidth       = 0.5                 ; change bar widths

     res@gsnRightString              = ""
     res@tiMainString                = ""
     res@tiMainFont                  = "helvetica"

     res@tmXBOn                      = False
     res@tmXTOn                      = False
     res@tmXBMode                    = "Explicit"          ; explicit labels
     res@tmXBValues                  = ispan(0,7,1)
     res@tmXBLabels                  = (/"","","","","","","",""/)
     res@tmYLLabelFontHeightF        = 0.012
     res@tmYLMajorOutwardLengthF     = -0.001     ; set tickmarks
     res@tmYLMinorOutwardLengthF     = -0.001
     res@tmYLMajorLengthF            = 0.021
     res@tmYLPrecision               = 1

     res@tiYAxisString        = "Radiative Forcing (Watts per square meter)"
     res@tiYAxisFontHeightF   = 0.01
     res@tiYAxisOffsetXF      = -.017
           
     res@xyLineThicknessF     = 3.   
     res@xyMonoLineColor      = False
     res@xyLineColors         = (/"red","blue"/)  ; Above/below bar colors

     plot = gsn_csm_xy(wks,ispan(1,6,1),arr,res)

     lres                   = True                    ; polyline mods desired
     lres@gsLineColor       = "black"                 ; color of lines
     lres@gsLineThicknessF  = 2.5                     ; thickness of lines
     lres@gsLineDashPattern = 0
     lres@gsLineColor       = "gray50"
        
     dum  = new(5,graphic)
     dum2 = dum
     dum3 = dum
        
     time   = fspan(1,5,5)
     colors = (/"darkgreen","darkgreen","darkgreen","darkgreen","darkgreen"/)

     do ii = 0,4
       lres@gsLineColor = colors(ii)
       dum(ii) = gsn_add_polyline(wks,plot,(/time(ii),time(ii)/), \
                                  (/minval(ii),maxval(ii)/),lres)
       dum2(ii) = gsn_add_polyline(wks,plot,(/time(ii)-.08,time(ii)+.08/), \
                                   (/maxval(ii),maxval(ii)/),lres)
       dum3(ii) = gsn_add_polyline(wks,plot,(/time(ii)-.08,time(ii)+.08/), \
                                   (/minval(ii),minval(ii)/),lres)
     end do

     resp             = True
     resp@gsFillColor = 48
     xpts             = (/0.,0.,7.,7.,0./)
     ypts             = (/0.,-5.,-5.,0.,0./)
     gsn_polygon (wks,plot,xpts,ypts,resp)
        
     resp@gsFillColor = 57
     xpts             = (/0.,0.,7.,7.,0./)
     ypts             = (/0.,2.,2.,0.,0./)
     gsn_polygon (wks,plot,xpts,ypts,resp)

     xres               = True
     xres@txFontHeightF = 0.009      
     gsn_text(wks,plot,"CO~B~2~N~",1,-3.,xres)       
     gsn_text(wks,plot,"CH~B~4~N~ + N~B~2~N~O",2,-.97,xres)  
     gsn_text(wks,plot,"Mineral Dust",3,-2.4,xres)   
     gsn_text(wks,plot,"Continental ice",4,-4.35,xres)       
     gsn_text(wks,plot,"+ sea level",4,-4.6,xres)    
     gsn_text(wks,plot,"Vegetation",5,-1.77,xres)    
     gsn_text(wks,plot,"Orbital",6,0.45,xres)        

     draw(plot)      
;    drawNDCGrid(wks)
     xres@txFontHeightF = 0.009
     xres@txAngleF      = 90.
     gsn_text_ndc(wks,"cooling",0.11,0.835,xres)     
     gsn_text_ndc(wks,"warming",0.11,0.95,xres)      
;=======================================================================
     delete(arr)
     delete(res)
     delete(xres)
     delete(xpts)
     delete(ypts)
     delete(resp)
     delete(lres)
     gsn_define_colormap(wks,"wh-bl-gr-ye-re")
     a = addfile(diri+"sstanom.robinsonproj.nc","r")
     sst = a->SST    
        
     res           = True
     res@gsnFrame  = False
     res@vpWidthF  = 0.5
     res@vpHeightF = 0.32
     res@vpXF      = .1
     res@vpYF      = .75

     res@mpProjection      = "Robinson"        ; choose projection
     res@mpFillOn          = False
     res@mpGridAndLimbOn   = True              ; turn on lat/lon lines
     res@mpPerimOn         = False
     res@mpGridLatSpacingF =  90               ; change latitude  line spacing
     res@mpGridLonSpacingF = 180.              ; change longitude line spacing
     res@mpGridLineColor   = "transparent"     ; trick ncl into drawing
                                               ; perimeter
     res@mpCenterLonF      = 300.

     res@cnFillOn             = True              ; color plot desired
     res@cnLinesOn            = False             ; turn off/on contour lines
     res@cnLineLabelsOn       = False             ; turn off contour lines
     res@cnLineColor          = "Background"
     res@cnLevelSelectionMode = "ManualLevels" ; set manual contour levels
     res@cnMinLevelValF       = -7.              ; set min contour level
     res@cnMaxLevelValF       =  1.              ; set max contour level
     res@cnLevelSpacingF      =  1.             ; set contour spacing
     res@cnFillColors         = (/8,17,30,50,65,95,120,134,152,161/)

        
     res@lbLabelFontHeightF       = 0.012          
     res@pmLabelBarHeightF        = 0.07          
     res@pmLabelBarWidthF         = 0.45             
     res@pmLabelBarOrthogonalPosF = 0.025  
        
     res@gsnLeftString     = ""
     res@gsnCenterString   = ""
     res@gsnRightString    = ""

     map = gsn_csm_contour_map(wks,sst,res)  
     res@cnMinLevelValF    =  500.           ; set min contour level
     res@cnMaxLevelValF    = 3500.           ; set max contour level
     res@cnLevelSpacingF   =  500.           ; set contour spacing
     delete(res@cnFillColors)

;    res@pmLabelBarOrthogonalPosF = 0.215    ; set label bar offset  (for horizontal label bar)
     res@lbOrientation     = "vertical"
     res@pmLabelBarHeightF = 0.26          
     res@pmLabelBarWidthF  = 0.07
     res@pmLabelBarOrthogonalPosF = -1.1575          ; -1.18 
     gsn_define_colormap(wks,"WhViBlGrYeOrRe")
     res@cnFillColors = (/20,17,14,12,10,8,6,4/)
;    res@cnFillColors = (/20,17,15,13,11,9,7,5/)
     map2 = gsn_csm_contour_map(wks,topo,res)
        
     xres               = True
     xres@txFontHeightF = 0.009      
     gsn_text_ndc(wks,"Sea Surface Temperature Change (~S~o~N~C)",0.35,0.385,\
                  xres)
     xres@txAngleF = 90.
     gsn_text_ndc(wks,"Ice Sheet Elevation (m)",0.01,0.59,xres)
;===========================================================================
     delete(xres)
     delete(res)
     delete(sst)
     arr = new((/5,2/),"float",-999.)
;    arr(0,:) = (/0.,16./)           ;done with gsn_polyline below
     arr(1,:) = (/15.,19./)
     arr(2,:) = (/22.5,30.5/)
     arr(3,:) = (/15.,15./)
     arr(4,:) = (/22.5,22.5/)        
     gsn_merge_colormaps(wks,"gsdtol","default")

     sres              = True
     sres@gsnDraw      = False
     sres@gsnFrame     = False

     sres@vpWidthF     = 0.22
     sres@vpHeightF    = 0.4
     sres@vpXF         = .72
     sres@vpYF         = .92

     sres@trXMinF      = 0.
     sres@trXMaxF      = 8.
     sres@trYMinF      = 0.
     sres@trYMaxF      = 32.5

     sres@tmXBOn       = True
     sres@tmXTOn       = False
     sres@tmYROn       = False
     sres@tmYRBorderOn = False
     sres@tmXTBorderOn = False
     sres@tmXBMode     = "Explicit"              ; explicit labels
     sres@tmXBValues   = ispan(0,8,1)
     sres@tmXBLabels   = sres@tmXBValues
     sres@tmYLMode     = "Explicit"              ; explicit labels
     sres@tmYLValues   = (/0,   5,  10, 15, 17.5, 20.,22.5,27.5,32.5/)
     sres@tmYLLabels   = (/"0","5","10","0","2.5","5", "0",  "5","10"/)
     sres@tmYLMinorValues = fspan(2.5,32.5,13)

     sres@tmYLPrecision        = 1
     sres@tmXBPrecision        = 1
     sres@tmYLLabelFontHeightF = 0.012
     sres@tmXBLabelFontHeightF = 0.012

     sres@tiYAxisString      = "Regional Temperature Change (~S~o~N~C cooling)"
     sres@tiYAxisFontHeightF = 0.015
     sres@tiYAxisOffsetXF    = -.015
     sres@tiXAxisString      = "Global Temperature Change (~S~o~N~C cooling)"
     sres@tiXAxisFontHeightF = 0.012
           
     sres@xyLineThicknessF  = 1.5
     sres@xyMonoDashPattern = False
     sres@xyDashPatterns    = (/2,2,2,0,0/)
     sres@xyMonoLineColor   = True
     xyplot = gsn_csm_xy(wks,ispan(0,8,8),arr,sres)

     polyres                   = True
     polyres@gsMarkerIndex     = 16          ; polymarker style
     polyres@gsMarkerSizeF     = 10.          ; polymarker size
        
     dum4 = new((/3,5/),graphic)
        
     xcoord = (/3.12,3.69, 4.54,5.12,3.35/)
     ycoord = (/2.41,7.42,10.84,9.67,7.03/)
     polyres@gsMarkerColor = "blue"
     do gg = 0,4
       dum4(0,gg) = gsn_add_polymarker(wks,xyplot,xcoord(gg),ycoord(gg), \
                                       polyres)
     end do
        
     ycoord = (/1.16,2.1,1.75,1.91,2.26/)
     ycoord = ycoord+15.
     polyres@gsMarkerColor = "red"
     do gg = 0,4
        dum4(1,gg) = gsn_add_polymarker(wks,xyplot,xcoord(gg),ycoord(gg),\
                                        polyres)
     end do
        
     delete(ycoord)
     ycoord = (/2.4,4.1,6.6,5.2/)
     ycoord = ycoord+22.5
     delete(xcoord)
     xcoord = (/3.12,3.69,4.54,5.12/)
     polyres@gsMarkerColor = "green"
     do gg = 0,3
        dum4(2,gg) = gsn_add_polymarker(wks,xyplot,xcoord(gg),ycoord(gg), \
                                        polyres)
     end do
        
     resline                  = True                      ; polyline mods desired
     resline@gsLineDashPattern  = 2
     dum5 = gsn_add_polyline(wks,xyplot,(/0.,7.5/),(/0.,15./),resline)

     resp = True
     resp@gsFillColor = 29
     xpts = (/0.,0.,8.,8.,0./)
     ypts = (/17.1,18.9,18.9,17.1,17.1/)
     gsn_polygon (wks,xyplot,xpts,ypts,resp)
     ypts = (/11.,7.,7.,11.,11./)
     gsn_polygon (wks,xyplot,xpts,ypts,resp)
     ypts = (/25.7,31.8,31.8,25.7,25.7/)
     gsn_polygon (wks,xyplot,xpts,ypts,resp)
     draw(xyplot)    
        
;    drawNDCGrid(wks)
     xres = True
     xres@txFontHeightF = 0.01
     xres@txAngleF = 90.
     xc =0.665
     gsn_text_ndc(wks,"Central Antarctica",xc,0.61,xres)     
     gsn_text_ndc(wks,"Tropical Atlantic",xc,0.75,xres)
     gsn_text_ndc(wks,"North Atlantic",xc,0.86,xres) 
     frame(wks)      
;     system("ghostview unique.ps")     
end
