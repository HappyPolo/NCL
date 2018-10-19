;*****************************************************
; coads_4.ncl
;
; Concepts illustrated:
;   - Plotting COADS (Comprehensive Ocean-Atmosphere Data Set) data
;   - Drawing color-filled contours over a cylindrical equidistant map
;   - Paneling four plots on a page with a common labelbar
;   - Setting contour levels using a min/max contour level and a spacing
;   - Spanning part of a color map for contour fill
;   - Converting "short" data to "float"
;   - Changing the center longitude for a cylindrical equidistant projection
;   - Using draw order resources to make sure filled map areas are drawn last
;   - Using "mask" to set a range of values in your data to missing
;   - Drawing raster contours
;   - Drawing subtitles at the top of a plot
;
; This example is very similar to coads_1.ncl. Not sure
; why it was created!
;
;*****************************************************
;
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"  
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"  
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"  
begin


; the "mean" and "nobs" are located on two files

  fa     = addfile("air.mean.nc","r")
  fb     = addfile("air.nobs.nc","r")

; create parameter arrays

  times  = (/707111, 714416, 721721, 729026 /)  ; user times
  yyyymm = (/193701, 195701, 197701, 199701 /)  ; yyyymm 

; Read only desired records and change to float 'on-the-fly'
                            
  air  = short2flt( fa->air({times},:,:) ) ; air temp        
  nobs = short2flt( fb->air({times},:,:) ) ; # obs for air

  nmin = 3                  

; perform filtering mask operates on air depending on number of obs
  air  = mask(air , nobs.ge.nmin, True)
;***************************************
; create individual plots
;***************************************  
  plot= new (dimsizes(times), graphic)          ; create graphical array

  wks = gsn_open_wks("png","coads")             ; send graphics to PNG file
  cmap = read_colormap_file("rainbow")          ; read color map data
  
  res                      = True               ; plot mods desired

  res@cnFillOn             = True               ; color contours
  res@cnFillPalette        = cmap(38:,:)        ; set color map
  res@cnLinesOn            = False              ; turn off contour lines
  res@cnFillMode           = "RasterFill"       ; Raster Mode

  res@cnLevelSelectionMode = "ManualLevels"     ; set manual contour levels
  res@cnMinLevelValF       =   2.               ; set min contour level
  res@cnMaxLevelValF       =  30.               ; set max contour level
  res@cnLevelSpacingF      =   2.               ; set contour spacing

  res@gsnDraw              = False              ; don't draw yet
  res@gsnFrame             = False              ; don't advance frame yet

  res@mpFillDrawOrder      = "PostDraw"         ; plot land last
  res@mpCenterLonF         = 180                ; centers plot at 180 vs 0

  res@lbLabelBarOn         = False              ; turn off individual lb's

  do i = 0,dimsizes(times)-1
     res@gsnRightString      = "time/date="+times(i)+" / "+yyyymm(i) 
     plot(i) = gsn_csm_contour_map_ce(wks,air({times(i)},:,:),res)
  end do
;************************************************
; create panel plot
;************************************************
  resP                  = True                   ; modify the panel plot
  resP@txString         = "COADS: greater than "+nmin+" observations"
  resP@gsnPanelLabelBar = True                   ; add common label bar
  resP@gsnMaximize      = True                   ; maximize plot
  gsn_panel(wks,plot,(/2,2/),resP)               ; now draw as one plot
  
end
