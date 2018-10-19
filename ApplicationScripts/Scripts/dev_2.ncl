;*************************************************
; dev_2.ncl
;
; Concepts illustrated:
;   - Calculating deviation from zonal mean
;   - Drawing zonal average plots
;   - Moving the contour informational label into the plot
;   - Changing the background color of the contour line labels
;   - Spanning part of a color map for contour fill
;   - Making the labelbar be vertical
;   - Paneling two plots vertically on a page
;   - Drawing color-filled contours over a cylindrical equidistant map
;   - Using a blue-white-red color map
;   - Reordering an array
;
;************************************************
;
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl" 
;************************************************
begin
;************************************************
; variable and file handling
;************************************************
   fn  = "b003_TS_200-299.nc" ; define filename
   in  = addfile(fn,"r")                                 ; open netcdf file
   ts  = in->TS                                          ; read in variable
;************************************************
;  calculate deviation from zonal mean
;************************************************
   anom = ts(lat|:,lon|:,time|:)                 ; trick to copy cv's and atts
   anom = dim_rmvmean(ts(lat|:,lon|:,time|:))    ; reordered array
;
; In version 5.1.1, you can replace the above two lines with
; the following single line. Use the dim_xxx_n functions to
; avoid having to reorder the data. Some of them have a 
; corresponding dim_xxx_n_Wrap function that copies metadata.
;
;   anom = dim_rmvmean_n_Wrap(ts,0)
;************************************************
; plot parameters
;************************************************
   wks  = gsn_open_wks("png","dev")              ; send graphics to PNG file 

   plot = new(2,graphic)                         ; create graphical array
   res              = True                       ; plot mods desired
   res@gsnFrame     = False                      ; don't draw 
   res@gsnDraw      = False                      ; don't advance frame yet
;************************************************
; original data
;************************************************
   res@gsnZonalMean               = True         ; add zonal plot
   res@gsnZonalMeanXMinF = 200.                  ; set minimum X-axis value for zonal mean plot  
   res@gsnZonalMeanXMaxF = 310.                  ; set maximum X-axis value for zonal mean plot  
   res@gsnZonalMeanYRefLine = 273.15             ; set reference line X-axis value
   res@mpFillOn                   = False        ; no grey continents
   res@cnInfoLabelOrthogonalPosF  = -0.17        ; move info label up
   res@cnLineLabelFontHeightF     = .012         ; increase font size
   res@cnLabelDrawOrder           = "PostDraw"   ; labels on top of lines
   res@cnLineLabelBackgroundColor = "white"      ; white background on labels
   res@gsnCenterString            = "Time(0)"    ; add center title

; panel expects plots to be of the same size. Since these two plots are
; very different, we are forcing them to be the same size by setting the
; width.
   res@vpWidthF                   = 0.7

   plot(0)=gsn_csm_contour_map(wks,ts(0,:,:),res)  
   delete(res@gsnZonalMean)                      ; delete zonal plot
   delete(res@gsnZonalMeanXMinF)		 ; delete zonal plot min x-axis resource
   delete(res@gsnZonalMeanXMaxF)		 ; delete zonal plot max x-axis resource
   delete(res@gsnZonalMeanYRefLine)		 ; delete zonal plot reference line resource
;************************************************
; anomaly data
;************************************************
   cmap = read_colormap_file("BlWhRe")             ; read color data
   ncolors = dimsizes(cmap(:,0))                   ; get number of colors

   res@gsnCenterString     = "Deviations from time ave"
   res@lbOrientation       = "Vertical"          ; vertical label bar
   res@cnFillOn            = True                ; color plot
   res@cnFillPalette       = cmap(22:ncolors-26,:) ; set color map

   plot(1)=gsn_csm_contour_map(wks,anom(:,:,0),res)
;************************************************
; panel plot
;************************************************
   gsn_panel(wks,plot,(/2,1/),False)
;***********************************************
end


