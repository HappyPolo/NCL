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
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl"

begin
     diri  = ncargpath("data") + "/cdf/"    ; Location of NetCDF files

     type = "png" 
     type@wkWidth = 2500
     type@wkHeight = 2500
;     type@wkColorModel = "cmyk"
     wks = gsn_open_wks(type,"robinson")
     gsn_merge_colormaps(wks,"BlWhRe","default")

     print("Reading the new ice mask and topo file")
     a = addfile(diri+"ice5g_21k_1deg.nc","r")
     topo = a->Topo
     icem = a->Icemask
        
     topo = mask(topo,icem.eq.1,True)          ;keep topo when icem.eq.1
     delete(icem)

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
     map2 = gsn_csm_contour_map(wks,topo,res)
        
     xres               = True
     xres@txFontHeightF = 0.009      
     gsn_text_ndc(wks,"Sea Surface Temperature Change (~S~o~N~C)",0.35,0.385,\
                  xres)
     xres@txAngleF = 90.
     gsn_text_ndc(wks,"Ice Sheet Elevation (m)",0.01,0.59,xres)
     frame(wks)      
end
