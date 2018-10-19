;*************************************************
; bar_horz_11.ncl
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
     wks = gsn_open_wks("png","bar_horz")   ; send graphics to PNG file

     sres = True
     sres@gsnDraw               = False
     sres@gsnFrame              = False
     sres@gsnXRefLine           = 0

     sres@vpWidthF              = 0.5
     sres@vpHeightF             = 0.7

     sres@trYMinF               = 0.4
     sres@trYMaxF               = 12.6
     sres@trXMinF               = 0.4
     sres@trXMaxF               = 1.2

     sres@gsnXYBarChart         = True
     sres@gsnXYBarChartBarWidth = 0.15           ; change bar widths

     sres@tmYLMode              = "Explicit"         ; explicit labels
     sres@tmYLValues            = ispan(1,12,1)
     sres@tmYLLabels            = (/"Jan","Feb","Mar","Apr","May","Jun","Jul","Aug","Sep", \
                                    "Oct","Nov","Dec"/)

     sres@tmYLLabelFontHeightF  = 0.0205
     sres@tmYRLabelFontHeightF  = 0.0205
     sres@tmXBLabelFontHeightF  = 0.0225

     sres@gsnRightString        = ""
     sres@tiXAxisString         = "(~S~o~N~C)"
        
     plots = new((/npanels,nplots_per_panel/),graphic)

; The Y values for each plot are different, ensuring that the bars don't overlap.
     do i = 0,npanels-1,1
       sres@gsnXYBarChartColors = "red"
       plots(i,0) = gsn_csm_xy(wks,stdarr(i,0,:),fspan(.775,11.775,12),sres)

       sres@gsnXYBarChartColors = "lightblue"
       plots(i,1) = gsn_csm_xy(wks,stdarr(i,1,:),fspan(.925,11.925,12),sres)

       sres@gsnXYBarChartColors = "blue"

       plots(i,2) = gsn_csm_xy(wks,stdarr(i,2,:),fspan(1.075,12.075,12),sres)
       sres@gsnXYBarChartColors = "green"

       plots(i,3) = gsn_csm_xy(wks,stdarr(i,3,:),fspan(1.225,12.225,12),sres)

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
     pnlres@gsnPanelMainString       = "Paneling bar plots, dummy data"
     pnlres@gsnPanelMainFontHeightF  = 0.025

; Panel the plots.
     gsn_panel(wks,plots(:,0),(/2,2/),pnlres)

; Create some labelbars for a legend
     lbres                    = True          ; labelbar only resources
     lbres@vpWidthF           = 0.1           ; labelbar width
     lbres@vpHeightF          = 0.2           ; labelbar height
     lbres@lbBoxMajorExtentF  = 0.15          ; puts space between color boxes
     lbres@lbMonoFillPattern  = True          ; Solid fill pattern
     lbres@lbLabelFontHeightF = 0.015         ; font height. default is small
     lbres@lbLabelJust        = "CenterLeft"  ; left justify labels
     lbres@lbPerimOn          = False

     colors = (/"red",   "lightblue", "blue",  "green"/)
     labels = (/"first", "second",    "third", "fourth"/)
     xpos   = (/0.22,    0.38,         0.55,     0.7/)

     do i=0,3
       lbres@lbFillColors = colors(i)
       gsn_labelbar_ndc(wks,1,labels(i),xpos(i),0.20,lbres)
     end do	

     frame(wks)   ; Advance the frame.
end
