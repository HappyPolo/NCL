;*************************************************
; panel_25.ncl
;
; Concepts illustrated:
;   - Paneling three horizontal plots with different widths
;   - Adding white space around paneled plots
;   - Creating a color map using named colors
;   - Explicitly setting contour levels
;   - Zooming in on a particular area on a Lambert Conformal map
;   - Attaching an outlined box to a map plot
;   - Adding a common labelbar to paneled plots
;
;*************************************************
; Thanks to Gary Bates of NOAA for contributing 
; this example.
;*************************************************
;
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
;
; This file still has to be loaded manually
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl"

begin

 nplots = 3

;==============================================
; read in logreg downscaled fcst data
;=============================================
 f = addfile ("apcp_ndjf_prism8_days4-6.nc", "r")

 lon2d  = f->lon
 lat2d  = f->lat

 analens = f->analogs
 verif = f->verification
 inittimes = f->inittimes
 ntimes = dimsizes(inittimes)

 nlon = dimsizes(lon2d(0,:))
 nlat = dimsizes(lat2d(:,0))
 print(nlon)
 print(nlat)

 ensmean2d = dim_avg_Wrap( analens(time|0, y|:, x|:, members|: ) )
 ensmean2d = ensmean2d / 25.4

 verif2d = verif(time|0, y|:, x|:)
 verif2d = verif2d / 25.4


;==============================================
; read in gfs fcst data
;=============================================
 file2 = addfile ("apcp.refcst_ens.grid.020300.1996.nc", "r")

 lon1 = 232.5
 lon2 = 242.5
 lat1 =  42.5
 lat2 =  52.5
 longfs  = file2->lon({lon1:lon2})
 latgfs  = file2->lat({lat1:lat2})

 apcp = short2flt( file2->apcp(:,:,{lat1:lat2},{lon1:lon2}) )

 ensgfs = dim_avg_Wrap( apcp(time|:, lat|:, lon|:, members|:) )
 ensgfs2d = dim_sum_Wrap( ensgfs(lat|:, lon|:, time|6:11) )
 ensgfs2d = ensgfs2d / 25.4


;==============================================
; create 3 panel plot
;=============================================
 wks  = gsn_open_wks ("png", "panel" )               ; send graphics to PNG file

 colors = (/"white","black","white",\
            "darkseagreen1", "palegreen2","green","lime green",\
            "yellow", "orange",\
            "tomato", "firebrick1", "red1"/)
 plot = new(nplots,graphic)                          ; create a plot array


;==============================================
; resources for the 2 lambert plots
;=============================================
 res             = True

 res@gsnDraw  = False                          ; don't draw
 res@gsnFrame = False                          ; don't advance frame

 res@cnLevelSelectionMode = "ExplicitLevels"                    ; set explicit contour levels
 res@cnLevels             = (/ .5,1.,1.5,2.,3.,4.,6.,8.,10./)   ; set levels
 res@cnFillOn             = True                                ; turn on color fill
 res@cnFillPalette        = colors                              ; set color map

 res@gsnAddCyclic         = False              ; regional data

; !!!!! any plot of data that is on a native grid, must use the "corners"
; method of zooming in on map.
 res@mpLimitMode       = "Corners"            ; choose range of map
 res@mpLeftCornerLatF  = lat2d(0,0)
 res@mpLeftCornerLonF  = lon2d(0,0)
 res@mpRightCornerLatF = lat2d(nlat-1,nlon-1)
 res@mpRightCornerLonF = lon2d(nlat-1,nlon-1)

; The following 4 pieces of information are REQUIRED to properly display
; data on a native lambert conformal grid.  This data should be specified
; somewhere in the model itself.
 res@mpProjection        = "LambertConformal"
 res@mpLambertParallel1F = 50.
 res@mpLambertParallel2F = 50.
 res@mpLambertMeridianF  = 253.

 res@mpDataBaseVersion           = "MediumRes"
 res@mpDataSetName               = "Earth..4"
 res@mpOutlineBoundarySets       = "GeophysicalandUSStates"
 res@mpGeophysicalLineThicknessF = 3.0
 res@mpUSStateLineThicknessF     = 3.0

 res@lbLabelBarOn        = False           ; turn off individual cb's

; usually, when data is placed onto a map, it is TRANSFORMED to the specified
; projection. Since this model is already on a native lambert conformal grid,
; we want to turn OFF the tranformation.

 res@tfDoNDCOverlay = True


