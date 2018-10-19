;**********************************
; Erik_taylor_panel_Example_1.ncl
;**********************************
; This script creates a panel plot of Taylor diagrams. This example 
; does not use default marker labels.
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
