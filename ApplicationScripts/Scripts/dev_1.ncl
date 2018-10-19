;*************************************************
; dev_1.ncl
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
;
;************************************************
;
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl" 
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
;
; This file still has to be loaded manually 
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl" 
;************************************************
begin
;************************************************
; variable and file handling
;************************************************
   fn  = "83.nc"                                 ; define filename
   in  = addfile(fn,"r")                         ; open netcdf file
   ts  = in->TS                                  ; select variable to ave
;************************************************
;  calculate deviation from zonal mean
;************************************************
   anom = ts                                     ; trick to copy cv's and atts
   anom = dim_rmvmean(ts)
;************************************************
; plot parameters
;************************************************
   wks  = gsn_open_wks("png","dev")              ; send graphics to PNG file 

   plot = new(2,graphic)                         ; create graphical array
   res              = True                       ; plot mods desired
;************************************************
; original data
;************************************************
   res@gsnDraw                    = False        ; don't draw yet
   res@gsnFrame                   = False        ; don't advance frame yet

   res@gsnZonalMean               = True         ; add zonal plot
   res@mpFillOn                   = False        ; no grey continents
   res@cnInfoLabelOrthogonalPosF  = -0.17        ; move info label up
   res@cnLineLabelFontHeightF     = .012         ; increase font size
   res@cnLabelDrawOrder           = "PostDraw"   ; labels on top of lines
   res@cnLineLabelBackgroundColor = "white"      ; white background on labels
   res@gsnCenterString            = "Original Data"

; panel expects plots to be of the same size. Since these two plots are
; very different, we are forcing them to be the same size by setting the
; width.
   res@vpWidthF                   = 0.7

   plot(0) = gsn_csm_contour_map(wks,ts(0,:,:),res)  
   delete(res@gsnZonalMean)                      ; delete zonal plot
;************************************************
; anomaly data
;************************************************
   cmap = read_colormap_file("BlWhRe")           ; read color data
   ncolors = dimsizes(cmap(:,0))                 ; get number of colors
   res@gsnCenterString     = "Deviation from zonal ave"
   res@lbOrientation       = "Vertical"          ; vertical label bar
   res@cnFillOn            = True                ; color plot
   res@cnFillPalette       = cmap(22:ncolors-26,:) ; set color map
   plot(1) = gsn_csm_contour_map(wks,anom(0,:,:),res)

; panel the two plots together
   gsn_panel(wks,plot,(/2,1/),False)
end


