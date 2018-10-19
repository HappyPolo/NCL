;--------------------------------------------------
;  mapgrid_3.ncl
;--------------------------------------------------
; Concepts illustrated:
;   - Drawing a lat/lon grid on a map
;   - Using draw order resources to draw map grid lines under land
;   - Changing the style of the map tickmarks labels
;   - Drawing a map using the medium resolution map outlines
;   - Changing the color of the map grid lines
;   - Setting the spacing for latitude/longitude grid lines
;   - Adding a map to another map as an annotation
;   - Drawing two sets of lat/lon grid lines at different spacings
;   - Drawing a map using the high resolution map outlines
;--------------------------------------------------
;
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"  
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"  

begin
  wks  = gsn_open_wks ("png", "mapgrid")          ; send graphics to PNG file
  
  res                        = True               ; plot mods desired
  res@gsnMaximize            = True
  res@gsnFrame               = False
  res@gsnDraw                = False

;
; You need the RANGS/GSHHS database to use HighRes:
;
;   http://www.ncl.ucar.edu/Document/Graphics/rangs.shtml
;
; Change to "MediumRes" or the default "LowRes" if you don't
; have the HighRes database.
;
  res@mpDataBaseVersion      = "HighRes"
  res@mpGridAndLimbOn        = True
  res@pmTickMarkDisplayMode  = "Always"           ; turn on tickmarks
  res@mpGridAndLimbDrawOrder = "PreDraw"          ; Draw grid before
                                                  ; map outlines
  res@mpMinLatF              =  17
  res@mpMaxLatF              =  20.5
  res@mpMinLonF              = -75
  res@mpMaxLonF              = -68

  res@mpGridSpacingF         = 0.25
  res@mpGridLineThicknessF   = 2.0
  res@mpGridLineColor        = "Gray30"

  res@tiMainString           = "Two sets of lat/lon grid lines"
  
;---Create map with thin, gray lat/lon lines
  map_thin = gsn_csm_map(wks,res)
 
  res@mpGridSpacingF         = 0.5
  res@mpGridLineThicknessF   = 3.0
  res@mpGridLineColor        = "black"

;---Create map with thicker, black lat/lon lines
  map_thick = gsn_csm_map(wks,res)

;
; If you don't set any annotation resources, then adding one
; plot as an annotation of another will simply make them 
; both the same size.
; 
  annoid = gsn_add_annotation(map_thin,map_thick,False)

  draw(map_thin)    ; Both maps will get drawn.
  frame(wks)
 
end
