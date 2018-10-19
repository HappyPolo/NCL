;----------------------------------------------------------------------
; contoursym_4.ncl
;
; Concepts illustrated:
;   - Using a blue-red color map
;   - Setting resources to match contour levels with a two-color color table
;   - Generating dummy data using "random_normal"
;   - Explicitly setting contour levels
;   - Drawing cell-filled contours
;----------------------------------------------------------------------
; This script was contributed by Chad Herman.
;----------------------------------------------------------------------
;
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"

;----------------------------------------------------------------------
; This function sets the gsnSpreadXXX resources necessary to correctly
; span a two-color colortable.
;
; lower  = cnMinLevelValF
; upper  = cnMaxLevelValF
; step   = cnLevelSpacingF
; center = The numerical value the colormap is centered on. For
;          anomalies or trends, it's common to use 0.0, so blue means
;          cold or cooling and red means warm or warming.
; color_end = The number of colors in colormap (ex. 97 for BlRe, 253 
;             for BlueRed)
; center_color = Color value on the left of the "center" value
; (see above).
;----------------------------------------------------------------------
undef("gsnColorRange")
function gsnColorRange(lower:numeric, upper:numeric, step:numeric, \
                       center:numeric, color_end:integer, center_color:integer)
local nboxes_left, nboxes_right, ncolors_left, ncolors_right, output, \
      color_start
begin

 color_start = 2 ; All of the color maps begin with 2.
;
; Calculate the number of color bar boxes to the left and right of
; the "center" value.
;
 nboxes_left  = (center - (lower - step))/step
 nboxes_right = ((upper + step) - center)/step

;
; Calculate the number of colors in the map on the left and right hand sides.
;
 ncolors_left = (center_color - color_start + 1)
 ncolors_right = (color_end - center_color)

 output = True

;
;
; Either the lower or upper extent of the color map will be adjusted. If
; the magnitude of the lower limit is less than the magnitude of the
; upper limit, then the lower limit has to be "moved in" towards the
; center color. Oppositely, the upper limit will be moved. If both the
; lower and upper numerical values are the same, then pass back 2 as the
; lower extent and color_end (number of colors) as the upper extent (use
; the whole map in other words).
;
 if(abs(lower) .lt. abs(upper))then

  output@ColorStart = round(center_color - (ncolors_right/nboxes_right)*nboxes_left, 3)
  output@ColorEnd   = color_end

 else

;---no "else if" in NCL :(
  if(abs(lower) .gt. abs(upper))then
   output@ColorStart = 2
   output@ColorEnd   = round(center_color + (ncolors_left/nboxes_left)*nboxes_right, 3)
  else
   output@ColorStart = 2
   output@ColorEnd   = color_end
  end if

 end if

 return(output)

end


;----------------------------------------------------------------------
; Main code
;----------------------------------------------------------------------
begin

;---Generate a grid of random data.
 nlat = 90
 nlon = 180

 lat = latGlobeFo(nlat, "lat", "latitude", "degrees_north")
 lon = lonGlobeFo(nlon, "lon", "longitude", "degrees_east")

 grid = onedtond(random_normal(0, 1, nlat*nlon), (/nlat, nlon/))
 grid!0 = "lat"
 grid!1 = "lon"
 grid&lat = lat
 grid&lon = lon

;---Set the plotting limits.
 grid_min    = -2.4
 grid_max    =  3.2
 grid_step   =  0.2
 grid_center =  0.0

;
; For the "BlRe" colormap, we have 97 colors and the color 
; transitions from blue to red at 49. See :
;
;  http://www.ncl.ucar.edu/Document/Graphics/ColorTables/BlRe.shtml
;
; For the "BlueRed" or "GreenYellow" color maps, we have 253 colors and
; a transition at color 97.
;
 gsn_range = gsnColorRange(grid_min, grid_max, grid_step, grid_center, 97, 49)

 res = True

 res@cnFillOn              = True
 res@cnFillMode            = "CellFill"
 res@cnLinesOn             = False
 res@cnLevelSelectionMode  = "ManualLevels"
 res@cnMinLevelValF        = grid_min
 res@cnMaxLevelValF        = grid_max
 res@cnLevelSpacingF       = grid_step

 res@gsnMaximize         = True
 res@gsnSpreadColors     = True
 res@gsnSpreadColorStart = gsn_range@ColorStart
 res@gsnSpreadColorEnd   = gsn_range@ColorEnd
 res@lbLabelStride       = 2

 wks = gsn_open_wks("png", "contoursym")  ; send graphics to PNG file
 gsn_define_colormap(wks,"BlRe")
 plot = gsn_csm_contour_map(wks, grid, res)
end
