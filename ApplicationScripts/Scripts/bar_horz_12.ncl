;*************************************************
; bar_horz_12.ncl
;
; Concepts illustrated:
;   - Drawing four sets of "floating" filled bars
;   - Changing the aspect ratio of a bar plot
;   - Changing the height of the bars in a bar plot
;   - Setting the minimum/maximum value of the X and Y axis in a bar plot
;   - Drawing a custom labelbar
;   - Explicitly setting tickmarks and labels on the left Y axis
;
;************************************************
; This example is not included in the main bar page, 
; but is being included here for reference purposes.
;************************************************
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

  arr_std = new((/12,4/),"float")      ; create array to hold monthly 
                                       ; standard deviation values
  do hh = 0,11
     arr_std(hh,0) = (/ dim_stddev(obsts(hh::12)) /)
     arr_std(hh,1) = (/ dim_stddev(b20007(hh::12)) /)
     arr_std(hh,2) = (/ dim_stddev(b30004(hh::12)) /)
     arr_std(hh,3) = (/ dim_stddev(b30009(hh::12)) /)
  end do
  arr_avg = random_uniform(-0.25,.5,(/12,4/)) ; create array holding fictional averages 
                                              ; (above files contain anomalies, thus
                                              ; averages would be = 0)
  arr_max = arr_avg+arr_std                   ; create array holding maximum monthly -1 
                                              ; standard deviation values
  arr_min = arr_avg-arr_std                   ; create array holding minimum monthly -1 
                                              ; standard deviation values

;======================================================================================
; Start the graphics
;======================================================================================

  wks      = gsn_open_wks("png","bar_horz")          ; send graphics to PNG file

  sres                       = True

  sres@gsnDraw               = True
  sres@gsnFrame              = False

  sres@vpWidthF              = 0.5
  sres@vpHeightF             = 0.7
  sres@vpYF                  = .15

  sres@trYMinF               =  0.4
  sres@trYMaxF               = 12.6
  sres@trXMinF               = -1.5
  sres@trXMaxF               =  1.5

  sres@gsnXYBarChart         = True
  sres@gsnXYBarChartBarWidth = 0.15     ; change bar widths
  sres@gsnXRefLineColor      = "transparent"

  sres@tmYLMode              = "Explicit"      ; explicit labels
  sres@tmYLValues            = (/1,2,3,4,5,6,7,8,9,10,11,12/)
  sres@tmYLLabels            = (/"Jan","Feb","Mar","Apr","May","Jun",\
                                 "Jul","Aug","Sep","Oct","Nov","Dec"/)
  sres@tmYLLabelFontHeightF  = 0.0205
  sres@tmYRLabelFontHeightF  = 0.0205
  sres@tmXBLabelFontHeightF  = 0.0225

  sres@tiMainString          = "Data Range: +/- 1 Standard Deviation"
  sres@tiMainFont            = "helvetica"
  sres@tiMainFontHeightF     = 0.025
  sres@tiXAxisString         = "(~S~o~N~C)"

  sres@gsnRightString        = ""
  
  plot1 = new((/2,12/),graphic)
  plot2 = plot1
  plot3 = plot1
  plot4 = plot1
  do gg = 0,11   
     sres@gsnXYBarChartColors = "red"
     sres@gsnXRefLine         = arr_avg(gg,0)    
     plot1(0,gg) = gsn_csm_xy(wks,arr_max(gg,0),.775+gg,sres)    ; draw each individual 
                                                                 ; max bar
     plot1(1,gg) = gsn_csm_xy(wks,arr_min(gg,0),.775+gg,sres)    ; draw each individual
                                                                 ; min bar
       
     sres@gsnXYBarChartColors = (/"lightblue"/)
     sres@gsnXRefLine         = arr_avg(gg,1)    

     plot2(0,gg) = gsn_csm_xy(wks,arr_max(gg,1),.925+gg,sres)
     plot2(1,gg) = gsn_csm_xy(wks,arr_min(gg,1),.925+gg,sres)   

     sres@gsnXYBarChartColors = (/"blue"/)
     sres@gsnXRefLine         = arr_avg(gg,2)    
     plot3(0,gg) = gsn_csm_xy(wks,arr_max(gg,2),1.075+gg,sres)
     plot3(1,gg) = gsn_csm_xy(wks,arr_min(gg,2),1.075+gg,sres)   
     
     sres@gsnXYBarChartColors = (/"green"/)    ; drawn on the X-axis
     sres@gsnXRefLine         = arr_avg(gg,3)    
     plot4(0,gg) = gsn_csm_xy(wks,arr_max(gg,3),1.225+gg,sres)
     plot4(1,gg) = gsn_csm_xy(wks,arr_min(gg,3),1.225+gg,sres)   
  end do
  
;---Create two individual labelbars
  lbres                    = True          ; labelbar only resources
  lbres@vpWidthF           = 0.3           ; labelbar width
  lbres@vpHeightF          = 0.1           ; labelbar height
  lbres@lbBoxMajorExtentF  = 0.36          ; puts space between color boxes
  lbres@lbMonoFillPattern  = True          ; Solid fill pattern
  lbres@lbFillColors       = (/"green","blue"/)
  lbres@lbLabelFontHeightF = 0.015         ; font height. default is small
  lbres@lbLabelJust        = "CenterLeft"  ; left justify labels
  lbres@lbPerimOn          = False
  lbres@lgPerimColor       = "white"

  labels = (/"CCSM3 (T85)","CCSM3 (T42)"/)
  gsn_labelbar_ndc(wks,2,labels,0.52,0.23,lbres)    ; draw right labelbar column
	
  lbres@lbFillColors    = (/"lightblue","red"/)
  labels                = (/"CCSM2 (T42)","OBS     "/)
  gsn_labelbar_ndc(wks,2,labels,0.17,0.23,lbres)    ; draw left labelbar column

  frame(wks)
end