;==============================================
; resources for gfs plot 
;=============================================
 resg          = True
 resg@gsnDraw  = False                          ; don't draw
 resg@gsnFrame = False                          ; don't advance frame

 resg@cnLevelSelectionMode = "ExplicitLevels"                       ; set explicit contour levels
 resg@cnLevels            = (/ .5,1.,1.5,2.,3.,4.,6.,8.,10./)       ; set levels
 resg@cnFillOn            = True                                    ; turn on color fill
 resg@cnFillPalette       = colors                                  ; set color map

 resg@gsnAddCyclic         = False              ; regional data

 resg@mpMinLatF            =  44.25    ; range to zoom in on
 resg@mpMaxLatF            =  50.
 resg@mpMinLonF            = 235.
 resg@mpMaxLonF            = 242.

 resg@tmXBLabelsOn         = False              ; do not draw bottom labels
 resg@tmYRLabelsOn         = False              ; no right labels
 resg@tmYLLabelsOn         = False              ; no left labels
 resg@tmXBOn               = False              ; no bottom tickmarks
 resg@tmXTOn               = False              
 resg@tmYLOn               = False             
 resg@tmYROn               = False            

 resg@mpDataBaseVersion           = "MediumRes"
 resg@mpOutlineBoundarySets       = "GeophysicalAndUSStates"
 resg@mpGeophysicalLineThicknessF = 3.0
 resg@mpNationalLineThicknessF    = 3.0
 resg@mpUSStateLineThicknessF     = 3.0
 
 resg@lbLabelBarOn                = False           ; turn off individual cb's


;*************************************************
; create points for box
;*************************************************
 resbox                  = True                      ; polyline mods desired
 resbox@gsLineColor      = "black"                     ; color of lines
 resbox@gsLineThicknessF = 4.0                       ; thickness of lines

; create array of dummy graphic variables. 
; each line must be associated with a unique dummy variable.
; draw each line separately. Each line must contain two points.
 ypts = (/ 47.33,  47.44,  47.16,  47.04,  47.33/)
 xpts = (/237.83, 238.68, 238.76, 237.92, 237.83/)

 dum = new(4*ntimes,graphic)  


;*************************************************
; draw maps
;*************************************************
 res@gsnRightString    = ""
 res@gsnLeftString     = ""

 resg@vpXF              = 0.015
 resg@vpYF              = 0.70
 resg@vpWidthF          = 0.28
 resg@vpHeightF         = 0.28
 resg@tiMainFontHeightF = .009
 resg@tiMainString      = "4-6 Day Fcst Ens-Mean Precip, GFS output"

 plot(0) = gsn_csm_contour_map(wks,ensgfs2d,resg)     ; Draw contours over a map.

 res@vpXF               = 0.26
 res@vpYF               = 0.70
 res@vpWidthF           = 0.28
 res@vpHeightF          = 0.28
 res@tiMainFontHeightF  = .009
 res@tiMainString       = "4-6 Day Fcst Ens-Mean Precip, Reforecast Adjusted"

 plot(1) = gsn_csm_contour_map(wks,ensmean2d,res)     ; Draw contours over a map.

 res@vpXF               = 0.64
 res@tiMainString       = "NARR Analyzed Precip, Downscaled"

 plot(2) = gsn_csm_contour_map(wks,verif2d,res)     ; Draw contours over a map.


;*************************************************
; add box to maps
;*************************************************
 do np=0,nplots-1
   do i = 0 , 3
     dum(np*4+i)=gsn_add_polyline(wks,plot(np),xpts(i:i+1), \
                                               ypts(i:i+1),resbox)      
   end do 
 end do


;************************************************
; create panel
;************************************************
 resP                     = True              ; modify the panel plot
 resP@gsnFrame            = False             ; don't advance the frame, so we can use gsn_text_ndc
 resP@gsnMaximize         = True              ; regional data
 resP@gsnPaperOrientation = "landscape"

 resP@txFontHeightF       = .021
 resP@gsnPanelMainString  = "3 Day Precip, 1996 Feb 7-9"
 resP@gsnPanelLabelBar    = True              ; add common colorbar
 resP@lbLabelFontHeightF  = 0.01              ; make labels smaller
 resP@gsnPanelXWhiteSpacePercent = 2
 resP@gsnPanelYWhiteSpacePercent = 2

 resP@gsnPanelDebug = True
 gsn_panel(wks,plot,(/1,nplots/),resP)             ; now draw as one plot

 txres               = True
 txres@txFontHeightF = 0.013
 gsn_text_ndc(wks,"Inches",0.50,0.27,txres)

 frame(wks)

end
