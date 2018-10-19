;----------------------------------------------------------------------
; panel_33.ncl
;
; Concepts illustrated:
;   - Combining two sets of paneled plots on one page
;   - Maximizing paneled plots after they've been created
;   - Drawing two labelbars in a combined panel plot
;   - Using lbBoxEndCapStyle to draw triangles at the end of a labelbar
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
    start_years = (/1951,1961/)
    end_years   = (/1991,2001/)
    nyears      = dimsizes(start_years)

;---Read in temperature and convert to degrees C.
    t       = f->TS                 
    t       = t - 273.15
    t@units = "degC"

;---Start the graphics
    wks  = gsn_open_wks("png","panel")         ; send graphics to PNG file
    
    res                     = True
    res@gsnDraw             = False
    res@gsnFrame            = False
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

    res@lbLabelBarOn        = False            ; turn off individual label bars

    res@gsnStringFontHeightF= 0.02
    res@gsnLeftString       = "TS"
    res@gsnRightString      = t@units

;---Resources for diff plots
    dres                    = res    
    dres@cnMinLevelValF     = -4.
    dres@cnMaxLevelValF     =  4.
    dres@cnLevelSpacingF    =  1.
    dres@cnFillPalette      = "temp_diff_18lev"

;---Create arrays to hold series of plots
    plots      = new(2*nyears,graphic)    
    diff_plots = new(nyears,graphic)    

    do i=0,nyears-1
;---Get data for start and end year of interest
      sy = ind(years.eq.start_years(i).and.months.eq.month)
      ey = ind(years.eq.end_years(i)  .and.months.eq.month)

      diff = t(sy,:,:)                ; trick to copy  metadata
      diff = t(ey,:,:) - t(sy,:,:)    ; overwrite with diff values

      diff@long_name = end_years(i) + "-" + start_years(i) + \
                       " TS field differences"
;---Debug prints
      print("========================================")
      printMinMax(t(sy,:,:),0)
      printMinMax(t(ey,:,:),0)
      printMinMax(diff,0)
    
;---Create the two start/end year plots and the difference plot
      res@gsnCenterString = smonth + " " + start_years(i)
      plots(i) = gsn_csm_contour_map_ce(wks,t(sy,:,:),res)

      res@gsnCenterString = smonth + " " + end_years(i)
      plots(i+nyears) = gsn_csm_contour_map_ce(wks,t(ey,:,:),res)

      dres@gsnCenterString = "Difference: " + smonth + " " + \
                             end_years(i) + "-" + start_years(i)
      diff_plots(i) = gsn_csm_contour_map_ce(wks, diff ,dres)
    end do

;---Resources for paneling
    pres                   = True              ; modify the panel plot
    pres@gsnPanelMainString= fname
    pres@gsnFrame          = False             ; don't advance frame yet
    pres@gsnDraw           = False             ; draw later, in maximize mode
    pres@gsnPanelBottom    = 0.33              ; top 2/3 of frame

    pres@gsnPanelLabelBar  = True              ; add common colorbar
    pres@lbOrientation     = "vertical"
    pres@pmLabelBarWidthF  = 0.075             ; make thinner
    pres@pmLabelBarHeightF = 0.40

;
; It is necessary to return the id of the paneled plots,
; so they can "live" for the rest of this script, for
; when we maximize them later.
; 
    panelid1 = gsn_panel_return(wks,plots,(/2,nyears/),pres) 

;---Calculate location for top of difference plots
    bb     = NhlGetBB(panelid1)
    bottom = min(bb(:,1))
    top    = max(bb(:,0))
    height = (top-bottom)/2.     ; Height of one row

;---Panel the diff plots at the bottom
    delete(pres@gsnPanelMainString)
    pres@gsnPanelTop       = bottom-0.01    ; lower 1/3 plus some white space
    pres@gsnPanelBottom    = pres@gsnPanelTop - height
    pres@lbBoxEndCapStyle  = "TriangleBothEnds"    ; Added in NCL V6.4.0

    pres@pmLabelBarHeightF = 0.20  

    panelid2 = gsn_panel_return(wks,diff_plots,(/1,2/),pres)

;---This will maximize the size of all the paneled stuff.
    maximize_output(wks,True)
end
    
