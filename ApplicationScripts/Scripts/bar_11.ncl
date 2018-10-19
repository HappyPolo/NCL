;*************************************************
; bar_11.ncl
;
; Concepts illustrated:
;   - Drawing filled bars using solid colors
;   - Changing the aspect ratio of a bar plot
;   - Setting the minimum/maximum value of the X and Y axis in a bar plot
;   - Overlaying XY plots on each other
;   - Paneling bar plots  
;   - Drawing a custom labelbar
;
;
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"

begin
     npts             = 12
     npanels          = 4
     nplots_per_panel = 4 
     stdarr           = random_uniform(0.1,1.15,(/npanels,nplots_per_panel,npts/))

;======================================================================================	
     wks = gsn_open_wks("png","bar")   ; send graphics to PNG file

     sres = True
     sres@gsnDraw               = False
     sres@gsnFrame              = False

     sres@vpWidthF              = 0.7
     sres@vpHeightF             = 0.5

     sres@trXMinF               = 0.4
     sres@trXMaxF               = 12.6
     sres@trYMinF               = 0.4
     sres@trYMaxF               = 1.2

     sres@gsnXYBarChart         = True
     sres@gsnXYBarChartBarWidth = 0.15           ; change bar widths

     sres@tmXBMode              = "Explicit"         ; explicit labels
     sres@tmXBValues            = ispan(1,12,1)
     sres@tmXBLabels            = (/"Jan","Feb","Mar","Apr","May","Jun","Jul","Aug","Sep", \
                                    "Oct","Nov","Dec"/)

     sres@tmXBLabelFontHeightF  = 0.0205
     sres@tmXTLabelFontHeightF  = 0.0205
     sres@tmYLLabelFontHeightF  = 0.0225

     sres@gsnRightString        = ""
     sres@tiYAxisString         = "(~S~o~N~C)"
        
     plots = new((/npanels,nplots_per_panel/),graphic)

; The X values for each plot is different, ensuring that the bars don't overlap.
     do i = 0,npanels-1,1
       sres@gsnXYBarChartColors = "red"
       plots(i,0) = gsn_csm_xy(wks,fspan(.775,11.775,12),stdarr(i,0,:),sres)

       sres@gsnXYBarChartColors = "lightblue"
       plots(i,1) = gsn_csm_xy(wks,fspan(.925,11.925,12),stdarr(i,1,:),sres)

       sres@gsnXYBarChartColors = "blue"

       plots(i,2) = gsn_csm_xy(wks,fspan(1.075,12.075,12),stdarr(i,2,:),sres)
       sres@gsnXYBarChartColors = "green"

       plots(i,3) = gsn_csm_xy(wks,fspan(1.225,12.225,12),stdarr(i,3,:),sres)

; Overlay the last three plots on the first one.
       do j=1,3
         overlay(plots(i,0),plots(i,j))
       end do
     end do

; Drawing plots(:,0) will also draw all the overlaid plots.
     pnlres                = True
     pnlres@gsnMaximize    = True   ; Maximize in frame
     pnlres@gsnFrame       = False  ; Don't advance frame.
     pnlres@gsnPanelBottom = 0.13   ; Leave room for labelbar

; Main title
     pnlres@txString       = "Paneling bar plots, dummy data"
     pnlres@txFontHeightF  = 0.025

; Panel the plots.
     gsn_panel(wks,plots(:,0),(/2,2/),pnlres)

; Create some labelbars for a legend
     lbres                    = True          ; labelbar only resources
     lbres@vpWidthF           = 0.2           ; labelbar width
     lbres@vpHeightF          = 0.1           ; labelbar height
     lbres@lbBoxMajorExtentF  = 0.15          ; puts space between color boxes
     lbres@lbMonoFillPattern  = True          ; Solid fill pattern
     lbres@lbLabelFontHeightF = 0.015         ; font height. default is small
     lbres@lbLabelJust        = "CenterLeft"  ; left justify labels
     lbres@lbPerimOn          = False

     colors = (/"red",   "lightblue", "blue",  "green"/)
     labels = (/"first", "second",    "third", "fourth"/)
     xpos   = (/0.05,    0.3,         0.55,     0.8/)

     do i=0,3
       lbres@lbFillColors = colors(i)
       gsn_labelbar_ndc(wks,1,labels(i),xpos(i),0.20,lbres)
     end do	

     frame(wks)   ; Advance the frame.
end
