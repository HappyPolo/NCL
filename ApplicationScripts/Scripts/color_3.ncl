;*************************************************
; color_3.ncl
;
; Concepts illustrated:
;   - Drawing filled contours using a selected color map
;   - Drawing contours over a polar stereographic map
;   - Changing the minimum latitude for a polar stereographic map
;   - Selecting a different color map
;   - Using "transparent" as a contour fill color
;   - Explicitly setting the fill colors for contours
;
;************************************************
;
; These files are loaded by default in NCL V6.2.0
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
  wks = gsn_open_wks("png","color")              ; send graphics to PNG file
  gsn_define_colormap(wks, "WhViBlGrYeOrReWh")   ; choose colormap

  res                      = True                ; plot mods desired

  res@tiMainString         = "Example of Using Named Colors" ; plot title
  res@gsnCenterString      = "Paleo_Ice"                     ; center title

  res@cnFillOn             = True               ; turns on the color
  res@cnLinesOn            = False              ; turn off contour lines

; select which colors out of the colormap to use. These are the colors of
; the contours only. They do not effect the missing value, continental fill
; color etc. The -1 is no color or "transparent"
  res@cnFillColors         = (/-1,4,9,19,35,81,75,91,99/)
  res@cnFillDrawOrder       = "PreDraw"         ; make sure fill map on top

  res@cnLevelSelectionMode = "ManualLevels"     ; set manual contour levels
  res@cnMinLevelValF       = 1.                 ; set min contour level
  res@cnMaxLevelValF       = 8.                 ; set max contour level

  res@gsnPolar             = "NH"               ; specify the hemisphere
  res@mpMinLatF            = 65                 ; specify min lat

; note: since ice data is stored on a reduced grid with a data gap in
; latitude from -35 to +35 degrees, it is necessary to provide gsun
; with a sub-set of the data. Otherwise, an error will occur and the
; plot will not be correct. 

  plot = gsn_csm_contour_map_polar(wks,ice({20.:90.},:),res)

  end
