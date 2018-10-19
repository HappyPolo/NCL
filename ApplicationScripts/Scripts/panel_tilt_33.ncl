;----------------------------------------------------------------------
; panel_33.ncl
;
; Concepts illustrated:
;   - Combining two sets of paneled plots on one page
;   - Maximizing paneled plots after they've been created
;   - Drawing two labelbars in a combined panel plot
;----------------------------------------------------------------------
;
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"

begin
;---Open file
    fname = "TS.cam3.toga_ENS.1950-2000.nc"
    f     = addfile(fname,"r")

;---Convert "time" to an ntim x 6 array of year,mon,day,hour,min,sec
    newtime = cd_calendar(f->time,0)
    years   = newtime(:,0)
    months  = newtime(:,1)
    
;---Indicate start and end years of interest. Best to only do 1 or 2 here
    month      = 1                  ; January
    smonth     = "Jan"
    plot_years = ispan(1951,1991,10)   ; every 10th year
    nyears     = dimsizes(plot_years)

;---Read in temperature and convert to degrees C.
    t       = f->TS                 
    t       = t - 273.15
    t@units = "degC"

;---Start the graphics
    
    res                     = True
    res@mpFillOn            = False            ; no need   

    res@cnLevelSelectionMode= "ManualLevels"   ; manual set levels
    res@cnMinLevelValF      = -3.0
    res@cnMaxLevelValF      = 27.0
    res@cnLevelSpacingF     = 1.5              ; 20 contour levels        
    res@cnFillOn            = True             ; color fill plot
    res@cnLinesOn           = False
    res@cnLineLabelsOn      = False
    res@cnInfoLabelOn       = False
    res@cnFillPalette       = "BlAqGrYeOrRe"

    res@gsnStringFontHeightF= 0.02
    res@gsnLeftString       = "TS"
    res@gsnRightString      = t@units
    res@gsnStringFontHeightF = 0.015
    res@lbLabelBarOn        = False            ; turn off individual label bars

;---Create array to hold plots
    plots = new(nyears,graphic)    

    do i=0,nyears-1
      wks  = gsn_open_wks("png","panel_"+plot_years(i))

;---Get data for year of interest
      iy = ind(years.eq.plot_years(i).and.months.eq.month)

;---Debug prints
      print("========================================")
      printMinMax(t(iy,:,:),0)
    
;---Create the start/end year plots
      res@gsnCenterString = smonth + " " + plot_years(i)
      plots(i) = gsn_csm_contour_map(wks,t(iy,:,:),res)
    end do

;--- new width and height of sheared images 1685x2383
     
     co1="panel_1951.png"
     co2="panel_1961.png"
     co3="panel_1971.png"
     co_width=2000  
     co_height=600
     dxco1=25
     dxco2=25
     dxco3=1
     dyco1=1370
     dyco2=890
     dyco3=400
     angle=-40
;-- cut off white space around the plot
     alpha = "on"
     bgc   = "white"
     cmd1 = "convert -alpha " + alpha + " -background " + bgc + " -density 300 -trim " + co1 + " tmp_c1.png"
     cmd2 = "convert -alpha " + alpha + " -background " + bgc + " -density 300 -trim " + co2 + " tmp_c2.png"
     cmd3 = "convert -alpha " + alpha + " -background " + bgc + " -density 300 -trim " + co3 + " tmp_c3.png"
     system(cmd1)
     system(cmd2)
     system(cmd3)
   #-- original and new coordinate positions of the edges for distortion
     xul=0      
    dxul=400
     yul=0      
    dyul=50
  
     xur=2200   
    dxur=1500
     yur=0      
    dyur=50
  
     xlr=2200   
    dxlr=1900
     ylr=1200   
    dylr=1200
  
     xll=0      
    dxll=0
     yll=1200   
    dyll=1200
        
;-- do the distortion and write the result to a temporary file
    cmd = "convert tmp_c1.png -alpha $alpha -virtual-pixel transparent -distort Perspective " + \
           $xul,$yul $dxul,$dyul   \
                                   $xur,$yur $dxur,$dyur   \ 
                                   $xlr,$ylr $dxlr,$dylr   \
                                   $xll,$yll $dxll,$dyll"  tmp_contour_1.png

end
    
