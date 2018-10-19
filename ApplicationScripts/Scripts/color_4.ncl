;*************************************************
; color_4.ncl
;
; Concepts illustrated:
;   - Drawing contours over a polar stereographic map
;   - Creating a color map using named colors
;   - Changing the minimum latitude for a polar stereographic map
;   - Using coordinate subscripting to read a specified geographical region
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
; read in netCDF file
;************************************************
  a = addfile("ice001608.nc","r")
;************************************************
; read in ice coverage
;************************************************
  ice = a->hice(0,:,:) 
;************************************************
; create plot
;************************************************
  wks = gsn_open_wks("png","color")               ; send graphics to PNG file

;***********************************************
; create array of named colors. Note that you 
; should not include the background or foreground
; colors.
;***********************************************
  colors = (/"white","royal blue","light sky blue",\
	     "powder blue","light sea green",\
              "pale green","wheat","brown","pink"/)

  res = True                                     ; plot mods desired

  res@tiMainString         = "Example of Using Named Colors" ; plot title
  res@gsnCenterString      = "Paleo_Ice"                     ; center title

  res@cnFillPalette        = colors
  res@cnFillOn             = True               ; turns on the color
  res@mpFillOn             = False              ; turns off continent gray
  res@cnLinesOn            = False              ; turn off contour lines

  res@cnLevelSelectionMode = "ManualLevels"     ; set manual contour levels
  res@cnMinLevelValF       = 1.                 ; set min contour level
  res@cnMaxLevelValF       = 8.                 ; set max contour level

  res@gsnPolar             = "NH"               ; specify the hemisphere
  res@mpMinLatF            = 70                 ; specify min lat

; note: since ice data is stored on a reduced grid with a data gap in
; latitude from -35 to +35 degrees, it is necessary to provide gsun
; with a sub-set of the data. Otherwise, an error will occur and the
; plot will not be correct. 

  plot = gsn_csm_contour_map_polar(wks,ice({20.:90.},:),res)

  end
