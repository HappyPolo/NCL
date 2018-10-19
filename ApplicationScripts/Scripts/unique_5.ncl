;*******************************************************
; unique_5.ncl
;
; Concepts illustrated:
;   - Drawing multiple bar charts on a page
;   - Drawing three custom legends outside a bar chart
;   - Using bar charts to draw standard deviations for four time series
;   - Drawing a time series plot
;*******************************************************
;
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"

begin
     print("timestart:" + systemfunc("date"))
     a = addfile("hadisst.nino34.1900-2003.nc","r")
     b = addfile("b30004.nino34.0100-0799.nc","r")
     c = addfile("b30009.nino34.0100-0599.nc","r")
     d = addfile("b20007.nino34.nc","r")
     obsts  = a->sst
     b20007 = d->sst		
     b30004 = b->sst		
     b30009 = c->sst		

     stdarr = new((/12,4/),"float")
     do hh = 0,11
        stdarr(hh,0) = (/ dim_stddev(obsts(hh::12)) /)
        stdarr(hh,1) = (/ dim_stddev(b20007(hh::12)) /)
        stdarr(hh,2) = (/ dim_stddev(b30004(hh::12)) /)
	stdarr(hh,3) = (/ dim_stddev(b30009(hh::12)) /)
     end do
     print("obs = "+dimsizes(obsts)+", t42b = "+dimsizes(b30004)+", t85 = "+dimsizes(b30009)+", t42a = "+dimsizes(b20007))
;======================================================================================	
     wks = gsn_open_wks("png","unique")          ; send graphics to PNG file

     sres = True
     sres@vpWidthF = 0.7
     sres@vpHeightF = 0.5
     sres@vpXF = .15
     sres@trXMinF = 0.4
     sres@trXMaxF = 12.6
     sres@trYMinF = 0.4
     sres@trYMaxF = 1.2
     sres@gsnDraw = True
     sres@gsnFrame = False
     sres@gsnXYBarChart = True
     sres@gsnXYBarChartBarWidth = 0.15           ; change bar widths
     sres@tmXBMode          = "Explicit"         ; explicit labels
     sres@tmXBValues        = (/1,2,3,4,5,6,7,8,9,10,11,12/)
     sres@tmXBLabels = (/"Jan","Feb","Mar","Apr","May","Jun","Jul","Aug","Sep","Oct","Nov","Dec"/)
     sres@tmXBLabelFontHeightF = 0.0205
     sres@tmXTLabelFontHeightF = 0.0205
     sres@tmYLLabelFontHeightF = 0.0225
     sres@tiMainFontHeightF = 0.025
     sres@tiMainFont = "helvetica"
     sres@tiMainString = "Nino3.4 Monthly Standard Deviation"
     sres@gsnRightString = ""
     sres@tiYAxisString = "(~S~o~N~C)"
        
     sres@gsnXYBarChartColors = (/"red"/)	
     plot1 = gsn_csm_xy(wks,fspan(.775,11.775,12),stdarr(:,0),sres)		; draw each time series
     sres@gsnXYBarChartColors = (/"lightblue"/)					; seperately, not
     plot2 = gsn_csm_xy(wks,fspan(.925,11.925,12),stdarr(:,1),sres)		; advancing the frame
     sres@gsnXYBarChartColors = (/"blue"/)					; but tweaking where
     plot3 = gsn_csm_xy(wks,fspan(1.075,12.075,12),stdarr(:,2),sres)		; each time series is
     sres@gsnXYBarChartColors = (/"green"/)					; drawn on the X-axis
     plot4 = gsn_csm_xy(wks,fspan(1.225,12.225,12),stdarr(:,3),sres)

     lbres                    = True          ; labelbar only resources
     lbres@vpWidthF           = 0.3           ; labelbar width
     lbres@vpHeightF          = 0.1           ; labelbar height
     lbres@lbBoxMajorExtentF  = 0.36          ; puts space between color boxes
     lbres@lbFillColors       = (/"green","blue"/)
     lbres@lbMonoFillPattern  = True          ; Solid fill pattern
     lbres@lbLabelFontHeightF = 0.035         ; font height. default is small
     lbres@lbLabelJust        = "CenterLeft"  ; left justify labels
     lbres@lbPerimOn          = False
     lbres@lgPerimColor 	 = "white"
     labels = (/"CCSM3 (T85)","CCSM3 (T42)"/)
     gsn_labelbar_ndc(wks,2,labels,0.52,0.23,lbres)	; draw right labelbar column
	
     lbres@lbFillColors       = (/"lightblue","red"/)
     labels = (/"CCSM2 (T42)","OBS        "/)
     gsn_labelbar_ndc(wks,2,labels,0.17,0.23,lbres)	; draw left labelbar column
     frame(wks)      
end
