;**********************************
; Erik_taylor_panel_Example_2.ncl
;**********************************
; This script creates a panel plot of Taylor diagrams. This example 
; does not use default marker labels and instead uses gsn_add_text
; to create individual labels within each plot. The labels are optional. 
;
; This Taylor plot interface relies on the script 
; "taylor_diagram_enoble.ncl", written by Erik Noble at Nasas.
;
; Inside of that script, the following parts are commented out:
;       ; dum11 = dum10
;       
;       ; if (rOpts .and. isatt(rOpts,"markerLabels")) then
;       ;             dum11(n*nVar+i) = gsn_add_text(wks,taylor,rOpts@markerLabels(i),X(n,i),Y(n,i)+markerTxYOffset,ptRes)
;       ;          else
;       ;             dum11(n*nVar+i) = gsn_add_text(wks,taylor,(i+1),X(n,i),Y(n,i)+markerTxYOffset,ptRes)
;       ;          end if
;
;       ; taylor@$unique_string("dum")$ = dum11  ; text
         
;**********************************
;
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"  
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"  
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
;
; These files still have to be loaded manually  
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl" 
load "./taylor_diagram_enoble.ncl"
;**********************************
begin
;**********************************
    type      = "png"
    plot_name = "Erik_taylor_panel_Example"

    plot_title = (/"Total Precipitation: WRF vs. TRMM ~C~               (5N-15N, 20W-10E)",  \
                   "Total Precipitation: WRF vs. TRMM ~C~               (10N-20N, 20W-10E)", \
                   "Total Precipitation: WRF vs. CMORPH ~C~               (5N-15N, 20W-10E)", \
                   "Total Precipitation: WRF vs. CMORPH ~C~               (10N-20N, 20W-10E)", \
                   "Total Precipitation: WRF vs. PERSIANN ~C~               (5N-15N, 20W-10E)", \
                   "Total Precipitation: WRF vs. PERSIANN ~C~               (10N-20N, 20W-10E)"/)

    ;**********************************
    ; Read ASCII data from several files
    ; into one big data array
    ;**********************************
    data        = new((/6,70,5/),float,-9999)
    data(0,:,:) = readAsciiTable("results_all_vs_TRMM_5-15_-20-10.text",5,"float",0)
    data(1,:,:) = readAsciiTable("results_all_vs_TRMM_10-20_-20-10.text",5,"float",0)
    data(2,:,:) = readAsciiTable("results_all_vs_CMORPH_5-15_-20-10.text",5,"float",0)
    data(3,:,:) = readAsciiTable("results_all_vs_CMORPH_10-20_-20-10.text",5,"float",0)
    data(4,:,:) = readAsciiTable("results_all_vs_PRESIANN_5-15_-20-10.text",5,"float",0)
    data(5,:,:) = readAsciiTable("results_all_vs_PRESIANN_10-20_-20-10.text",5,"float",0)
        
    ;**********************************
    ; Put the ratios and pattern correlations into
    ; arrays for plotting
    ;**********************************
    plots      = 6
    nDataSets  = 4                               ; number of datasets
    npts       = dimsizes(data(0,:,0))
    ratio      = new ((/plots, nDataSets, npts/),float )
    cc         = new ((/plots, nDataSets, npts/),float )
   
    cc(:,0,0:63)     = data(:,0:63,1)
    ratio(:,0,0:63)  = data(:,0:63,3)
    cc(:,1,64:66)    = data(:,64:66,1)
    ratio(:,1,64:66) = data(:,64:66,3)
    cc(:,2,67:68)    = data(:,67:68,1)
    ratio(:,2,67:68) = data(:,67:68,3)
    cc(:,3,69)       = data(:,69,1)
    ratio(:,3,69)    = data(:,69,3)

        
    ; *******************************************************************
    ; Open wks and set plot options
    ; *******************************************************************
    wks = gsn_open_wks(type,plot_name)

    plot = new(6,graphic)

    res                 = True                     ; diagram mods desired
    res@Colors          = (/"red","blue","green","brown"/)       ; marker colors
    res@caseLabels      = (/"WRF","HRRP","Reanalysis","RM3"/)
    res@Markers         = (/16,10,11,13/);(/16,16,16,16/)        ; marker styles
    res@markerTxYOffset = 0.04                     ; offset btwn marker & label
    res@gsMarkerSizeF   = 0.006                    ; marker size  
    res@txFontHeightF   = 0.015                    ; text size

    ;res@stnRad         = (/ 0.5, 1.5 /)     ; additional standard radii
    res@ccRays          = (/ 0.4, 0.9 /)     ; correllation rays
    res@ccRays_color    = "LightGray"        ; default is "black"

    res@centerDiffRMS   = False               ; RMS 'circles'
    res@centerDiffRMS_color = "LightGray"    ; default is "black"/)
        
    res@taylorDraw  = False                          ; don't draw
    res@taylorFrame = False                          ; don't advance frame
    ; res@gsnMaximize = True
    ; *******************************************************************
    ; Generate one plot for each season + annual.
    ; *******************************************************************
    do i=0,plots-1
      res@tiMainString    = plot_title(i)              ; title
      plot(i)  = taylor_diagram(wks, ratio(i,:,:), cc(i,:,:), res)
    end do

    ;optional code for adding text strings.
    txid = new((/plots,9/),graphic)
    txres = True
    txres@txFont        = "helvetica-bold" 
    txres@txFontHeightF = 0.0135
    ; 5-15 TRMM
    ; models
    txid(0,0) = gsn_add_text(wks,plot(0),"2", 0.11, 1.44, txres)
    txid(0,1) = gsn_add_text(wks,plot(0),"59", 0.13, 1.35,txres)
    txid(0,2) = gsn_add_text(wks,plot(0),"62", 0.26, 1.02,txres)
    txid(0,3) = gsn_add_text(wks,plot(0),"TRMM", 1.12, 0.07,txres)
    txid(0,4) = gsn_add_text(wks,plot(0),"CMORPH", 0.79, 0.76,txres)
    txid(0,5) = gsn_add_text(wks,plot(0),"PERSIANN", 0.26, 0.71,txres)
    txid(0,6) = gsn_add_text(wks,plot(0),"MERRA", 0.26, 0.54,txres)
    txid(0,7) = gsn_add_text(wks,plot(0),"NNRP2", 0.12, 0.85,txres)
    txid(0,8) = gsn_add_text(wks,plot(0),"RM3", 0.78, 0.61,txres)
         
    ; models
    txid(1,0) = gsn_add_text(wks,plot(1),"2", 1.68, 2.49,txres)
    txid(1,1) = gsn_add_text(wks,plot(1),"59", 1.51, 1.80,txres)
    txid(1,2) = gsn_add_text(wks,plot(1),"62", 0.59, 1.26,txres)
    txid(1,3) = gsn_add_text(wks,plot(1),"TRMM", 1.10, 0.07,txres)
    txid(1,4) = gsn_add_text(wks,plot(1),"CMORPH", 1.25, 1.02,txres)
    txid(1,5) = gsn_add_text(wks,plot(1),"PERSIANN", 0.75, 1.04,txres)
    txid(1,6) = gsn_add_text(wks,plot(1),"MERRA", 0.52, 0.93,txres)
    txid(1,7) = gsn_add_text(wks,plot(1),"NNRP2", 0.57, 1.37,txres)
    txid(1,8) = gsn_add_text(wks,plot(1),"RM3", 0.94, 0.85,txres)      
         
    txid(2,0) = gsn_add_text(wks,plot(2),"2", 0.50, 1.80,txres)
    txid(2,1) = gsn_add_text(wks,plot(2),"59", 0.64, 1.25,txres)
    txid(2,2) = gsn_add_text(wks,plot(2),"62", 0.40, 1.00,txres)
    txid(2,3) = gsn_add_text(wks,plot(2),"TRMM", 0.90, 0.75,txres)
    txid(2,4) = gsn_add_text(wks,plot(2),"CMORPH", 1.2, 0.07,txres)
    txid(2,5) = gsn_add_text(wks,plot(2),"PERSIANN", 0.55, 0.65,txres)
    txid(2,6) = gsn_add_text(wks,plot(2),"MERRA", 0.20, 0.73,txres)
    txid(2,7) = gsn_add_text(wks,plot(2),"NNRP2", 0.16, 0.90,txres)
    txid(2,8) = gsn_add_text(wks,plot(2),"RM3", 0.60, 0.91,txres)
                 
    txid(3,0) = gsn_add_text(wks,plot(3),"2", 1.21, 1.51,txres)
    txid(3,1) = gsn_add_text(wks,plot(3),"59", 1.17, 1.01,txres)
    txid(3,2) = gsn_add_text(wks,plot(3),"62", 0.50, 0.72,txres)
    txid(3,3) = gsn_add_text(wks,plot(3),"TRMM", 0.78, 0.50,txres)
    txid(3,4) = gsn_add_text(wks,plot(3),"CMORPH", 1.2, 0.07,txres)
    txid(3,5) = gsn_add_text(wks,plot(3),"PERSIANN", 0.25, 0.40,txres)
    txid(3,6) = gsn_add_text(wks,plot(3),"MERRA", 0.28, 0.50,txres)
    txid(3,7) = gsn_add_text(wks,plot(3),"NNRP2", 0.35, 0.87,txres)
    txid(3,8) = gsn_add_text(wks,plot(3),"RM3", 0.70, 0.41,txres)
         
    txid(4,0) = gsn_add_text(wks,plot(4),"2", 0.82, 2.06,txres)
    txid(4,1) = gsn_add_text(wks,plot(4),"59", 0.67, 1.48,txres)
    txid(4,2) = gsn_add_text(wks,plot(4),"62", 0.49, 1.22,txres)
    txid(4,3) = gsn_add_text(wks,plot(4),"TRMM", 0.88, 1.10,txres)
    txid(4,4) = gsn_add_text(wks,plot(4),"CMORPH", 0.90, 0.80,txres)
    txid(4,5) = gsn_add_text(wks,plot(4),"PERSIANN", 1.2, 0.07,txres)
    txid(4,6) = gsn_add_text(wks,plot(4),"MERRA", 0.20, 0.73,txres)
    txid(4,7) = gsn_add_text(wks,plot(4),"NNRP2", 0.16, 1.10,txres)
    txid(4,8) = gsn_add_text(wks,plot(4),"RM3", 0.50, 1.10,txres)
                 
    txid(5,0) = gsn_add_text(wks,plot(5),"2", 1.50, 1.95,txres)
    txid(5,1) = gsn_add_text(wks,plot(5),"59", 1.37, 1.37,txres)
    txid(5,2) = gsn_add_text(wks,plot(5),"62", 0.65, 0.92,txres)
    txid(5,3) = gsn_add_text(wks,plot(5),"TRMM", 1.15, 0.79,txres)
    txid(5,4) = gsn_add_text(wks,plot(5),"CMORPH", 0.50, 0.57,txres)
    txid(5,5) = gsn_add_text(wks,plot(5),"PERSIANN", 1.2, 0.07,txres)
    txid(5,6) = gsn_add_text(wks,plot(5),"MERRA", 0.350, 0.73,txres)
    txid(5,7) = gsn_add_text(wks,plot(5),"NNRP2", 0.48, 1.10,txres)
    txid(5,8) = gsn_add_text(wks,plot(5),"RM3", 0.80, 0.70,txres)
          
    ; *******************************************************************
    ; Create demo panels
    ; *******************************************************************
    resP                                  = True
    resP@gsnMaximize                      = True
    resP@gsnPanelFigureStrings            = (/"a)","b)","c)","d)","e)","f)"/)
    resP@gsnPanelFigureStringsFontHeightF = 0.013 
    resP@amJust                           = "TopLeft"

    gsn_panel(wks,plot,(/3,2/),resP)
end
 
