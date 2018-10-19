; ===========================================
; conLev_4.ncl
;
; Concepts illustrated:
;   - Explicitly setting contour levels
;   - Explicitly setting the fill colors for contours
;   - Reordering an array
;   - Removing the mean
;   - Drawing color-filled contours over a cylindrical equidistant map
;   - Turning off contour line labels
;   - Turning off contour lines
;   - Turning off map fill
;   - Turning on map outlines
;
; ===========================================
;
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl" 
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl" 

begin
  f      = addfile ("b003_TS_200-299.nc", "r")
  x      = f->TS(:,:,:)       ; Grab lowest sigma level (=17)
  newx   = dim_rmvmean_n_Wrap(x,0)

  wks = gsn_open_wks("png","conLev")       ; send graphics to PNG file
  gsn_define_colormap(wks,"BlRe")

  res             = True
  res@gsnMaximize = True                        ; maximize plot in frame
  res@mpFillOn    = False                       ; turn map fill off
  res@mpOutlineOn = True                        ; turn the map outline on
  res@cnLevelSelectionMode = "ExplicitLevels"   ; set explicit contour levels
  res@cnLevels    = (/ -12, -10.,-8.,-6.,-4.,-2.,-1.,1.,2.,4.,6.,8.,10.,12./)   ; set levels
  res@cnFillOn    = True                        ; turn on color fill
  res@cnLinesOn   = False                       ; turn off the contour lines
  res@cnFillColors = (/ 3,13,23,30,36,41,45,-1,59,63,68,74,81,91,96/)  ; set the colors to be used
  res@cnLineLabelsOn = False                    ; turn the line labels off

  plot = gsn_csm_contour_map(wks,newx(0,:,:),res)    
end     
