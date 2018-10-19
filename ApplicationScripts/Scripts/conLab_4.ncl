;*************************************************
; conLab_4.ncl
;
; Concepts illustrated:
;   - Drawing color-filled contours over a cylindrical equidistant map
;   - Setting the background fill color for contour labels to white
;   - Forcing labels to appear on every contour line
;   - Masking contour lines so they don't go through contour labels
;   - Masking contours so they don't go through contour labels
;   - Changing the contour level spacing
;   - Zooming in on a particular area on a cylindrical equidistant map
;   - Spanning the full color map for contour fill
;   - Creating a center subtitle
;   - Paneling three plots vertically on a page
;
;************************************************
;
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"  
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"  
;************************************************
begin
;************************************************
; read in netCDF file
;************************************************
  a = addfile("$NCARG_ROOT/lib/ncarg/data/cdf/uv300.nc","r")
;************************************************
; read in zonal winds
;************************************************
  u = a->U(1,:,:)                                
;************************************************
; create default plot
;************************************************
  wks  = gsn_open_wks("png","conLab")             ; open a png file

  res  = True

  res@cnFillOn                   = True          ; turn on color

  res@mpMinLatF                  = -30           ; zoom map
  res@mpMaxLatF                  =  30
  res@mpMinLonF                  = 0
  res@mpMaxLonF                  = 70
  res@cnFillPalette              = "gui_default"

  res@cnLineLabelsOn             = True          ; turn on line labels

  res@cnLineLabelBackgroundColor = "white"       ; white bckgrnd around label
  plot = gsn_csm_contour_map_ce(wks,u,res)       ; create a cylindrical equidistant plot


end



